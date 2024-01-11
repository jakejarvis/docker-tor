#!/bin/sh
set -e

# fix permissions
chown -R debian-tor:debian-tor /var/lib/tor
find /var/lib/tor -type d -exec chmod 700 {} \;
find /var/lib/tor -type f -exec chmod 600 {} \;

# step down from root to tor user
gosu debian-tor tor "$@"
