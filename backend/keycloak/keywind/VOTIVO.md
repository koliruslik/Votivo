# Votivo Keywind theme

Vendored from https://github.com/lukin/keywind at upstream commit
`bdf966fdae0071ccd46dab4efdc38458a643b409`, with local Votivo changes.
The upstream Apache-2.0 license is preserved in LICENSE.

- Primary and secondary palettes match the Votivo frontend.
- `info.ftl` styles shared information screens, including email confirmation sent
  and email updated, while preserving Keycloak's messages and return/action links.
- `update-email.ftl` styles Keycloak's UPDATE_EMAIL action with the same Keywind
  components as password updates, including email validation and AIA cancellation.
- WebAuthn decoding creates owned Uint8Array instances to satisfy current
  TypeScript BufferSource types.
- package.json and pnpm-lock.yaml preserve the local dependency versions.

Build from this directory with Node.js and pnpm:

```sh
npx pnpm install --frozen-lockfile
npx pnpm build
npx pnpm build:jar
cp out/keywind.jar ../providers/keywind.jar
```

Recreate the Keycloak container from backend/ after replacing the JAR.
The committed providers/keywind.jar is the ready-to-use build.
