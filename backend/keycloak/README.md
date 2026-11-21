# Keycloak configuration

`import/v3/votivo-realm.json` is the current snapshot. Earlier snapshots are not bundled in this checkout; v1 remains available in Git history.
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

`KEYCLOAK_REALM_VERSION=v3` in `backend/.env` selects the version for initial import.
Version identifiers refer to configuration snapshots, not separate Keycloak realms.
The realm name stays `votivo` in every version; all files must be named
`votivo-realm.json` to match the realm import naming convention.

Keep released version directories unchanged. To prepare a new version, run from
`backend/` in PowerShell:

```powershell
New-Item -ItemType Directory -Path keycloak/import/v4
Copy-Item keycloak/import/v3/votivo-realm.json keycloak/import/v4/votivo-realm.json
```

Edit the new file, preserve environment placeholders for secrets, and describe
changes in `keycloak/CHANGELOG.md`. For v5, copy v4 and follow the same process.
Changes made in the Admin Console are not automatically saved into these files;
export and sanitize the updated realm before saving it as a new version.

To select a version, set `KEYCLOAK_REALM_VERSION=v3` (or the desired version) in `.env` and update `.env.example`
if that version should become the default for new checkouts. Recreate the Keycloak container
to apply the new mount. This does NOT update an existing `votivo` realm: startup
import skips existing realms. Apply changes to a running realm through Admin API
or Admin Console and record them in the changelog. Selecting an older version
also does not roll back an existing realm or its database.

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
