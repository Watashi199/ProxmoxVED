#!/usr/bin/env bash
source <(curl -fsSL "${COMMUNITY_SCRIPTS_URL:-https://raw.githubusercontent.com/community-scripts/ProxmoxVED/main}/misc/build.func")
# Copyright (c) 2021-2026 community-scripts ORG
# Author: OpenAI Codex (GPT-5)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://grafana.com/

APP="Monitoring Stack"
var_tags="${var_tags:-monitoring;analytics;logging}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_arm64="${var_arm64:-no}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/monitoring-stack ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_error "Automatic updates are not supported for ${APP} in this v1 release."
  msg_error "Recreate the container or maintain package versions manually inside the LXC."
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access Grafana using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"
echo -e "${INFO}${YW} Internal services available inside the LXC:${CL}"
echo -e "${TAB}${BGN}Prometheus:${CL} http://127.0.0.1:9090"
echo -e "${TAB}${BGN}Alertmanager:${CL} http://127.0.0.1:9093"
echo -e "${TAB}${BGN}Loki:${CL} http://127.0.0.1:3100"
echo -e "${TAB}${BGN}Node Exporter:${CL} http://127.0.0.1:9100"
echo -e "${TAB}${BGN}Alloy:${CL} http://127.0.0.1:12345"
