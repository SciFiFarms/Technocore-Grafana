#!/usr/bin/env bash

# https://unix.stackexchange.com/questions/79068/how-to-export-variables-that-are-set-all-at-once
set -a
GF_SERVER_ROOT_URL=https://${DOCKER_HOST}/grafana/

TIMESERIES_DB_USERNAME=$(cat /run/secrets/timeseries_db_username)
TIMESERIES_DB_PASSWORD=$(cat /run/secrets/timeseries_db_password)
set +a
# TODO: Rather than do this by hand, should loop over all .template files in the folder.
cat /etc/grafana/provisioning/datasources/technocore-postgres.yaml.template | envsubst > /etc/grafana/provisioning/datasources/technocore-postgres.yaml
cat /etc/grafana/provisioning/datasources/technocore-influxdb.yaml.template | envsubst > /etc/grafana/provisioning/datasources/technocore-influxdb.yaml
cat /etc/grafana/provisioning/datasources/technocore-prometheus.yaml.template | envsubst > /etc/grafana/provisioning/datasources/technocore-prometheus.yaml
cat /etc/grafana/provisioning/datasources/technocore-loki.yaml.template | envsubst > /etc/grafana/provisioning/datasources/technocore-loki.yaml
