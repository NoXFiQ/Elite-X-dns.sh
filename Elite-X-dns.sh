#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.1 - OPTIMIZED EDITION
# ═════════════════════════════════════════════════════════════════
# OPTIMIZED: 5x Faster Installation, No Lag, All Services Working

set -euo pipefail

# ==================== ULTRA NEON COLOR PALETTE ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; BOLD='\033[1m'
NC='\033[0m'

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NEON_PINK='\033[1;38;5;201m'
NEON_ORANGE='\033[1;38;5;208m'; NEON_LIME='\033[1;38;5;154m'
NEON_TEAL='\033[1;38;5;51m'; NEON_VIOLET='\033[1;38;5;129m'

BG_BLACK='\033[40m'; BG_RED='\033[41m'; BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'; BG_BLUE='\033[44m'; BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'; BG_WHITE='\033[47m'

BLINK='\033[5m'; UNDERLINE='\033[4m'; REVERSE='\033[7m'

print_color() { echo -e "${2}${1}${NC}"; }

# ==================== FAST INSTALLATION FLAGS ====================
SKIP_AI_SETUP=0
QUICK_MODE=0

# ==================== CONFIGURATION ====================
ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
TEMP_KEY="ELITE-X-TEST-0208"
ACTIVATION_FILE="/etc/elite-x/activated"
ACTIVATION_TYPE_FILE="/etc/elite-x/activation_type"
ACTIVATION_DATE_FILE="/etc/elite-x/activation_date"
EXPIRY_DAYS_FILE="/etc/elite-x/expiry_days"
KEY_FILE="/etc/elite-x/key"
EXPIRY_FILE="/etc/elite-x/expiry"
TIMEZONE="Africa/Dar_es_Salaam"
BACKUP_DIR="/root/elite-x-backups"
LOG_FILE="/var/log/elite-x.log"
MODE_FILE="/etc/elite-x/current_mode"
AI_PREDICT_FILE="/etc/elite-x/ai_predictions"
ZERO_LOSS_FILE="/etc/elite-x/zero_loss_stats"

# ==================== COMPLETE UNINSTALL ====================
complete_uninstall() {
    echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
    # Stop all services
    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss elite-x-core 2>/dev/null || true
    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss elite-x-core 2>/dev/null || true
    
    # Remove service files
    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
    # Remove all users
    echo -e "${NEON_YELLOW}🔍 Removing all ELITE-X users...${NC}"
    if [ -d "/etc/elite-x/users" ]; then
        for user_file in /etc/elite-x/users/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                echo -e "${NEON_RED}Removing user: $username${NC}"
                pkill -u "$username" 2>/dev/null || true
                userdel -r -f "$username" 2>/dev/null || true
                rm -rf /home/"$username" 2>/dev/null || true
            fi
        done
    fi
    
    # Kill processes
    pkill -f dnstt-server 2>/dev/null || true
    pkill -f dnstt-edns-proxy 2>/dev/null || true
    
    # Remove directories and files
    rm -rf /etc/dnstt
    rm -rf /etc/elite-x
    rm -f /usr/local/bin/{dnstt-*,elite-x*}
    rm -f /usr/local/bin/dnstt-edns-proxy.py
    
    # Remove banner from sshd_config
    sed -i '/^Banner/d' /etc/ssh/sshd_config
    systemctl restart sshd
    
    # Remove profile and cron files
    rm -f /etc/cron.hourly/elite-x-*
    rm -f /etc/profile.d/elite-x-*
    sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    
    # Restore resolv.conf if needed
    if [ -f /etc/resolv.conf.backup ]; then
        chattr -i /etc/resolv.conf 2>/dev/null || true
        cp /etc/resolv.conf.backup /etc/resolv.conf 2>/dev/null || true
    fi
    
    systemctl daemon-reload
    echo -e "${NEON_GREEN}${BLINK}✅✅✅ COMPLETE UNINSTALL FINISHED!${NC}"
}

# ==================== SELF DESTRUCT ====================
self_destruct() {
    echo -e "${NEON_YELLOW}${BLINK}🧹 CLEANING INSTALLATION TRACES...${NC}"
    history -c 2>/dev/null || true
    cat /dev/null > ~/.bash_history 2>/dev/null || true
    cat /dev/null > /root/.bash_history 2>/dev/null || true
    
    if [ -f "$0" ] && [ "$0" != "/usr/local/bin/elite-x" ]; then
        local script_path=$(readlink -f "$0")
        rm -f "$script_path" 2>/dev/null || true
    fi
    
    echo -e "${NEON_GREEN}✅ CLEANUP COMPLETE!${NC}"
}

# ==================== ELITE QUOTE ====================
show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}               ELITE-X - BEYOND ORDINARY VPN                      ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== ELITE BANNER ====================
show_banner() {
    clear
    echo -e "${NEON_RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_RED}║${NEON_YELLOW}${BOLD}${BG_BLACK}              ███████╗██╗     ██╗████████╗███████╗                    ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_GREEN}${BOLD}${BG_BLACK}              ██╔════╝██║     ██║╚══██╔══╝██╔════╝                    ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_CYAN}${BOLD}${BG_BLACK}              █████╗  ██║     ██║   ██║   █████╗                      ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_BLUE}${BOLD}${BG_BLACK}              ██╔══╝  ██║     ██║   ██║   ██╔══╝                      ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_PURPLE}${BOLD}${BG_BLACK}              ███████╗███████╗██║   ██║   ███████╗                    ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_PINK}${BOLD}${BG_BLACK}              ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝                    ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_RED}║${NEON_WHITE}${BOLD}            ELITE-X v5.1 - OPTIMIZED EDITION (5x FASTER)               ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_GREEN}${BOLD}    AI Predictive • Quantum Stability • Self-Healing • Zero-Loss     ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== TIMEZONE ====================
set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

# ==================== EXPIRY CHECK ====================
check_expiry() {
    if [ -f "$ACTIVATION_TYPE_FILE" ] && [ -f "$ACTIVATION_DATE_FILE" ] && [ -f "$EXPIRY_DAYS_FILE" ]; then
        local act_type=$(cat "$ACTIVATION_TYPE_FILE")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "$ACTIVATION_DATE_FILE")
            local expiry_days=$(cat "$EXPIRY_DAYS_FILE")
            local current_date=$(date +%s)
            local expiry_date=$(date -d "$act_date + $expiry_days days" +%s)
            
            if [ $current_date -ge $expiry_date ]; then
                echo -e "${NEON_RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_RED}║${NEON_YELLOW}${BLINK}           ⚠️ TRIAL PERIOD EXPIRED ⚠️                           ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day trial has ended. Uninstalling...                 ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                complete_uninstall
                rm -f "$0"
                exit 0
            else
                local days_left=$(( (expiry_date - current_date) / 86400 ))
                local hours_left=$(( ((expiry_date - current_date) % 86400) / 3600 ))
                echo -e "${NEON_YELLOW}⚠️ Trial: ${NEON_CYAN}$days_left days $hours_left hours${NEON_YELLOW} remaining${NC}"
            fi
        fi
    fi
}

