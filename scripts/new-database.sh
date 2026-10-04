#!/bin/sh
# Подключает PostgreSQL сервису: manifests/database/<имя>-db.yaml (CloudNativePG) и manifests/secrets/<имя>-db.yaml
# (ExternalSecret: учётка для БД и DSN для приложения). Дальше: .\19-vault.ps1 -Db <имя> (пароль в Vault) и в
# .helm/values-dev.yaml сервиса:  database: { enabled: true }
# Использование: new-database.sh <имя-сервиса> [корень репозитория]
set -eu
NAME=$1; ROOT=${2:-$(cd "$(dirname "$0")/.." && pwd)}
for kind in database secrets; do
  src="$ROOT/manifests/$kind/origination-db.yaml"
  dst="$ROOT/manifests/$kind/$NAME-db.yaml"
  [ -f "$dst" ] && { echo "exists: $dst"; continue; }
  sed "s/origination/$NAME/g" "$src" > "$dst"
  echo "created: $dst"
done
