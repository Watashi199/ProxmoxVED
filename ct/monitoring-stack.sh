#!/usr/bin/env bash
source <(curl -fsSL "${COMMUNITY_SCRIPTS_URL:-https://raw.githubusercontent.com/community-scripts/ProxmoxVED/main}/misc/build.func")
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Watashi (Watashi199) | Co-author: OpenAI Codex (GPT-5)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://grafana.com/

APP="Monitoring-Stack"
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
echo -e "${INFO}${YW} Access it using the following URLs:${CL}"
echo -e "${TAB}${BGN}Grafana${CL} http://${IP}:3000"
echo -e "${TAB}${BGN}Prometheus${CL} http://${IP}:9090"
echo -e "${TAB}${BGN}Alertmanager${CL} http://${IP}:9093"
echo -e "${INFO}${YW} Loki, Node Exporter, and Alloy remain local-only inside the LXC.${CL}"
