#!/bin/sh
# Использование: bump.sh <файл dev/x.yml> <revision> <tag> <digest>
set -eu
F=$1; REV=$2; TAG=$3; DIG=$4
sed -i -e "s|^\( *targetRevision: \).*# bot:revision|\1$REV # bot:revision|" \
       -e "s|^\( *tag: \).*# bot:tag|\1\"$TAG\" # bot:tag|" \
       -e "s|^\( *digest: \).*# bot:digest|\1\"$DIG\" # bot:digest|" "$F"
