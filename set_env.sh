#!/usr/bin/env sh

for filename in /run/secrets/*; do
  variable=$(echo "$filename" | tr '[:lower:]' '[:upper:]' | sed 's:.*/::')
  echo "${variable}"
  export "${variable}"="$(cat "$filename")"
done

exec "$@"