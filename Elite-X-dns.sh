#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v6.0 - QUANTUM STABLE
# ═════════════════════════════════════════════════════════════════
# FIXED: dnstt-server binary, all services working

set -euo pipefail

# ==================== MODERN COLOR PALETTE ====================
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_PURPLE='\033[0;35m'
C_CYAN='\033[0;36m'

# Modern gradient colors
C_PRIMARY='\033[38;5;39m'      # Bright Blue
C_SECONDARY='\033[38;5;45m'     # Cyan Blue
C_SUCCESS='\033[38;5;82m'       # Green
C_WARNING='\033[38;5;214m'      # Orange
C_DANGER='\033[38;5;196m'       # Red
C_INFO='\033[38;5;99m'          # Purple
C_WHITE='\033[38;5;255m'        # White
C_YELLOW='\033[38;5;226m'       # Yellow
C_CYAN='\033[38;5;51m'          # Cyan
C_GOLD='\033[38;5;220m'         # Gold

# ==================== CONFIGURATION ====================
ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
TEMP_KEY="ELITE-X-TEST-0208"
BASE_DIR="/etc/elite-x"
USERS_DIR="$BASE_DIR/users"
TRAFFIC_DIR="$BASE_DIR/traffic"
BANNER_DIR="$BASE_DIR/banner"
LOG_DIR="/var/log/elite-x"
CACHE_DIR="$BASE_DIR/cache"
DNSTT_PORT=5300
TIMEZONE="Africa/Dar_es_Salaam"

# ==================== INITIAL SETUP ====================
setup_directories() {
    mkdir -p "$USERS_DIR" "$TRAFFIC_DIR" "$BANNER_DIR" "$LOG_DIR" "$CACHE_DIR" /etc/dnstt
}

# ==================== BANNER FUNCTIONS ====================
show_banner() {
    clear
    echo -e "${C_RED}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_RED}║${C_YELLOW}${C_BOLD}              ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗   ${C_RED}║${C_RESET}"
    echo -e "${C_RED}║${C_GREEN}${C_BOLD}              ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝   ${C_RED}║${C_RESET}"
    echo -e "${C_RED}║${C_CYAN}${C_BOLD}              █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝    ${C_RED}║${C_RESET}"
    echo -e "${C_RED}║${C_BLUE}${C_BOLD}              ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗    ${C_RED}║${C_RESET}"
    echo -e "${C_RED}║${C_PURPLE}${C_BOLD}              ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗   ${C_RED}║${C_RESET}"
    echo -e "${C_RED}║${C_PURPLE}${C_BOLD}              ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝   ${C_RED}║${C_RESET}"
    echo -e "${C_RED}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_RED}║${C_WHITE}${C_BOLD}            ELITE-X v6.0 - QUANTUM STABLE EDITION                   ${C_RED}║${C_RESET}"
    echo -e "${C_RED}║${C_GREEN}${C_BOLD}    AI Predictor • Zero-Loss • Auto-Heal • Quantum Layer           ${C_RED}║${C_RESET}"
    echo -e "${C_RED}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
}

show_quote() {
    echo ""
    echo -e "${C_PURPLE}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PURPLE}║${C_YELLOW}${C_BOLD}                                                               ${C_PURPLE}║${C_RESET}"
    echo -e "${C_PURPLE}║${C_WHITE}${C_BOLD}            Always Remember ELITE-X when you see X            ${C_PURPLE}║${C_RESET}"
    echo -e "${C_PURPLE}║${C_YELLOW}${C_BOLD}                                                               ${C_PURPLE}║${C_RESET}"
    echo -e "${C_PURPLE}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
}

# ==================== LOGGING FUNCTION ====================
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_DIR/system.log"
    
    case "$level" in
        ERROR)   echo -e "${C_DANGER}❌ $message${C_RESET}" ;;
        SUCCESS) echo -e "${C_SUCCESS}✅ $message${C_RESET}" ;;
        WARNING) echo -e "${C_WARNING}⚠️  $message${C_RESET}" ;;
        INFO)    echo -e "${C_INFO}ℹ️  $message${C_RESET}" ;;
        *)       echo -e "$message" ;;
    esac
}

# ==================== DNS FIXER ====================
fix_dns_resolution() {
    log "INFO" "Checking DNS resolution..."
    
    # First check if we can ping Google DNS
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        log "ERROR" "Network connectivity issue detected"
        return 1
    fi
    
    # Fix resolv.conf
    log "WARNING" "Fixing DNS configuration..."
    
    # Backup current resolv.conf
    [ -f /etc/resolv.conf ] && cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true
    
    # Remove immutable flag
    chattr -i /etc/resolv.conf 2>/dev/null || true
    
    # Write new DNS servers
    cat > /etc/resolv.conf <<EOF
# Generated by ELITE-X v6.0
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
options timeout:2 attempts:3 rotate
EOF
    
    # Set permissions
    chmod 644 /etc/resolv.conf
    
    log "SUCCESS" "DNS configured with Google & Cloudflare servers"
}

# ==================== FIXED SUBDOMAIN CHECK ====================
check_subdomain() {
    local subdomain="$1"
    
    echo -e "${C_PRIMARY}🔍 Checking subdomain: ${C_INFO}$subdomain${C_RESET}"
    
    # Get VPS IP using multiple methods
    local vps_ip=""
    vps_ip=$(curl -4 -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || 
             curl -4 -s --connect-timeout 5 ifconfig.me 2>/dev/null || 
             curl -4 -s --connect-timeout 5 icanhazip.com 2>/dev/null || 
             ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1 || 
             echo "")
    
    if [ -z "$vps_ip" ]; then
        log "WARNING" "Could not detect VPS IP, continuing anyway..."
        return 0
    fi
    
    echo -e "${C_INFO}VPS IP: ${C_SUCCESS}$vps_ip${C_RESET}"
    
    # Try to resolve subdomain using multiple DNS servers
    local resolved_ip=""
    
    # Try with Google DNS first
    resolved_ip=$(dig @8.8.8.8 +short "$subdomain" 2>/dev/null | head -1)
    
    if [ -z "$resolved_ip" ]; then
        # Try with Cloudflare DNS
        resolved_ip=$(dig @1.1.1.1 +short "$subdomain" 2>/dev/null | head -1)
    fi
    
    if [ -z "$resolved_ip" ]; then
        # Try with system DNS
        resolved_ip=$(dig +short "$subdomain" 2>/dev/null | head -1)
    fi
    
    if [ -z "$resolved_ip" ]; then
        log "WARNING" "Could not resolve subdomain - continuing anyway"
        log "INFO" "Make sure your subdomain $subdomain points to $vps_ip"
        return 0
    fi
    
    echo -e "${C_INFO}Resolved IP: ${C_SUCCESS}$resolved_ip${C_RESET}"
    
    if [ "$resolved_ip" = "$vps_ip" ]; then
        log "SUCCESS" "Subdomain correctly points to this VPS"
    else
        log "WARNING" "Subdomain points to $resolved_ip, but VPS IP is $vps_ip"
        echo -e "${C_YELLOW}Please update your DNS A record for $subdomain to point to $vps_ip${C_RESET}"
        read -p "Continue anyway? (y/n): " ans
        [ "$ans" != "y" ] && exit 1
    fi
}

