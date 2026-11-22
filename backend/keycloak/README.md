# Keycloak configuration

`import/v5/votivo-realm.json` is the current snapshot; v3 and v4 are preserved unchanged. Older snapshots remain available in Git history.
Keep future Keycloak configuration (themes, scripts, etc.) under this directory.
Only `import/${KEYCLOAK_REALM_VERSION}` is mounted to `/opt/keycloak/data/import`.

## Initial import

1. Copy `../.env.example` to `../.env` and set all password/secret values.
2. Set `SMTP_PASSWORD` (the provider SMTP key) and `SMTP_FROM` for SMTP in v2 and later. `RESEND_API_KEY` is retained for compatibility with older configurations.
3. Run `docker compose up -d keycloak` from `backend/`.

Keycloak starts with `--import-realm`. The file is imported only if the `votivo`
realm does not already exist. Existing realms are skipped: restarting does not
apply later JSON edits or rotate passwords/secrets in an existing realm.
Use the Admin Console or Admin API to update an existing realm. Do not delete
PostgreSQL volumes to apply configuration changes.

## Secrets and export contents

Realm JSON uses environment placeholders for the SMTP credentials and
confidential client secrets. Real values belong only in the ignored local `.env`.
Do not replace placeholders in committed JSON with real secrets.

This is an application configuration export, not a user/database backup.
Regular users and their passwords/sessions are excluded. Service accounts and
their current role assignments are retained.

Client IDs are preserved exactly as configured in Keycloak, including
`votivo-user-admi` (the current administrative client ID).

PostgreSQL must contain `keycloak_db`. The init script creates it only when the
PostgreSQL data volume is first initialized.

## Realm configuration versions

`KEYCLOAK_REALM_VERSION=v5` in `backend/.env` selects the version for initial import.
Version identifiers refer to configuration snapshots, not separate Keycloak realms.
The realm name stays `votivo` in every version; all files must be named
`votivo-realm.json` to match the realm import naming convention.

Keep released version directories unchanged. To prepare a new version, run from
`backend/` in PowerShell:

```powershell
New-Item -ItemType Directory -Path keycloak/import/v6
Copy-Item keycloak/import/v5/votivo-realm.json keycloak/import/v6/votivo-realm.json
```

Edit the new file, preserve environment placeholders for secrets, and describe
changes in `keycloak/CHANGELOG.md`. For v7, copy v6 and follow the same process.
Changes made in the Admin Console are not automatically saved into these files;
export and sanitize the updated realm before saving it as a new version.

To select a version, set `KEYCLOAK_REALM_VERSION=v5` (or the desired version) in `.env` and update `.env.example`
if that version should become the default for new checkouts. Recreate the Keycloak container
to apply the new mount. This does NOT update an existing `votivo` realm: startup
import skips existing realms. Apply changes to a running realm through Admin API
or Admin Console and record them in the changelog. Selecting an older version
also does not roll back an existing realm or its database.

## User Service API clients (v5)

The API also requires `KEYCLOAK_USER_SERVICE_MANAGEMENT_SECRET`, passed to User
Service as `APP_IDENTITY_MANAGEMENT_CLIENT_SECRET`. For an existing realm, create
the confidential `user-service-management` client with service accounts enabled,
browser/password flows and DPoP disabled, and the default scopes `service_account`,
`roles`, `basic`, `kc-admin-api`. Grant its service account `realm-management`
`view-users` and `manage-users`. Keep its secret separate from synchronization.

Create the bearer-only resource client `user-service`. On `votivo-frontend`, add an
Audience protocol mapper including client audience `user-service` in access tokens.
Preserve existing role mappings, PKCE and DPoP settings. Freshly issued frontend
tokens must include this audience. Existing realms are not updated by startup import.

The public issuer configured in User Service must match the token issuer exactly;
the JWKS URL may use the internal Docker address. Configure the frontend's actual
origin in `APP_SECURITY_ALLOWED_ORIGINS`. SMTP is required for email change
verification. `APP_IDENTITY_MANAGEMENT_EMAIL_AS_USERNAME=true` matches this realm.

Set `KEYCLOAK_USER_SERVICE_SYNC_SECRET` before initial import; Compose passes the same
value to Keycloak and User Service (`APP_IDENTITY_CLIENT_SECRET`). User Service uses
`http://keycloak:8080` inside Docker and `http://localhost:18080` from the host.
The v4 `user-service-sync` client is confidential with service accounts enabled,
browser/password flows disabled and DPoP off. Its default scopes are
`service_account`, `roles`, `basic`, `kc-admin-api`; full scope is allowed, but its
service account is granted only `realm-management` `view-users` and `query-users`.
It receives no `manage-users` or `realm-admin` role. v4 also makes realm role
`admin` a composite containing `user`.

For an existing realm, create/configure this client and account with those settings
through Admin Console/API, set the same secret, and update the `admin` composite.
Importing v4 at startup does not apply these changes to an existing realm. Record
the change without storing credentials in JSON. Do not reuse the administrative
`votivo-user-admi` client for synchronization.

Admin Console steps for an existing realm:

1. Select `votivo`, Clients -> Create client -> OpenID Connect, client ID `user-service-sync`.
2. Enable Client authentication and Service accounts roles. Disable Standard flow, Direct access grants, Implicit flow and DPoP-bound access tokens; save. Configure the client secret to match `KEYCLOAK_USER_SERVICE_SYNC_SECRET`.
3. Under Client scopes, add `service_account`, `roles`, `basic`, `kc-admin-api` as default scopes and enable Full scope allowed in the dedicated scope settings.
4. Under Service account roles -> Assign role -> Filter by clients, grant `realm-management` roles `view-users` and `query-users` only.
5. Under Realm roles -> `admin`, enable composition and add realm role `user` as an associated role. Preserve other existing composites.

## RabbitMQ event provider

`providers/keycloak-to-rabbit-3.0.5.jar` is mounted read-only into
`/opt/keycloak/providers`. The development startup discovers the provider.
Keycloak waits for RabbitMQ to become healthy before starting.

The `KK_TO_RMQ_*` environment variables use Docker host `rabbitmq`, port `5672`,
`RABBITMQ_VHOST` (default `/`), the shared RabbitMQ credentials, and exchange
`identity.users.exchange`. `RABBITMQ_DEFAULT_VHOST` uses the same vhost for fresh
broker data volumes. Changing it does not create vhosts in an existing broker.
Other application services currently assume `/`; keep that value unless their
connection settings are updated too.

After recreating the containers:

1. In RabbitMQ Management, create the durable `topic` exchange
   `identity.users.exchange` in vhost `/` (or your selected vhost). The provider
   publishes to an existing exchange; it does not declare it.
2. Create and bind the consuming service queue before producing events.
3. In Keycloak, select `votivo`, then Realm settings -> Events -> Event listeners.
   Add `keycloak-to-rabbitmq`, preserve existing listeners, and save.
4. Record subsequent realm changes in a new configuration version.

The bundled JAR was built against Keycloak 21.1.2, while this compose uses 26.8.2.
Runtime compatibility and event delivery must be checked after container startup.
