#!/usr/bin/env bash
set -euo pipefail

############################################
# CONFIG — ПРАВЬ ПОД СЕБЯ
############################################
DOMAIN="n8n.alternative-ai.org"          # например, n8n.example.com (нужно для SSL)
ADMIN_EMAIL="admin@alternative-ai.org"    # для Let's Encrypt
TZ="UTC"
BASE_DIR="/opt/n8n"

# БД
POSTGRES_USER="n8n"
POSTGRES_DB="n8n"

############################################
# HELPERS
############################################
random() { tr -dc 'A-Za-z0-9' </dev/urandom | head -c "${1:-32}"; echo; }
need()  { command -v "$1" >/dev/null 2>&1 || return 1; }

############################################
# CHECKS
############################################
if [[ -z "${DOMAIN}" ]]; then
  echo "ERROR: DOMAIN пуст. Для SSL нужен домен с A-записью на этот сервер."
  exit 1
fi

############################################
# SECRETS
############################################
N8N_ENCRYPTION_KEY="$(random 64)"
POSTGRES_PASSWORD="$(random 32)"

############################################
# PACKAGES (curl, jq, ffmpeg)
############################################
echo "[*] Installing base packages..."
if need dnf; then
  sudo dnf -y update
  sudo dnf -y install curl jq ffmpeg ca-certificates
elif need yum; then
  sudo yum -y update
  # ffmpeg в AL2 проще через rpmfusion/epel, но быстрее поставить из n8n-контейнера.
  sudo yum -y install curl jq ca-certificates
else
  echo "Unsupported distro. Need dnf/yum."
  exit 1
fi

############################################
# DOCKER + COMPOSE
############################################
if ! need docker; then
  echo "[*] Installing Docker..."
  curl -fsSL https://get.docker.com | sudo sh
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker "$USER" || true
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "[*] Installing Docker Compose plugin..."
  DOCKER_CLI_PLUGIN_DIR="/usr/lib/docker/cli-plugins"
  sudo mkdir -p "$DOCKER_CLI_PLUGIN_DIR"
  # последний релиз compose
  COMPOSE_URL="$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest \
    | jq -r '.assets[] | select(.name|test("linux-x86_64$")) | .browser_download_url')"
  sudo curl -L "$COMPOSE_URL" -o "$DOCKER_CLI_PLUGIN_DIR/docker-compose"
  sudo chmod +x "$DOCKER_CLI_PLUGIN_DIR/docker-compose"
fi

############################################
# FOLDERS
############################################
echo "[*] Preparing directories..."
sudo mkdir -p "${BASE_DIR}"/{data,postgres,caddy}
sudo chown -R "$USER":"$USER" "$BASE_DIR"

############################################
# ENV
############################################
cat > "${BASE_DIR}/.env" <<EOF
# ====== n8n ======
GENERIC_TIMEZONE=${TZ}
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
N8N_PORT=5678
N8N_EDITOR_BASE_URL=https://${DOMAIN}
N8N_PUBLIC_URL=https://${DOMAIN}
N8N_SECURE_COOKIE=true
EXECUTIONS_MODE=regular

# ====== DB ======
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}

# ====== INTERNAL ======
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
DB_POSTGRESDB_USER=${POSTGRES_USER}
DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
EOF

############################################
# Dockerfile: n8n + ffmpeg внутри контейнера
############################################
cat > "${BASE_DIR}/Dockerfile" <<'EOF'
FROM n8nio/n8n:latest
USER root
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ffmpeg; \
    rm -rf /var/lib/apt/lists/*
USER node
EOF

############################################
# Caddyfile (SSL / reverse proxy)
############################################
cat > "${BASE_DIR}/caddy/Caddyfile" <<EOF
{
  email ${ADMIN_EMAIL}
}
${DOMAIN} {
  encode zstd gzip
  reverse_proxy n8n:5678
}
EOF

############################################
# docker-compose.yaml
############################################
cat > "${BASE_DIR}/docker-compose.yaml" <<'YAML'
services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - ./postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 10

  n8n:
    build: .
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    env_file: .env
    environment:
      GENERIC_TIMEZONE: ${GENERIC_TIMEZONE}
    volumes:
      - ./data:/home/node/.n8n
    # За портом следит Caddy (443)

  caddy:
    image: caddy:latest
    restart: unless-stopped
    depends_on:
      - n8n
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    ports:
      - "80:80"
      - "443:443"

volumes:
  caddy_data:
  caddy_config:
YAML

############################################
# START
############################################
echo "[*] Starting stack..."
cd "$BASE_DIR"
docker compose pull
docker compose build
docker compose up -d

############################################
# INFO
############################################
echo
echo "========================================="
echo " n8n развернут с PostgreSQL и SSL (Caddy)"
echo " Домен:        https://${DOMAIN}"
echo " Данные:       ${BASE_DIR}"
echo " Postgres user: ${POSTGRES_USER}"
echo " Postgres pass: ${POSTGRES_PASSWORD}"
echo " N8N ENC KEY:   ${N8N_ENCRYPTION_KEY}"
echo "========================================="
echo "Проверь в Lightsail: открыт ли фаерволл на 80/443."
echo "Docker и контейнеры настроены на автозапуск (restart: unless-stopped)."
