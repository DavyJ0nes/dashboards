#!/bin/bash

docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GF_SECURITY_ADMIN_PASSWORD=hunter2" \
  -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
  -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
  -e "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}" \
  -v "$PWD/data":/var/lib/grafana \
  -v "$PWD/compiled":/var/lib/grafana/dashboards \
  -v "$PWD/config/dashboards":/etc/grafana/provisioning/dashboards \
  -v "$PWD/config/datasources":/etc/grafana/provisioning/datasources \
  grafana/grafana

open http://localhost:3000