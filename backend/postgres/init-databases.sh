#!/bin/sh
# Runs once, on the first start of an empty data volume. Add a line per new service.
# Each service gets its own database and its own user: a service reads and writes only its own data.
# Identifiers are quoted because "user" is a reserved word. The password equals the name here, which is fine for local development only.
set -eu

create_database() {
	name=$1
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-SQL
		CREATE USER "$name" WITH PASSWORD '$name';
		CREATE DATABASE "${name}_db" OWNER "$name";
	SQL
}

create_database user
create_database poll
create_database vote
create_database result
create_database keycloak
