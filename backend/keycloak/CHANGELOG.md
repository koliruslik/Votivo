# Realm configuration changelog

## v3 - 2026-11-21

- Fresh export of the current votivo realm after application role and frontend mapper changes.
- Preserves the live role scope mappings, default roles, clients, event listeners and service account mappings.
- Real SMTP/client secrets remain in local .env; regular users and credentials are excluded.
- Selected as the default initial-import snapshot; does not migrate existing realms.

## v2 - 2026-11-21

- Fresh online export of the current votivo realm, including current login, registration, clients, roles and service account mappings.
- SMTP host: smtp-relay.brevo.com. SMTP password uses the provider-neutral SMTP_PASSWORD environment variable.
- Real secrets remain in local .env; regular users and credentials are excluded.
- Selected as the default initial-import version; existing realms are not overwritten.

## v1 - 2026-11-21

- Initial snapshot of the configured `votivo` realm.
- Includes `votivo-frontend`, `votivo-user-admi`, roles and service account mappings.
- SMTP and confidential client secrets are resolved from environment placeholders.
- Excludes regular user accounts and user credentials.
- Preserves current client settings; this is not a security configuration revision.
