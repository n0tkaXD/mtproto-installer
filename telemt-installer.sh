#!/usr/bin/env bash
set -Eeuo pipefail

# Telemt MTProto Proxy Installer
# installer by n0tkaXD
#
# GitHub-ready single-file installer for Ubuntu/Debian.
# Installs Telemt MTProto Proxy in FakeTLS mode.
#
# Quick install:
#   sudo bash telemt-installer.sh
#
# Non-interactive:
#   sudo bash telemt-installer.sh install --port 8443 --domain www.cloudflare.com --ad-tag 00000000000000000000000000000000
#
# Commands:
#   install      Install or update Telemt
#   monitor      Live connection/device-ish monitor
#   status       Show service status
#   link         Show Telegram proxy link
#   adtag        Change/remove ad tag
#   restart      Restart Telemt
#   uninstall    Remove Telemt service and files
#   help         Show help

APP_NAME="Telemt MTProto Proxy"
AUTHOR="n0tkaXD"

SERVICE_NAME="telemt"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
BIN_PATH="/bin/telemt"
CONFIG_DIR="/etc/telemt"
CONFIG_FILE="${CONFIG_DIR}/telemt.toml"
WORKDIR="/opt/telemt"
SECRET_FILE="${WORKDIR}/secret.txt"
LINK_FILE="${WORKDIR}/link.txt"
API_URL="http://127.0.0.1:9091"

DEFAULT_PORT="8443"
DEFAULT_DOMAIN="www.cloudflare.com"
DEFAULT_USER="main"
DEFAULT_MONITOR_INTERVAL="2"

PORT=""
TLS_DOMAIN=""
AD_TAG=""
USERNAME="$DEFAULT_USER"
MONITOR_INTERVAL="$DEFAULT_MONITOR_INTERVAL"
NO_FIREWALL="0"
FORCE_443="0"
NON_INTERACTIVE="0"

BOLD=""
DIM=""
RED=""
GREEN=""
YELLOW=""
BLUE=""
MAGENTA=""
CYAN=""
RESET=""

if [[ -t 1 ]]; then
  BOLD="$(printf '\033[1m')"
  DIM="$(printf '\033[2m')"
  RED="$(printf '\033[31m')"
  GREEN="$(printf '\033[32m')"
  YELLOW="$(printf '\033[33m')"
  BLUE="$(printf '\033[34m')"
  MAGENTA="$(printf '\033[35m')"
  CYAN="$(printf '\033[36m')"
  RESET="$(printf '\033[0m')"
fi

say()  { printf '%b\n' "$*"; }
info() { say "${BLUE}›${RESET} $*"; }
ok()   { say "${GREEN}✓${RESET} $*"; }
warn() { say "${YELLOW}!${RESET} $*"; }
err()  { say "${RED}✗${RESET} $*" >&2; }
die()  { err "$*"; exit 1; }

banner() {
  cat <<EOF
${MAGENTA}${BOLD}
╔══════════════════════════════════════════════════╗
║          Telemt MTProto Proxy Installer          ║
║                installer by n0tkaXD              ║
╚══════════════════════════════════════════════════╝
${RESET}
EOF
}

usage() {
  cat <<EOF
${BOLD}${APP_NAME}${RESET}
installer by ${AUTHOR}

Usage:
  sudo bash telemt-installer.sh [command] [options]

Commands:
  install       Install or update Telemt
  monitor       Live monitor: connections, active IPs, estimated devices
  status        Show service status
  link          Show saved Telegram proxy link
  adtag         Change/remove ad tag
  restart       Restart Telemt
  uninstall     Remove Telemt service and files
  help          Show this help

Options:
  --port PORT            Proxy port. Default: ${DEFAULT_PORT}
  --domain DOMAIN        FakeTLS domain. Default: ${DEFAULT_DOMAIN}
  --ad-tag HEX           32-hex ad tag from @MTProxybot. Empty = disabled
  --user NAME            Telemt username. Default: ${DEFAULT_USER}
  --interval SEC         Monitor refresh interval. Default: ${DEFAULT_MONITOR_INTERVAL}
  --no-firewall          Do not touch UFW
  --force-443            Allow port 443. Not recommended.
  -y, --yes              Non-interactive defaults

Examples:
  sudo bash telemt-installer.sh
  sudo bash telemt-installer.sh install --port 8443
  sudo bash telemt-installer.sh install --port 2096 --domain www.microsoft.com
  sudo bash telemt-installer.sh install --ad-tag 1234567890abcdef1234567890abcdef
  sudo bash telemt-installer.sh monitor
  sudo bash telemt-installer.sh adtag
  sudo bash telemt-installer.sh link
  sudo bash telemt-installer.sh uninstall

Notes:
  - This installer does not use Docker.
  - It does not touch existing Docker containers.
  - It refuses to use port 443 unless --force-443 is provided.
  - It installs Telemt in FakeTLS mode.
  - "Devices" are estimated: Telegram can open several TCP connections per one app/device.
EOF
}

