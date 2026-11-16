#!/usr/bin/env bash
set -euo pipefail

quote_oracle_identifier() {
  local value="$1"

  if [[ "$value" == *$'\n'* || "$value" == *$'\r'* ]]; then
    echo "Oracle passwords must not contain line breaks." >&2
    return 1
  fi

  value="${value//\"/\"\"}"
  printf '"%s"' "$value"
}

: "${CATALOG_DB_PASSWORD:?CATALOG_DB_PASSWORD must be set}"
: "${BOOKINGS_DB_PASSWORD:?BOOKINGS_DB_PASSWORD must be set}"
: "${AUDIT_DB_PASSWORD:?AUDIT_DB_PASSWORD must be set}"

catalog_password="$(quote_oracle_identifier "$CATALOG_DB_PASSWORD")"
bookings_password="$(quote_oracle_identifier "$BOOKINGS_DB_PASSWORD")"
audit_password="$(quote_oracle_identifier "$AUDIT_DB_PASSWORD")"

sqlplus -s / as sysdba <<SQL
WHENEVER SQLERROR EXIT SQL.SQLCODE
SET DEFINE OFF
SET ECHO OFF
SET VERIFY OFF

ALTER SESSION SET CONTAINER = FREEPDB1;

CREATE USER CAMPUSLAB_CATALOG IDENTIFIED BY ${catalog_password};
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO CAMPUSLAB_CATALOG;
ALTER USER CAMPUSLAB_CATALOG QUOTA UNLIMITED ON USERS;

CREATE USER CAMPUSLAB_BOOKINGS IDENTIFIED BY ${bookings_password};
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO CAMPUSLAB_BOOKINGS;
ALTER USER CAMPUSLAB_BOOKINGS QUOTA UNLIMITED ON USERS;

CREATE USER CAMPUSLAB_AUDIT IDENTIFIED BY ${audit_password};
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO CAMPUSLAB_AUDIT;
ALTER USER CAMPUSLAB_AUDIT QUOTA UNLIMITED ON USERS;

EXIT
SQL
