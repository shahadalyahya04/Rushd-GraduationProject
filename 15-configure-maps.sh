#!/bin/sh
set -eu

: "${GOOGLE_MAPS_API_KEY:?Set GOOGLE_MAPS_API_KEY to a browser key with Maps JavaScript API enabled}"
case "$GOOGLE_MAPS_API_KEY" in
    *[!A-Za-z0-9_-]*)
        echo "GOOGLE_MAPS_API_KEY contains unexpected characters" >&2
        exit 1
        ;;
esac

sed "s/__RUSHD_MAPS_API_KEY__/$GOOGLE_MAPS_API_KEY/g" \
    /opt/rushd-index.html > /usr/share/nginx/html/index.html
