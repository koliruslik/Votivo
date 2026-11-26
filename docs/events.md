# Events

Poll Service, Vote Service and Result Service talk to each other asynchronously through RabbitMQ. This page is the contract; each service's README links here.

```text
 Poll Service ──poll.started / poll.ended──▶ poll.events.exchange ─┬─▶ vote-service.poll-events   ─▶ Vote Service
                                                                   └─▶ result-service.poll-events ─▶ Result Service
 Vote Service ──vote.cast / vote.revoked───▶ vote.events.exchange ───▶ result-service.vote-events ─▶ Result Service
```

Keycloak publishes user events to `identity.users.exchange` for User Service; see [backend/keycloak/README.md](../backend/keycloak/README.md).

## Topology

Each producer owns one durable **topic** exchange. A consumer owns one durable queue per exchange it reads, bound with the routing keys it needs, so a new consumer never touches the producer.

| Exchange | Producer | Routing key | Queue | Consumer |
| --- | --- | --- | --- | --- |
| `poll.events.exchange` | Poll | `poll.started`, `poll.ended` | `vote-service.poll-events` | Vote |
| `poll.events.exchange` | Poll | `poll.started`, `poll.ended` | `result-service.poll-events` | Result |
| `vote.events.exchange` | Vote | `vote.cast`, `vote.revoked` | `result-service.vote-events` | Result |

**Dead letters.** Every queue is declared with `x-dead-letter-exchange=votivo.dlx` and `x-dead-letter-routing-key=<queue name>`. `votivo.dlx` is a durable direct exchange; `<queue>.dlq` is bound to it with the routing key `<queue>` and keeps what a consumer rejected, for inspection and replay.

**Who declares what.** The topology is created twice on purpose, and both must stay identical:

- by [`backend/rabbitmq/definitions.json`](../backend/rabbitmq/definitions.json), imported through the management API by the one-shot `rabbitmq-topology` container before any service starts, so an event published before its consumer has ever started waits in the queue instead of being dropped;
- by every service for the exchanges and queues it uses, so a service also works against a broker without the definitions. Declaring an existing exchange or queue with the same arguments is a no-op; different arguments fail with `PRECONDITION_FAILED`.

The compose import targets the default vhost `/`; with another `RABBITMQ_VHOST` the services still declare everything themselves.

## Delivery guarantees

- **At least once.** Producers write the event to an outbox table in the transaction of the change it describes and publish it afterwards, with publisher confirms. A crash can publish an event twice but never loses one or publishes one for a rolled-back change.
- **Mandatory publishing.** A message no queue is bound for is returned by the broker; the producer keeps it in the outbox and retries.
- **Idempotent consumers.** The AMQP `message_id` is the event id (a UUID). Result Service stores it with the counters in one transaction and skips an id it has seen; Vote Service's handlers are idempotent by construction (upserts).
- **Order.** Events of one producer reach one queue in the order they were written, because the relay stops at the first failure. The queues of Result Service are independent, so a vote can be processed before `poll.started`; Result Service accepts that.
- **Failures.** A message no retry can fix (not JSON, unknown routing key, missing id) is rejected without requeue and ends in the `.dlq`. A transient failure (database down) is retried and dead-lettered only when the retries run out.

## Messages

JSON, UTF-8, `content_type: application/json`, `delivery_mode: 2` (persistent), keys in `snake_case`. A consumer ignores fields it does not know, so a producer can add fields without a coordinated release. All ids are UUIDs and are assigned by Poll Service.

### `poll.started` (Poll → Vote, Result)

Published when a draft becomes `PUBLISHED`. The content of a published poll cannot change, so this is the whole snapshot voting needs.

```json
{
  "poll_id": "11111111-1111-4111-8111-111111111111",
  "title": "Lunch",
  "anonymous": false,
  "allow_vote_change": true,
  "ends_at": "2099-12-31T12:00:00Z",
  "questions": [
    {
      "id": "22222222-2222-4222-8222-222222222222",
      "text": "Where?",
      "multiple": false,
      "options": [
        { "id": "33333333-3333-4333-8333-333333333333", "text": "Pizza" },
        { "id": "44444444-4444-4444-8444-444444444444", "text": "Sushi" }
      ]
    }
  ]
}
```

`multiple` is `true` for a multiple-choice question. `allow_vote_change` lets a participant change or revoke a vote; an anonymous poll never allows it (Vote Service enforces both).

`ends_at` is the optional UTC deadline (RFC 3339). If set, it must be in the future at publication.
Vote Service stores it and rejects cast/change/revoke at or after that instant, even if the scheduled
`poll.ended` event has not arrived yet. Missing or null means there is no scheduled closure.

### `poll.ended` (Poll → Vote, Result)

Published when a `PUBLISHED` poll stops taking votes: the owner or a moderator closed it, its deadline elapsed,
or a moderator blocked it. Closing voting and deadline expiry use reason `closed`. Blocking a draft or a poll that
is already closed publishes nothing.

```json
{ "poll_id": "11111111-1111-4111-8111-111111111111", "reason": "closed" }
```

`reason` is `closed` or `blocked`.

### `vote.cast` (Vote → Result)

Published when a vote is accepted: add one ballot and one vote to every listed option.

```json
{
  "poll_id": "11111111-1111-4111-8111-111111111111",
  "answers": [
    { "question_id": "22222222-2222-4222-8222-222222222222", "option_ids": ["33333333-3333-4333-8333-333333333333"] }
  ],
  "request_id": "optional id of the HTTP request, for log correlation"
}
```

The event never carries the user, so an anonymous poll cannot be de-anonymized from the broker.

### `vote.revoked` (Vote → Result)

Published when a vote is withdrawn: subtract one ballot and one vote from every listed option (the old answers). **Changing a vote** is a `vote.revoked` of the old answers followed by a `vote.cast` of the new ones, written in one transaction.

Same body as `vote.cast`.

## Adding an event or a consumer

1. Add the routing key to the producer's README and to this page.
2. New consumer: add its queue, its `.dlq` and the bindings to `definitions.json` and declare the same in the service.
3. Keep the ids and field names stable; add fields, do not rename them.
