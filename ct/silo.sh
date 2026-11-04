#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/community-scripts/DevScripts/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Watashi199
# License: MIT | https://github.com/community-scripts/DevScripts/raw/main/LICENSE
# Source: https://github.com/Silo-Server/silo-server

APP="Silo"
var_tags="${var_tags:-media;streaming}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-8192}"
var_disk="${var_disk:-20}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
#var_arm64="${var_arm64:-no}" # unset = ask the user; set yes/no only when verified
var_unprivileged="${var_unprivileged:-1}"
var_gpu="${var_gpu:-yes}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/silo ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_branch "silo" "Silo-Server/silo-server" "main"; then
    msg_info "Stopping Silo"
    systemctl stop silo
    msg_ok "Stopped Silo"

    fetch_and_deploy_gh_branch "silo" "Silo-Server/silo-server" "main"

    msg_info "Building Silo Web App"
    cd /opt/silo/web
    $STD pnpm install --frozen-lockfile
    $STD pnpm run build
    msg_ok "Built Silo Web App"

    msg_info "Building Silo Server"
    cd /opt/silo
    $STD go build -o /opt/silo/silo ./cmd/silo/
    msg_ok "Built Silo Server"

    msg_info "Starting Silo"
    systemctl start silo
    msg_ok "Started Silo"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Access it using the following URL:${CL}"
echo -e "${GATEWAY}${BGN}http://${IP}:8080${CL}"
