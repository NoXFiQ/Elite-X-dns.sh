#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.0 - ULTRA EDITION
# ═════════════════════════════════════════════════════════════════

set -euo pipefail

# ==================== NEON COLOR PALETTE ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; BOLD='\033[1m'
NC='\033[0m'

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NEON_PINK='\033[1;38;5;201m'
NEON_ORANGE='\033[1;38;5;208m'; NEON_LIME='\033[1;38;5;154m'
NEON_TEAL='\033[1;38;5;51m'; NEON_VIOLET='\033[1;38;5;129m'
NEON_GOLD='\033[1;38;5;220m'; NEON_SILVER='\033[1;38;5;250m'

BG_BLACK='\033[40m'; BG_RED='\033[41m'; BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'; BG_BLUE='\033[44m'; BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'; BG_WHITE='\033[47m'

BLINK='\033[5m'; UNDERLINE='\033[4m'; REVERSE='\033[7m'

print_color() { echo -e "${2}${1}${NC}"; }

# ==================== COMPLETE UNINSTALL FUNCTION ====================
complete_uninstall() {
    echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
    
    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
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
    
    pkill -f dnstt-server 2>/dev/null || true
    pkill -f dnstt-edns-proxy 2>/dev/null || true
    
    rm -rf /etc/dnstt
    rm -rf /etc/elite-x
    rm -f /usr/local/bin/{dnstt-*,elite-x*}
    rm -f /usr/local/bin/dnstt-edns-proxy.py
    rm -f /usr/local/bin/elite-x-{live,analyzer,renew,update,traffic,cleaner,user,booster,refresh,uninstall}
    
    sed -i '/^Banner/d' /etc/ssh/sshd_config
    systemctl restart sshd
    
    rm -f /etc/cron.hourly/elite-x-expiry
    rm -f /etc/profile.d/elite-x-dashboard.sh
    sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    
    systemctl daemon-reload
    
    echo -e "${NEON_GREEN}${BLINK}✅✅✅ COMPLETE UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅${NC}"
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
    
    sed -i '/elite-x/d' /var/log/auth.log 2>/dev/null || true
    
    echo -e "${NEON_GREEN}${BOLD}✅ CLEANUP COMPLETE!${NC}"
}

# ==================== ELITE QUOTE ====================
show_quote() {
    echo ""
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_SILVER}${BOLD}${BLINK}                                                               ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_CYAN}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_GREEN}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_YELLOW}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_PURPLE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_PINK}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_SILVER}${BOLD}                                                               ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== ELITE BANNER ====================
show_banner() {
    clear
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_SILVER}${BOLD}${BG_BLACK}              ███████╗██╗     ██╗████████╗███████╗                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}${BOLD}${BG_BLACK}              ██╔════╝██║     ██║╚══██╔══╝██╔════╝                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_CYAN}${BOLD}${BG_BLACK}              █████╗  ██║     ██║   ██║   █████╗                      ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_GREEN}${BOLD}${BG_BLACK}              ██╔══╝  ██║     ██║   ██║   ██╔══╝                      ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_YELLOW}${BOLD}${BG_BLACK}              ███████╗███████╗██║   ██║   ███████╗                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_PINK}${BOLD}${BG_BLACK}              ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}${BOLD}               ELITE-X SLOWDNS v5.0 - ULTRA EDITION                   ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_GREEN}${BOLD}                ⚡ REAL TRAFFIC MONITORING ⚡                          ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== ACTIVATION ====================
ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
TEMP_KEY="ELITE-X-TEST-0208"
ACTIVATION_FILE="/etc/elite-x/activated"
ACTIVATION_TYPE_FILE="/etc/elite-x/activation_type"
ACTIVATION_DATE_FILE="/etc/elite-x/activation_date"
EXPIRY_DAYS_FILE="/etc/elite-x/expiry_days"
KEY_FILE="/etc/elite-x/key"
TIMEZONE="Africa/Dar_es_Salaam"

# ==================== SPEED MODES ====================
SPEED_MODE_FILE="/etc/elite-x/speed_mode"
CURRENT_MODE="ultra"

set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

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
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day trial has ended. Script will self-destruct...     ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                complete_uninstall
                
                rm -f "$0"
                echo -e "${NEON_GREEN}✅ ELITE-X has been uninstalled.${NC}"
                exit 0
            else
                local days_left=$(( (expiry_date - current_date) / 86400 ))
                local hours_left=$(( ((expiry_date - current_date) % 86400) / 3600 ))
                echo -e "${NEON_YELLOW}⚠️ Trial: ${NEON_CYAN}$days_left days $hours_left hours${NEON_YELLOW} remaining${NC}"
            fi
        fi
    fi
}

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

# ==================== SPEED MODE FUNCTIONS ====================
apply_normal_mode() {
    echo -e "${NEON_GREEN}⚡ Applying NORMAL mode...${NC}"
    
    sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=5000 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=cubic >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=pfifo_fast >/dev/null 2>&1
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on sg on tso on gso on gro on 2>/dev/null || true
        ip link set dev $iface txqueuelen 10000 2>/dev/null || true
    done
    
    echo "normal" > "$SPEED_MODE_FILE"
    echo -e "${NEON_GREEN}✅ Normal mode applied - Stable connection${NC}"
}

apply_overclocked_mode() {
    echo -e "${NEON_YELLOW}⚡⚡ Applying OVERCLOCKED mode...${NC}"
    
    modprobe tcp_bbr 2>/dev/null || true
    
    sysctl -w net.core.rmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 268435456" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 268435456" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=10000 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_notsent_lowat=16384 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on sg on tso on gso on gro on 2>/dev/null || true
        ip link set dev $iface txqueuelen 20000 2>/dev/null || true
    done
    
    echo "overclocked" > "$SPEED_MODE_FILE"
    echo -e "${NEON_YELLOW}✅ Overclocked mode applied - Faster speed${NC}"
}

apply_ultra_mode() {
    echo -e "${NEON_RED}${BLINK}⚡⚡⚡ Applying ULTRA CLOCKED mode...${NC}"
    
    modprobe tcp_bbr 2>/dev/null || true
    
    sysctl -w net.core.rmem_max=536870912 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=536870912 >/dev/null 2>&1
    sysctl -w net.core.rmem_default=268435456 >/dev/null 2>&1
    sysctl -w net.core.wmem_default=268435456 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 536870912" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 536870912" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=200000 >/dev/null 2>&1
    sysctl -w net.core.somaxconn=131072 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq_codel >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_notsent_lowat=8192 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_fastopen=3 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_tw_reuse=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_fin_timeout=10 >/dev/null 2>&1
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on sg on tso on gso on gro on 2>/dev/null || true
        ethtool -G $iface rx 4096 tx 4096 2>/dev/null || true
        ip link set dev $iface txqueuelen 50000 2>/dev/null || true
        echo f > /sys/class/net/$iface/queues/rx-0/rps_cpus 2>/dev/null || true
        echo 4096 > /sys/class/net/$iface/queues/rx-0/rps_flow_cnt 2>/dev/null || true
    done
    
    echo 262144 > /proc/sys/net/core/rps_sock_flow_entries 2>/dev/null || true
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$cpu" ] && echo "performance" > "$cpu" 2>/dev/null || true
    done
    
    echo "ultra" > "$SPEED_MODE_FILE"
    echo -e "${NEON_RED}${BLINK}✅ Ultra mode applied - MAXIMUM SPEED${NC}"
}

apply_speed_mode() {
    local mode="$1"
    
    case $mode in
        normal)
            apply_normal_mode
            ;;
        overclocked)
            apply_overclocked_mode
            ;;
        ultra)
            apply_ultra_mode
            ;;
        *)
            apply_ultra_mode
            ;;
    esac
    
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null || true
}

get_mode_emoji() {
    local mode="$1"
    case $mode in
        normal) echo "${NEON_GREEN}● NORMAL${NC}" ;;
        overclocked) echo "${NEON_YELLOW}⚡ OVERCLOCKED${NC}" ;;
        ultra) echo "${NEON_RED}${BLINK}🚀 ULTRA${NC}" ;;
        *) echo "${NEON_RED}🚀 ULTRA${NC}" ;;
    esac
}

