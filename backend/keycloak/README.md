# Keycloak configuration

`import/v1/votivo-realm.json` contains the initial Votivo realm configuration.
Keep future Keycloak configuration (themes, scripts, etc.) under this directory.
Only `import/${KEYCLOAK_REALM_VERSION}` is mounted to `/opt/keycloak/data/import`.

## Initial import

1. Copy `../.env.example` to `../.env` and set all password/secret values.
2. Set `RESEND_API_KEY` and `SMTP_FROM` for SMTP email delivery.
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

`KEYCLOAK_REALM_VERSION=v1` in `backend/.env` selects the version for initial import.
Version identifiers refer to configuration snapshots, not separate Keycloak realms.
The realm name stays `votivo` in every version; all files must be named
`votivo-realm.json` to match the realm import naming convention.

Keep released version directories unchanged. To prepare a new version, run from
`backend/` in PowerShell:

```powershell
New-Item -ItemType Directory -Path keycloak/import/v2
Copy-Item keycloak/import/v1/votivo-realm.json keycloak/import/v2/votivo-realm.json
```

Edit the new file, preserve environment placeholders for secrets, and describe
changes in `keycloak/CHANGELOG.md`. For v3, copy v2 and follow the same process.
Changes made in the Admin Console are not automatically saved into these files;
export and sanitize the updated realm before saving it as a new version.

To select v2, set `KEYCLOAK_REALM_VERSION=v2` in `.env` and update `.env.example`
if v2 should become the default for new checkouts. Recreate the Keycloak container
to apply the new mount. This does NOT update an existing `votivo` realm: startup
import skips existing realms. Apply changes to a running realm through Admin API
or Admin Console and record them in the changelog. Selecting an older version
also does not roll back an existing realm or its database.
