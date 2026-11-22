"""Export local realm configuration without passwords or regular users.

Run from the repository root: python backend/keycloak/export_realm.py v7
Credentials are read from backend/.env and are never printed.
"""
import json
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path


def main():
    version = sys.argv[1]
    if not re.fullmatch(r"v\d+", version):
        raise ValueError("Expected a version such as v7")
    root = Path(__file__).resolve().parent
    destination = root / "import" / version / "votivo-realm.json"
    if destination.exists():
        raise ValueError("Refusing to overwrite an existing realm snapshot")
    env = {}
    for line in (root.parent / ".env").read_text(encoding="utf-8-sig").splitlines():
        if line.strip() and not line.lstrip().startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            env[key.strip()] = value.strip().strip("\"'")
    base = "http://127.0.0.1:" + env.get("KEYCLOAK_PORT", "18080")
    form = urllib.parse.urlencode({
        "grant_type": "password", "client_id": "admin-cli",
        "username": env.get("KEYCLOAK_ADMIN_USERNAME", "admin"),
        "password": env["KEYCLOAK_ADMIN_PASSWORD"],
    }).encode()
    request = urllib.request.Request(base + "/realms/master/protocol/openid-connect/token", data=form)
    with urllib.request.urlopen(request, timeout=30) as response:
        token = json.load(response)["access_token"]

    def api(path, method="GET"):
        request = urllib.request.Request(base + "/admin/realms/votivo/" + path,
            headers={"Authorization": "Bearer " + token}, method=method)
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.load(response)

    realm = api("partial-export?exportClients=true&exportGroupsAndRoles=true", "POST")
    secret_names = {
        "votivo-user-admi": "KEYCLOAK_VOTIVO_USER_ADMI_SECRET",
        "user-service-sync": "KEYCLOAK_USER_SERVICE_SYNC_SECRET",
        "user-service-management": "KEYCLOAK_USER_SERVICE_MANAGEMENT_SECRET",
    }
    for client in realm.get("clients", []):
        if client.get("publicClient") or client.get("bearerOnly"):
            client.pop("secret", None)
        if client.get("secret"):
            name = secret_names.get(client["clientId"])
            if not name:
                raise ValueError("Unmapped confidential client: " + client["clientId"])
            client["secret"] = "${" + name + "}"
        client.pop("registrationAccessToken", None)
    for key, name in {"password": "SMTP_PASSWORD", "from": "SMTP_FROM"}.items():
        realm.setdefault("smtpServer", {})[key] = "${" + name + "}"
    if realm.get("identityProviders"):
        raise ValueError("Review identity provider secrets before exporting")
    # Export only machine identities and their current explicit role mappings.
    realm["users"] = []
    for client in api("clients"):
        if not client.get("serviceAccountsEnabled"):
            continue
        account = api("clients/" + client["id"] + "/service-account-user")
        mappings = api("users/" + account["id"] + "/role-mappings")
        realm["users"].append({
            "username": account["username"], "enabled": account["enabled"],
            "serviceAccountClientId": client["clientId"],
            "realmRoles": [r["name"] for r in mappings.get("realmMappings", [])],
            "clientRoles": {m["client"]: [r["name"] for r in m["mappings"]]
                for m in mappings.get("clientMappings", {}).values()},
        })
    text = json.dumps(realm, ensure_ascii=False, indent=2) + "\n"
    for name, value in env.items():
        if any(word in name for word in ("PASSWORD", "SECRET", "API_KEY")) and len(value) >= 8 and value in text:
            raise ValueError("Export contains a value from " + name)
    def check(value, path="realm"):
        if isinstance(value, dict):
            for key, child in value.items():
                if key == "credentials" and isinstance(child, list) and child:
                    raise ValueError("Unexpected credentials at " + path)
                check(child, path + "." + key)
        elif isinstance(value, list):
            for index, child in enumerate(value):
                check(child, path + "[" + str(index) + "]")
        elif isinstance(value, str) and "**********" in value:
            raise ValueError("Masked secret requires review at " + path)
    check(realm)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(text, encoding="utf-8")
    print("Saved sanitized realm:", destination)
    print("Themes:", realm.get("loginTheme"), realm.get("emailTheme"))
    print("Account console enabled:", next(c["enabled"] for c in realm["clients"] if c["clientId"] == "account-console"))


if __name__ == "__main__":
    main()