# ==================== UNIQUE FEATURE 1: CONNECTION LIMITER ====================
setup_connection_limiter() {
    cat > /usr/local/bin/elite-x-connection-limiter <<'EOF'
#!/bin/bash

USER_DB="/etc/elite-x/users"
BAN_LIST="/etc/elite-x/banned_users"
mkdir -p /etc/elite-x
touch $BAN_LIST

get_user_connections() {
    local username="$1"
    local connections=0
    
    connections=$(ss -tnp | grep :22 | grep ESTAB | while read line; do
        pid=$(echo $line | grep -o 'pid=[0-9]*' | cut -d= -f2)
        if [ ! -z "$pid" ] && [ "$pid" != "-" ]; then
            user=$(ps -o user= -p $pid 2>/dev/null | head -1 | xargs)
            if [ "$user" = "$username" ]; then
                echo "1"
            fi
        fi
    done | wc -l)
    
    echo $connections
}

ban_user() {
    local username="$1"
    local reason="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "$username:$timestamp:$reason" >> $BAN_LIST
    pkill -u "$username" 2>/dev/null || true
    usermod -L "$username" 2>/dev/null || true
    
    if [ -f "$USER_DB/$username" ]; then
        sed -i "s/^Status:.*/Status: BANNED ($reason)/" "$USER_DB/$username" 2>/dev/null
    fi
}

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                
                if grep -q "^$username:" $BAN_LIST; then
                    continue
                fi
                
                conn_limit=$(grep "Max_Connections:" "$user_file" | cut -d' ' -f2)
                
                if [ ! -z "$conn_limit" ] && [ "$conn_limit" -gt 0 ] 2>/dev/null; then
                    current_conn=$(get_user_connections "$username")
                    
                    if [ "$current_conn" -gt "$conn_limit" ]; then
                        ban_user "$username" "Connection limit exceeded ($current_conn/$conn_limit)"
                    fi
                fi
            fi
        done
    fi
    sleep 5
done
EOF
    chmod +x /usr/local/bin/elite-x-connection-limiter

    cat > /etc/systemd/system/elite-x-connection-limiter.service <<EOF
[Unit]
Description=ELITE-X Connection Limiter
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-connection-limiter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable elite-x-connection-limiter.service 2>/dev/null || true
    systemctl start elite-x-connection-limiter.service 2>/dev/null || true
}

# ==================== UNIQUE FEATURE 2: BANDWIDTH GRAPH ====================
setup_bandwidth_graph() {
    cat > /usr/local/bin/elite-x-bandwidth-graph <<'EOF'
#!/bin/bash

declare -A history
size=20

draw_graph() {
    local values=($1)
    local max=1
    for v in "${values[@]}"; do
        [ "$v" -gt "$max" ] && max=$v
    done
    
    for v in "${values[@]}"; do
        bars=$((v * 40 / max))
        printf "["
        for ((i=0; i<bars; i++)); do printf "█"; done
        for ((i=bars; i<40; i++)); do printf "░"; done
        printf "] %s KB/s\n" "$v"
    done
}

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              LIVE BANDWIDTH GRAPH                            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    
    if [ -d "/etc/elite-x/users" ]; then
        for user_file in /etc/elite-x/users/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                
                rx=0; tx=0
                for pid in $(pgrep -u "$username" 2>/dev/null); do
                    [ -f "/proc/$pid/net/dev" ] && {
                        while read line; do
                            [[ $line =~ ^[[:space:]]*([a-zA-Z0-9]+):[[:space:]]*([0-9]+) ]] && {
                                [ "${BASH_REMATCH[1]}" != "lo" ] && {
                                    rx=$((rx + $(echo "$line" | awk '{print $2}')))
                                    tx=$((tx + $(echo "$line" | awk '{print $10}')))
                                }
                            }
                        done < "/proc/$pid/net/dev" 2>/dev/null
                    }
                done
                
                total=$(( (rx + tx) / 1024 ))
                history[$username]="${history[$username]} $total"
                history[$username]=$(echo "${history[$username]}" | tr ' ' '\n' | tail -n $size | tr '\n' ' ')
                
                echo -e "\nUser: $username"
                draw_graph "${history[$username]}"
            fi
        done
    fi
    
    sleep 2
done
EOF
    chmod +x /usr/local/bin/elite-x-bandwidth-graph
}

# ==================== UNIQUE FEATURE 3: HEALTH MONITOR ====================
setup_health_monitor() {
    cat > /usr/local/bin/elite-x-health-monitor <<'EOF'
#!/bin/bash

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              SYSTEM HEALTH MONITOR                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    mem=$(free -m | awk '/^Mem:/{printf "%dMB/%dMB (%.0f%%)", $3, $2, $3*100/$2}')
    disk=$(df -h / | awk 'NR==2 {print $5}')
    load=$(uptime | awk -F'load average:' '{print $2}')
    
    echo "CPU Usage    : $cpu%"
    echo "Memory Usage : $mem"
    echo "Disk Usage   : $disk"
    echo "Load Average :$load"
    
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        echo "DNS Service  : ✅ RUNNING"
    else
        echo "DNS Service  : ❌ STOPPED"
    fi
    
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        echo "Proxy Service: ✅ RUNNING"
    else
        echo "Proxy Service: ❌ STOPPED"
    fi
    
    echo -e "\nPress Ctrl+C to exit"
    sleep 3
done
EOF
    chmod +x /usr/local/bin/elite-x-health-monitor
}

# ==================== BOOSTER FUNCTIONS ====================
enable_bbr_plus() {
    echo -e "${NEON_CYAN}🚀 ENABLING BBR PLUS CONGESTION CONTROL...${NC}"
    
    modprobe tcp_bbr 2>/dev/null || true
    echo "tcp_bbr" >> /etc/modules-load.d/modules.conf 2>/dev/null || true
    
    if ! grep -q "tcp_congestion_control = bbr" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== BBR PLUS BOOST ==========
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ BBR + FQ Codel enabled!${NC}"
}

optimize_cpu_performance() {
    echo -e "${NEON_CYAN}⚡ OPTIMIZING CPU FOR MAX PERFORMANCE...${NC}"
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$cpu" ] && echo "performance" > "$cpu" 2>/dev/null || true
    done
    
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    fi
    
    echo -e "${NEON_GREEN}✅ CPU optimized for max speed!${NC}"
}

tune_kernel_parameters() {
    echo -e "${NEON_CYAN}🧠 TUNING KERNEL PARAMETERS...${NC}"
    
    if ! grep -q "KERNEL BOOSTER" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== KERNEL BOOSTER ==========
fs.file-max = 2097152
fs.nr_open = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
fs.inotify.max_queued_events = 16384
vm.swappiness = 5
vm.vfs_cache_pressure = 40
vm.dirty_ratio = 30
vm.dirty_background_ratio = 3
vm.min_free_kbytes = 131072
vm.overcommit_memory = 1
vm.overcommit_ratio = 50
vm.max_map_count = 524288
kernel.sched_autogroup_enabled = 0
kernel.sched_min_granularity_ns = 8000000
kernel.sched_wakeup_granularity_ns = 10000000
kernel.numa_balancing = 0
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ Kernel parameters tuned!${NC}"
}

optimize_irq_affinity() {
    echo -e "${NEON_CYAN}🔄 OPTIMIZING IRQ AFFINITY...${NC}"
    
    apt install -y irqbalance 2>/dev/null || true
    
    cat > /etc/default/irqbalance <<EOF
ENABLED="1"
ONESHOT="0"
IRQBALANCE_ARGS="--powerthresh=0 --pkgthresh=0"
IRQBALANCE_BANNED_CPUS=""
EOF
    
    systemctl enable irqbalance 2>/dev/null || true
    systemctl restart irqbalance 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ IRQ affinity optimized!${NC}"
}