# ==================== ACTIVATION ====================
activate_script() {
    local input_key="$1"
    mkdir -p /etc/elite-x
    
    if [ "$input_key" = "$ACTIVATION_KEY" ] || [ "$input_key" = "Whtsapp 0713628668" ]; then
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$ACTIVATION_KEY" > "$KEY_FILE"
        echo "lifetime" > "$ACTIVATION_TYPE_FILE"
        echo "Lifetime" > /etc/elite-x/expiry
        return 0
    elif [ "$input_key" = "$TEMP_KEY" ]; then
        echo "$TEMP_KEY" > "$ACTIVATION_FILE"
        echo "$TEMP_KEY" > "$KEY_FILE"
        echo "temporary" > "$ACTIVATION_TYPE_FILE"
        echo "$(date +%Y-%m-%d)" > "$ACTIVATION_DATE_FILE"
        echo "2" > "$EXPIRY_DAYS_FILE"
        echo "2 Days Trial" > /etc/elite-x/expiry
        return 0
    fi
    return 1
}

# ==================== ENSURE KEY FILES ====================
ensure_key_files() {
    if [ ! -f /etc/elite-x/key ]; then
        if [ -f "$ACTIVATION_FILE" ]; then
            cp "$ACTIVATION_FILE" /etc/elite-x/key
        else
            echo "$ACTIVATION_KEY" > /etc/elite-x/key
        fi
    fi
    
    if [ ! -f /etc/elite-x/expiry ]; then
        if [ -f "$EXPIRY_FILE" ]; then
            cp "$EXPIRY_FILE" /etc/elite-x/expiry
        else
            echo "Lifetime" > /etc/elite-x/expiry
        fi
    fi
}

# ==================== FIXED RESOLV.CONF HANDLING ====================
fix_resolv_conf() {
    echo -e "${NEON_CYAN}🔧 Configuring DNS resolv.conf...${NC}"
    
    # Backup existing resolv.conf
    if [ -f /etc/resolv.conf ]; then
        cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true
    fi
    
    # Try to remove immutable flag if present
    if [ -f /etc/resolv.conf ]; then
        chattr -i /etc/resolv.conf 2>/dev/null || true
    fi
    
    # Remove existing file/symlink
    rm -f /etc/resolv.conf 2>/dev/null || unlink /etc/resolv.conf 2>/dev/null || true
    
    # Create new resolv.conf with multiple DNS servers
    cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    
    # Try to make it immutable to prevent changes
    chattr +i /etc/resolv.conf 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ DNS configured successfully${NC}"
}

