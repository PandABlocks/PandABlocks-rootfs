#!/bin/sh
HERE=$(dirname $0)
if ! nc 127.0.0.1 8080 2> /dev/null; then
    # If admin-server isn't started, then start it now and retry
    # This might fail if another one is already starting up, so
    # log any errors and still continue with the netcat
    $HERE/admin-server.py 2>> /var/log/web-admin.log
    nc 127.0.0.1 8080
fi