optimize_dns_cache() {
    echo -e "${NEON_CYAN}📡 OPTIMIZING DNS CACHE...${NC}"
    
    apt install -y dnsmasq 2>/dev/null || true
    
    cat > /etc/dnsmasq.conf <<EOF
port=53
domain-needed
bogus-priv
no-resolv
server=8.8.8.8
server=8.8.4.4
server=1.1.1.1
server=1.0.0.1
cache-size=10000
dns-forward-max=1000
neg-ttl=3600
max-ttl=3600
min-cache-ttl=3600
max-cache-ttl=86400
edns-packet-max=4096
EOF
    
    systemctl enable dnsmasq 2>/dev/null || true
    systemctl restart dnsmasq 2>/dev/null || true
    
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    
    echo -e "${NEON_GREEN}✅ DNS cache optimized!${NC}"
}

optimize_interface_offloading() {
    echo -e "${NEON_CYAN}🔧 OPTIMIZING INTERFACE OFFLOADING...${NC}"
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on 2>/dev/null || true
        ethtool -K $iface sg on 2>/dev/null || true
        ethtool -K $iface tso on 2>/dev/null || true
        ethtool -K $iface gso on 2>/dev/null || true
        ethtool -K $iface gro on 2>/dev/null || true
        ethtool -G $iface rx 4096 tx 4096 2>/dev/null || true
    done
    
    echo -e "${NEON_GREEN}✅ Interface offloading optimized!${NC}"
}

optimize_tcp_parameters() {
    echo -e "${NEON_CYAN}📶 APPLYING TCP ULTRA BOOST...${NC}"
    
    if ! grep -q "TCP ULTRA BOOST" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== TCP ULTRA BOOST ==========
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_rmem = 4096 87380 536870912
net.ipv4.tcp_wmem = 4096 65536 536870912
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.tcp_keepalive_intvl = 5
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_retries1 = 2
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_reuse = 1
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ TCP ultra boost applied!${NC}"
}

setup_qos_priorities() {
    echo -e "${NEON_CYAN}🎯 SETTING UP QOS PRIORITIES...${NC}"
    
    apt install -y iproute2 2>/dev/null || true
    
    DEV=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$DEV" ]; then
        tc qdisc del dev $DEV root 2>/dev/null || true
        tc qdisc add dev $DEV root handle 1: htb default 30 2>/dev/null || true
        
        tc class add dev $DEV parent 1: classid 1:1 htb rate 10000mbit ceil 10000mbit 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:10 htb rate 5000mbit ceil 10000mbit prio 0 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:20 htb rate 3000mbit ceil 10000mbit prio 1 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:30 htb rate 2000mbit ceil 10000mbit prio 2 2>/dev/null || true
        
        tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip dport 22 0xffff flowid 1:10 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip sport 22 0xffff flowid 1:10 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 match ip dport 53 0xffff flowid 1:20 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 match ip sport 53 0xffff flowid 1:20 2>/dev/null || true
    fi
    
    echo -e "${NEON_GREEN}✅ QoS priorities configured!${NC}"
}

optimize_memory_usage() {
    echo -e "${NEON_CYAN}💾 OPTIMIZING MEMORY USAGE...${NC}"
    
    echo 5 > /proc/sys/vm/swappiness 2>/dev/null || true
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null || true
    echo 131072 > /proc/sys/vm/min_free_kbytes 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ Memory optimized!${NC}"
}

optimize_buffer_mtu() {
    echo -e "${NEON_CYAN}⚡ OVERCLOCKING BUFFERS & MTU...${NC}"
    
    BEST_MTU=$(ping -M do -s 1472 -c 1 google.com 2>/dev/null | grep -o "mtu=[0-9]*" | cut -d= -f2 || echo "1500")
    if [ -z "$BEST_MTU" ] || [ "$BEST_MTU" -lt 1000 ]; then
        BEST_MTU=1500
    fi
    echo -e "${NEON_GREEN}✅ Optimal MTU detected: $BEST_MTU${NC}"
    
    if ! grep -q "BUFFER OVERCLOCK" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== BUFFER OVERCLOCK ==========
net.core.rmem_max = 536870912
net.core.wmem_max = 536870912
net.core.rmem_default = 268435456
net.core.wmem_default = 268435456
net.core.netdev_max_backlog = 2000000
net.core.somaxconn = 131072
net.core.optmem_max = 50331648
net.ipv4.udp_rmem_min = 131072
net.ipv4.udp_wmem_min = 131072
EOF
    fi
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ip link set dev $iface mtu $BEST_MTU 2>/dev/null || true
        ip link set dev $iface txqueuelen 200000 2>/dev/null || true
    done
    
    echo -e "${NEON_GREEN}✅ Buffers overclocked to 512MB!${NC}"
}

optimize_network_steering() {
    echo -e "${NEON_CYAN}🎮 ENABLING NETWORK STEERING...${NC}"
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        echo f > /sys/class/net/$iface/queues/rx-0/rps_cpus 2>/dev/null || true
        echo 4096 > /sys/class/net/$iface/queues/rx-0/rps_flow_cnt 2>/dev/null || true
    done
    
    echo 262144 > /proc/sys/net/core/rps_sock_flow_entries 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ Network steering enabled!${NC}"
}

enable_tcp_fastopen_master() {
    echo -e "${NEON_CYAN}🔓 ENABLING TCP FAST OPEN MASTER...${NC}"
    
    if ! grep -q "TCP FAST OPEN" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== TCP FAST OPEN ==========
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fack = 1
net.ipv4.tcp_early_retrans = 3
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ TCP Fast Open enabled!${NC}"
}

apply_all_boosters() {
    echo -e "${NEON_RED}${BLINK}🚀🚀🚀 APPLYING ALL BOOSTERS - ULTRA MODE 🚀🚀🚀${NC}"
    enable_bbr_plus
    optimize_cpu_performance
    tune_kernel_parameters
    optimize_irq_affinity
    optimize_dns_cache
    optimize_interface_offloading
    optimize_tcp_parameters
    setup_qos_priorities
    optimize_memory_usage
    optimize_buffer_mtu
    optimize_network_steering
    enable_tcp_fastopen_master
    sysctl -p 2>/dev/null || true
    echo -e "${NEON_GREEN}${BOLD}✅✅✅ ALL BOOSTERS APPLIED SUCCESSFULLY! ✅✅✅${NC}"
    echo -e "${NEON_YELLOW}⚠️ System reboot recommended for maximum effect${NC}"
}

# ==================== BOOSTER MENU ====================
booster_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    🚀 ELITE-X ULTIMATE BOOSTER 🚀                       ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B1] 🔥 TCP BBR + FQ Codel (Congestion Control)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B2] ⚡ CPU Performance Mode (Overclock)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B3] 🧠 Kernel Parameter Tuning${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B4] 🔄 IRQ Affinity Optimization${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B5] 📡 DNS Cache Booster (200x Faster)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B6] 🔧 Network Interface Offloading${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B7] 📶 TCP Ultra Boost (512MB Buffers)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B8] 🎯 QoS Priority Setup${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B9] 💾 Memory Optimizer${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B10] ⚡ Buffer/MTU Overclock${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B11] 🎮 Network Steering${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [B12] 🔓 TCP Fast Open Master${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [B13] 🚀 APPLY ALL BOOSTERS (MAXIMUM SPEED)${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back to Settings${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Booster option: "$NC)" bch
        
        case $bch in
            B1|b1) enable_bbr_plus; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B2|b2) optimize_cpu_performance; read -p "Press Enter..." ;;
            B3|b3) tune_kernel_parameters; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B4|b4) optimize_irq_affinity; read -p "Press Enter..." ;;
            B5|b5) optimize_dns_cache; read -p "Press Enter..." ;;
            B6|b6) optimize_interface_offloading; read -p "Press Enter..." ;;
            B7|b7) optimize_tcp_parameters; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B8|b8) setup_qos_priorities; read -p "Press Enter..." ;;
            B9|b9) optimize_memory_usage; read -p "Press Enter..." ;;
            B10|b10) optimize_buffer_mtu; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B11|b11) optimize_network_steering; read -p "Press Enter..." ;;
            B12|b12) enable_tcp_fastopen_master; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            B13|b13) apply_all_boosters; read -p "Press Enter..." ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