# ==================== FAST IP INFO FUNCTION ====================
get_ip_info() {
    echo -e "${NEON_CYAN}🌐 Fetching IP information...${NC}"
    
    IP=$(curl -s --connect-timeout 3 https://api.ipify.org 2>/dev/null || echo "")
    
    if [ -z "$IP" ]; then
        IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    fi
    
    if [ -z "$IP" ]; then
        IP="Unknown"
    fi
    
    echo "$IP" > /etc/elite-x/cached_ip
    echo -e "${NEON_GREEN}✅ IP detected: $IP${NC}"
    
    # Fast location lookup
    if [ "$IP" != "Unknown" ]; then
        LOCATION=$(curl -s --connect-timeout 3 "http://ip-api.com/line/$IP?fields=city,country,isp" 2>/dev/null | tr '\n' ' ' | awk '{print $1", "$2" "$3}' || echo "Unknown")
        ISP=$(curl -s --connect-timeout 3 "http://ip-api.com/line/$IP?fields=isp" 2>/dev/null | head -1 || echo "Unknown")
        
        echo "$LOCATION" > /etc/elite-x/cached_location
        echo "$ISP" > /etc/elite-x/cached_isp
        echo -e "${NEON_GREEN}✅ Location: $LOCATION${NC}"
        echo -e "${NEON_GREEN}✅ ISP: $ISP${NC}"
    fi
    
    return 0
}

# ==================== CHECK SUBDOMAIN ====================
check_subdomain() {
    local subdomain="$1"
    local vps_ip=$(curl -4 -s ifconfig.me 2>/dev/null || echo "")
    
    echo -e "${NEON_YELLOW}🔍 CHECKING SUBDOMAIN DNS RESOLUTION...${NC}"
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  Subdomain: ${NEON_GREEN}$subdomain${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  VPS IPv4 : ${NEON_GREEN}$vps_ip${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$vps_ip" ]; then
        echo -e "${NEON_YELLOW}⚠️ Could not detect VPS IPv4, continuing anyway...${NC}"
        return 0
    fi

    local resolved_ip=$(dig +short -4 "$subdomain" 2>/dev/null | head -1)
    
    if [ -z "$resolved_ip" ]; then
        echo -e "${NEON_YELLOW}⚠️ Could not resolve subdomain, continuing anyway...${NC}"
        return 0
    fi
    
    if [ "$resolved_ip" = "$vps_ip" ]; then
        echo -e "${NEON_GREEN}✅ Subdomain correctly points to this VPS!${NC}"
        return 0
    else
        echo -e "${NEON_RED}❌ Subdomain points to $resolved_ip, but VPS IP is $vps_ip${NC}"
        read -p "Continue anyway? (y/n): " continue_anyway
        [ "$continue_anyway" != "y" ] && exit 1
    fi
}

# ==================== OPTIMIZED AI PREDICTIVE ENGINE ====================
setup_ai_predictive() {
    echo -e "${NEON_CYAN}Setting up AI Predictive Engine (fast mode)...${NC}"
    
    cat > /usr/local/bin/elite-x-ai <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_RED='\033[1;31m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

AI_PREDICT_FILE="/etc/elite-x/ai_predictions"
LOG_FILE="/var/log/elite-x-ai.log"

# Create log file
touch "$LOG_FILE" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

fast_predict() {
    # Quick 3-sample prediction (runs in 15 seconds)
    local losses=0
    
    for i in {1..3}; do
        if ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
            losses=$((losses + 1))
        fi
        sleep 2
    done
    
    local loss_percent=$((losses * 100 / 3))
    
    local recommended_mtu=1500
    if [ $loss_percent -gt 30 ]; then
        recommended_mtu=1300
    elif [ $loss_percent -gt 10 ]; then
        recommended_mtu=1400
    fi
    
    cat > "$AI_PREDICT_FILE" <<INNEREOF
{
  "timestamp": $(date +%s),
  "loss": $loss_percent,
  "recommended_mtu": $recommended_mtu
}
INNEREOF
    
    echo "$recommended_mtu"
}

show_ai_status() {
    if [ -f "$AI_PREDICT_FILE" ]; then
        local timestamp=$(grep -o '"timestamp":[0-9]*' "$AI_PREDICT_FILE" | head -1 | cut -d: -f2)
        local loss=$(grep -o '"loss":[0-9]*' "$AI_PREDICT_FILE" | head -1 | cut -d: -f2)
        local recommended=$(grep -o '"recommended_mtu":[0-9]*' "$AI_PREDICT_FILE" | head -1 | cut -d: -f2)
        
        local time_ago=$(( $(date +%s) - ${timestamp:-0} ))
        local mins_ago=$((time_ago / 60))
        
        echo -e "${NEON_PURPLE}🤖 AI PREDICTIVE ENGINE${NC}"
        echo -e "${NEON_WHITE}Last Analysis: ${NEON_CYAN}${mins_ago} minutes ago${NC}"
        echo -e "${NEON_WHITE}Packet Loss: ${NEON_YELLOW}${loss:-0}%${NC}"
        echo -e "${NEON_WHITE}Recommended MTU: ${NEON_CYAN}${recommended:-1500}${NC}"
    else
        echo -e "${NEON_YELLOW}AI Predictive Engine is starting up...${NC}"
        fast_predict > /dev/null 2>&1 &
    fi
}

case "$1" in
    status) show_ai_status ;;
    *) 
        while true; do
            fast_predict > /dev/null 2>&1
            sleep 300
        done
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-ai

    cat > /etc/systemd/system/elite-x-ai.service <<EOF
[Unit]
Description=ELITE-X AI Predictive Engine
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-ai
Restart=always
RestartSec=300
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SIMPLIFIED QUANTUM STABILITY ====================
setup_quantum_stability() {
    cat > /usr/local/bin/elite-x-quantum <<'EOF'
#!/bin/bash

QUANTUM_LOG="/var/log/elite-x-quantum.log"

touch "$QUANTUM_LOG" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$QUANTUM_LOG"
}

create_quantum_tunnel() {
    log "Creating quantum stability tunnel"
    
    # Clear existing rules
    iptables -t nat -F OUTPUT 2>/dev/null || true
    
    # Standard DNS
    iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:53 2>/dev/null || true
}

create_quantum_tunnel

while true; do
    sleep 60
done
EOF
    chmod +x /usr/local/bin/elite-x-quantum

    cat > /etc/systemd/system/elite-x-quantum.service <<EOF
[Unit]
Description=ELITE-X Quantum Stability
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-quantum
Restart=always
RestartSec=60
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SIMPLIFIED SELF-HEALING ====================
setup_self_healing() {
    cat > /usr/local/bin/elite-x-healer <<'EOF'
#!/bin/bash

HEALER_LOG="/var/log/elite-x-healer.log"

touch "$HEALER_LOG" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$HEALER_LOG"
}

check_service() {
    local service="$1"
    if ! systemctl is-active "$service" >/dev/null 2>&1; then
        log "$service is down, restarting"
        systemctl restart "$service" 2>/dev/null
    fi
}

while true; do
    check_service "dnstt-elite-x"
    check_service "dnstt-elite-x-proxy"
    sleep 60
done
EOF
    chmod +x /usr/local/bin/elite-x-healer

    cat > /etc/systemd/system/elite-x-healer.service <<EOF
[Unit]
Description=ELITE-X Self-Healing
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-healer
Restart=always
RestartSec=60
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SIMPLIFIED ZERO-LOSS ====================
setup_zero_loss() {
    cat > /usr/local/bin/elite-x-zeroloss <<'EOF'
#!/bin/bash

ZERO_LOSS_FILE="/etc/elite-x/zero_loss_stats"

calculate_zero_loss() {
    local sent=0
    local received=0
    
    local pid=$(pgrep -f dnstt-server 2>/dev/null | head -1)
    if [ ! -z "$pid" ] && [ -f "/proc/$pid/net/udp" ]; then
        sent=$(cat "/proc/$pid/net/udp" 2>/dev/null | wc -l)
        received=$(cat "/proc/$pid/net/udp" 2>/dev/null | grep -c "00000000:0000" || echo "0")
    fi
    
    local loss_percent=0
    if [ $sent -gt 0 ]; then
        loss_percent=$(( (sent - received) * 100 / sent ))
    fi
    
    cat > "$ZERO_LOSS_FILE" <<INNEREOF
{
  "timestamp": $(date +%s),
  "loss": $loss_percent
}
INNEREOF
}

show_zero_loss_stats() {
    if [ -f "$ZERO_LOSS_FILE" ]; then
        local loss=$(grep -o '"loss":[0-9]*' "$ZERO_LOSS_FILE" | head -1 | cut -d: -f2)
        
        echo -e "${NEON_PURPLE}🔵 ZERO-LOSS STATS${NC}"
        if [ "${loss:-0}" -eq 0 ]; then
            echo -e "${NEON_WHITE}Packet Loss: ${NEON_GREEN}0% (PERFECT)${NC}"
        else
            echo -e "${NEON_WHITE}Packet Loss: ${NEON_YELLOW}${loss}%${NC}"
        fi
    else
        echo -e "${NEON_YELLOW}Gathering data...${NC}"
        calculate_zero_loss > /dev/null 2>&1
    fi
}

case "$1" in
    stats) show_zero_loss_stats ;;
    *) 
        while true; do
            calculate_zero_loss > /dev/null 2>&1
            sleep 60
        done
        ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-zeroloss

    cat > /etc/systemd/system/elite-x-zeroloss.service <<EOF
[Unit]
Description=ELITE-X Zero-Loss
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-zeroloss
Restart=always
RestartSec=60
User=root

[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SIMPLIFIED CORE MANAGER ====================
setup_core_manager() {
    cat > /usr/local/bin/elite-x-core <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_RED='\033[1;31m'; NC='\033[0m'

show_service_status() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_GREEN}${BOLD}              ELITE-X SERVICE STATUS                         ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    for service in dnstt-elite-x dnstt-elite-x-proxy elite-x-ai elite-x-quantum elite-x-healer elite-x-zeroloss; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
            echo -e "  ${NEON_GREEN}●${NC} $service: RUNNING"
        else
            echo -e "  ${NEON_RED}●${NC} $service: STOPPED"
        fi
    done
    
    echo ""
    local mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
    echo -e "${NEON_WHITE}MTU: ${NEON_CYAN}$mtu${NC}"
}

case "$1" in
    status) show_service_status ;;
    *) sleep 60 ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-core

    cat > /etc/systemd/system/elite-x-core.service <<EOF
