#!/bin/sh
set -o errexit

# fix permissions
find /var/lib/tor -type d -exec chmod 700 {} \;
find /var/lib/tor -type f -exec chmod 600 {} \;

exec "$@"