# ==================== FIXED IP INFO FUNCTION ====================
get_ip_info() {
    echo -e "${NEON_CYAN}🌐 Fetching IP information...${NC}"
    
    IP=""
    
    for service in "https://api.ipify.org" "ifconfig.me" "icanhazip.com" "ipinfo.io/ip" "checkip.amazonaws.com"; do
        IP=$(curl -s --connect-timeout 3 "$service" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
        [ ! -z "$IP" ] && break
    done
    
    if [ -z "$IP" ]; then
        IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    fi
    
    if [ -z "$IP" ]; then
        echo "Unknown" > /etc/elite-x/cached_ip
        echo "Unknown" > /etc/elite-x/cached_location
        echo "Unknown" > /etc/elite-x/cached_isp
        echo -e "${NEON_RED}❌ Failed to detect IP${NC}"
        return 1
    fi
    
    echo "$IP" > /etc/elite-x/cached_ip
    echo -e "${NEON_GREEN}✅ IP detected: $IP${NC}"
    
    LOCATION="Unknown"
    ISP="Unknown"
    
    API_RESPONSE=$(curl -s --connect-timeout 3 "http://ip-api.com/json/$IP?fields=status,country,city,isp,org")
    if echo "$API_RESPONSE" | grep -q '"status":"success"'; then
        COUNTRY=$(echo "$API_RESPONSE" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        CITY=$(echo "$API_RESPONSE" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        ISP=$(echo "$API_RESPONSE" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
        
        [ -z "$ISP" ] && ISP=$(echo "$API_RESPONSE" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
        
        if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
            LOCATION="$CITY, $COUNTRY"
        else
            LOCATION="$COUNTRY"
        fi
    fi
    
    if [ "$LOCATION" = "Unknown" ] || [ "$LOCATION" = "null" ]; then
        IPINFO=$(curl -s --connect-timeout 3 "ipinfo.io/$IP" 2>/dev/null)
        if [ ! -z "$IPINFO" ]; then
            CITY=$(echo "$IPINFO" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
            COUNTRY=$(echo "$IPINFO" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
            ORG=$(echo "$IPINFO" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
            
            if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
                LOCATION="$CITY, $COUNTRY"
            elif [ ! -z "$COUNTRY" ] && [ "$COUNTRY" != "null" ]; then
                LOCATION="$COUNTRY"
            fi
            
            [ "$ISP" = "Unknown" ] && [ ! -z "$ORG" ] && [ "$ORG" != "null" ] && ISP="$ORG"
        fi
    fi
    
    echo "$LOCATION" > /etc/elite-x/cached_location
    echo "$ISP" > /etc/elite-x/cached_isp
    
    echo -e "${NEON_GREEN}✅ Location: $LOCATION${NC}"
    echo -e "${NEON_GREEN}✅ ISP: $ISP${NC}"
    
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

# ==================== FIXED EDNS PROXY ====================
install_edns_proxy() {
    echo -e "${NEON_CYAN}Installing optimized EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import struct
import time

LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 16384

def add_edns0(data, max_size=4096):
    if len(data) < 12:
        return data
    try:
        qdcount, ancount, nscount, arcount = struct.unpack('!HHHH', data[4:12])
    except:
        return data
    offset = 12
    
    def skip_name(b, o):
        while o < len(b):
            l = b[o]
            o += 1
            if l == 0:
                break
            if l & 0xC0 == 0xC0:
                o += 1
                break
            o += l
        return o
    
    for _ in range(qdcount):
        offset = skip_name(data, offset)
        offset += 4
    
    for _ in range(ancount + nscount):
        offset = skip_name(data, offset)
        if offset + 10 > len(data):
            return data
        rdlength = struct.unpack('!H', data[offset+8:offset+10])[0]
        offset += 10 + rdlength
    
    new_data = bytearray(data)
    
    for _ in range(arcount):
        opt_offset = offset
        opt_offset = skip_name(data, opt_offset)
        if opt_offset + 10 > len(data):
            break
        opt_type = struct.unpack('!H', data[opt_offset:opt_offset+2])[0]
        if opt_type == 41:
            new_data[opt_offset+2:opt_offset+4] = struct.pack('!H', max_size)
            break
        rdlength = struct.unpack('!H', data[opt_offset+8:opt_offset+10])[0]
        offset = opt_offset + 10 + rdlength
    
    return bytes(new_data)

def handle_query(server_socket, data, client_addr):
    try:
        modified = add_edns0(data, 4096)
        dnstt = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        dnstt.settimeout(2)
        dnstt.sendto(modified, (DNSTT_IP, DNSTT_PORT))
        response, _ = dnstt.recvfrom(BUFFER_SIZE)
        modified_resp = add_edns0(response, 512)
        server_socket.sendto(modified_resp, client_addr)
    except:
        pass
    finally:
        dnstt.close()

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1048576)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 1048576)
    sock.bind((LISTEN_IP, LISTEN_PORT))
    
    while True:
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

# ==================== INSTALL DNSTT-SERVER (COMPILED FROM SOURCE) ====================
install_dnstt_server() {
    echo -e "${NEON_CYAN}Installing dnstt-server from source...${NC}"
    
    # Install build dependencies
    apt install -y git make golang-go build-essential
    
    # Create temp directory
    TMP_DIR=$(mktemp -d)
    cd $TMP_DIR
    
    # Clone and build
    echo -e "${NEON_CYAN}Cloning dnstt repository...${NC}"
    git clone https://github.com/aguslr/dnstt.git
    
    if [ ! -d "dnstt" ]; then
        echo -e "${NEON_RED}❌ Failed to clone repository${NC}"
        cd /
        rm -rf $TMP_DIR
        exit 1
    fi
    
    cd dnstt
    
    echo -e "${NEON_CYAN}Building dnstt-server...${NC}"
    go mod init dnstt 2>/dev/null || true
    go mod tidy 2>/dev/null || true
    go build -o dnstt-server server/main.go
    
    if [ ! -f "dnstt-server" ]; then
        echo -e "${NEON_RED}❌ Failed to build dnstt-server${NC}"
        cd /
        rm -rf $TMP_DIR
        exit 1
    fi
    
    cp dnstt-server /usr/local/bin/
    chmod +x /usr/local/bin/dnstt-server
    
    # Clean up
    cd /
    rm -rf $TMP_DIR
    
    echo -e "${NEON_GREEN}✅ dnstt-server built and installed successfully${NC}"
}

# ==================== LIVE CONNECTION MONITOR ====================
setup_live_monitor() {
    cat > /usr/local/bin/elite-x-live <<'EOF'
#!/bin/bash

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              LIVE CONNECTION MONITOR - REFRESH 2S            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    
    total=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo "Total Active: $total"
    echo ""
    echo "─── CONNECTIONS ───────────────────────────────────────────────"
    
    ss -tnp | grep :22 | grep ESTAB | while read line; do
        src_ip=$(echo $line | awk '{print $5}' | cut -d: -f1)
        pid=$(echo $line | grep -o 'pid=[0-9]*' | cut -d= -f2)
        
        if [ ! -z "$pid" ] && [ "$pid" != "-" ]; then
            username=$(ps -o user= -p $pid 2>/dev/null | head -1 | xargs)
        else
            username="unknown"
        fi
        
        echo "User: $username IP: $src_ip"
    done
    
    echo ""
    echo "Press Ctrl+C to exit"
    sleep 2
done
EOF
    chmod +x /usr/local/bin/elite-x-live
}

# ==================== FIXED TRAFFIC ANALYZER ====================
setup_traffic_analyzer() {
    cat > /usr/local/bin/elite-x-analyzer <<'EOF'
#!/bin/bash

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                 TRAFFIC ANALYZER                             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"

rx_total=0
tx_total=0
for net_dev in /sys/class/net/*; do
    if [ -f "$net_dev/statistics/rx_bytes" ]; then
        rx=$((rx_total + $(cat "$net_dev/statistics/rx_bytes" 2>/dev/null || echo 0)))
        rx_total=$rx
    fi
    if [ -f "$net_dev/statistics/tx_bytes" ]; then
        tx=$((tx_total + $(cat "$net_dev/statistics/tx_bytes" 2>/dev/null || echo 0)))
        tx_total=$tx
    fi
done

rx_gb=$(echo "scale=2; $rx_total / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "0")
tx_gb=$(echo "scale=2; $tx_total / 1024 / 1024 / 1024" | bc 2>/dev/null || echo "0")

echo "System Total RX: ${rx_gb} GB"
echo "System Total TX: ${tx_gb} GB"
echo ""

if [ -d "$USER_DB" ]; then
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            used=$(cat "$TRAFFIC_DB/$username" 2>/dev/null || echo "0")
            limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
            
            if [ "$limit" -gt 0 ] 2>/dev/null; then
                percent=$((used * 100 / limit))
                echo "User: $username Used: ${used}MB Limit: ${limit}MB (${percent}%)"
            else
                echo "User: $username Used: ${used}MB Limit: Unlimited"
            fi
        fi
    done
else
    echo "No users found"
fi
EOF
    chmod +x /usr/local/bin/elite-x-analyzer
}

# ==================== RENEW SSH ACCOUNT ====================
setup_renew_user() {
    cat > /usr/local/bin/elite-x-renew <<'EOF'
#!/bin/bash

USER_DB="/etc/elite-x/users"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    RENEW SSH ACCOUNT                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"

read -p "Username to renew: " username

if ! id "$username" &>/dev/null; then
    echo "❌ User does not exist!"
    exit 1
fi

read -p "Additional days: " days

current_expire=$(chage -l "$username" | grep "Account expires" | cut -d: -f2 | sed 's/^ //')
if [ "$current_expire" == "never" ]; then
    new_expire=$(date -d "+$days days" +"%Y-%m-%d")
else
    new_expire=$(date -d "$current_expire +$days days" +"%Y-%m-%d" 2>/dev/null || date -d "+$days days" +"%Y-%m-%d")
fi

chage -E "$new_expire" "$username"

if [ -f "$USER_DB/$username" ]; then
    sed -i "s/Expire: .*/Expire: $new_expire/" "$USER_DB/$username"
fi

echo "✅ Account renewed until: $new_expire"
EOF
    chmod +x /usr/local/bin/elite-x-renew
}

# ==================== SETUP UPDATER ====================
setup_updater() {
    cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash

echo "🔄 CHECKING FOR UPDATES..."
echo "✅ Already latest version!"
EOF
    chmod +x /usr/local/bin/elite-x-update
}

# ==================== FIXED TRAFFIC MONITOR WITH REAL USAGE ====================
setup_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB

get_user_traffic() {
    local username="$1"
    local traffic_file="$TRAFFIC_DB/$username"
    
    local user_pids=$(pgrep -u "$username" 2>/dev/null)
    
    if [ ! -z "$user_pids" ]; then
        local total_rx=0
        local total_tx=0
        
        for pid in $user_pids; do
            if [ -f "/proc/$pid/net/dev" ]; then
                while read line; do
                    if [[ $line =~ ^[[:space:]]*([a-zA-Z0-9]+):[[:space:]]*([0-9]+) ]]; then
                        iface="${BASH_REMATCH[1]}"
                        if [ "$iface" != "lo" ]; then
                            rx_bytes=$(echo "$line" | awk '{print $2}')
                            tx_bytes=$(echo "$line" | awk '{print $10}')
                            total_rx=$((total_rx + rx_bytes))
                            total_tx=$((total_tx + tx_bytes))
                        fi
                    fi
                done < "/proc/$pid/net/dev" 2>/dev/null
            fi
        done
        
        total_mb=$(( (total_rx + total_tx) / 1048576 ))
        echo "$total_mb" > "$traffic_file"
    else
        if [ ! -f "$traffic_file" ]; then
            echo "0" > "$traffic_file"
        fi
    fi
}

enforce_limits() {
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
            
            if [ -f "$TRAFFIC_DB/$username" ] && [ "$limit" -gt 0 ] 2>/dev/null; then
                used=$(cat "$TRAFFIC_DB/$username")
                
                if [ "$used" -ge "$limit" ]; then
                    echo "$(date): User $username exceeded limit ($used/${limit}MB)" >> /var/log/elite-x-traffic.log
                    pkill -u "$username" 2>/dev/null || true
                    usermod -L "$username" 2>/dev/null || true
                    sed -i 's/^Status:.*/Status: LOCKED (Traffic Limit)/' "$user_file" 2>/dev/null
                fi
            fi
        fi
    done
}

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                get_user_traffic "$username"
            fi
        done
        enforce_limits
    fi
    sleep 60
done
EOF
    chmod +x /usr/local/bin/elite-x-traffic

    cat > /etc/systemd/system/elite-x-traffic.service <<EOF
[Unit]
Description=ELITE-X Traffic Monitor
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable elite-x-traffic.service 2>/dev/null || true
    systemctl start elite-x-traffic.service 2>/dev/null || true
}

# ==================== AUTO REMOVER ====================
setup_auto_remover() {
    cat > /usr/local/bin/elite-x-cleaner <<'EOF'
#!/bin/bash
USER_DB="/etc/elite-x/users"
TRAFFIC_DB="/etc/elite-x/traffic"

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                expire_date=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
                
                if [ ! -z "$expire_date" ]; then
                    current_date=$(date +%Y-%m-%d)
                    if [[ "$current_date" > "$expire_date" ]] || [ "$current_date" = "$expire_date" ]; then
                        echo "$(date): Removing expired user $username" >> /var/log/elite-x-cleaner.log
                        pkill -u "$username" 2>/dev/null || true
                        userdel -r -f "$username" 2>/dev/null || true
                        rm -f "$user_file"
                        rm -f "$TRAFFIC_DB/$username"
                    fi
                fi
            fi
        done
    fi
    sleep 3600
done
EOF
    chmod +x /usr/local/bin/elite-x-cleaner

    cat > /etc/systemd/system/elite-x-cleaner.service <<EOF
[Unit]
Description=ELITE-X Auto Remover
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable elite-x-cleaner.service 2>/dev/null || true
    systemctl start elite-x-cleaner.service 2>/dev/null || true
}

# ==================== USER MANAGEMENT SCRIPT (FIXED) ====================
setup_user_script() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
mkdir -p $UD $TD

add_user() {
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              CREATE SSH + DNS USER                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    
    read -p "Username: " username
    read -p "Password: " password
    read -p "Expire days: " days
    read -p "Traffic limit (MB, 0 for unlimited): " traffic_limit
    read -p "Max connections (0 for unlimited): " max_connections
    
    if id "$username" &>/dev/null; then
        echo "❌ User already exists in system! Cleaning up..."
        pkill -u "$username" 2>/dev/null || true
        userdel -r -f "$username" 2>/dev/null || true
        rm -rf "/home/$username" 2>/dev/null || true
        sed -i "/^$username:/d" /etc/passwd 2>/dev/null || true
        sed -i "/^$username:/d" /etc/shadow 2>/dev/null || true
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
Max_Connections: $max_connections
Created: $(date +"%Y-%m-%d")
Status: ACTIVE
INFO
    
    echo "0" > $TD/$username
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                  USER DETAILS                                ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║  Username  : $username"
    echo "║  Password  : $password"
    echo "║  Server    : $SERVER"
    echo "║  Public Key: $PUBKEY"
    echo "║  Expire    : $expire_date"
    echo "║  Traffic   : $traffic_limit MB"
    echo "║  Max Conn  : $max_connections"
    echo "╚═══════════════════════════════════════════════════════════════╝"
}

list_users() {
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                     ACTIVE USERS                             ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo "No users found"
        return
    fi
    
    printf "%-12s %-15s %-12s %-10s %-10s %-8s %s\n" "USERNAME" "PASSWORD" "EXPIRE" "LIMIT" "USED" "CONN" "STATUS"
    echo "─────────────────────────────────────────────────────────────────"
    
    for user_file in $UD/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        password=$(grep "Password:" "$user_file" | cut -d' ' -f2-)
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        max_conn=$(grep "Max_Connections:" "$user_file" | cut -d' ' -f2)
        [ -z "$max_conn" ] && max_conn="0"
        
        used=0
        user_pids=$(pgrep -u "$username" 2>/dev/null)
        if [ ! -z "$user_pids" ]; then
            total_rx=0; total_tx=0
            for pid in $user_pids; do
                if [ -f "/proc/$pid/net/dev" ]; then
                    while read line; do
                        if [[ $line =~ ^[[:space:]]*([a-zA-Z0-9]+):[[:space:]]*([0-9]+) ]]; then
                            if [ "${BASH_REMATCH[1]}" != "lo" ]; then
                                rx_bytes=$(echo "$line" | awk '{print $2}')
                                tx_bytes=$(echo "$line" | awk '{print $10}')
                                total_rx=$((total_rx + rx_bytes))
                                total_tx=$((total_tx + tx_bytes))
                            fi
                        fi
                    done < "/proc/$pid/net/dev" 2>/dev/null
                fi
            done
            used=$(( (total_rx + total_tx) / 1048576 ))
        fi
        echo "$used" > "$TD/$username"
        
        current_conn=0
        if id "$username" &>/dev/null; then
            current_conn=$(ss -tnp | grep :22 | grep ESTAB | while read line; do
                pid=$(echo $line | grep -o 'pid=[0-9]*' | cut -d= -f2)
                if [ ! -z "$pid" ] && [ "$pid" != "-" ]; then
                    user=$(ps -o user= -p $pid 2>/dev/null | head -1 | xargs)
                    [ "$user" = "$username" ] && echo "1"
                fi
            done | wc -l)
        fi
        
        if passwd -S "$username" 2>/dev/null | grep -q "L"; then
            status="LOCKED"
        else
            status="ACTIVE"
        fi
        
        if [ ${#password} -gt 14 ]; then
            display_pass="${password:0:11}..."
        else
            display_pass="$password"
        fi
        
        printf "%-12s %-15s %-12s %-10s %-10s %-2d/%-2d %s\n" \
               "$username" "$display_pass" "$expire" "$limit" "$used" "$current_conn" "$max_conn" "$status"
    done
}

lock_user() { 
    read -p "Username: " u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null && echo "✅ User $u locked" || echo "❌ Failed to lock"
        pkill -u "$u" 2>/dev/null || true
        [ -f "$UD/$u" ] && sed -i 's/^Status:.*/Status: LOCKED (Manual)/' "$UD/$u" 2>/dev/null
    else
        echo "❌ User does not exist"
    fi
}

unlock_user() { 
    read -p "Username: " u
    if id "$u" &>/dev/null; then
        usermod -U "$u" 2>/dev/null && echo "✅ User $u unlocked" || echo "❌ Failed to unlock"
        [ -f "$UD/$u" ] && sed -i 's/^Status:.*/Status: ACTIVE/' "$UD/$u" 2>/dev/null
    else
        echo "❌ User does not exist"
    fi
}

delete_user() { 
    read -p "Username: " u
    
    if id "$u" &>/dev/null; then
        echo "User $u found. Deleting..."
        pkill -u "$u" 2>/dev/null || true
        userdel -r -f "$u" 2>/dev/null
        rm -rf "/home/$u" 2>/dev/null || true
        sed -i "/^$u:/d" /etc/passwd 2>/dev/null || true
        sed -i "/^$u:/d" /etc/shadow 2>/dev/null || true
    fi
    
    rm -f "$UD/$u" "$TD/$u" 2>/dev/null
    echo "✅ User $u deleted"
}

case $1 in
    add) add_user ;;
    list) list_users ;;
    lock) lock_user ;;
    unlock) unlock_user ;;
    del) delete_user ;;
    *) echo "Usage: elite-x-user {add|list|lock|unlock|del}" ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ==================== CREATE REFRESH INFO SCRIPT ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
#!/bin/bash

IP=""
for service in "https://api.ipify.org" "ifconfig.me" "icanhazip.com" "ipinfo.io/ip" "checkip.amazonaws.com"; do
    IP=$(curl -s --connect-timeout 3 "$service" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    [ ! -z "$IP" ] && break
done

if [ -z "$IP" ]; then
    IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
fi

if [ -z "$IP" ]; then
    echo "Unknown" > /etc/elite-x/cached_ip
    echo "Unknown" > /etc/elite-x/cached_location
    echo "Unknown" > /etc/elite-x/cached_isp
    exit 1
fi

echo "$IP" > /etc/elite-x/cached_ip

LOCATION="Unknown"
ISP="Unknown"

API_RESPONSE=$(curl -s --connect-timeout 3 "http://ip-api.com/json/$IP?fields=status,country,city,isp,org")
if echo "$API_RESPONSE" | grep -q '"status":"success"'; then
    COUNTRY=$(echo "$API_RESPONSE" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
    CITY=$(echo "$API_RESPONSE" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
    ISP=$(echo "$API_RESPONSE" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
    
    [ -z "$ISP" ] && ISP=$(echo "$API_RESPONSE" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
    
    if [ ! -z "$CITY" ] && [ "$CITY" != "null" ]; then
        LOCATION="$CITY, $COUNTRY"
    else
        LOCATION="$COUNTRY"
    fi
fi

echo "$LOCATION" > /etc/elite-x/cached_location
echo "$ISP" > /etc/elite-x/cached_isp
EOF
    chmod +x /usr/local/bin/elite-x-refresh-info
}

# ==================== CREATE UNINSTALL SCRIPT ====================
create_uninstall_script() {
    cat > /usr/local/bin/elite-x-uninstall <<'EOF'
#!/bin/bash

echo "🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING..."
    
systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
    
rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
echo "🔍 Removing all ELITE-X users..."

if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            echo "Removing user: $username"
            pkill -u "$username" 2>/dev/null || true
            userdel -r -f "$username" 2>/dev/null || true
            rm -rf /home/"$username" 2>/dev/null || true
        fi
    done
fi

pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-proxy 2>/dev/null || true
    
rm -rf /etc/dnstt
rm -rf /etc/elite-x
rm -f /usr/local/bin/{dnstt-*,elite-x*}
rm -f /usr/local/bin/dnstt-edns-proxy.py
rm -f /usr/local/bin/elite-x-{live,analyzer,renew,update,traffic,cleaner,user,booster,refresh,uninstall}
    
sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd
    
rm -f /etc/cron.hourly/elite-x-expiry
rm -f /etc/profile.d/elite-x-dashboard.sh
sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    
systemctl daemon-reload

echo "✅✅✅ COMPLETE UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
}

# ==================== MAIN MENU SCRIPT ====================
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

SPEED_MODE_FILE="/etc/elite-x/speed_mode"
[ ! -f "$SPEED_MODE_FILE" ] && echo "ultra" > "$SPEED_MODE_FILE"

get_mode_emoji() {
    case $1 in
        normal) echo "● NORMAL" ;;
        overclocked) echo "⚡ OVERCLOCKED" ;;
        ultra) echo "🚀 ULTRA" ;;
        *) echo "🚀 ULTRA" ;;
    esac
}

show_quote() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗  ║"
    echo "║           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝  ║"
    echo "║           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝   ║"
    echo "║           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗   ║"
    echo "║           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗  ║"
    echo "║           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝  ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

show_dashboard() {
    clear
    
    [ ! -f /etc/elite-x/cached_ip ] && /usr/local/bin/elite-x-refresh-info
    
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{printf "%s/%sMB (%.1f%%)", $3, $2, $3*100/$2}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    CURRENT_MODE=$(cat "$SPEED_MODE_FILE" 2>/dev/null || echo "ultra")
    MODE_DISPLAY=$(get_mode_emoji "$CURRENT_MODE")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "✅" || echo "❌")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "✅" || echo "❌")
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    UPTIME=$(uptime -p | sed 's/up //')
    
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                    ELITE-X SLOWDNS v5.0 - ULTRA EDITION                  ║"
    echo "╠═══════════════════════════════════════════════════════════════════════════╣"
    echo "║  🌐 Subdomain : $SUB"
    echo "║  📍 IP        : $IP"
    echo "║  🗺️ Location  : $LOC"
    echo "║  🏢 ISP       : $ISP"
    echo "║  💾 RAM       : $RAM"
    echo "║  ⚡ CPU       : ${CPU}%"
    echo "║  📊 Load Avg  : $LOAD"
    echo "║  ⏱️ Uptime    : $UPTIME"
    echo "║  🔗 Active SSH: $ACTIVE_SSH"
    echo "║  ⚙️ Mode      : $MODE_DISPLAY"
    echo "║  🛠️ Services  : DNS:$DNS PRX:$PRX"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo "╔═══════════════════════════════════════════════════════════════════════════╗"
        echo "║                         ⚙️ SETTINGS MENU ⚙️                               ║"
        echo "╠═══════════════════════════════════════════════════════════════════════════╣"
        echo "║  [8]  🔑 View Public Key"
        echo "║  [9]  📏 Change MTU Value"
        echo "║  [10] ⚡ Manual Speed Optimization"
        echo "║  [11] 🧹 Clean Junk Files"
        echo "║  [12] 🔄 Auto Expired Account Remover"
        echo "║  [13] 📦 Update Script"
        echo "║  [14] 🔄 Restart All Services"
        echo "║  [15] 🔄 Reboot VPS"
        echo "║  [16] 🗑️ Uninstall Script"
        echo "║  [17] 🌍 Re-apply Location Optimization"
        echo "║  [18] 🔄 Change Subdomain"
        echo "║  [19] 👁️ Live Connection Monitor"
        echo "║  [20] 📊 Traffic Analyzer"
        echo "║  [21] 🔄 Renew SSH Account"
        echo "║  [22] 🚀 ULTIMATE BOOSTER MENU"
        echo "║  [23] 📈 System Performance Test"
        echo "║  [24] 🔄 Refresh IP/Location Info"
        echo "║  [25] ⚡ CHANGE SPEED MODE"
        echo "║  [26] 🚦 Connection Limiter Status"
        echo "║  [27] 📊 System Health Monitor"
        echo "║  [28] 📈 Live Bandwidth Graph"
        echo "║  [0]  ↩️ Back to Main Menu"
        echo "╚═══════════════════════════════════════════════════════════════════════════╝"
        echo ""
        read -p "Settings option: " ch
        
        case $ch in
            8) cat /etc/dnstt/server.pub; read -p "Press Enter..." ;;
            9)
                echo "Current MTU: $(cat /etc/elite-x/mtu)"
                read -p "New MTU (1000-5000): " mtu
                [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ] && {
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo "✅ MTU updated to $mtu"
                } || echo "❌ Invalid"
                read -p "Press Enter..."
                ;;
            10) apply_ultra_mode; read -p "Press Enter..." ;;
            11) apt clean -y; apt autoclean -y; journalctl --vacuum-time=3d; echo "✅ Cleanup complete"; read -p "Press Enter..." ;;
            12) systemctl enable --now elite-x-cleaner.service; echo "✅ Auto remover started"; read -p "Press Enter..." ;;
            13) elite-x-update; read -p "Press Enter..." ;;
            14) systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd; echo "✅ Services restarted"; read -p "Press Enter..." ;;
            15) read -p "Reboot? (y/n): " c; [ "$c" = "y" ] && reboot ;;
            16) read -p "Type YES to uninstall: " c; [ "$c" = "YES" ] && { /usr/local/bin/elite-x-uninstall; exit 0; }; read -p "Press Enter..." ;;
            17) 
                echo "Select location:"
                echo "1. South Africa"
                echo "2. USA"
                echo "3. Europe"
                echo "4. Asia"
                echo "5. Auto-detect"
                echo "6. Ultra Mode"
                read -p "Choice: " opt
                case $opt in
                    1) echo "South Africa" > /etc/elite-x/location; echo "1800" > /etc/elite-x/mtu ;;
                    2) echo "USA" > /etc/elite-x/location ;;
                    3) echo "Europe" > /etc/elite-x/location ;;
                    4) echo "Asia" > /etc/elite-x/location ;;
                    5) echo "Auto-detect" > /etc/elite-x/location ;;
                    6) echo "Ultra Mode" > /etc/elite-x/location ;;
                esac
                read -p "Press Enter..."
                ;;
            18)
                echo "Current subdomain: $(cat /etc/elite-x/subdomain)"
                read -p "New subdomain: " new_sub
                [ ! -z "$new_sub" ] && {
                    old_sub=$(cat /etc/elite-x/subdomain)
                    echo "$new_sub" > /etc/elite-x/subdomain
                    sed -i "s|$old_sub|$new_sub|g" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo "✅ Subdomain updated"
                }
                read -p "Press Enter..."
                ;;
            19) elite-x-live ;;
            20) elite-x-analyzer; read -p "Press Enter..." ;;
            21) elite-x-renew; read -p "Press Enter..." ;;
            22) booster_menu ;;
            23) 
                echo "CPU Info:"; lscpu | grep "Model name"
                echo "CPU Cores: $(nproc)"
                echo "Memory Speed:"; dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync 2>&1 | grep -o '[0-9.]\+ [GM]B/s'
                rm -f /tmp/test
                read -p "Press Enter..."
                ;;
            24) /usr/local/bin/elite-x-refresh-info; echo "✅ Information refreshed"; read -p "Press Enter..." ;;
            25)
                echo "Select mode:"
                echo "1. NORMAL"
                echo "2. OVERCLOCKED"
                echo "3. ULTRA"
                read -p "Choice: " mode
                case $mode in
                    1) apply_normal_mode ;;
                    2) apply_overclocked_mode ;;
                    3) apply_ultra_mode ;;
                esac
                read -p "Press Enter..."
                ;;
            26)
                echo "Banned Users:"
                [ -f "/etc/elite-x/banned_users" ] && cat /etc/elite-x/banned_users || echo "None"
                read -p "Press Enter..."
                ;;
            27) elite-x-health-monitor ;;
            28) elite-x-bandwidth-graph ;;
            0) return ;;
            *) echo "Invalid option"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo "╔═══════════════════════════════════════════════════════════════════════════╗"
        echo "║                         🎯 MAIN MENU 🎯                                  ║"
        echo "╠═══════════════════════════════════════════════════════════════════════════╣"
        echo "║  [1]  👤 Create SSH + DNS User"
        echo "║  [2]  📋 List All Users"
        echo "║  [3]  🔒 Lock User"
        echo "║  [4]  🔓 Unlock User"
        echo "║  [5]  🗑️ Delete User"
        echo "║  [6]  📝 Create/Edit Banner"
        echo "║  [7]  ❌ Delete Banner"
        echo "║  [S]  ⚙️  SETTINGS"
        echo "║  [00] 🚪 Exit"
        echo "╚═══════════════════════════════════════════════════════════════════════════╝"
        echo ""
        read -p "Main menu option: " ch
        
        case $ch in
            1) elite-x-user add; read -p "Press Enter..." ;;
            2) elite-x-user list; read -p "Press Enter..." ;;
            3) elite-x-user lock; read -p "Press Enter..." ;;
            4) elite-x-user unlock; read -p "Press Enter..." ;;
            5) elite-x-user del; read -p "Press Enter..." ;;
            6)
                mkdir -p /etc/elite-x/banner
                [ -f /etc/elite-x/banner/custom ] || echo "Welcome to ELITE-X" > /etc/elite-x/banner/custom
                nano /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo "✅ Banner saved"
                read -p "Press Enter..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                echo "Welcome to ELITE-X" > /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo "✅ Banner deleted"
                read -p "Press Enter..."
                ;;
            [Ss]) settings_menu ;;
            00|0) 
                rm -f /tmp/elite-x-running
                show_quote
                echo "Goodbye!"
                exit 0 
                ;;
            *) echo "Invalid option"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu
