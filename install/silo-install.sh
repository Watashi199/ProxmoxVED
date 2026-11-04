#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Watashi199
# License: MIT | https://github.com/community-scripts/DevScripts/raw/main/LICENSE
# Source: https://github.com/Silo-Server/silo-server

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  build-essential \
  pkg-config \
  git \
  libvips-dev \
  redis-server \
  fonts-noto-core \
  fonts-noto-cjk
systemctl enable -q --now redis-server
msg_ok "Installed Dependencies"

setup_deb822_repo \
  "jellyfin" \
  "https://repo.jellyfin.org/jellyfin_team.gpg.key" \
  "https://repo.jellyfin.org/debian" \
  "$(get_os_info codename)"
msg_info "Installing Jellyfin FFmpeg"
$STD apt install -y jellyfin-ffmpeg8
msg_ok "Installed Jellyfin FFmpeg"

setup_hwaccel
PG_VERSION="18" PG_MODULES="pgvector" setup_postgresql
PG_DB_NAME="silo" PG_DB_USER="silo" PG_DB_EXTENSIONS="vector,pg_trgm,citext" setup_postgresql_db
setup_go
NODE_VERSION="24" NODE_MODULE="pnpm@10" setup_nodejs

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

msg_info "Configuring Silo"
mkdir -p /opt/silo_data /var/lib/silo/artwork /var/lib/silo/compat/jellyfin-web
cat <<EOF >/opt/silo_data/.env
DATABASE_URL=postgres://silo:${PG_DB_PASS}@127.0.0.1:5432/silo?sslmode=disable
REDIS_URL=redis://127.0.0.1:6379
# Encrypts stored credentials. Back it up apart from the database: without it they cannot be recovered.
SECRET_KEY=$(openssl rand -base64 48)
PORT=8080
JF_PORT=8096
ABS_PORT=13378
# The Jellyfin Web installer runs npm, which should trust the system CA store.
NODE_OPTIONS=--use-openssl-ca
EOF
chmod 600 /opt/silo_data/.env
msg_ok "Configured Silo"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/silo.service
[Unit]
Description=Silo Media Server
Wants=network-online.target
After=network-online.target postgresql.service redis-server.service
Requires=postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/silo_data
EnvironmentFile=/opt/silo_data/.env
ExecStart=/opt/silo/silo -env /opt/silo_data/.env
Restart=on-failure
RestartSec=5
TimeoutStopSec=120

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now silo
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
