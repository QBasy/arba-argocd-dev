#!/bin/sh
# Подключает сервису базу в общем кластере platform-db (CloudNativePG):
#  - роль <имя> в manifests/database/platform-db.yaml (между маркерами bot:roles)
#  - manifests/database/<имя>.yaml (Database)
#  - manifests/secrets/<имя>-db.yaml (ExternalSecret: пароль роли и DSN для приложения)
# Дальше: запушить, .\19-vault.ps1 -Db <имя> (пароль в Vault), в .helm/values-dev.yaml: database: { enabled: true }
# Использование: new-database.sh <имя-сервиса> [корень репозитория]
set -eu
NAME=$1; ROOT=${2:-$(cd "$(dirname "$0")/.." && pwd)}
CL="$ROOT/manifests/database/platform-db.yaml"

if grep -q "name: $NAME\$" "$CL"; then echo "role exists: $NAME"; else
  tmp=$(mktemp)
  awk -v n="$NAME" '/# bot:roles:end/ {
    print "      - name: " n; print "        ensure: present"; print "        login: true"
    print "        passwordSecret: { name: " n "-db-credentials }" } { print }' "$CL" > "$tmp" && cat "$tmp" > "$CL" && rm -f "$tmp"
  echo "role added: $NAME"
fi

f="$ROOT/manifests/database/$NAME.yaml"
if [ -f "$f" ]; then echo "exists: $f"; else
cat > "$f" <<EOT
# База $NAME в общем кластере platform-db (владелец — одноимённая роль).
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: $NAME
  namespace: database
  annotations: { argocd.argoproj.io/sync-wave: "1" }
spec:
  name: $NAME
  owner: $NAME
  cluster: { name: platform-db }
EOT
echo "created: $f"; fi

f="$ROOT/manifests/secrets/$NAME-db.yaml"
if [ -f "$f" ]; then echo "exists: $f"; else
cat > "$f" <<EOT
# Пароль БД $NAME хранится в Vault: kv/dev/$NAME-db {username, password}.
# 1) пароль роли для CloudNativePG (namespace database)
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: $NAME-db-credentials
  namespace: database
  annotations: { argocd.argoproj.io/sync-wave: "1" }
spec:
  refreshInterval: 1m
  secretStoreRef: { kind: ClusterSecretStore, name: vault }
  target:
    name: $NAME-db-credentials
    template:
      type: kubernetes.io/basic-auth
      metadata:
        labels: { cnpg.io/reload: "true" }
  data:
    - { secretKey: username, remoteRef: { key: dev/$NAME-db, property: username } }
    - { secretKey: password, remoteRef: { key: dev/$NAME-db, property: password } }
---
# 2) DSN для приложения (namespace dev), ключ dsn -> <ИМЯ>_DATABASE_DSN
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: $NAME-db
  namespace: dev
  annotations: { argocd.argoproj.io/sync-wave: "1" }
spec:
  refreshInterval: 1m
  secretStoreRef: { kind: ClusterSecretStore, name: vault }
  target:
    name: $NAME-db
    template:
      data:
        dsn: "postgres://{{ .username }}:{{ .password }}@platform-db-rw.database.svc.cluster.local:5432/$NAME?sslmode=require"
  data:
    - { secretKey: username, remoteRef: { key: dev/$NAME-db, property: username } }
    - { secretKey: password, remoteRef: { key: dev/$NAME-db, property: password } }
EOT
echo "created: $f"; fi
