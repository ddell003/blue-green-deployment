#!/bin/sh
cat << EOF |
[supervisord]

[program:cloud_sql_proxy]
command='/usr/local/bin/cloud_sql_proxy'
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

EOF
/usr/bin/supervisord -c /dev/stdin

SECS_WAIT_THRESHOLD=15
SECS_WAITED=0

# Since the commands ran with this entrypoint relies on a
# database connection, we have to wait for it to execute

while ! nc -z 127.0.0.1 3306 </dev/null;
do
    echo "Waiting for Cloud SQL Proxy..."
    sleep 1;

    SECS_WAITED=$((SECS_WAITED+1))

    if [ "$SECS_WAITED" -gt "$SECS_WAIT_THRESHOLD" ];
    then
        echo "Waited for more than $SECS_WAIT_THRESHOLD seconds, exiting"
        exit 1
    fi
done

echo "Cloud SQL Proxy Started"
exec "$@"