need_root() {
  [[ "${EUID}" -eq 0 ]] || die "Run as root: sudo bash telemt-installer.sh"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

ask() {
  local prompt="$1"
  local default="$2"
  local answer=""

  if [[ -t 0 && "$NON_INTERACTIVE" != "1" ]]; then
    read -r -p "$(printf '%b' "${CYAN}?${RESET} ${prompt} ${DIM}[${default}]${RESET}: ")" answer
  fi

  if [[ -z "$answer" ]]; then
    echo "$default"
  else
    echo "$answer"
  fi
}

ask_optional() {
  local prompt="$1"
  local current="$2"
  local answer=""

  if [[ -t 0 && "$NON_INTERACTIVE" != "1" ]]; then
    if [[ -n "$current" ]]; then
      read -r -p "$(printf '%b' "${CYAN}?${RESET} ${prompt} ${DIM}[current: ${current}; empty = keep; '-' = remove]${RESET}: ")" answer
      if [[ -z "$answer" ]]; then
        echo "$current"
      elif [[ "$answer" == "-" ]]; then
        echo ""
      else
        echo "$answer"
      fi
    else
      read -r -p "$(printf '%b' "${CYAN}?${RESET} ${prompt} ${DIM}[empty = disabled]${RESET}: ")" answer
      echo "$answer"
    fi
  else
    echo "$current"
  fi
}

confirm() {
  local prompt="$1"
  local default="${2:-n}"
  local answer=""

  if [[ "$NON_INTERACTIVE" == "1" ]]; then
    [[ "$default" =~ ^[Yy]$ ]]
    return
  fi

  if [[ ! -t 0 ]]; then
    [[ "$default" =~ ^[Yy]$ ]]
    return
  fi

  local suffix="[y/N]"
  [[ "$default" =~ ^[Yy]$ ]] && suffix="[Y/n]"

  read -r -p "$(printf '%b' "${YELLOW}?${RESET} ${prompt} ${DIM}${suffix}${RESET}: ")" answer
  answer="${answer:-$default}"

  [[ "$answer" =~ ^[Yy]$ ]]
}

detect_arch() {
  local arch
  arch="$(uname -m)"

  case "$arch" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    *)
      die "Unsupported architecture: $arch"
      ;;
  esac
}

detect_libc() {
  if ldd --version 2>&1 | grep -qi musl; then
    echo "musl"
  else
    echo "gnu"
  fi
}

detect_public_ip() {
  local ip=""
  ip="$(curl -4fsS --max-time 8 https://api.ipify.org 2>/dev/null || true)"

  if [[ -z "$ip" ]]; then
    ip="$(curl -4fsS --max-time 8 https://ifconfig.me/ip 2>/dev/null || true)"
  fi

  if [[ -z "$ip" ]]; then
    ip="$(hostname -I | awk '{print $1}')"
    warn "Could not detect public IPv4 reliably. Using: $ip"
  fi

  echo "$ip"
}

