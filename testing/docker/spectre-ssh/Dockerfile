FROM ghcr.io/linuxserver/openssh-server

RUN useradd developer
RUN mkdir -p /home/developer/htdocs
RUN mkdir -p /home/developer/htdocs/logs

COPY sample_key.pub /home/developer/htdocs/.ssh/authorized_keys
RUN chmod 700 /home/developer/htdocs/.ssh && chmod 600 /home/developer/htdocs/.ssh/authorized_keys

RUN chown -R developer /home/developer/htdocs
RUN chgrp -R developer /home/developer/htdocs
RUN usermod -d /home/developer/htdocs developer