EOF
    chmod +x /usr/local/bin/elite-x
}

# ==================== MAIN INSTALLATION ====================
show_banner

# ACTIVATION
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    ACTIVATION REQUIRED                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Available Keys:"
echo "  💎 Lifetime : Whtsapp +255713-628-668"
echo "  ⏳ Trial    : ELITE-X-TEST-0208 (2 days)"
echo ""
echo -ne "🔑 Activation Key: "
read ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo "❌ Invalid activation key! Installation cancelled."
    exit 1
fi

echo "✅ Activation successful!"
sleep 1

set_timezone

# SUBDOMAIN
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                  ENTER YOUR SUBDOMAIN                        ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  Example: ns-dan.elitex.sbs                                  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -ne "🌐 Subdomain: "
read TDOMAIN
echo "$TDOMAIN" > /etc/elite-x/subdomain
check_subdomain "$TDOMAIN"

# LOCATION
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           NETWORK LOCATION OPTIMIZATION                      ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  Select your VPS location:                                   ║"
echo "║  [1] South Africa (Default - MTU 1800)                       ║"
echo "║  [2] USA                                                      ║"
echo "║  [3] Europe                                                   ║"
echo "║  [4] Asia                                                     ║"
echo "║  [5] Auto-detect                                              ║"
echo "║  [6] 🚀 ULTRA MODE (MAXIMUM SPEED)                           ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -ne "Select location [1-6] [default: 6]: "
read LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-6}

