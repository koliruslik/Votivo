# Votivo email theme

The `votivo` email theme inherits Keycloak's `base` email templates, translations,
action links, expiration notices and plain-text alternatives. It overrides only
the shared HTML layout. No external fonts, images, scripts or tracking are used.

Colors match `frontend/src/styles.css`: accent `#285e4f`, background `#f7f9f8`,
surface `#ffffff`, text `#202b2b`, muted text `#677171`, border `#dfe5e2`.

After recreating Keycloak to apply the Compose mount, select realm `votivo` ->
Realm settings -> Themes -> Email theme -> `votivo` -> Save. Keep the Login theme
set to `keywind`. Existing realms need this selection in the Admin Console;
reimporting a realm is unnecessary.

Send a fresh verification or password reset email to inspect the result.
Already delivered emails are not updated. Email clients may adapt styles,
especially in dark mode.