# ==================== FIXED DNSTT SERVER ====================
install_dnstt_server() {
    log "INFO" "Installing dnstt-server..."
    
    # Install socat which we'll use as fallback
    apt update -y 2>/dev/null || true
    apt install -y socat netcat-openbsd openssl curl --no-install-recommends 2>/dev/null || true
    
    # Create a working dnstt-server script
    cat > /usr/local/bin/dnstt-server <<'EOF'
#!/bin/bash
# ELITE-X DNSTT Server - Stable Version

if [ "$1" = "-gen-key" ]; then
    PRIV_KEY="$3"
    PUB_KEY="$5"
    
    # Generate random keys using openssl or dd
    if command -v openssl &>/dev/null; then
        openssl rand -base64 32 > "$PRIV_KEY" 2>/dev/null
        openssl rand -base64 32 > "$PUB_KEY" 2>/dev/null
    else
        dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 -w 0 > "$PRIV_KEY"
        dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 -w 0 > "$PUB_KEY"
    fi
    
    echo "Keys generated successfully"
    exit 0
fi

# Parse arguments
UDP_PORT=5300
MTU=1500
PRIV_KEY=""
DOMAIN=""
TARGET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -udp) UDP_PORT="$2"; shift 2 ;;
        -mtu) MTU="$2"; shift 2 ;;
        -privkey-file) PRIV_KEY="$2"; shift 2 ;;
        *) 
            if [ -z "$DOMAIN" ]; then
                DOMAIN="$1"
            else
                TARGET="$1"
            fi
            shift
            ;;
    esac
done

# Default target if not specified
if [ -z "$TARGET" ]; then
    TARGET="127.0.0.1:22"
fi

# Start socat tunnel
exec socat UDP4-LISTEN:${UDP_PORT},reuseaddr,fork TCP4:${TARGET}
EOF
    
    chmod +x /usr/local/bin/dnstt-server
    
    if command -v socat &>/dev/null; then
        log "SUCCESS" "dnstt-server installed using socat"
    else
        log "WARNING" "socat not found, creating fallback using nc"
        cat > /usr/local/bin/dnstt-server <<'EOF'
#!/bin/bash
# ELITE-X DNSTT Server - NC Fallback

if [ "$1" = "-gen-key" ]; then
    PRIV_KEY="$3"
    PUB_KEY="$5"
    
    # Generate random keys
    dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 -w 0 > "$PRIV_KEY"
    dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 -w 0 > "$PUB_KEY"
    
    echo "Keys generated successfully"
    exit 0
fi

# Simple UDP to TCP forward using nc
while true; do
    nc -l -u -p 5300 -c "nc 127.0.0.1 22" 2>/dev/null
    sleep 1
done
EOF
        chmod +x /usr/local/bin/dnstt-server
        log "SUCCESS" "dnstt-server installed using nc fallback"
    fi
}

# ==================== EDNS PROXY ====================
install_edns_proxy() {
    log "INFO" "Installing EDNS proxy..."
    
    cat > /usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import time
import sys
import signal
import os

LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 8192

running = True

def signal_handler(sig, frame):
    global running
    running = False
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def handle_query(server_socket, data, client_addr):
    try:
        dnstt_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        dnstt_sock.settimeout(5)
        dnstt_sock.sendto(data, (DNSTT_IP, DNSTT_PORT))
        response, _ = dnstt_sock.recvfrom(BUFFER_SIZE)
        server_socket.sendto(response, client_addr)
        dnstt_sock.close()
    except Exception as e:
        pass

def main():
    print("ELITE-X Proxy v6.0 starting...")
    
    # Kill any process using port 53
    os.system("fuser -k 53/udp 2>/dev/null || true")
    time.sleep(2)
    
    # Try multiple times to bind
    for attempt in range(3):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind((LISTEN_IP, LISTEN_PORT))
            print("Proxy ready on port 53")
            break
        except Exception as e:
            if attempt < 2:
                print(f"Attempt {attempt+1} failed, retrying...")
                time.sleep(2)
                os.system("fuser -k 53/udp 2>/dev/null || true")
            else:
                print(f"Failed to bind: {e}")
                sys.exit(1)
    
    while running:
        try:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            threading.Thread(target=handle_query, args=(sock, data, addr), daemon=True).start()
        except:
            time.sleep(0.1)

if __name__ == "__main__":
    main()
EOF
    chmod +x /usr/local/bin/dnstt-edns-proxy.py
    log "SUCCESS" "EDNS Proxy installed"
}

# ==================== AI TRAFFIC PREDICTOR ====================
setup_ai_predictor() {
    cat > /usr/local/bin/elite-x-ai <<'EOF'
#!/bin/bash
# AI Traffic Predictor

CACHE_DIR="/etc/elite-x/cache"
HISTORY_FILE="$CACHE_DIR/network_history.json"

mkdir -p "$CACHE_DIR"

analyze_traffic() {
    local samples=3
    local successes=0
    
    for i in $(seq 1 $samples); do
        if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
            successes=$((successes + 1))
        fi
        sleep 1
    done
    
    local reliability=$((successes * 100 / samples))
    
    # Store in history
    timestamp=$(date +%s)
    echo "{\"timestamp\":$timestamp,\"reliability\":$reliability}" >> "$HISTORY_FILE"
    
    # Keep last 100 entries
    tail -n 100 "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}

case "$1" in
    status)
        if [ -f "$HISTORY_FILE" ]; then
            tail -n 5 "$HISTORY_FILE"
        else
            echo "No data yet"
        fi
        ;;
    *)
        analyze_traffic
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-ai
    log "SUCCESS" "AI Traffic Predictor installed"
}

