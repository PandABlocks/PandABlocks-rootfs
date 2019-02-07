#!/bin/sh
HERE=$(dirname $0)
if ! nc 127.0.0.1 8080 2> /dev/null; then
    # If admin-server isn't started, then start it now and retry
    $HERE/admin-server.py
    nc 127.0.0.1 8080
fi