current_port() {
  [[ -f "$CONFIG_FILE" ]] || return 0
  awk '
    /^\[server\]/ {in_server=1; next}
    /^\[/ && $0 !~ /^\[server\]/ {in_server=0}
    in_server && /^[[:space:]]*port[[:space:]]*=/ {
      gsub(/[^0-9]/, "", $0);
      print $0;
      exit
    }
  ' "$CONFIG_FILE" 2>/dev/null || true
}

current_domain() {
  [[ -f "$CONFIG_FILE" ]] || return 0
  awk -F'"' '
    /^\[censorship\]/ {in_block=1; next}
    /^\[/ && $0 !~ /^\[censorship\]/ {in_block=0}
    in_block && /^[[:space:]]*tls_domain[[:space:]]*=/ {
      print $2;
      exit
    }
  ' "$CONFIG_FILE" 2>/dev/null || true
}

current_ad_tag() {
  [[ -f "$CONFIG_FILE" ]] || return 0
  awk -F'"' '
    /^\[general\]/ {in_block=1; next}
    /^\[/ && $0 !~ /^\[general\]/ {in_block=0}
    in_block && /^[[:space:]]*ad_tag[[:space:]]*=/ {
      print $2;
      exit
    }
  ' "$CONFIG_FILE" 2>/dev/null || true
}

current_username() {
  [[ -f "$CONFIG_FILE" ]] || { echo "$DEFAULT_USER"; return 0; }
  awk -F'=' '
    /^\[access.users\]/ {in_block=1; next}
    /^\[/ && $0 !~ /^\[access.users\]/ {in_block=0}
    in_block && /^[[:space:]]*[A-Za-z0-9_.-]+[[:space:]]*=/ {
      gsub(/[[:space:]]/, "", $1);
      print $1;
      exit
    }
  ' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_USER"
}

current_secret() {
  if [[ -f "$SECRET_FILE" ]]; then
    tr -d '[:space:]' < "$SECRET_FILE"
    return 0
  fi

  [[ -f "$CONFIG_FILE" ]] || return 0
  awk -F'"' '
    /^\[access.users\]/ {in_block=1; next}
    /^\[/ && $0 !~ /^\[access.users\]/ {in_block=0}
    in_block && /^[[:space:]]*[A-Za-z0-9_.-]+[[:space:]]*=/ {
      print $2;
      exit
    }
  ' "$CONFIG_FILE" 2>/dev/null || true
}

validate_username() {
  [[ "$USERNAME" =~ ^[A-Za-z0-9_.-]{1,64}$ ]] || die "Invalid username: ${USERNAME}"
}

validate_port() {
  [[ "$PORT" =~ ^[0-9]+$ ]] || die "Port must be numeric: $PORT"
  (( PORT >= 1 && PORT <= 65535 )) || die "Port out of range: $PORT"

  if [[ "$PORT" == "443" && "$FORCE_443" != "1" ]]; then
    die "Port 443 is protected. Use --force-443 only if you are absolutely sure."
  fi
}

validate_ad_tag() {
  [[ -z "$AD_TAG" ]] && return 0
  [[ "$AD_TAG" =~ ^[0-9a-fA-F]{32}$ ]] || die "Ad tag must be exactly 32 hex chars from @MTProxybot"
  AD_TAG="$(printf '%s' "$AD_TAG" | tr 'A-F' 'a-f')"
}

port_busy() {
  ss -ltn "( sport = :$PORT )" 2>/dev/null | grep -q LISTEN
}

port_owner_is_telemt() {
  ss -ltnp "( sport = :$PORT )" 2>/dev/null | grep -q "$SERVICE_NAME" || false
}

show_port_owner() {
  ss -ltnp "( sport = :$PORT )" 2>/dev/null || true
}

install_dependencies() {
  info "Checking system dependencies"

  require_cmd systemctl
  require_cmd uname
  require_cmd tar
  require_cmd openssl
  require_cmd ss

  local missing=()

  command -v curl >/dev/null 2>&1 || missing+=("curl")
  command -v python3 >/dev/null 2>&1 || missing+=("python3")

  if [[ "${#missing[@]}" -gt 0 ]]; then
    info "Installing missing packages: ${missing[*]}"
    apt-get update -y >/dev/null
    apt-get install -y ca-certificates "${missing[@]}" >/dev/null
  fi

  ok "Dependencies are ready"
}

create_user() {
  if ! id telemt >/dev/null 2>&1; then
    info "Creating system user: telemt"
    useradd -d "$WORKDIR" -m -r -U telemt
  fi
}

download_telemt() {
  local arch libc tarball url tmp
  arch="$(detect_arch)"
  libc="$(detect_libc)"
  tarball="telemt-${arch}-linux-${libc}.tar.gz"
  url="https://github.com/telemt/telemt/releases/latest/download/${tarball}"
  tmp="$(mktemp -d)"

  info "Downloading Telemt latest release"
  curl -fL "$url" -o "${tmp}/${tarball}" >/dev/null

  tar -xzf "${tmp}/${tarball}" -C "$tmp"

  [[ -f "${tmp}/telemt" ]] || die "Telemt binary not found in release archive"

  install -m 0755 "${tmp}/telemt" "$BIN_PATH"
  rm -rf "$tmp"

  ok "Telemt installed to ${BIN_PATH}"
}

write_config() {
  local secret="$1"
  local public_ip="$2"

  mkdir -p "$CONFIG_DIR" "$WORKDIR" "${WORKDIR}/tlsfront"
  chmod 750 "$CONFIG_DIR" "$WORKDIR"

  echo "$secret" > "$SECRET_FILE"
  chmod 600 "$SECRET_FILE"

  cat > "$CONFIG_FILE" <<EOF
# Telemt MTProto Proxy
# installer by n0tkaXD

[general]
use_middle_proxy = true
log_level = "normal"
EOF

  if [[ -n "$AD_TAG" ]]; then
    cat >> "$CONFIG_FILE" <<EOF
ad_tag = "${AD_TAG}"
EOF
  fi

  cat >> "$CONFIG_FILE" <<EOF

[general.modes]
classic = false
secure = false
tls = true

[general.links]
show = "*"
public_host = "${public_ip}"
public_port = ${PORT}

[server]
port = ${PORT}

[server.api]
enabled = true
listen = "127.0.0.1:9091"
whitelist = ["127.0.0.1/32", "::1/128"]
minimal_runtime_enabled = true
minimal_runtime_cache_ttl_ms = 1000
runtime_edge_enabled = true
runtime_edge_cache_ttl_ms = 1000
runtime_edge_top_n = 20
read_only = false

[[server.listeners]]
ip = "0.0.0.0"

[censorship]
tls_domain = "${TLS_DOMAIN}"
mask = true
tls_emulation = true
tls_front_dir = "${WORKDIR}/tlsfront"

[access.users]
${USERNAME} = "${secret}"
EOF

  if [[ -n "$AD_TAG" ]]; then
    cat >> "$CONFIG_FILE" <<EOF

[access.user_ad_tags]
${USERNAME} = "${AD_TAG}"
EOF
  fi

  chown -R telemt:telemt "$CONFIG_DIR" "$WORKDIR"
  chmod 640 "$CONFIG_FILE"

  ok "Config written to ${CONFIG_FILE}"
}

write_service() {
  cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Telemt MTProto Proxy
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=telemt
Group=telemt
WorkingDirectory=${WORKDIR}
ExecStart=${BIN_PATH} ${CONFIG_FILE}
Restart=on-failure
RestartSec=3
LimitNOFILE=65536
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  ok "Systemd service created"
}

open_firewall() {
  if [[ "$NO_FIREWALL" == "1" ]]; then
    warn "Firewall step skipped"
    return
  fi

  if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -qi "Status: active"; then
    info "Opening TCP/${PORT} in UFW"
    ufw allow "${PORT}/tcp" >/dev/null || true
    ok "UFW rule added"
  else
    info "UFW is not active, firewall unchanged"
  fi
}

start_service() {
  info "Starting Telemt"
  systemctl enable --now "$SERVICE_NAME" >/dev/null

  for _ in $(seq 1 25); do
    if port_busy; then
      ok "Telemt is listening on 0.0.0.0:${PORT}"
      return
    fi
    sleep 1
  done

  journalctl -u "$SERVICE_NAME" -n 80 --no-pager || true
  die "Telemt did not start listening on port ${PORT}"
}

api_get() {
  local path="$1"
  curl -fsS --max-time 5 "${API_URL}${path}"
}

api_ready() {
  api_get "/v1/health" >/dev/null 2>&1
}

manual_tls_link() {
  local public_ip="$1"
  local secret="$2"
  local domain_hex
  domain_hex="$(printf "%s" "$TLS_DOMAIN" | od -An -tx1 | tr -d ' \n')"
  echo "tg://proxy?server=${public_ip}&port=${PORT}&secret=ee${secret}${domain_hex}"
}

refresh_link() {
  local public_ip secret api_link https_link
  public_ip="$(detect_public_ip)"
  secret="$(current_secret)"

  info "Generating link"

  api_link=""
  if api_ready; then
    api_link="$(api_get "/v1/users" | python3 -c '
import json, sys
try:
    payload = json.load(sys.stdin)
    for u in payload.get("data", []):
        links = u.get("links", {})
        tls = links.get("tls", [])
        if tls:
            print(tls[0])
            raise SystemExit
except Exception:
    pass
' || true)"
  fi

  if [[ -z "$api_link" ]]; then
    warn "API link generation unavailable, using fallback link builder"
    api_link="$(manual_tls_link "$public_ip" "$secret")"
  fi

  https_link="${api_link/tg:\/\/proxy/https:\/\/t.me\/proxy}"

  cat > "$LINK_FILE" <<EOF
Telemt MTProto Proxy
installer by n0tkaXD

Server: ${public_ip}
Port: ${PORT}
FakeTLS domain: ${TLS_DOMAIN}
User: ${USERNAME}
Ad tag: ${AD_TAG:-disabled}

Telegram link:
${api_link}

HTTPS link:
${https_link}

Useful commands:
systemctl status telemt
journalctl -u telemt -n 100 --no-pager
curl -s ${API_URL}/v1/users
cat ${LINK_FILE}
EOF

  chown telemt:telemt "$LINK_FILE"
  chmod 600 "$LINK_FILE"

  say ""
  say "${GREEN}${BOLD}Done.${RESET} Your MTProto FakeTLS link:"
  say ""
  say "${CYAN}${api_link}${RESET}"
  say ""
  say "Saved to: ${BOLD}${LINK_FILE}${RESET}"
}

install_telemt() {
  need_root

  local current_p current_d current_tag current_user current_s public_ip secret
  current_p="$(current_port)"
  current_d="$(current_domain)"
  current_tag="$(current_ad_tag)"
  current_user="$(current_username)"
  current_s="$(current_secret)"

  PORT="${PORT:-${current_p:-$DEFAULT_PORT}}"
  TLS_DOMAIN="${TLS_DOMAIN:-${current_d:-$DEFAULT_DOMAIN}}"
  USERNAME="${USERNAME:-${current_user:-$DEFAULT_USER}}"

  if [[ -z "${AD_TAG+x}" || -z "$AD_TAG" ]]; then
    AD_TAG="${current_tag:-}"
  fi

  if [[ "$NON_INTERACTIVE" != "1" && -t 0 ]]; then
    PORT="$(ask "Proxy port" "$PORT")"
    TLS_DOMAIN="$(ask "FakeTLS domain" "$TLS_DOMAIN")"
    USERNAME="$(ask "User name" "$USERNAME")"
    AD_TAG="$(ask_optional "Ad tag from @MTProxybot" "$AD_TAG")"
  fi

  validate_username
  validate_port
  validate_ad_tag

  banner
  info "Installer by ${AUTHOR}"
  info "Mode: FakeTLS"
  info "Port: ${PORT}"
  info "Domain: ${TLS_DOMAIN}"
  info "User: ${USERNAME}"

  if [[ -n "$AD_TAG" ]]; then
    info "Ad tag: enabled"
  else
    info "Ad tag: disabled"
  fi

  if port_busy && ! port_owner_is_telemt; then
    err "Port ${PORT} is already busy:"
    show_port_owner
    die "Choose another port, for example: --port 2096"
  fi

  systemctl stop "$SERVICE_NAME" >/dev/null 2>&1 || true

  install_dependencies
  create_user
  download_telemt

  public_ip="$(detect_public_ip)"

  if [[ -n "$current_s" && "$current_s" =~ ^[0-9a-fA-F]{32}$ ]]; then
    secret="$current_s"
  else
    secret="$(openssl rand -hex 16)"
  fi

  write_config "$secret" "$public_ip"
  write_service
  open_firewall
  start_service
  refresh_link

  say ""
  say "${DIM}Tip:${RESET} run ${BOLD}sudo bash $0 monitor${RESET} to watch active connections."
}

show_status() {
  need_root
  banner
  systemctl --no-pager --full status "$SERVICE_NAME" || true
}

show_link() {
  need_root

  if [[ ! -f "$LINK_FILE" ]]; then
    die "Link file not found. Install first."
  fi

  banner
  cat "$LINK_FILE"
}

restart_service() {
  need_root
  banner
  info "Restarting Telemt"
  systemctl restart "$SERVICE_NAME"
  ok "Restarted"
  systemctl --no-pager --full status "$SERVICE_NAME" || true
}

format_stats() {
  USERS_JSON="${1:-{}}" SUMMARY_JSON="${2:-{}}" python3 - <<'PY'
import json, os, math

def load_env(name):
    try:
        return json.loads(os.environ.get(name, "{}") or "{}")
    except Exception:
        return {}

users_payload = load_env("USERS_JSON")
summary_payload = load_env("SUMMARY_JSON")

users = users_payload.get("data") or []
summary_root = summary_payload.get("data") or {}
summary = summary_root.get("data") or summary_root
totals = summary.get("totals") or {}

def to_int(value, default=0):
    try:
        return int(value)
    except Exception:
        return default

total_conns = totals.get("current_connections")
active_users = totals.get("active_users")

if total_conns is None:
    total_conns = sum(to_int(u.get("current_connections")) for u in users)
else:
    total_conns = to_int(total_conns)

if active_users is None:
    active_users = sum(1 for u in users if to_int(u.get("current_connections")) > 0)
else:
    active_users = to_int(active_users)

all_ips = []
for u in users:
    for ip in (u.get("active_unique_ips_list") or []):
        if ip not in all_ips:
            all_ips.append(ip)

estimated_devices = max(active_users, math.ceil(total_conns / 3)) if total_conns else 0

print(f"Active TCP connections : {total_conns}")
print(f"Active users/secrets   : {active_users}")
print(f"Active unique IPs      : {len(all_ips)}")
print(f"Estimated devices      : ~{estimated_devices}")
print("")
print("Per user")
print("--------")

if not users:
    print("No users returned by API.")
else:
    for u in users:
        username = u.get("username", "?")
        conns = to_int(u.get("current_connections"))
        ips = u.get("active_unique_ips") or 0
        ip_list = ", ".join(u.get("active_unique_ips_list") or [])
        recent_ips = u.get("recent_unique_ips")
        total_octets = to_int(u.get("total_octets"))
        mb = total_octets / 1024 / 1024
        ad = u.get("user_ad_tag") or "disabled"

        print(f"{username}:")
        print(f"  connections : {conns}")
        print(f"  active IPs  : {ips}")
        if recent_ips is not None:
            print(f"  recent IPs  : {recent_ips}")
        print(f"  traffic     : {mb:.2f} MiB")
        print(f"  ad tag      : {ad}")
        print(f"  IP list     : {ip_list or '-'}")
        print("")

print("Note: Telegram may open several TCP connections from one app/device.")
print("      Exact device identity is not exposed to MTProxy; this is an estimate.")
PY
}

print_monitor_once() {
  local users_json summary_json

  if ! api_ready; then
    warn "Telemt API is not reachable at ${API_URL}"
    say "Try: systemctl status telemt"
    return 1
  fi

  users_json="$(api_get "/v1/users" || echo '{}')"
  summary_json="$(api_get "/v1/runtime/connections/summary" || echo '{}')"

  format_stats "$users_json" "$summary_json"
}

monitor() {
  need_root

  if [[ ! -f "$SERVICE_FILE" ]]; then
    die "Telemt is not installed."
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    die "python3 is required for monitor."
  fi

  while true; do
    clear || true
    banner
    say "${BOLD}Live monitor${RESET} ${DIM}(refresh: ${MONITOR_INTERVAL}s, Ctrl+C to exit)${RESET}"
    say ""
    print_monitor_once || true
    sleep "$MONITOR_INTERVAL"
  done
}

change_adtag() {
  need_root

  if [[ ! -f "$CONFIG_FILE" ]]; then
    die "Telemt config not found. Install first."
  fi

  local current_p current_d current_tag current_user current_s public_ip
  current_p="$(current_port)"
  current_d="$(current_domain)"
  current_tag="$(current_ad_tag)"
  current_user="$(current_username)"
  current_s="$(current_secret)"

  PORT="${PORT:-${current_p:-$DEFAULT_PORT}}"
  TLS_DOMAIN="${TLS_DOMAIN:-${current_d:-$DEFAULT_DOMAIN}}"
  USERNAME="${USERNAME:-${current_user:-$DEFAULT_USER}}"

  if [[ -z "${AD_TAG+x}" || -z "$AD_TAG" ]]; then
    AD_TAG="${current_tag:-}"
  fi

  banner
  say "${BOLD}Ad tag setup${RESET}"
  say ""
  say "Paste 32-hex tag from @MTProxybot."
  say "Leave empty to keep current. Type '-' to remove."
  say ""

  AD_TAG="$(ask_optional "Ad tag" "$AD_TAG")"

  validate_username
  validate_port
  validate_ad_tag

  public_ip="$(detect_public_ip)"
  write_config "$current_s" "$public_ip"

  info "Restarting Telemt"
  systemctl restart "$SERVICE_NAME"
  ok "Ad tag updated"
  refresh_link
}

uninstall_telemt() {
  need_root
  banner

  if ! confirm "Remove Telemt service, binary and config?" "n"; then
    warn "Cancelled"
    exit 0
  fi

  systemctl stop "$SERVICE_NAME" >/dev/null 2>&1 || true
  systemctl disable "$SERVICE_NAME" >/dev/null 2>&1 || true
  rm -f "$SERVICE_FILE"
  systemctl daemon-reload

  rm -f "$BIN_PATH"
  rm -rf "$CONFIG_DIR" "$WORKDIR"

  if id telemt >/dev/null 2>&1; then
    userdel telemt >/dev/null 2>&1 || true
  fi

  ok "Telemt removed"
}

interactive_menu() {
  banner

  if [[ -f "$SERVICE_FILE" ]]; then
    say "${BOLD}Choose action:${RESET}"
    say "  1) Show link"
    say "  2) Live monitor"
    say "  3) Status"
    say "  4) Restart"
    say "  5) Change ad tag"
    say "  6) Reinstall / update"
    say "  7) Uninstall"
    say "  q) Quit"
    say ""

    local choice
    read -r -p "$(printf '%b' "${CYAN}?${RESET} Select: ")" choice

    case "$choice" in
      1) show_link ;;
      2) monitor ;;
      3) show_status ;;
      4) restart_service ;;
      5) change_adtag ;;
      6) install_telemt ;;
      7) uninstall_telemt ;;
      q|Q) exit 0 ;;
      *) die "Unknown choice" ;;
    esac
  else
    say "${BOLD}Install Telemt MTProto Proxy${RESET}"
    say ""
    install_telemt
  fi
}

parse_args() {
  COMMAND="${1:-}"

  if [[ -n "$COMMAND" ]]; then
    shift || true
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --port)
        PORT="${2:-}"
        shift 2
        ;;
      --domain)
        TLS_DOMAIN="${2:-}"
        shift 2
        ;;
      --ad-tag|--adtag)
        AD_TAG="${2:-}"
        shift 2
        ;;
      --user|--username)
        USERNAME="${2:-}"
        shift 2
        ;;
      --interval)
        MONITOR_INTERVAL="${2:-$DEFAULT_MONITOR_INTERVAL}"
        shift 2
        ;;
      --no-firewall)
        NO_FIREWALL="1"
        shift
        ;;
      --force-443)
        FORCE_443="1"
        shift
        ;;
      -y|--yes)
        NON_INTERACTIVE="1"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
  done
}

main() {
  if [[ $# -eq 0 ]]; then
    interactive_menu
    exit 0
  fi

  parse_args "$@"

  case "$COMMAND" in
    install) install_telemt ;;
    monitor) monitor ;;
    status) show_status ;;
    link) show_link ;;
    adtag) change_adtag ;;
    restart) restart_service ;;
    uninstall) uninstall_telemt ;;
    help|-h|--help) usage ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