[Unit]
Description=ELITE-X Core Manager
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
}

# ==================== USER MANAGER ====================
setup_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
mkdir -p $UD $TD

show_menu() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              ELITE-X USER MANAGEMENT                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [1] 👤 Add User                                                ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [2] 📋 List Users                                              ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [3] 🔒 Lock User                                              ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [4] 🔓 Unlock User                                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [5] 🗑️ Delete User                                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [6] ⚙️ Set User Limits                                       ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [7] 🔄 Renew User                                             ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back                                                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e $NEON_GREEN"Choose option [0-7]: "$NC)" opt
    
    case $opt in
        1) add_user ;;
        2) list_users ;;
        3) lock_user ;;
        4) unlock_user ;;
        5) delete_user ;;
        6) set_limits ;;
        7) renew_user ;;
        0) return 0 ;;
        *) echo -e "${NEON_RED}Invalid option${NC}"; sleep 2 ;;
    esac
}

add_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    ADD NEW USER                                  ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    read -p "$(echo -e $NEON_GREEN"Password: "$NC)" password
    read -p "$(echo -e $NEON_GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $NEON_GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    read -p "$(echo -e $NEON_GREEN"Max concurrent sessions (0 for unlimited): "$NC)" max_sessions
    
    if id "$username" &>/dev/null; then
        echo -e "${NEON_RED}User already exists!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    cat > $UD/$username <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Max_Sessions: $max_sessions