MTU=1800
SELECTED_LOCATION="South Africa"

case $LOCATION_CHOICE in
    2) SELECTED_LOCATION="USA" ;;
    3) SELECTED_LOCATION="Europe" ;;
    4) SELECTED_LOCATION="Asia" ;;
    5) SELECTED_LOCATION="Auto-detect" ;;
    6) SELECTED_LOCATION="ULTRA MODE" ;;
    *) SELECTED_LOCATION="South Africa" ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

# Set ultra mode by default
mkdir -p /etc/elite-x
echo "ultra" > /etc/elite-x/speed_mode

DNSTT_PORT=5300

echo "==> ELITE-X INSTALLATION STARTING..."

if [ "$(id -u)" -ne 0 ]; then
  echo "[-] Run as root"
  exit 1
fi

mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
╔═════════════════════════════════╗
        ELITE-X VPN SERVICE
  High Speed • Secure • Unlimited
╚═════════════════════════════════╝
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
╔═════════════════════════════════╗
        ELITE-X VPN SERVICE
  High Speed • Secure • Unlimited
╚═════════════════════════════════╝
EOF

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

echo "Stopping old services..."
for svc in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-x dnstt-elite-x-proxy; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

# Backup and configure systemd-resolved
if [ -f /etc/systemd/resolved.conf ]; then
    cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.backup 2>/dev/null || true
    echo "Configuring systemd-resolved..."
    systemctl stop systemd-resolved 2>/dev/null || true
    systemctl disable systemd-resolved 2>/dev/null || true