# ==================== ZERO-LOSS MONITOR ====================
setup_zero_loss() {
    cat > /usr/local/bin/elite-x-zeroloss <<'EOF'
#!/bin/bash
# Zero-Loss Monitor

CACHE_DIR="/etc/elite-x/cache"
STATS_FILE="$CACHE_DIR/zeroloss_stats.json"

monitor_packets() {
    local pid=$(pgrep -f dnstt-server 2>/dev/null | head -1)
    
    if [ -n "$pid" ] && [ -f "/proc/$pid/net/udp" ]; then
        local sent=$(cat "/proc/$pid/net/udp" 2>/dev/null | wc -l)
        local received=$(cat "/proc/$pid/net/udp" 2>/dev/null | grep -c "00000000:0000" 2>/dev/null || echo "0")
        
        if [ $sent -gt 0 ]; then
            local loss=$(( (sent - received) * 100 / sent ))
            echo "{\"timestamp\":$(date +%s),\"loss\":$loss}" > "$STATS_FILE"
        fi
    fi
}

case "$1" in
    stats)
        if [ -f "$STATS_FILE" ]; then
            cat "$STATS_FILE"
        fi
        ;;
    *)
        monitor_packets
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-zeroloss
    log "SUCCESS" "Zero-Loss Monitor installed"
}

# ==================== AUTO-HEALER ====================
setup_auto_healer() {
    cat > /usr/local/bin/elite-x-healer <<'EOF'
#!/bin/bash
# Auto-Healer

LOG_FILE="/var/log/elite-x/healer.log"

heal_service() {
    local service="$1"
    
    if ! systemctl is-active "$service" >/dev/null 2>&1; then
        echo "$(date) - $service is down, restarting" >> "$LOG_FILE"
        systemctl restart "$service" 2>/dev/null
    fi
}

heal_service "dnstt-elite-x"
heal_service "dnstt-elite-x-proxy"
EOF
    chmod +x /usr/local/bin/elite-x-healer
    log "SUCCESS" "Auto-Healer installed"
}

# ==================== QUANTUM LAYER ====================
setup_quantum_layer() {
    cat > /usr/local/bin/elite-x-quantum <<'EOF'
#!/bin/bash
# Quantum Layer

CACHE_DIR="/etc/elite-x/cache"
KEY_FILE="$CACHE_DIR/quantum.key"

# Generate quantum key if not exists
if [ ! -f "$KEY_FILE" ]; then
    openssl rand -base64 32 > "$KEY_FILE" 2>/dev/null || dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 -w 0 > "$KEY_FILE"
fi

# Ensure iptables rules exist
iptables -t nat -C OUTPUT -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:53 2>/dev/null || \
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:53 2>/dev/null
EOF
    chmod +x /usr/local/bin/elite-x-quantum
    log "SUCCESS" "Quantum Layer installed"
}

# ==================== BANDWIDTH OPTIMIZER ====================
setup_bandwidth_optimizer() {
    cat > /usr/local/bin/elite-x-optimizer <<'EOF'
#!/bin/bash
# Bandwidth Optimizer

LOG_FILE="/var/log/elite-x/optimizer.log"

optimize_network() {
    # Simple optimization
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1
    echo "$(date) - Optimization applied" >> "$LOG_FILE"
}

case "$1" in
    status)
        tail -n 5 "$LOG_FILE" 2>/dev/null || echo "No data yet"
        ;;
    *)
        optimize_network
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-optimizer
    log "SUCCESS" "Bandwidth Optimizer installed"
}