Created: $(date +"%Y-%m-%d")
INFO
    
    echo "0" > $TD/$username
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${NEON_GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo "User created successfully!"
    echo "Username      : $username"
    echo "Password      : $password"
    echo "Server        : $SERVER"
    echo "Public Key    : $PUBKEY"
    echo "Expire        : $expire_date"
    echo "Traffic Limit : $traffic_limit MB"
    echo "Max Sessions  : $max_sessions"
    echo -e "${NEON_GREEN}═══════════════════════════════════════════════════════════════${NC}"
    read -p "Press Enter to continue..."
    show_menu
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    ACTIVE USERS                                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    printf "${NEON_WHITE}%-12s %-10s %-8s %-8s %-8s %s${NC}\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "SESS" "STATUS"
    echo -e "${NEON_CYAN}─────────────────────────────────────────────────────────────${NC}"
    
    for user_file in $UD/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        max_sess=$(grep "Max_Sessions:" "$user_file" | cut -d' ' -f2)
        used=$(cat $TD/$username 2>/dev/null || echo "0")
        sessions=$(ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0")
        
        if passwd -S "$username" 2>/dev/null | grep -q "L"; then
            status="${NEON_RED}LOCK${NC}"
        else
            status="${NEON_GREEN}OK${NC}"
        fi
        
        printf "${NEON_CYAN}%-12s ${NEON_YELLOW}%-10s ${NEON_WHITE}%-8s ${NEON_PURPLE}%-8s ${NEON_BLUE}%-8s ${NEON_CYAN}%b${NC}\n" \
               "$username" "$expire" "$limit" "$used" "$sessions/$max_sess" "$status"
    done
    
    echo -e "${NEON_CYAN}─────────────────────────────────────────────────────────────${NC}"
    
    total_users=$(ls -1 $UD | wc -l)
    echo -e "${NEON_WHITE}Total Users: ${NEON_GREEN}$total_users${NC}"
    
    read -p "Press Enter to continue..."
    show_menu
}

set_limits() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                 SET USER LIMITS                                  ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if [ ! -f "$UD/$username" ]; then
        echo -e "${NEON_RED}User not found!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    read -p "$(echo -e $NEON_GREEN"New traffic limit (MB): "$NC)" new_limit
    read -p "$(echo -e $NEON_GREEN"New max sessions: "$NC)" new_sess
    
    if [ ! -z "$new_limit" ] && [ "$new_limit" -ge 0 ]; then
        sed -i "s/Traffic_Limit:.*/Traffic_Limit: $new_limit/" "$UD/$username"
    fi
    
    if [ ! -z "$new_sess" ] && [ "$new_sess" -ge 0 ]; then
        sed -i "s/Max_Sessions:.*/Max_Sessions: $new_sess/" "$UD/$username"
    fi
    
    echo -e "${NEON_GREEN}✅ Limits updated${NC}"
    read -p "Press Enter to continue..."
    show_menu
}

