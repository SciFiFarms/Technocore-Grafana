FROM grafana/grafana:6.5.1
# Needed because Grafana is embedded within Home Assistant
ENV GF_SECURITY_ALLOW_EMBEDDING=true
# Needed because Grafana is running behind https.
ENV GF_SECURITY_COOKIE_SECURE=true

USER root
# Install envsubst. Needed in entrypoint.sh and comes in the gettext-base package.
RUN apk add gettext
COPY provisioning /etc/grafana/provisioning
RUN chown -R grafana:grafana "$GF_PATHS_PROVISIONING" 
USER grafana

## Add dogfish
#COPY dogfish/ /usr/share/dogfish
#COPY migrations/ /usr/share/dogfish/shell-migrations
#RUN ln -s /usr/share/dogfish/dogfish /usr/bin/dogfish
#RUN mkdir /var/lib/dogfish 
## Need to do this all together because ultimately, the config folder is a volume, and anything done in there will be lost. 
#RUN mkdir -p /var/www/html/config/ && touch /var/www/html/config/migrations.log && ln -s /var/www/html/config/migrations.log /var/lib/dogfish/migrations.log 

# Set up the CMD as well as the pre and post hooks.
COPY go-init /bin/go-init
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY exitpoint.sh /usr/bin/exitpoint.sh

ENTRYPOINT ["go-init"]
CMD ["-main", "entrypoint.sh /run.sh", "-post", "exitpoint.sh"]