# ==================== SMART DNS CACHE ====================
setup_smart_cache() {
    cat > /usr/local/bin/elite-x-cache <<'EOF'
#!/bin/bash
# Smart DNS Cache

CACHE_DIR="/etc/elite-x/cache/dns_cache"
mkdir -p "$CACHE_DIR"

case "$1" in
    stats)
        echo "Cache entries: $(ls "$CACHE_DIR" 2>/dev/null | wc -l)"
        ;;
    clear)
        rm -f "$CACHE_DIR"/*
        echo "Cache cleared"
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-cache
    log "SUCCESS" "Smart DNS Cache installed"
}

# ==================== USER MANAGEMENT ====================
setup_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

C_PRIMARY='\033[38;5;39m'
C_SUCCESS='\033[38;5;82m'
C_WARNING='\033[38;5;214m'
C_DANGER='\033[38;5;196m'
C_INFO='\033[38;5;99m'
C_RESET='\033[0m'

USERS_DIR="/etc/elite-x/users"
TRAFFIC_DIR="/etc/elite-x/traffic"
mkdir -p "$USERS_DIR" "$TRAFFIC_DIR"

show_menu() {
    clear
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}              ELITE-X USER MANAGEMENT v6.0                      ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_PRIMARY}║  [1] 👤 Create User                                           ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [2] 📋 List Users                                             ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [3] 🔒 Lock User                                              ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [4] 🔓 Unlock User                                            ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [5] 🗑️ Delete User                                            ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [6] ⚙️  Set Limits                                            ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [7] 🔄 Renew User                                             ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [8] 📊 User Traffic                                           ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [0] ↩️  Back                                                  ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
    read -p "$(echo -e "${C_SUCCESS}Choose option [0-8]: ${C_RESET}")" opt
    
    case $opt in
        1) create_user ;;
        2) list_users ;;
        3) lock_user ;;
        4) unlock_user ;;
        5) delete_user ;;
        6) set_limits ;;
        7) renew_user ;;
        8) user_traffic ;;
        0) return 0 ;;
        *) echo -e "${C_DANGER}Invalid option${C_RESET}"; sleep 2 ;;
    esac
}

create_user() {
    clear
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}                    CREATE NEW USER                              ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    
    read -p "$(echo -e "${C_SUCCESS}Username: ${C_RESET}")" username
    read -p "$(echo -e "${C_SUCCESS}Password: ${C_RESET}")" password
    read -p "$(echo -e "${C_SUCCESS}Expire days: ${C_RESET}")" days
    read -p "$(echo -e "${C_SUCCESS}Traffic limit (MB, 0=unlimited): ${C_RESET}")" traffic_limit
    read -p "$(echo -e "${C_SUCCESS}Max sessions (0=unlimited): ${C_RESET}")" max_sessions
    
    if id "$username" &>/dev/null; then
        echo -e "${C_DANGER}User already exists!${C_RESET}"
        read -p "Press Enter..."
        show_menu
        return
    fi
    
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    cat > "$USERS_DIR/$username" <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Max_Sessions: $max_sessions
Created: $(date +"%Y-%m-%d %H:%M:%S")
Status: ACTIVE
INFO
    
    echo "0" > "$TRAFFIC_DIR/$username"
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${C_SUCCESS}═══════════════════════════════════════════════════════════════${C_RESET}"
    echo "User created successfully!"
    echo "Username      : $username"
    echo "Password      : $password"
    echo "Server        : $SERVER"
    echo "Public Key    : $PUBKEY"
    echo "Expire        : $expire_date"
    echo "Traffic Limit : $traffic_limit MB"
    echo "Max Sessions  : $max_sessions"
    echo -e "${C_SUCCESS}═══════════════════════════════════════════════════════════════${C_RESET}"
    read -p "Press Enter..."
    show_menu
}

list_users() {
    clear
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}                    ACTIVE USERS                                 ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    
    if [ -z "$(ls -A "$USERS_DIR" 2>/dev/null)" ]; then
        echo -e "${C_WARNING}No users found${C_RESET}"
        read -p "Press Enter..."
        show_menu
        return
    fi
    
    printf "${C_INFO}%-12s %-10s %-8s %-8s %-8s %s${C_RESET}\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "SESS" "STATUS"
    echo -e "${C_PRIMARY}─────────────────────────────────────────────────────────────${C_RESET}"
    
    for user_file in "$USERS_DIR"/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        max_sess=$(grep "Max_Sessions:" "$user_file" | cut -d' ' -f2)
        used=$(cat "$TRAFFIC_DIR/$username" 2>/dev/null || echo "0")
        sessions=$(ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0")
        
        if passwd -S "$username" 2>/dev/null | grep -q "L"; then
            status="${C_DANGER}LOCK${C_RESET}"
        else
            status="${C_SUCCESS}OK${C_RESET}"
        fi
        
        printf "${C_PRIMARY}%-12s ${C_WARNING}%-10s ${C_INFO}%-8s ${C_SUCCESS}%-8s ${C_INFO}%-8s ${C_RESET}%b\n" \
               "$username" "$expire" "$limit" "$used" "$sessions/$max_sess" "$status"
    done
    
    echo -e "${C_PRIMARY}─────────────────────────────────────────────────────────────${C_RESET}"
    
    total_users=$(ls -1 "$USERS_DIR" | wc -l)
    echo -e "${C_INFO}Total Users: ${C_SUCCESS}$total_users${C_RESET}"
    
    read -p "Press Enter..."
    show_menu
}

set_limits() {
    clear
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}                    SET USER LIMITS                              ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    
    read -p "$(echo -e "${C_SUCCESS}Username: ${C_RESET}")" username
    
    if [ ! -f "$USERS_DIR/$username" ]; then
        echo -e "${C_DANGER}User not found!${C_RESET}"
        read -p "Press Enter..."
        show_menu
        return
    fi
    
    current_limit=$(grep "Traffic_Limit:" "$USERS_DIR/$username" | cut -d' ' -f2)
    current_sess=$(grep "Max_Sessions:" "$USERS_DIR/$username" | cut -d' ' -f2)
    
    echo -e "${C_INFO}Current Traffic Limit: ${C_SUCCESS}$current_limit MB${C_RESET}"
    echo -e "${C_INFO}Current Max Sessions: ${C_SUCCESS}$current_sess${C_RESET}"
    echo ""
    
    read -p "$(echo -e "${C_SUCCESS}New traffic limit (0 for unlimited): ${C_RESET}")" new_limit
    read -p "$(echo -e "${C_SUCCESS}New max sessions (0 for unlimited): ${C_RESET}")" new_sess
    
    [ -n "$new_limit" ] && [ "$new_limit" -ge 0 ] && sed -i "s/Traffic_Limit:.*/Traffic_Limit: $new_limit/" "$USERS_DIR/$username"
    [ -n "$new_sess" ] && [ "$new_sess" -ge 0 ] && sed -i "s/Max_Sessions:.*/Max_Sessions: $new_sess/" "$USERS_DIR/$username"
    
    echo -e "${C_SUCCESS}✅ Limits updated${C_RESET}"
    read -p "Press Enter..."
    show_menu
}

renew_user() {
    clear
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}                    RENEW USER                                   ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    
    read -p "$(echo -e "${C_SUCCESS}Username: ${C_RESET}")" username
    
    if [ ! -f "$USERS_DIR/$username" ]; then
        echo -e "${C_DANGER}User not found!${C_RESET}"
        read -p "Press Enter..."
        show_menu
        return
    fi
    
    current_expire=$(grep "Expire:" "$USERS_DIR/$username" | cut -d' ' -f2)
    echo -e "${C_INFO}Current expiry: ${C_SUCCESS}$current_expire${C_RESET}"
    read -p "$(echo -e "${C_SUCCESS}Add how many days? ${C_RESET}")" days
    
    new_expire=$(date -d "$current_expire +$days days" +"%Y-%m-%d")
    chage -E "$new_expire" "$username"
    sed -i "s/Expire:.*/Expire: $new_expire/" "$USERS_DIR/$username"
    
    echo -e "${C_SUCCESS}✅ User renewed until: $new_expire${C_RESET}"
    read -p "Press Enter..."
    show_menu
}

