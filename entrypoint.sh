#!/bin/sh
set -o errexit

# fix permissions
find /var/lib/tor -type d -exec chmod -v 700 {} \;
find /var/lib/tor -type f -exec chmod -v 600 {} \;
chown -R debian-tor /var/lib/tor

exec "$@"
