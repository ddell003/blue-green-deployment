#!/bin/sh
cat << EOF |
[supervisord]
nodaemon=true

[program:php-fpm]
command=/usr/local/sbin/php-fpm -R -F -c /usr/local/etc/php-fpm.conf
autorestart=false
autostart=true
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

EOF
/usr/bin/supervisord -c /dev/stdin