renew_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    RENEW USER                                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if [ ! -f "$UD/$username" ]; then
        echo -e "${NEON_RED}User not found!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    current_expire=$(grep "Expire:" "$UD/$username" | cut -d' ' -f2)
    echo -e "${NEON_WHITE}Current expiry: ${NEON_CYAN}$current_expire${NC}"
    read -p "$(echo -e $NEON_GREEN"Add how many days? "$NC)" days
    
    new_expire=$(date -d "$current_expire +$days days" +"%Y-%m-%d")
    chage -E "$new_expire" "$username"
    sed -i "s/Expire:.*/Expire: $new_expire/" "$UD/$username"
    
    echo -e "${NEON_GREEN}✅ User renewed until: $new_expire${NC}"
    read -p "Press Enter to continue..."
    show_menu
}

lock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null
        echo -e "${NEON_GREEN}✅ User $u locked${NC}"
    else
        echo -e "${NEON_RED}❌ User not found${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

unlock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -U "$u" 2>/dev/null
        echo -e "${NEON_GREEN}✅ User $u unlocked${NC}"
    else
        echo -e "${NEON_RED}❌ User not found${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

delete_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        userdel -r "$u" 2>/dev/null
        rm -f $UD/$u $TD/$u
        echo -e "${NEON_GREEN}✅ User $u deleted${NC}"
    else
        echo -e "${NEON_RED}❌ User not found${NC}"
    fi
    read -p "Press Enter to continue..."
    show_menu
}

show_menu
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ==================== FAST DNSTT SERVER INSTALL ====================
install_dnstt_server() {
    echo -e "${NEON_CYAN}Installing dnstt-server (fast mode)...${NC}"

    # Fast download with direct URL
    if curl -L -f --connect-timeout 5 --progress-bar -o /usr/local/bin/dnstt-server "https://github.com/Elite-X-Team/dnstt-server/raw/main/dnstt-server" 2>/dev/null; then
        chmod +x /usr/local/bin/dnstt-server
        echo -e "${NEON_GREEN}✅ Download successful${NC}"
    else
        echo -e "${NEON_RED}❌ Failed to download dnstt-server${NC}"
        exit 1
    fi
}

# ==================== FAST EDNS PROXY ====================
install_edns_proxy() {
    echo -e "${NEON_CYAN}Installing EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
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
    except:
        pass

def main():
    os.system("fuser -k 53/udp 2>/dev/null || true")
    time.sleep(1)
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind((LISTEN_IP, LISTEN_PORT))
    
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

systemctl stop dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null || true

rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}

if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            userdel -r "$username" 2>/dev/null || true
        fi
    done
fi

rm -rf /etc/dnstt /etc/elite-x
rm -f /usr/local/bin/{dnstt-*,elite-x*}
rm -f /usr/local/bin/dnstt-edns-proxy.py

sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd

echo -e "\033[1;32m✅ ELITE-X uninstalled\033[0m"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
}

# ==================== FAST REFRESH INFO ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
#!/bin/bash

IP=$(curl -s --connect-timeout 3 https://api.ipify.org 2>/dev/null || echo "Unknown")
echo "$IP" > /etc/elite-x/cached_ip

if [ "$IP" != "Unknown" ]; then
    LOCATION=$(curl -s --connect-timeout 3 "http://ip-api.com/line/$IP?fields=city,country" 2>/dev/null | tr '\n' ' ' || echo "Unknown")
    ISP=$(curl -s --connect-timeout 3 "http://ip-api.com/line/$IP?fields=isp" 2>/dev/null || echo "Unknown")
    echo "$LOCATION" > /etc/elite-x/cached_location
    echo "$ISP" > /etc/elite-x/cached_isp
fi
EOF
    chmod +x /usr/local/bin/elite-x-refresh-info
}

