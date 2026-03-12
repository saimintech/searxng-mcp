#!/bin/sh
# Inject the SECRET_KEY env var into settings.yml at container startup.
# This avoids baking secrets into the Docker image.

set -e

SETTINGS="/etc/searxng/settings.yml"

if [ -z "$SECRET_KEY" ]; then
  echo "[entrypoint] ERROR: SECRET_KEY env var is not set. Generate one with:"
  echo "  openssl rand -hex 32"
  exit 1
fi

# Replace the ${SECRET_KEY} placeholder in settings.yml
sed -i "s|\${SECRET_KEY}|${SECRET_KEY}|g" "$SETTINGS"

echo "[entrypoint] Starting SearxNG..."
exec /sbin/tini -- /usr/local/searxng/manage.sh run
