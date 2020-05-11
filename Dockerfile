FROM node:12.16.3-alpine AS build
RUN mkdir -p /code
COPY plugins/ajax-panel/ /code
WORKDIR /code
RUN npm install yarn && \
    yarn && \
    yarn run build && \
    yarn cache clean

FROM grafana/grafana:6.5.1
# Needed because Grafana is embedded within Home Assistant
ENV GF_SECURITY_ALLOW_EMBEDDING=true
# Needed because Grafana is running behind https.
ENV GF_SECURITY_COOKIE_SECURE=true

# Intstall mqtt-panel
RUN grafana-cli --pluginUrl https://github.com/geeks-r-us/mqtt-panel/releases/download/v1.0.0/geeksrus-mqtt-panel-1.0.0.zip  plugins install mqtt-panel 
#ENV GF_INSTALL_PLUGINS=https://github.com/geeks-r-us/mqtt-panel/releases/download/v1.0.0/geeksrus-mqtt-panel-1.0.0.zip;mqtt-panel

USER root
# Install envsubst. Needed in entrypoint.sh and comes in the gettext-base package.
RUN apk add gettext
COPY provisioning /etc/grafana/provisioning

COPY --from=build /code /usr/share/grafana/plugins/ajax-panel

COPY dashboards /usr/share/grafana/dashboards
RUN chown -R grafana:grafana "$GF_PATHS_PROVISIONING" 
RUN chown -R grafana:grafana "/var/lib/grafana/" 

# Add dogfish
# This should be set to where the volume mounts to.
ARG PERSISTANT_DIR=/var/lib/grafana
COPY dogfish/ /usr/share/dogfish
COPY migrations/ /usr/share/dogfish/shell-migrations
RUN ln -s /usr/share/dogfish/dogfish /usr/bin/dogfish
RUN mkdir /var/lib/dogfish 
RUN chown -R grafana:grafana /var/lib/dogfish/
# Need to do this all together because ultimately, the config folder is a volume, and anything done in there will be lost. 

USER grafana
RUN mkdir -p ${PERSISTANT_DIR} && touch ${PERSISTANT_DIR}/migrations.log && ln -s ${PERSISTANT_DIR}/migrations.log /var/lib/dogfish/migrations.log 

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
