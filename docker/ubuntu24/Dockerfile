[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log

[program:mme]
command=/opt/venv/bin/python3 /magma/lte/gateway/python/mme.py
autostart=true
autorestart=true
stdout_logfile=/var/log/mme.log
stderr_logfile=/var/log/mme.err

[program:sessiond]
command=/opt/venv/bin/python3 /magma/lte/gateway/python/sessiond.py
autostart=true
autorestart=true
stdout_logfile=/var/log/sessiond.log
stderr_logfile=/var/log/sessiond.err

[program:pipelined]
command=/opt/venv/bin/python3 /magma/lte/gateway/python/pipelined.py
autostart=true
autorestart=true
stdout_logfile=/var/log/pipelined.log
stderr_logfile=/var/log/pipelined.err

[program:sctpd]
command=/usr/sbin/sctpd -d
autostart=true
autorestart=true
stdout_logfile=/var/log/sctpd.log
stderr_logfile=/var/log/sctpd.err