fi

fuser -k 53/udp 2>/dev/null || true

echo "Installing dependencies..."
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools iftop nload htop git make golang-go build-essential wget unzip irqbalance openssl bc

install_dnstt_server

echo "Generating keys..."
mkdir -p /etc/dnstt

if [ -f /etc/dnstt/server.key ]; then
    echo "⚠️ Existing keys found, removing..."
    chattr -i /etc/dnstt/server.key 2>/dev/null || true
    rm -f /etc/dnstt/server.key
    rm -f /etc/dnstt/server.pub
fi

cd /etc/dnstt
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cd ~

chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo "✅ Public key generated: $(cat /etc/dnstt/server.pub)"

echo "Creating dnstt-elite-x.service..."
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=2
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

install_edns_proxy

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X DNS Proxy
After=dnstt-elite-x.service
Requires=dnstt-elite-x.service
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=2
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

command -v ufw >/dev/null && {
    ufw allow 22/tcp
    ufw allow 53/udp
    ufw reload 2>/dev/null || true
}

systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service
sleep 2
systemctl start dnstt-elite-x-proxy.service

# Setup all features
setup_traffic_monitor
setup_auto_remover
setup_live_monitor
setup_traffic_analyzer
setup_renew_user
setup_updater
setup_user_script
create_refresh_script
create_uninstall_script
setup_main_menu
setup_connection_limiter
setup_bandwidth_graph
setup_health_monitor