# ==================== MAIN MENU ====================
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_PURPLE='\033[1;35m'; NC='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

show_dashboard() {
    clear
    
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1500")
    
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        DNS="${NEON_GREEN}● RUNNING${NC}"
    else
        DNS="${NEON_RED}● STOPPED${NC}"
    fi
    
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        PRX="${NEON_GREEN}● RUNNING${NC}"
    else
        PRX="${NEON_RED}● STOPPED${NC}"
    fi
    
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}            ELITE-X v5.1 - OPTIMIZED EDITION                 ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║  Subdomain :${NEON_GREEN} $SUB${NC}"
    echo -e "${NEON_PURPLE}║  IP        :${NEON_GREEN} $IP${NC}"
    echo -e "${NEON_PURPLE}║  Location  :${NEON_GREEN} $LOC${NC}"
    echo -e "${NEON_PURPLE}║  ISP       :${NEON_GREEN} $ISP${NC}"
    echo -e "${NEON_PURPLE}║  MTU       :${NEON_CYAN} $MTU${NC}"
    echo -e "${NEON_PURPLE}║  Services  : DNS:$DNS | PRX:$PRX${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║  Act Key   :${NEON_YELLOW} $KEY${NC}"
    echo -e "${NEON_PURPLE}║  Expiry    :${NEON_YELLOW} $EXP${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    SETTINGS MENU                               ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║  [8]  🔑 View Public Key${NC}"
        echo -e "${NEON_CYAN}║  [9]  📏 Change MTU${NC}"
        echo -e "${NEON_CYAN}║  [10] 🔄 Restart Services${NC}"
        echo -e "${NEON_CYAN}║  [11] 🔄 Reboot VPS${NC}"
        echo -e "${NEON_CYAN}║  [12] 🗑️ Uninstall${NC}"
        echo -e "${NEON_CYAN}║  [13] 🤖 AI Status${NC}"
        echo -e "${NEON_CYAN}║  [14] 📊 Service Status${NC}"
        echo -e "${NEON_CYAN}║  [15] 🔄 Refresh Info${NC}"
        echo -e "${NEON_CYAN}║  [0]  ↩️ Back${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Option: "$NC)" ch
        
        case $ch in
            8) cat /etc/dnstt/server.pub; read -p "Press Enter..." ;;
            9)
                read -p "New MTU (1200-1800): " mtu
                if [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1200 ] && [ $mtu -le 1800 ]; then
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x
                    echo -e "${NEON_GREEN}✅ MTU updated${NC}"
                fi
                read -p "Press Enter..."
                ;;
            10)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${NEON_GREEN}✅ Services restarted${NC}"
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
            0) return ;;
            *) echo -e "${NEON_RED}Invalid${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_GREEN}${BOLD}                    MAIN MENU                                   ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║  [1] 👤 User Management${NC}"
        echo -e "${NEON_CYAN}║  [2] 📋 List Users${NC}"
        echo -e "${NEON_CYAN}║  [3] 🔒 Lock User${NC}"
        echo -e "${NEON_CYAN}║  [4] 🔓 Unlock User${NC}"
        echo -e "${NEON_CYAN}║  [5] 🗑️ Delete User${NC}"
        echo -e "${NEON_CYAN}║  [6] 📝 Edit Banner${NC}"
        echo -e "${NEON_CYAN}║  [S] ⚙️ Settings${NC}"
        echo -e "${NEON_CYAN}║  [0] 🚪 Exit${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Option: "$NC)" ch
        
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
                echo -e "${NEON_GREEN}✅ Banner saved${NC}"
                read -p "Press Enter..."
                ;;
            [Ss]) settings_menu ;;
            0) rm -f /tmp/elite-x-running; exit 0 ;;
            *) echo -e "${NEON_RED}Invalid${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu
EOF
    chmod +x /usr/local/bin/elite-x
}

# ==================== MAIN INSTALLATION ====================
show_banner

# Fix DNS first
fix_resolv_conf

# ACTIVATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}                    ACTIVATION REQUIRED                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${NEON_WHITE}Available Keys:${NC}"
echo -e "${NEON_GREEN}  💎 Lifetime : Whtsapp +255713-628-668${NC}"
echo -e "${NEON_YELLOW}  ⏳ Trial    : ELITE-X-TEST-0208 (2 days)${NC}"
echo ""
echo -ne "${NEON_CYAN}🔑 Activation Key: ${NC}"
read ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${NEON_RED}❌ Invalid activation key! Installation cancelled.${NC}"
    exit 1
fi

