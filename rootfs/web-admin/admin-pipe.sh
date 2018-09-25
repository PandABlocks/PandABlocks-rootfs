#!/bin/sh
HERE=$(dirname $0)
# If admin-server isn't started, then start it now and retry
nc localhost 8080 2> /dev/null || (
    $HERE/admin-server.py
    nc localhost 8080
)
