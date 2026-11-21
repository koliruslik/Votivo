# Realm configuration changelog

## v1 - 2026-11-21

- Initial snapshot of the configured `votivo` realm.
- Includes `votivo-frontend`, `votivo-user-admi`, roles and service account mappings.
- SMTP and confidential client secrets are resolved from environment placeholders.
- Excludes regular user accounts and user credentials.
- Preserves current client settings; this is not a security configuration revision.
