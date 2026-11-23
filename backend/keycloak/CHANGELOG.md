# Realm configuration changelog

## v8 - 2026-11-23

- Copies sanitized v7 and enables UPDATE_EMAIL for the frontend Change email action. Also enabled in the running local realm.
- Selected for fresh imports. Existing realms enable UPDATE_EMAIL through Authentication -> Required actions.

## v7 - 2026-11-23

- Exports the current running `votivo` realm through the Admin API. Regular users,
  passwords and sessions are excluded; current service-account role assignments
  are preserved. SMTP and confidential client secrets use environment placeholders.
- Selects `keywind` for login and `votivo` for email. Stores the built Keywind JAR,
  its source and local palette/WebAuthn changes, and the shared email layout.
- Enables `always_set_password_on_register_form` and preserves the configured
  user-profile attribute order. Email verification remains enabled.
- Disables `account-console`; the administrative console remains available.
- Uses only SMTP_FROM and SMTP_PASSWORD for sender/password configuration;
  the exported Brevo SMTP host, port and login remain in the realm snapshot.
- Selected for fresh imports. Existing realms are not reimported or migrated.
- `export_realm.py` supports future sanitized online configuration exports.

## v6 - 2026-11-22

- Copies v5 and adds the `poll-service-audience` mapper to `votivo-frontend`, so access tokens carry the `poll-service` audience that the frontend gateway and Poll Service require. Without it every authenticated Poll request is refused.
- Selected as the default for initial import. Existing realms are not migrated; apply the mapper through the Admin Console or Admin API (`frontend/docs/poll-service-audience-mapper.json`).

## v5 - 2026-11-22

- Adds the `user-service` API audience to frontend access tokens.
- Adds a separate `user-service-management` service account with `view-users` and `manage-users` for profile changes, account deletion and blocking. The synchronization account remains read-only.
- Uses `${KEYCLOAK_USER_SERVICE_MANAGEMENT_SECRET}`; existing realms require applying these changes through the Admin Console or Admin API.

## v4 - 2026-11-22

- Copies v3 unchanged except for the new read-only `user-service-sync` confidential machine client and service account, plus `admin` now composing the `user` realm role.
- Client credentials only: browser/password flows and DPoP are disabled for this machine client. Default scopes include service-account, role claims and the Admin API audience; the account receives `realm-management` `view-users` and `query-users` only.
- Uses `${KEYCLOAK_USER_SERVICE_SYNC_SECRET}`; no real secret is stored in the snapshot.
- Selected as the default for initial import. Existing realms must be updated through Admin Console/API; restarting with v4 does not migrate them or rotate credentials.

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