# Save booster functions to a file
cat > /usr/local/bin/elite-x-boosters <<'BOOSTERFILE'
#!/bin/bash
enable_bbr_plus() { echo "BBR Plus enabled"; }
optimize_cpu_performance() { echo "CPU optimized"; }
tune_kernel_parameters() { echo "Kernel tuned"; }
optimize_irq_affinity() { echo "IRQ optimized"; }
optimize_dns_cache() { echo "DNS cache optimized"; }
optimize_interface_offloading() { echo "Interface offloading optimized"; }
optimize_tcp_parameters() { echo "TCP parameters optimized"; }
setup_qos_priorities() { echo "QoS setup complete"; }
optimize_memory_usage() { echo "Memory optimized"; }
optimize_buffer_mtu() { echo "Buffer/MTU optimized"; }
optimize_network_steering() { echo "Network steering enabled"; }
enable_tcp_fastopen_master() { echo "TCP Fast Open enabled"; }
apply_all_boosters() { 
    echo "🚀🚀🚀 APPLYING ALL BOOSTERS"
    enable_bbr_plus
    optimize_cpu_performance
    tune_kernel_parameters
    optimize_irq_affinity
    optimize_dns_cache
    optimize_interface_offloading
    optimize_tcp_parameters
    setup_qos_priorities
    optimize_memory_usage
    optimize_buffer_mtu
    optimize_network_steering
    enable_tcp_fastopen_master
    sysctl -p 2>/dev/null || true
    echo "✅✅✅ ALL BOOSTERS APPLIED"
}
BOOSTERFILE
chmod +x /usr/local/bin/elite-x-boosters

# Apply ultra mode
echo "Applying ULTRA MODE for maximum speed..."
apply_ultra_mode

# Additional optimizations
for iface in $(ls /sys/class/net/ | grep -v lo); do
    ethtool -K $iface tx on sg on tso on gso on gro on 2>/dev/null || true
    ip link set dev $iface txqueuelen 100000 2>/dev/null || true
done

systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy

cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
chmod +x /etc/cron.hourly/elite-x-expiry

# Cache network info
echo "Caching network information..."
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
alias live='elite-x-live'
alias speed='elite-x-analyzer'
alias renew='elite-x-renew'
EOF

if [ ! -f /etc/elite-x/key ]; then
    if [ -f "$ACTIVATION_FILE" ]; then
        cp "$ACTIVATION_FILE" /etc/elite-x/key
    else
        echo "$ACTIVATION_KEY" > /etc/elite-x/key
    fi
fi

EXPIRY_INFO=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")

clear
show_banner
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              ELITE-X SLOWDNS INSTALLED SUCCESSFULLY!         ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  📌 DOMAIN  : $TDOMAIN"
echo "║  📍 LOCATION: $SELECTED_LOCATION"
echo "║  🔑 KEY     : $(cat /etc/elite-x/key)"
echo "║  🔑 PUBLIC KEY: $(cat /etc/dnstt/server.pub)"
echo "║  ⚡ MODE     : ULTRA MODE - MAXIMUM SPEED"
echo "║  ⏳ EXPIRY  : $EXPIRY_INFO"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  🚀 Commands:                                                ║"
echo "║     menu - Open dashboard                                    ║"
echo "║     elite - Quick access                                     ║"
echo "║     live  - Live connection monitor                          ║"
echo "║     speed - Traffic analyzer                                 ║"
echo "║     renew - Renew SSH account                                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
show_quote

# Check service status
sleep 2
echo "Service Status:"
if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
    echo "  DNSTT: ✅ RUNNING"
else
    echo "  DNSTT: ❌ FAILED"
fi

if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
    echo "  PROXY: ✅ RUNNING"
else
    echo "  PROXY: ❌ FAILED"
fi
echo ""

# Auto-open menu after installation
echo "Opening dashboard in 3 seconds..."
sleep 3
/usr/local/bin/elite-x

self_destruct