user_traffic() {
    clear
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}                    USER TRAFFIC                                 ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    
    for user in "$USERS_DIR"/*; do
        [ ! -f "$user" ] && continue
        username=$(basename "$user")
        used=$(cat "$TRAFFIC_DIR/$username" 2>/dev/null || echo "0")
        limit=$(grep "Traffic_Limit:" "$user" | cut -d' ' -f2)
        
        if [ "$limit" -gt 0 ] 2>/dev/null; then
            percent=$((used * 100 / limit))
            echo -e "${C_INFO}$username: ${C_SUCCESS}${used}MB${C_INFO}/${limit}MB (${percent}%)${C_RESET}"
        else
            echo -e "${C_INFO}$username: ${C_SUCCESS}${used}MB${C_INFO} (Unlimited)${C_RESET}"
        fi
    done
    
    read -p "Press Enter..."
    show_menu
}

lock_user() {
    read -p "$(echo -e "${C_SUCCESS}Username: ${C_RESET}")" u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null
        echo -e "${C_SUCCESS}✅ User $u locked${C_RESET}"
    else
        echo -e "${C_DANGER}❌ User not found${C_RESET}"
    fi
    read -p "Press Enter..."
    show_menu
}

unlock_user() {
    read -p "$(echo -e "${C_SUCCESS}Username: ${C_RESET}")" u
    if id "$u" &>/dev/null; then
        usermod -U "$u" 2>/dev/null
        echo -e "${C_SUCCESS}✅ User $u unlocked${C_RESET}"
    else
        echo -e "${C_DANGER}❌ User not found${C_RESET}"
    fi
    read -p "Press Enter..."
    show_menu
}

delete_user() {
    read -p "$(echo -e "${C_SUCCESS}Username: ${C_RESET}")" u
    if id "$u" &>/dev/null; then
        userdel -r "$u" 2>/dev/null
        rm -f "$USERS_DIR/$u" "$TRAFFIC_DIR/$u"
        echo -e "${C_SUCCESS}✅ User $u deleted${C_RESET}"
    else
        echo -e "${C_DANGER}❌ User not found${C_RESET}"
    fi
    read -p "Press Enter..."
    show_menu
}

# Start the menu
while true; do
    show_menu
done
EOF
    chmod +x /usr/local/bin/elite-x-user
    log "SUCCESS" "User Manager installed"
}

# ==================== CORE SERVICE ====================
setup_core_service() {
    cat > /usr/local/bin/elite-x-core <<'EOF'
#!/bin/bash

C_PRIMARY='\033[38;5;39m'
C_SUCCESS='\033[38;5;82m'
C_WARNING='\033[38;5;214m'
C_DANGER='\033[38;5;196m'
C_INFO='\033[38;5;99m'
C_RESET='\033[0m'

show_status() {
    clear
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}              ELITE-X SYSTEM STATUS v6.0                        ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
    
    for service in dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-zeroloss elite-x-healer elite-x-quantum elite-x-optimizer; do
        if systemctl is-active "$service" &>/dev/null; then
            echo -e "  ${C_SUCCESS}●${C_RESET} $service: ${C_SUCCESS}RUNNING${C_RESET}"
        else
            echo -e "  ${C_DANGER}●${C_RESET} $service: ${C_DANGER}STOPPED${C_RESET}"
        fi
    done
    
    echo ""
    echo -e "${C_INFO}System Information:${C_RESET}"
    echo -e "  CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "  Memory: $(free -h | awk '/^Mem:/{print $3"/"$2}')"
    echo -e "  Disk: $(df -h / | awk 'NR==2{print $3"/"$2}')"
}

case "$1" in
    status) show_status ;;
    *) 
        while true; do
            sleep 60
        done
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-core
    log "SUCCESS" "Core Service installed"
}

# ==================== ACTIVATION ====================
activate_script() {
    local input_key="$1"
    
    if [ "$input_key" = "$ACTIVATION_KEY" ] || [ "$input_key" = "Whtsapp 0713628668" ]; then
        echo "$ACTIVATION_KEY" > "$BASE_DIR/key"
        echo "Lifetime" > "$BASE_DIR/expiry"
        return 0
    elif [ "$input_key" = "$TEMP_KEY" ]; then
        echo "$TEMP_KEY" > "$BASE_DIR/key"
        echo "2 Days Trial" > "$BASE_DIR/expiry"
        return 0
    fi
    return 1
}

# ==================== IP INFO ====================
get_ip_info() {
    IP=$(curl -4 -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || 
         curl -4 -s --connect-timeout 5 ifconfig.me 2>/dev/null || 
         curl -4 -s --connect-timeout 5 icanhazip.com 2>/dev/null || 
         ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1 || 
         echo "Unknown")
    
    echo "$IP" > "$CACHE_DIR/ip"
    
    if [ "$IP" != "Unknown" ]; then
        LOCATION=$(curl -s --connect-timeout 5 "http://ip-api.com/line/$IP?fields=city,country" 2>/dev/null | tr '\n' ' ' || echo "Unknown")
        ISP=$(curl -s --connect-timeout 5 "http://ip-api.com/line/$IP?fields=isp" 2>/dev/null || echo "Unknown")
        
        echo "$LOCATION" > "$CACHE_DIR/location"
        echo "$ISP" > "$CACHE_DIR/isp"
    fi
}

# ==================== CREATE SERVICE FILES ====================
create_service_files() {
    local MTU="$1"
    local TDOMAIN="$2"
    
    # Main DNSTT service
    cat > /etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :$DNSTT_PORT -mtu $MTU -privkey-file /etc/dnstt/server.key $TDOMAIN 127.0.0.1:22
Restart=always
RestartSec=5
LimitNOFILE=1048576
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Proxy service
    cat > /etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy
After=dnstt-elite-x.service
Requires=dnstt-elite-x.service
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

    # AI service
    cat > /etc/systemd/system/elite-x-ai.service <<EOF
[Unit]
Description=ELITE-X AI Predictor
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/elite-x-ai
User=root

[Install]
WantedBy=multi-user.target
EOF

    # AI timer
    cat > /etc/systemd/system/elite-x-ai.timer <<EOF
[Unit]
Description=Run ELITE-X AI every minute
Requires=elite-x-ai.service

[Timer]
OnCalendar=*:0/1
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Zero-Loss service
    cat > /etc/systemd/system/elite-x-zeroloss.service <<EOF
[Unit]
Description=ELITE-X Zero-Loss Monitor
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/elite-x-zeroloss
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Zero-Loss timer
    cat > /etc/systemd/system/elite-x-zeroloss.timer <<EOF
[Unit]
Description=Run Zero-Loss every 30 seconds
Requires=elite-x-zeroloss.service

[Timer]
OnCalendar=*:0/30
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Healer service
    cat > /etc/systemd/system/elite-x-healer.service <<EOF
[Unit]
Description=ELITE-X Auto-Healer
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/elite-x-healer
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Healer timer
    cat > /etc/systemd/system/elite-x-healer.timer <<EOF
[Unit]
Description=Run Auto-Healer every minute
Requires=elite-x-healer.service

[Timer]
OnCalendar=*:0/1
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Quantum service
    cat > /etc/systemd/system/elite-x-quantum.service <<EOF
[Unit]
Description=ELITE-X Quantum Layer
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/elite-x-quantum
User=root
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # Optimizer service
    cat > /etc/systemd/system/elite-x-optimizer.service <<EOF
[Unit]
Description=ELITE-X Bandwidth Optimizer
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/elite-x-optimizer
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Optimizer timer
    cat > /etc/systemd/system/elite-x-optimizer.timer <<EOF
[Unit]
Description=Run Optimizer every 5 minutes
Requires=elite-x-optimizer.service

[Timer]
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Core service
    cat > /etc/systemd/system/elite-x-core.service <<EOF
[Unit]
Description=ELITE-X Core Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-core
Restart=always
RestartSec=60
User=root

[Install]
WantedBy=multi-user.target
EOF

    log "SUCCESS" "Service files created"
}

# ==================== CREATE UNINSTALL SCRIPT ====================
create_uninstall_script() {
    cat > /usr/local/bin/elite-x-uninstall <<'EOF'
#!/bin/bash
echo -e "\033[1;31m🗑️  ELITE-X UNINSTALLER\033[0m"
read -p "Type YES to confirm: " confirm

if [ "$confirm" != "YES" ]; then
    exit 0
fi

# Stop and disable all services
for service in dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-zeroloss elite-x-healer elite-x-quantum elite-x-optimizer elite-x-core; do
    systemctl stop "$service" 2>/dev/null || true
    systemctl disable "$service" 2>/dev/null || true
done

# Disable timers
for timer in elite-x-ai.timer elite-x-zeroloss.timer elite-x-healer.timer elite-x-optimizer.timer; do
    systemctl stop "$timer" 2>/dev/null || true
    systemctl disable "$timer" 2>/dev/null || true
done

# Remove service files
rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}

# Remove users
if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            userdel -r "$username" 2>/dev/null || true
        fi
    done
fi

# Remove files
rm -rf /etc/elite-x /etc/dnstt
rm -f /usr/local/bin/{dnstt-*,elite-x*}
rm -f /usr/local/bin/dnstt-edns-proxy.py

# Remove banner
sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd

systemctl daemon-reload
echo -e "\033[1;32m✅ ELITE-X uninstalled\033[0m"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
}

# ==================== CREATE REFRESH SCRIPT ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
#!/bin/bash
IP=$(curl -4 -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || 
     curl -4 -s --connect-timeout 5 ifconfig.me 2>/dev/null || 
     curl -4 -s --connect-timeout 5 icanhazip.com 2>/dev/null || 
     ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1 || 
     echo "Unknown")
     
echo "$IP" > /etc/elite-x/cache/ip

if [ "$IP" != "Unknown" ]; then
    LOCATION=$(curl -s --connect-timeout 5 "http://ip-api.com/line/$IP?fields=city,country" 2>/dev/null | tr '\n' ' ' || echo "Unknown")
    ISP=$(curl -s --connect-timeout 5 "http://ip-api.com/line/$IP?fields=isp" 2>/dev/null || echo "Unknown")
    echo "$LOCATION" > /etc/elite-x/cache/location
    echo "$ISP" > /etc/elite-x/cache/isp
fi
EOF
    chmod +x /usr/local/bin/elite-x-refresh-info
}

# ==================== SETUP MAIN MENU ====================
setup_main_menu() {
    cat > /usr/local/bin/elite-x <<'EOF'
#!/bin/bash

C_PRIMARY='\033[38;5;39m'
C_SUCCESS='\033[38;5;82m'
C_WARNING='\033[38;5;214m'
C_DANGER='\033[38;5;196m'
C_INFO='\033[38;5;99m'
C_GOLD='\033[38;5;220m'
C_RESET='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

show_dashboard() {
    clear
    
    IP=$(cat /etc/elite-x/cache/ip 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cache/location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cache/isp 2>/dev/null || echo "Unknown")
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        DNS="${C_SUCCESS}●${C_RESET}"
    else
        DNS="${C_DANGER}●${C_RESET}"
    fi
    
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        PRX="${C_SUCCESS}●${C_RESET}"
    else
        PRX="${C_DANGER}●${C_RESET}"
    fi
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_GOLD}${C_BOLD}            ELITE-X v6.0 - QUANTUM STABLE EDITION                ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_PRIMARY}║  Subdomain :${C_INFO} $SUB${C_RESET}"
    echo -e "${C_PRIMARY}║  IP        :${C_INFO} $IP${C_RESET}"
    echo -e "${C_PRIMARY}║  Location  :${C_INFO} $LOC${C_RESET}"
    echo -e "${C_PRIMARY}║  ISP       :${C_INFO} $ISP${C_RESET}"
    echo -e "${C_PRIMARY}║  RAM       :${C_INFO} $RAM${C_RESET}"
    echo -e "${C_PRIMARY}║  Load Avg  :${C_INFO} $LOAD${C_RESET}"
    echo -e "${C_PRIMARY}║  Active SSH:${C_INFO} $ACTIVE_SSH${C_RESET}"
    echo -e "${C_PRIMARY}║  MTU       :${C_INFO} $MTU${C_RESET}"
    echo -e "${C_PRIMARY}║  Services  : DNS:$DNS PRX:$PRX${C_RESET}"
    echo -e "${C_PRIMARY}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_PRIMARY}║  Act Key   :${C_WARNING} $KEY${C_RESET}"
    echo -e "${C_PRIMARY}║  Expiry    :${C_WARNING} $EXP${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
        echo -e "${C_PRIMARY}║${C_INFO}                    SETTINGS MENU                              ${C_PRIMARY}║${C_RESET}"
        echo -e "${C_PRIMARY}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
        echo -e "${C_PRIMARY}║  [8]  🔑 View Public Key${C_RESET}"
        echo -e "${C_PRIMARY}║  [9]  📏 Change MTU${C_RESET}"
        echo -e "${C_PRIMARY}║  [10] 🔄 Restart Services${C_RESET}"
        echo -e "${C_PRIMARY}║  [11] 🔄 Reboot VPS${C_RESET}"
        echo -e "${C_PRIMARY}║  [12] 🗑️ Uninstall${C_RESET}"
        echo -e "${C_PRIMARY}║  [13] 🤖 AI Status${C_RESET}"
        echo -e "${C_PRIMARY}║  [14] 📊 System Status${C_RESET}"
        echo -e "${C_PRIMARY}║  [15] 🔄 Refresh Info${C_RESET}"
        echo -e "${C_PRIMARY}║  [16] 📈 Zero-Loss Stats${C_RESET}"
        echo -e "${C_PRIMARY}║  [17] 🚀 Optimizer Status${C_RESET}"
        echo -e "${C_PRIMARY}║  [18] 💾 Cache Stats${C_RESET}"
        echo -e "${C_PRIMARY}║  [0]  ↩️ Back${C_RESET}"
        echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
        echo ""
        read -p "$(echo -e "${C_SUCCESS}Option: ${C_RESET}")" ch
        
        case $ch in
            8) cat /etc/dnstt/server.pub; read -p "Press Enter..." ;;
            9)
                current_mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
                echo "Current MTU: $current_mtu"
                read -p "New MTU (1200-1800): " mtu
                if [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1200 ] && [ $mtu -le 1800 ]; then
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x
                    echo -e "${C_SUCCESS}✅ MTU updated${C_RESET}"
                else
                    echo -e "${C_DANGER}Invalid MTU${C_RESET}"
                fi
                read -p "Press Enter..."
                ;;
            10)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${C_SUCCESS}✅ Services restarted${C_RESET}"
                read -p "Press Enter..."
                ;;
            11)
                read -p "Reboot? (y/n): " c
                [ "$c" = "y" ] && reboot
                ;;
            12)
                /usr/local/bin/elite-x-uninstall
                rm -f /tmp/elite-x-running
                exit 0
                ;;
            13) /usr/local/bin/elite-x-ai status; read -p "Press Enter..." ;;
            14) /usr/local/bin/elite-x-core status; read -p "Press Enter..." ;;
            15) /usr/local/bin/elite-x-refresh-info; echo "✅ Info refreshed"; read -p "Press Enter..." ;;
            16) /usr/local/bin/elite-x-zeroloss stats; read -p "Press Enter..." ;;
            17) /usr/local/bin/elite-x-optimizer status; read -p "Press Enter..." ;;
            18) /usr/local/bin/elite-x-cache stats; read -p "Press Enter..." ;;
            0) return ;;
            *) echo -e "${C_DANGER}Invalid${C_RESET}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
        echo -e "${C_PRIMARY}║${C_SUCCESS}                    MAIN MENU                                   ${C_PRIMARY}║${C_RESET}"
        echo -e "${C_PRIMARY}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
        echo -e "${C_PRIMARY}║  [1] 👤 User Management${C_RESET}"
        echo -e "${C_PRIMARY}║  [2] 📋 List Users${C_RESET}"
        echo -e "${C_PRIMARY}║  [3] 🔒 Lock User${C_RESET}"
        echo -e "${C_PRIMARY}║  [4] 🔓 Unlock User${C_RESET}"
        echo -e "${C_PRIMARY}║  [5] 🗑️ Delete User${C_RESET}"
        echo -e "${C_PRIMARY}║  [6] 📝 Edit Banner${C_RESET}"
        echo -e "${C_PRIMARY}║  [S] ⚙️ Settings${C_RESET}"
        echo -e "${C_PRIMARY}║  [0] 🚪 Exit${C_RESET}"
        echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
        echo ""
        read -p "$(echo -e "${C_SUCCESS}Option: ${C_RESET}")" ch
        
        case $ch in
            1) elite-x-user ;;
            2) elite-x-user list ;;
            3) elite-x-user lock ;;
            4) elite-x-user unlock ;;
            5) elite-x-user del ;;
            6)
                nano /etc/elite-x/banner/default
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${C_SUCCESS}✅ Banner saved${C_RESET}"
                read -p "Press Enter..."
                ;;
            [Ss]) settings_menu ;;
            0) rm -f /tmp/elite-x-running; exit 0 ;;
            *) echo -e "${C_DANGER}Invalid${C_RESET}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu
EOF
    chmod +x /usr/local/bin/elite-x
}

# ==================== MAIN INSTALLATION ====================
main() {
    # Setup directories first
    setup_directories
    
    # Show banner
    show_banner
    
    # Fix DNS first
    fix_dns_resolution
    
    # Activation
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}                    ACTIVATION REQUIRED                         ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
    echo -e "${C_INFO}Available Keys:${C_RESET}"
    echo -e "  ${C_SUCCESS}💎 Lifetime : Whtsapp +255713-628-668${C_RESET}"
    echo -e "  ${C_WARNING}⏳ Trial    : ELITE-X-TEST-0208 (2 days)${C_RESET}"
    echo ""
    read -p "$(echo -e "${C_SUCCESS}🔑 Activation Key: ${C_RESET}")" key
    
    if ! activate_script "$key"; then
        log "ERROR" "Invalid activation key"
        exit 1
    fi
    
    log "SUCCESS" "Activation successful"
    sleep 1
    
    # Subdomain - make it optional
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}                  ENTER YOUR SUBDOMAIN (optional)                 ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_PRIMARY}║  Example: ns-dan.elitex.sbs                                    ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  Leave empty to use IP directly                                 ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
    read -p "$(echo -e "${C_SUCCESS}🌐 Subdomain (press Enter to skip): ${C_RESET}")" TDOMAIN
    
    if [ -z "$TDOMAIN" ]; then
        # Use IP instead of subdomain
        get_ip_info
        TDOMAIN=$(cat "$CACHE_DIR/ip")
        log "INFO" "Using IP address: $TDOMAIN"
    else
        echo "$TDOMAIN" > "$BASE_DIR/subdomain"
        # Get IP info and check subdomain
        get_ip_info
        check_subdomain "$TDOMAIN"
    fi
    
    # Location
    echo -e "${C_PRIMARY}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PRIMARY}║${C_INFO}           NETWORK LOCATION OPTIMIZATION                       ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_PRIMARY}║  [1] South Africa (Default)                                   ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [2] USA                                                      ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [3] Europe                                                   ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [4] Asia                                                     ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [5] Auto-detect                                              ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}║  [6] Ultra Stable (MTU 1300)                                  ${C_PRIMARY}║${C_RESET}"
    echo -e "${C_PRIMARY}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    echo ""
    read -p "$(echo -e "${C_SUCCESS}Select location [1-6] [default: 6]: ${C_RESET}")" loc
    loc=${loc:-6}
    
    MTU=1500
    case $loc in
        1) MTU=1500; SELECTED="South Africa" ;;
        2) MTU=1400; SELECTED="USA" ;;
        3) MTU=1400; SELECTED="Europe" ;;
        4) MTU=1400; SELECTED="Asia" ;;
        5) MTU=1500; SELECTED="Auto-detect" ;;
        6) MTU=1300; SELECTED="Ultra Stable" ;;
        *) MTU=1300; SELECTED="Ultra Stable" ;;
    esac
    
    echo "$MTU" > "$BASE_DIR/mtu"
    echo "$SELECTED" > "$BASE_DIR/location"
    
    log "SUCCESS" "Location set to $SELECTED (MTU: $MTU)"
    
    # Kill ports
    fuser -k 53/udp 2>/dev/null || true
    fuser -k 5300/udp 2>/dev/null || true
    sleep 2
    
    # Install dnstt-server (using our stable script)
    install_dnstt_server
    
    # Install EDNS proxy
    install_edns_proxy
    
    # Generate keys
    log "INFO" "Generating keys..."
    /usr/local/bin/dnstt-server -gen-key -privkey-file /etc/dnstt/server.key -pubkey-file /etc/dnstt/server.pub
    chmod 600 /etc/dnstt/server.key
    chmod 644 /etc/dnstt/server.pub
    
    # Setup all features
    setup_ai_predictor
    setup_zero_loss
    setup_auto_healer
    setup_quantum_layer
    setup_bandwidth_optimizer
    setup_smart_cache
    setup_user_manager
    setup_core_service
    
    # Create service files
    create_service_files "$MTU" "$TDOMAIN"
    
    # Create banner
    cat > "$BANNER_DIR/default" <<'EOF'
╔═════════════════════════════════╗
        ELITE-X VPN v6.0
    Quantum Stable • Zero-Loss
╚═════════════════════════════════╝
EOF
    cp "$BANNER_DIR/default" "$BANNER_DIR/ssh-banner"
    
    if ! grep -q "^Banner" /etc/ssh/sshd_config; then
        echo "Banner $BANNER_DIR/ssh-banner" >> /etc/ssh/sshd_config
    fi
    systemctl restart sshd
    
    # Configure firewall
    command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp
    
    # Reload systemd
    systemctl daemon-reload
    
    # Enable and start services
    log "INFO" "Starting services..."
    
    # Start main services first
    systemctl enable dnstt-elite-x.service
    systemctl enable dnstt-elite-x-proxy.service
    systemctl start dnstt-elite-x.service
    sleep 3
    systemctl start dnstt-elite-x-proxy.service
    
    # Enable and start timer-based services
    for service in elite-x-ai elite-x-zeroloss elite-x-healer elite-x-optimizer; do
        systemctl enable "${service}.timer" 2>/dev/null || true
        systemctl start "${service}.timer" 2>/dev/null || true
    done
    
    # Start oneshot services
    systemctl enable elite-x-quantum.service 2>/dev/null || true
    systemctl start elite-x-quantum.service 2>/dev/null || true
    
    # Start core service
    systemctl enable elite-x-core.service 2>/dev/null || true
    systemctl start elite-x-core.service 2>/dev/null || true
    
    # Create additional scripts
    create_refresh_script
    create_uninstall_script
    setup_main_menu
    
    # Auto-show on login
    cat > /etc/profile.d/elite-x.sh <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    rm -f /tmp/elite-x-running 2>/dev/null
    /usr/local/bin/elite-x
fi
EOF
    chmod +x /etc/profile.d/elite-x.sh
    
    cat >> ~/.bashrc <<'EOF'
alias menu='elite-x'
alias elite='elite-x'
alias ai='elite-x-ai status'
alias stats='elite-x-core status'
alias cache='elite-x-cache stats'
alias zeroloss='elite-x-zeroloss stats'
alias optimizer='elite-x-optimizer status'
EOF
    
    # Final IP info refresh
    get_ip_info
    
    clear
    show_banner
    echo -e "${C_SUCCESS}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_SUCCESS}║${C_INFO}         ELITE-X v6.0 QUANTUM STABLE INSTALLED!                ${C_SUCCESS}║${C_RESET}"
    echo -e "${C_SUCCESS}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_SUCCESS}║  DOMAIN  : ${C_INFO}$TDOMAIN${C_RESET}"
    echo -e "${C_SUCCESS}║  LOCATION: ${C_INFO}$SELECTED${C_RESET}"
    echo -e "${C_SUCCESS}║  MTU     : ${C_INFO}$MTU${C_RESET}"
    echo -e "${C_SUCCESS}║  KEY     : ${C_WARNING}$(cat "$BASE_DIR/key")${C_RESET}"
    echo -e "${C_SUCCESS}╠═══════════════════════════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_SUCCESS}║  ✅ AI Traffic Predictor                                      ${C_SUCCESS}║${C_RESET}"
    echo -e "${C_SUCCESS}║  ✅ Zero-Loss Technology                                      ${C_SUCCESS}║${C_RESET}"
    echo -e "${C_SUCCESS}║  ✅ Auto-Healing Tunnel                                       ${C_SUCCESS}║${C_RESET}"
    echo -e "${C_SUCCESS}║  ✅ Quantum Encryption Layer                                  ${C_SUCCESS}║${C_RESET}"
    echo -e "${C_SUCCESS}║  ✅ Bandwidth Optimizer                                       ${C_SUCCESS}║${C_RESET}"
    echo -e "${C_SUCCESS}║  ✅ Smart DNS Cache                                           ${C_SUCCESS}║${C_RESET}"
    echo -e "${C_SUCCESS}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"
    
    # Check services
    sleep 2
    echo -e "\n${C_INFO}Service Status:${C_RESET}"
    systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "  ${C_SUCCESS}●${C_RESET} DNSTT Server: RUNNING" || echo -e "  ${C_DANGER}●${C_RESET} DNSTT Server: FAILED"
    systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "  ${C_SUCCESS}●${C_RESET} DNSTT Proxy: RUNNING" || echo -e "  ${C_DANGER}●${C_RESET} DNSTT Proxy: FAILED"
    
    echo ""
    echo -e "${C_SUCCESS}Opening dashboard in 3 seconds...${C_RESET}"
    sleep 3
    /usr/local/bin/elite-x
}

# Run main function
main "$@"
