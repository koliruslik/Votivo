# Authentication and authorization

## Trust boundary

```
browser ──DPoP-bound access token + proof──▶ web gateway (frontend/server) ──X-Internal-Auth + X-User-ID──▶ Poll / Vote / Result
browser ──DPoP-bound access token + proof──▶ User Service (verifies the token and the proof itself)
```

| Component | Who verifies what |
|---|---|
| **Web gateway** (`frontend/server`) | Access token: RS256 signature through the Keycloak JWKS, issuer, expiry, audience `poll-service`, `typ = Bearer`. DPoP: proof signature, key thumbprint (`cnf.jkt`), method, URL, `ath` (token hash), time, replay. Only DPoP-bound tokens are accepted (`REQUIRE_DPOP`, default `true`), so a token cannot be used as a plain Bearer. The user is the verified `sub`; `X-User-ID` from the client is discarded. |
| **Poll Service** | Defence in depth: signature, RS256 only, issuer, expiry, audience `poll-service`, `typ = Bearer`. It cannot see the browser's proof, so a token with `cnf` (DPoP-bound) is accepted only when `INTERNAL_AUTH_SECRET` is configured, i.e. when the gateway stands in front. Roles from `realm_access.roles`. |
| **Vote, Result** | No tokens. They serve only calls that carry `X-Internal-Auth` (constant-time comparison); Vote takes the user from `X-User-ID`. Without the secret nobody can name a user. |
| **User Service** | Verifies the token and the DPoP proof itself (Spring Security resource server): signature, issuer, expiry, audience `user-service`, `typ = Bearer`, canonical UUID `sub`, bound-token-as-Bearer refused, replay cache. |

`INTERNAL_AUTH_SECRET` is one random value shared by `web`, Poll, Vote and Result (`backend/.env`). Vote and Result refuse to start without it; Poll serves without the gate only when it is empty (development), and then refuses DPoP-bound tokens. The compose file publishes their ports on `127.0.0.1` only.

## Audiences

| API | Audience in the access token | Keycloak client mapper |
|---|---|---|
| Poll (and, through the gateway, Vote and Result) | `poll-service` | `poll-service-audience` (realm v6) |
| User Service | `user-service` | `user-service-audience` |

The access token of `votivo-frontend` carries both.

## Roles

Realm roles are lower case: `user` and `admin`; `admin` includes `user` (composite role). Every service reads `realm_access.roles` and maps `admin` to `ROLE_ADMIN` + `ROLE_USER`, `user` to `ROLE_USER`. Look-alikes (`ADMIN`, `USER`) and unrelated roles grant nothing. A valid token without either role gets `403`.

## Token types

Keycloak marks access tokens with `typ = Bearer` and ID, refresh and offline tokens with other values. All verifiers require `Bearer`.

## Tests

| Repository | Where |
|---|---|
| frontend | `server/auth.test.mjs`: valid token; expired; wrong signature, issuer, audience; `alg=none` and HS256 key confusion; ID/refresh/untyped tokens; roles; unbound token refused; missing, replayed, wrong-key, wrong-URL, wrong-method, wrong-hash and wrong-type DPoP proofs; Bearer downgrade; forged `X-User-ID`; gateway secret forwarded |
| Poll | `SecurityConfigTest`, `GatewayAuthTest`: issuer/audience/subject/expiry, `typ`, unsigned and HS256 tokens, bound token without a gateway, roles, missing or wrong gateway secret, role gate |
| Vote | `middleware/internalauth_test.go`: missing, wrong, longer and empty secrets, forged `X-User-ID` |
| Result | `ResultServiceApplicationTests`: calls without or with a wrong secret |
| User Service | `ApiSecurityTest` (existing DPoP and token suite) plus `typ` cases |