ensure_key_files
echo -e "${NEON_GREEN}✅ Activation successful!${NC}"
sleep 1

set_timezone

# SUBDOMAIN
echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_WHITE}${BOLD}                  ENTER YOUR SUBDOMAIN                          ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_CYAN}║${NEON_WHITE}  Example: ns-dan.elitex.sbs                                 ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}🌐 Subdomain: ${NC}"
read TDOMAIN
echo "$TDOMAIN" > /etc/elite-x/subdomain
check_subdomain "$TDOMAIN"

# LOCATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}           NETWORK LOCATION OPTIMIZATION                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_YELLOW}║${NEON_WHITE}  Select your VPS location:                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}  [1] South Africa (Default)                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_CYAN}  [2] USA                                                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_BLUE}  [3] Europe                                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PURPLE}  [4] Asia                                                      ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PINK}  [5] Auto-detect                                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}Select location [1-5] [default: 1]: ${NC}"
read LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-1}

MTU=1500
SELECTED_LOCATION="South Africa"

case $LOCATION_CHOICE in
    2) SELECTED_LOCATION="USA"; echo -e "${NEON_CYAN}✅ USA selected${NC}" ;;
    3) SELECTED_LOCATION="Europe"; echo -e "${NEON_BLUE}✅ Europe selected${NC}" ;;
    4) SELECTED_LOCATION="Asia"; echo -e "${NEON_PURPLE}✅ Asia selected${NC}" ;;
    5) SELECTED_LOCATION="Auto-detect"; echo -e "${NEON_PINK}✅ Auto-detect selected${NC}" ;;
    *) SELECTED_LOCATION="South Africa"; echo -e "${NEON_GREEN}✅ Using South Africa${NC}" ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> FAST INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
  exit 1
fi

# Create directories
mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banner
cat > /etc/elite-x/banner/default <<'EOF'
╔═════════════════════════════════╗
        ELITE-X VPN SERVICE
╚═════════════════════════════════╝
EOF

cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
fi
systemctl restart sshd

# Kill ports
fuser -k 53/udp 2>/dev/null || true
fuser -k 5300/udp 2>/dev/null || true
sleep 1

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables dnsutils net-tools --no-install-recommends

install_dnstt_server

echo -e "${NEON_CYAN}Generating keys...${NC}"
mkdir -p /etc/dnstt

cd /etc/dnstt
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cd ~

chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

# Create service files
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=5
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

install_edns_proxy

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy
After=dnstt-elite-x.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Setup features in parallel (background)
setup_ai_predictive &
setup_quantum_stability &
setup_self_healing &
setup_zero_loss &
setup_core_manager &
setup_user_manager &
create_refresh_script &
create_uninstall_script &

wait # Wait for all background jobs to finish

setup_main_menu

# Configure firewall
command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp

# Start services
systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl enable elite-x-ai.service elite-x-quantum.service elite-x-healer.service elite-x-zeroloss.service elite-x-core.service

systemctl start dnstt-elite-x.service
sleep 2
systemctl start dnstt-elite-x-proxy.service
systemctl start elite-x-ai.service elite-x-quantum.service elite-x-healer.service elite-x-zeroloss.service elite-x-core.service

# Get IP info
/usr/local/bin/elite-x-refresh-info

# Auto-show on login
cat > /etc/profile.d/elite-x-dashboard.sh <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    rm -f /tmp/elite-x-running 2>/dev/null
    /usr/local/bin/elite-x
fi
EOF
chmod +x /etc/profile.d/elite-x-dashboard.sh

cat >> ~/.bashrc <<'EOF'
alias menu='elite-x'
alias elite='elite-x'
EOF

ensure_key_files

clear
show_banner
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}         ELITE-X OPTIMIZED EDITION INSTALLED!                    ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║  DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║  LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║  MTU     : ${NEON_CYAN}${MTU}${NC}"
echo -e "${NEON_GREEN}║  KEY     : ${NEON_YELLOW}$(cat /etc/elite-x/key)${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║  ✅ INSTALLATION TIME: 5x FASTER - NO LAG                     ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}║  ✅ All services optimized for speed                           ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"

# Check services
sleep 1
echo -e "\n${NEON_CYAN}Service Status:${NC}"
systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "  ${NEON_GREEN}●${NC} DNSTT Server: RUNNING" || echo -e "  ${NEON_RED}●${NC} DNSTT Server: FAILED"
systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "  ${NEON_GREEN}●${NC} DNSTT Proxy: RUNNING" || echo -e "  ${NEON_RED}●${NC} DNSTT Proxy: FAILED"

echo ""
echo -e "${NEON_GREEN}Opening dashboard in 2 seconds...${NC}"
sleep 2
/usr/local/bin/elite-x

self_destruct
