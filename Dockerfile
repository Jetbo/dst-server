FROM jetbo/linux-gsm-docker:latest

# Extra depdencies
USER root
RUN apt update -y
RUN apt install -y libcurl4-gnutls-dev:i386

# Run server on linuxgsm user
USER linuxgsm

# Move linuxgsm files to help with volume setup
RUN mkdir -p /home/linuxgsm/gsm
RUN cp /home/linuxgsm/linuxgsm.sh /home/linuxgsm/gsm/linuxgsm.sh
WORKDIR /home/linuxgsm/gsm

# Install dstserver
RUN bash linuxgsm.sh dstserver
RUN ./dstserver auto-install

# Game ports
EXPOSE 10999/udp
# Steam ports
EXPOSE 27015/tcp 27015/udp 27016/tcp 27016/udp 8766/tcp 8766/udp
# Health check
EXPOSE 8080

# Copy custom config
COPY --chown=linuxgsm:linuxgsm scripts/dstserver.cfg /home/linuxgsm/gsm/dstserver.cfg

# Copy scripts
COPY --chown=linuxgsm:linuxgsm scripts/load_config.sh /home/linuxgsm/gsm/load_config.sh
COPY --chown=linuxgsm:linuxgsm scripts/cluster.ini /home/linuxgsm/gsm/cluster.ini
COPY --chown=linuxgsm:linuxgsm scripts/server.ini /home/linuxgsm/gsm/server.ini
COPY --chown=linuxgsm:linuxgsm scripts/cluster_token.txt /home/linuxgsm/gsm/cluster_token.txt
RUN chmod +x /home/linuxgsm/gsm/load_config.sh

# Copy simple server health checks
RUN mkdir -p /home/linuxgsm/healthcheck
COPY healthcheck/ping.html /home/linuxgsm/healthcheck/ping.html

# Create simple volume folders
RUN mkdir -p /home/linuxgsm/gsm/log \
  /home/linuxgsm/.local/share/Steam/logs \
  /home/linuxgsm/.klei/DoNotStarveTogether

# Config must be loaded AFTER any volumes
ENTRYPOINT [ "/home/linuxgsm/gsm/load_config.sh" ]
CMD []
