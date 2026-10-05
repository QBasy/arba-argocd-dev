#!/bin/sh
# Дописывает в dev/<имя>.yml стандартные values Go-сервиса (env, DSN из Secret <имя>-db, миграции), если их там ещё нет,
# и подключает базу в platform-db (new-database.sh). Использование: wire-service.sh <имя> [корень репозитория]
set -eu
NAME=$1; ROOT=${2:-$(cd "$(dirname "$0")/.." && pwd)}
F="$ROOT/dev/$NAME.yml"; [ -f "$F" ] || { echo "нет $F"; exit 1; }
UP=$(echo "$NAME" | tr 'a-z-' 'A-Z_')
if grep -q "secretEnv:" "$F"; then echo "уже настроен: $F"; else
  sed -e "s|__UP__|$UP|g" -e "s|__NAME__|$NAME|g" "$ROOT/templates/go-values.tpl" > /tmp/wire-$$.txt
  awk -v blk=/tmp/wire-$$.txt '{ print } /# bot:digest/ { while ((getline l < blk) > 0) print l; close(blk) }' "$F" > /tmp/wire-$$.yml
  cat /tmp/wire-$$.yml > "$F"; rm -f /tmp/wire-$$.txt /tmp/wire-$$.yml
  echo "настроен: $F"
fi
sh "$ROOT/scripts/new-database.sh" "$NAME" "$ROOT"
