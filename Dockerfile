FROM grafana/grafana:6.2.2

USER root
# Install envsubst. Needed in entrypoint.sh and comes in the gettext-base package.
RUN apt-get update && apt-get install -y gettext-base && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
COPY provisioning /etc/grafana/provisioning
RUN chown -R grafana:grafana "$GF_PATHS_PROVISIONING" 
USER grafana

# Set up the CMD as well as the pre and post hooks.
COPY go-init /bin/go-init
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY exitpoint.sh /usr/bin/exitpoint.sh

ENTRYPOINT ["go-init"]
CMD ["-pre", "entrypoint.sh", "-main", "/run.sh", "-post", "exitpoint.sh"]
