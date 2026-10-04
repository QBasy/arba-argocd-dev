#!/bin/sh
# Создаёт dev/<имя>.yml из templates/service.yml.tpl, если файла ещё нет. Вызывается из CI сервиса (deploy-dev)
# Использование: new-service.sh <имя> <repoURL> <imageRepo> <tier: engine|platform> [корень репозитория]
set -eu
NAME=$1; REPO=$2; IMAGE=$3; TIER=$4; ROOT=${5:-$(cd "$(dirname "$0")/.." && pwd)}
OUT="$ROOT/dev/$NAME.yml"
if [ -f "$OUT" ]; then echo "exists: $OUT"; exit 0; fi
sed -e "s|__NAME__|$NAME|g" -e "s|__REPO_URL__|$REPO|g" -e "s|__IMAGE_REPO__|$IMAGE|g" -e "s|__TIER__|$TIER|g" \
  "$ROOT/templates/service.yml.tpl" > "$OUT"
echo "created: $OUT"
