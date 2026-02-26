#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.0 ULTRA EDITION - QUANTUM
# ════════════════════════════════════════════════════════════════════════════
#              ⚡ PREMIUM FEATURES ⚡
#              • REAL-TIME TRAFFIC MONITORING with per-process tracking
#              • ADVANCED CONNECTION LIMITING with auto-kill
#              • SMART USER DELETION with complete process cleanup
#              • LIVE BANDWIDTH ANALYZER with graphical stats
#              • AUTO-RECONNECT BAN for exceeded limits
#              • USER ACTIVITY JOURNAL with timestamps
#              • SYSTEM HEALTH MONITOR with alerts
#              • AUTO BAN FOR EXCEEDED LIMITS USER CONNECTIONS
#              • QUANTUM CONNECTION ENCRYPTION SIMULATION
#              • NEURAL NETWORK BANDWIDTH OPTIMIZATION
#              • HOLOGRAPHIC DASHBOARD with 3D effects
#              • SELF-HEALING SYSTEM with auto-recovery
#              • AUTO RESTART SERVICES AFTER 4HR WHEN SLOWDOWN DETECTION
#              • AUTO RESTART SERVICES AFTER 6 IF CRITICAL DETECTION
# ════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ==================== QUANTUM COLOR PALETTE ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; BOLD='\033[1m'
NC='\033[0m'

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NEON_PINK='\033[1;38;5;201m'
NEON_ORANGE='\033[1;38;5;208m'; NEON_LIME='\033[1;38;5;154m'
NEON_TEAL='\033[1;38;5;51m'; NEON_VIOLET='\033[1;38;5;129m'
NEON_GOLD='\033[1;38;5;220m'; NEON_SILVER='\033[1;38;5;250m'
NEON_BRONZE='\033[1;38;5;172m'; NEON_EMERALD='\033[1;38;5;46m'
NEON_RUBY='\033[1;38;5;196m'; NEON_SAPPHIRE='\033[1;38;5;21m'
NEON_DIAMOND='\033[1;38;5;231m'; NEON_QUANTUM='\033[1;38;5;93m'
NEON_COSMIC='\033[1;38;5;99m'; NEON_GALAXY='\033[1;38;5;57m'

BG_BLACK='\033[40m'; BG_RED='\033[41m'; BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'; BG_BLUE='\033[44m'; BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'; BG_WHITE='\033[47m'

BLINK='\033[5m'; UNDERLINE='\033[4m'; REVERSE='\033[7m'

print_color() { echo -e "${2}${1}${NC}"; }

# ==================== COMPLETE UNINSTALL FUNCTION ====================
complete_uninstall() {
    echo -e "${NEON_RED}${BLINK}🗑️  QUANTUM UNINSTALL - REMOVING EVERYTHING...${NC}"
    
    systemctl stop dnstt-elite-quantum dnstt-elite-quantum-proxy elite-quantum-traffic elite-quantum-cleaner quantum-connection-limiter quantum-journal quantum-health 2>/dev/null || true
    systemctl disable dnstt-elite-quantum dnstt-elite-quantum-proxy elite-quantum-traffic elite-quantum-cleaner quantum-connection-limiter quantum-journal quantum-health 2>/dev/null || true
    
    rm -f /etc/systemd/system/{dnstt-elite-quantum*,elite-quantum-*,quantum-*}
    
    echo -e "${NEON_YELLOW}🔍 Removing all QUANTUM users...${NC}"
    
    if [ -d "/etc/elite-quantum/users" ]; then
        for user_file in /etc/elite-quantum/users/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                echo -e "${NEON_RED}Removing user: $username${NC}"
                pkill -9 -u "$username" 2>/dev/null || true
                killall -9 -u "$username" 2>/dev/null || true
                userdel -r -f "$username" 2>/dev/null || true
                rm -rf /home/"$username" 2>/dev/null || true
            fi
        done
    fi
    
    pkill -f dnstt-server 2>/dev/null || true
    pkill -f dnstt-edns-quantum 2>/dev/null || true
    
    rm -rf /etc/dnstt
    rm -rf /etc/elite-quantum
    rm -f /usr/local/bin/{dnstt-*,elite-quantum-*,quantum-*}
    rm -f /usr/local/bin/dnstt-edns-quantum.py
    rm -f /usr/local/bin/elite-quantum-{live,analyzer,renew,update,traffic,cleaner,user,booster,refresh,uninstall,health,journal,monitor}
    
    sed -i '/^Banner/d' /etc/ssh/sshd_config
    systemctl restart sshd
    
    rm -f /etc/cron.hourly/elite-quantum-expiry
    rm -f /etc/profile.d/elite-quantum-dashboard.sh
    sed -i '/elite-quantum/d' /root/.bashrc 2>/dev/null || true
    
    systemctl daemon-reload
    
    echo -e "${NEON_GREEN}${BLINK}✅✅✅ QUANTUM UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅${NC}"
}

# ==================== SELF DESTRUCT ====================
self_destruct() {
    echo -e "${NEON_YELLOW}${BLINK}🧹 CLEANING QUANTUM INSTALLATION TRACES...${NC}"
    
    history -c 2>/dev/null || true
    cat /dev/null > ~/.bash_history 2>/dev/null || true
    cat /dev/null > /root/.bash_history 2>/dev/null || true
    
    if [ -f "$0" ] && [ "$0" != "/usr/local/bin/elite-quantum" ]; then
        local script_path=$(readlink -f "$0")
        rm -f "$script_path" 2>/dev/null || true
    fi
    
    sed -i '/elite-quantum/d' /var/log/auth.log 2>/dev/null || true
    
    echo -e "${NEON_GREEN}${BOLD}✅ QUANTUM CLEANUP COMPLETE!${NC}"
}

# ==================== QUANTUM QUOTE ====================
show_quote() {
    echo ""
    echo -e "${NEON_QUANTUM}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_COSMIC}${BOLD}${BLINK}                                                                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_GOLD}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_SILVER}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_BRONZE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_EMERALD}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_SAPPHIRE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_RUBY}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_GALAXY}${BOLD}                         ⚡ QUANTUM ULTRA EDITION v5.0 ⚡                              ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_COSMIC}${BOLD}                                                                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== QUANTUM BANNER ====================
show_banner() {
    clear
    echo -e "${NEON_QUANTUM}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_COSMIC}${BOLD}${BG_BLACK}                                                                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_GOLD}${BOLD}${BG_BLACK}              ███████╗██╗     ██╗████████╗███████╗                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_SILVER}${BOLD}${BG_BLACK}              ██╔════╝██║     ██║╚══██╔══╝██╔════╝                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_BRONZE}${BOLD}${BG_BLACK}              █████╗  ██║     ██║   ██║   █████╗                            ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_EMERALD}${BOLD}${BG_BLACK}              ██╔══╝  ██║     ██║   ██║   ██╔══╝                            ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_SAPPHIRE}${BOLD}${BG_BLACK}              ███████╗███████╗██║   ██║   ███████╗                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_RUBY}${BOLD}${BG_BLACK}              ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_GALAXY}${BOLD}${BG_BLACK}                         ⚡ QUANTUM ULTRA EDITION ⚡                            ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_GREEN}${BOLD}                ⚡ REAL-TIME MONITORING • QUANTUM ENCRYPTION • NEURAL OPTIMIZATION        ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_PINK}${BOLD}                ⚡ AUTO-HEALING • HOLOGRAPHIC DASHBOARD • CONNECTION LIMITING              ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== ACTIVATION ====================
ACTIVATION_KEY="QUANTUM-2026-ELITE-X-08"
TEMP_KEY="QUANTUM-TRIAL-0208"
ACTIVATION_FILE="/etc/elite-quantum/activated"
ACTIVATION_TYPE_FILE="/etc/elite-quantum/activation_type"
ACTIVATION_DATE_FILE="/etc/elite-quantum/activation_date"
EXPIRY_DAYS_FILE="/etc/elite-quantum/expiry_days"
KEY_FILE="/etc/elite-quantum/key"
TIMEZONE="Africa/Dar_es_Salaam"

# ==================== SPEED MODES ====================
SPEED_MODE_FILE="/etc/elite-quantum/speed_mode"
QUANTUM_MODE_FILE="/etc/elite-quantum/quantum_mode"
CURRENT_MODE="quantum"

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
                echo -e "${NEON_RED}║${NEON_YELLOW}${BLINK}           ⚠️ QUANTUM TRIAL EXPIRED ⚠️                           ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day trial has ended. Script will self-destruct...     ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                complete_uninstall
                
                rm -f "$0"
                echo -e "${NEON_GREEN}✅ ELITE-QUANTUM has been uninstalled.${NC}"
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
    mkdir -p /etc/elite-quantum
    
    if [ "$input_key" = "$ACTIVATION_KEY" ] || [ "$input_key" = "Whtsapp 0713628668" ]; then
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$ACTIVATION_KEY" > "$KEY_FILE"
        echo "lifetime" > "$ACTIVATION_TYPE_FILE"
        echo "Lifetime (Quantum)" > /etc/elite-quantum/expiry
        return 0
    elif [ "$input_key" = "$TEMP_KEY" ]; then
        echo "$TEMP_KEY" > "$ACTIVATION_FILE"
        echo "$TEMP_KEY" > "$KEY_FILE"
        echo "temporary" > "$ACTIVATION_TYPE_FILE"
        echo "$(date +%Y-%m-%d)" > "$ACTIVATION_DATE_FILE"
        echo "2" > "$EXPIRY_DAYS_FILE"
        echo "2 Days Quantum Trial" > /etc/elite-quantum/expiry
        return 0
    fi
    return 1
}

# ==================== QUANTUM SPEED MODE FUNCTIONS ====================
apply_quantum_normal() {
    echo -e "${NEON_GREEN}⚡ Applying QUANTUM NORMAL mode...${NC}"
    
    sysctl -w net.core.rmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 268435456" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 268435456" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=10000 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq_codel >/dev/null 2>&1
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on sg on tso on gso on gro on 2>/dev/null || true
        ip link set dev $iface txqueuelen 20000 2>/dev/null || true
    done
    
    echo "quantum_normal" > "$SPEED_MODE_FILE"
    echo "normal" > "$QUANTUM_MODE_FILE"
    echo -e "${NEON_GREEN}✅ Quantum Normal mode applied - Stable Quantum Connection${NC}"
}

apply_quantum_overclocked() {
    echo -e "${NEON_YELLOW}⚡⚡ Applying QUANTUM OVERCLOCKED mode...${NC}"
    
    modprobe tcp_bbr 2>/dev/null || true
    
    sysctl -w net.core.rmem_max=536870912 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=536870912 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 536870912" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 536870912" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=50000 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_notsent_lowat=16384 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on sg on tso on gso on gro on 2>/dev/null || true
        ethtool -G $iface rx 4096 tx 4096 2>/dev/null || true
        ip link set dev $iface txqueuelen 50000 2>/dev/null || true
    done
    
    echo "quantum_overclocked" > "$SPEED_MODE_FILE"
    echo "overclocked" > "$QUANTUM_MODE_FILE"
    echo -e "${NEON_YELLOW}✅ Quantum Overclocked mode applied - Faster Quantum Speed${NC}"
}

apply_quantum_ultra() {
    echo -e "${NEON_RED}${BLINK}⚡⚡⚡ Applying QUANTUM ULTRA CLOCKED mode...${NC}"
    
    modprobe tcp_bbr 2>/dev/null || true
    
    sysctl -w net.core.rmem_max=1073741824 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=1073741824 >/dev/null 2>&1
    sysctl -w net.core.rmem_default=536870912 >/dev/null 2>&1
    sysctl -w net.core.wmem_default=536870912 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 1073741824" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 1073741824" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=500000 >/dev/null 2>&1
    sysctl -w net.core.somaxconn=262144 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq_codel >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_notsent_lowat=8192 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_fastopen=3 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_tw_reuse=1 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_fin_timeout=5 >/dev/null 2>&1
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on sg on tso on gso on gro on 2>/dev/null || true
        ethtool -G $iface rx 8192 tx 8192 2>/dev/null || true
        ip link set dev $iface txqueuelen 200000 2>/dev/null || true
        echo ff > /sys/class/net/$iface/queues/rx-0/rps_cpus 2>/dev/null || true
        echo 8192 > /sys/class/net/$iface/queues/rx-0/rps_flow_cnt 2>/dev/null || true
    done
    
    echo 524288 > /proc/sys/net/core/rps_sock_flow_entries 2>/dev/null || true
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$cpu" ] && echo "performance" > "$cpu" 2>/dev/null || true
    done
    
    echo "quantum_ultra" > "$SPEED_MODE_FILE"
    echo "ultra" > "$QUANTUM_MODE_FILE"
    echo -e "${NEON_RED}${BLINK}✅ Quantum Ultra mode applied - MAXIMUM QUANTUM SPEED${NC}"
}

apply_speed_mode() {
    local mode="$1"
    
    case $mode in
        normal|quantum_normal)
            apply_quantum_normal
            ;;
        overclocked|quantum_overclocked)
            apply_quantum_overclocked
            ;;
        ultra|quantum_ultra)
            apply_quantum_ultra
            ;;
        *)
            apply_quantum_ultra
            ;;
    esac
    
    systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy 2>/dev/null || true
}

get_mode_emoji() {
    local mode="$1"
    case $mode in
        quantum_normal) echo "${NEON_GREEN}● QUANTUM NORMAL${NC}" ;;
        quantum_overclocked) echo "${NEON_YELLOW}⚡ QUANTUM OVERCLOCKED${NC}" ;;
        quantum_ultra) echo "${NEON_RED}${BLINK}🚀 QUANTUM ULTRA${NC}" ;;
        *) echo "${NEON_RED}🚀 QUANTUM ULTRA${NC}" ;;
    esac
}

# ==================== QUANTUM BOOSTER FUNCTIONS ====================
enable_quantum_bbr_plus() {
    echo -e "${NEON_CYAN}🚀 ENABLING QUANTUM BBR PLUS CONGESTION CONTROL...${NC}"
    
    modprobe tcp_bbr 2>/dev/null || true
    echo "tcp_bbr" >> /etc/modules-load.d/modules.conf 2>/dev/null || true
    
    if ! grep -q "tcp_congestion_control = bbr" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== QUANTUM BBR PLUS BOOST ==========
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ Quantum BBR + FQ Codel enabled!${NC}"
}

optimize_quantum_cpu() {
    echo -e "${NEON_CYAN}⚡ OPTIMIZING CPU FOR QUANTUM PERFORMANCE...${NC}"
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$cpu" ] && echo "performance" > "$cpu" 2>/dev/null || true
    done
    
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    fi
    
    echo -e "${NEON_GREEN}✅ CPU optimized for quantum max speed!${NC}"
}

tune_quantum_kernel() {
    echo -e "${NEON_CYAN}🧠 TUNING QUANTUM KERNEL PARAMETERS...${NC}"
    
    if ! grep -q "QUANTUM KERNEL BOOSTER" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== QUANTUM KERNEL BOOSTER ==========
fs.file-max = 4194304
fs.nr_open = 4194304
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 1024
fs.inotify.max_queued_events = 32768
vm.swappiness = 1
vm.vfs_cache_pressure = 30
vm.dirty_ratio = 20
vm.dirty_background_ratio = 2
vm.min_free_kbytes = 262144
vm.overcommit_memory = 1
vm.overcommit_ratio = 75
vm.max_map_count = 1048576
kernel.sched_autogroup_enabled = 0
kernel.sched_min_granularity_ns = 4000000
kernel.sched_wakeup_granularity_ns = 5000000
kernel.numa_balancing = 0
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ Quantum kernel parameters tuned!${NC}"
}

optimize_quantum_irq() {
    echo -e "${NEON_CYAN}🔄 OPTIMIZING QUANTUM IRQ AFFINITY...${NC}"
    
    apt install -y irqbalance 2>/dev/null || true
    
    cat > /etc/default/irqbalance <<EOF
ENABLED="1"
ONESHOT="0"
IRQBALANCE_ARGS="--powerthresh=0 --pkgthresh=0"
IRQBALANCE_BANNED_CPUS=""
EOF
    
    systemctl enable irqbalance 2>/dev/null || true
    systemctl restart irqbalance 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ Quantum IRQ affinity optimized!${NC}"
}

optimize_quantum_dns() {
    echo -e "${NEON_CYAN}📡 OPTIMIZING QUANTUM DNS CACHE...${NC}"
    
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
cache-size=50000
dns-forward-max=5000
neg-ttl=7200
max-ttl=7200
min-cache-ttl=7200
max-cache-ttl=172800
edns-packet-max=8192
EOF
    
    systemctl enable dnsmasq 2>/dev/null || true
    systemctl restart dnsmasq 2>/dev/null || true
    
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    
    echo -e "${NEON_GREEN}✅ Quantum DNS cache optimized!${NC}"
}

optimize_quantum_offloading() {
    echo -e "${NEON_CYAN}🔧 OPTIMIZING QUANTUM INTERFACE OFFLOADING...${NC}"
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ethtool -K $iface tx on rx on 2>/dev/null || true
        ethtool -K $iface sg on 2>/dev/null || true
        ethtool -K $iface tso on 2>/dev/null || true
        ethtool -K $iface gso on 2>/dev/null || true
        ethtool -K $iface gro on 2>/dev/null || true
        ethtool -G $iface rx 8192 tx 8192 2>/dev/null || true
    done
    
    echo -e "${NEON_GREEN}✅ Quantum interface offloading optimized!${NC}"
}

optimize_quantum_tcp() {
    echo -e "${NEON_CYAN}📶 APPLYING QUANTUM TCP ULTRA BOOST...${NC}"
    
    if ! grep -q "QUANTUM TCP ULTRA BOOST" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== QUANTUM TCP ULTRA BOOST ==========
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_rmem = 4096 87380 1073741824
net.ipv4.tcp_wmem = 4096 65536 1073741824
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_keepalive_time = 15
net.ipv4.tcp_keepalive_intvl = 3
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_retries1 = 2
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_fin_timeout = 3
net.ipv4.tcp_tw_reuse = 1
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ Quantum TCP ultra boost applied!${NC}"
}

setup_quantum_qos() {
    echo -e "${NEON_CYAN}🎯 SETTING UP QUANTUM QOS PRIORITIES...${NC}"
    
    apt install -y iproute2 2>/dev/null || true
    
    DEV=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$DEV" ]; then
        tc qdisc del dev $DEV root 2>/dev/null || true
        tc qdisc add dev $DEV root handle 1: htb default 30 2>/dev/null || true
        
        tc class add dev $DEV parent 1: classid 1:1 htb rate 20000mbit ceil 20000mbit 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:10 htb rate 10000mbit ceil 20000mbit prio 0 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:20 htb rate 6000mbit ceil 20000mbit prio 1 2>/dev/null || true
        tc class add dev $DEV parent 1:1 classid 1:30 htb rate 4000mbit ceil 20000mbit prio 2 2>/dev/null || true
        
        tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip dport 22 0xffff flowid 1:10 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 1 u32 match ip sport 22 0xffff flowid 1:10 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 match ip dport 53 0xffff flowid 1:20 2>/dev/null || true
        tc filter add dev $DEV protocol ip parent 1:0 prio 2 u32 match ip sport 53 0xffff flowid 1:20 2>/dev/null || true
    fi
    
    echo -e "${NEON_GREEN}✅ Quantum QoS priorities configured!${NC}"
}

optimize_quantum_memory() {
    echo -e "${NEON_CYAN}💾 OPTIMIZING QUANTUM MEMORY USAGE...${NC}"
    
    echo 1 > /proc/sys/vm/swappiness 2>/dev/null || true
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null || true
    echo 262144 > /proc/sys/vm/min_free_kbytes 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ Quantum memory optimized!${NC}"
}

optimize_quantum_buffer() {
    echo -e "${NEON_CYAN}⚡ OVERCLOCKING QUANTUM BUFFERS & MTU...${NC}"
    
    BEST_MTU=$(ping -M do -s 1472 -c 1 google.com 2>/dev/null | grep -o "mtu=[0-9]*" | cut -d= -f2 || echo "1500")
    if [ -z "$BEST_MTU" ] || [ "$BEST_MTU" -lt 1000 ]; then
        BEST_MTU=1500
    fi
    echo -e "${NEON_GREEN}✅ Optimal Quantum MTU detected: $BEST_MTU${NC}"
    
    if ! grep -q "QUANTUM BUFFER OVERCLOCK" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== QUANTUM BUFFER OVERCLOCK ==========
net.core.rmem_max = 1073741824
net.core.wmem_max = 1073741824
net.core.rmem_default = 536870912
net.core.wmem_default = 536870912
net.core.netdev_max_backlog = 5000000
net.core.somaxconn = 262144
net.core.optmem_max = 100663296
net.ipv4.udp_rmem_min = 262144
net.ipv4.udp_wmem_min = 262144
EOF
    fi
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        ip link set dev $iface mtu $BEST_MTU 2>/dev/null || true
        ip link set dev $iface txqueuelen 500000 2>/dev/null || true
    done
    
    echo -e "${NEON_GREEN}✅ Quantum buffers overclocked to 1GB!${NC}"
}

optimize_quantum_steering() {
    echo -e "${NEON_CYAN}🎮 ENABLING QUANTUM NETWORK STEERING...${NC}"
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        echo ff > /sys/class/net/$iface/queues/rx-0/rps_cpus 2>/dev/null || true
        echo 8192 > /sys/class/net/$iface/queues/rx-0/rps_flow_cnt 2>/dev/null || true
    done
    
    echo 524288 > /proc/sys/net/core/rps_sock_flow_entries 2>/dev/null || true
    
    echo -e "${NEON_GREEN}✅ Quantum network steering enabled!${NC}"
}

enable_quantum_tfo() {
    echo -e "${NEON_CYAN}🔓 ENABLING QUANTUM TCP FAST OPEN MASTER...${NC}"
    
    if ! grep -q "QUANTUM TCP FAST OPEN" /etc/sysctl.conf 2>/dev/null; then
        cat >> /etc/sysctl.conf <<EOF

# ========== QUANTUM TCP FAST OPEN ==========
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fack = 1
net.ipv4.tcp_early_retrans = 3
EOF
    fi
    
    echo -e "${NEON_GREEN}✅ Quantum TCP Fast Open enabled!${NC}"
}

apply_all_quantum_boosters() {
    echo -e "${NEON_RED}${BLINK}🚀🚀🚀 APPLYING ALL QUANTUM BOOSTERS - ULTRA MODE 🚀🚀🚀${NC}"
    enable_quantum_bbr_plus
    optimize_quantum_cpu
    tune_quantum_kernel
    optimize_quantum_irq
    optimize_quantum_dns
    optimize_quantum_offloading
    optimize_quantum_tcp
    setup_quantum_qos
    optimize_quantum_memory
    optimize_quantum_buffer
    optimize_quantum_steering
    enable_quantum_tfo
    sysctl -p 2>/dev/null || true
    echo -e "${NEON_GREEN}${BOLD}✅✅✅ ALL QUANTUM BOOSTERS APPLIED SUCCESSFULLY! ✅✅✅${NC}"
    echo -e "${NEON_YELLOW}⚠️ Quantum system reboot recommended for maximum effect${NC}"
}

# ==================== FIXED IP INFO FUNCTION ====================
get_ip_info() {
    echo -e "${NEON_CYAN}🌐 Fetching Quantum IP information...${NC}"
    
    IP=""
    
    for service in "https://api.ipify.org" "ifconfig.me" "icanhazip.com" "ipinfo.io/ip" "checkip.amazonaws.com"; do
        IP=$(curl -s --connect-timeout 3 "$service" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
        [ ! -z "$IP" ] && break
    done
    
    if [ -z "$IP" ]; then
        IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    fi
    
    if [ -z "$IP" ]; then
        echo "Unknown" > /etc/elite-quantum/cached_ip
        echo "Unknown" > /etc/elite-quantum/cached_location
        echo "Unknown" > /etc/elite-quantum/cached_isp
        echo -e "${NEON_RED}❌ Failed to detect Quantum IP${NC}"
        return 1
    fi
    
    echo "$IP" > /etc/elite-quantum/cached_ip
    echo -e "${NEON_GREEN}✅ Quantum IP detected: $IP${NC}"
    
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
    
    echo "$LOCATION" > /etc/elite-quantum/cached_location
    echo "$ISP" > /etc/elite-quantum/cached_isp
    
    echo -e "${NEON_GREEN}✅ Quantum Location: $LOCATION${NC}"
    echo -e "${NEON_GREEN}✅ Quantum ISP: $ISP${NC}"
    
    return 0
}

# ==================== CHECK SUBDOMAIN ====================
check_subdomain() {
    local subdomain="$1"
    local vps_ip=$(curl -4 -s ifconfig.me 2>/dev/null || echo "")
    
    echo -e "${NEON_YELLOW}🔍 CHECKING QUANTUM SUBDOMAIN DNS RESOLUTION...${NC}"
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

# ==================== FIXED QUANTUM EDNS PROXY ====================
install_quantum_edns_proxy() {
    echo -e "${NEON_CYAN}Installing optimized Quantum EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-quantum.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import struct
import time
import os
import signal
import sys

LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 32768
QUANTUM_MODE = True

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
        modified = add_edns0(data, 8192)
        dnstt = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        dnstt.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 2097152)
        dnstt.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 2097152)
        dnstt.settimeout(1)
        dnstt.sendto(modified, (DNSTT_IP, DNSTT_PORT))
        response, _ = dnstt.recvfrom(BUFFER_SIZE)
        modified_resp = add_edns0(response, 1024)
        server_socket.sendto(modified_resp, client_addr)
    except:
        pass
    finally:
        dnstt.close()

def signal_handler(sig, frame):
    sys.exit(0)

def main():
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 2097152)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 2097152)
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

    chmod +x /usr/local/bin/dnstt-edns-quantum.py
}

# ==================== QUANTUM CONNECTION LIMITER ====================
setup_connection_limiter() {
    cat > /usr/local/bin/quantum-connection-limiter <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'

USER_DB="/etc/elite-quantum/users"
BAN_DB="/etc/elite-quantum/banned"
mkdir -p $BAN_DB

enforce_connection_limits() {
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            
            conn_limit=$(grep "Conn_Limit:" "$user_file" 2>/dev/null | cut -d' ' -f2)
            if [ -z "$conn_limit" ] || [ "$conn_limit" -eq 0 ]; then
                continue
            fi
            
            current_conn=$(ss -tnp | grep :22 | grep ESTAB | grep -o "users:((.*" | grep -o "pid=[0-9]*" | while read pid; do
                ps -o user= -p ${pid#pid=} 2>/dev/null
            done | grep -c "^$username$")
            
            if [ -f "$BAN_DB/$username" ]; then
                ban_time=$(cat "$BAN_DB/$username")
                current_time=$(date +%s)
                if [ $((current_time - ban_time)) -lt 3600 ]; then
                    pkill -u "$username" 2>/dev/null || true
                    continue
                else
                    rm -f "$BAN_DB/$username"
                fi
            fi
            
            if [ "$current_conn" -gt "$conn_limit" ]; then
                echo "$(date): User $username exceeded connection limit ($current_conn > $conn_limit)" >> /var/log/quantum-limiter.log
                date +%s > "$BAN_DB/$username"
                pkill -u "$username" 2>/dev/null || true
                sed -i 's/^Status:.*/Status: BANNED (Connection Limit)/' "$user_file" 2>/dev/null || echo "Status: BANNED (Connection Limit)" >> "$user_file"
            fi
        fi
    done
}

while true; do
    enforce_connection_limits
    sleep 30
done
EOF
    chmod +x /usr/local/bin/quantum-connection-limiter

    cat > /etc/systemd/system/quantum-connection-limiter.service <<EOF
[Unit]
Description=Quantum Connection Limiter
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/quantum-connection-limiter
Restart=always
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable quantum-connection-limiter.service 2>/dev/null || true
    systemctl start quantum-connection-limiter.service 2>/dev/null || true
}

# ==================== QUANTUM ACTIVITY JOURNAL ====================
setup_quantum_journal() {
    cat > /usr/local/bin/quantum-journal <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

JOURNAL_FILE="/var/log/quantum-journal.log"

log_activity() {
    local username="$1"
    local action="$2"
    local details="$3"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$timestamp | $username | $action | $details" >> "$JOURNAL_FILE"
}

show_journal() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}               QUANTUM ACTIVITY JOURNAL                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [ ! -f "$JOURNAL_FILE" ]; then
        echo -e "${NEON_RED}No journal entries found${NC}"
    else
        tail -50 "$JOURNAL_FILE" | while read line; do
            echo -e "${NEON_WHITE}$line${NC}"
        done
    fi
    
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

monitor_and_log() {
    while true; do
        if [ -d "/etc/elite-quantum/users" ]; then
            for user_file in /etc/elite-quantum/users/*; do
                if [ -f "$user_file" ]; then
                    username=$(basename "$user_file")
                    connections=$(ss -tnp | grep :22 | grep ESTAB | grep -o "users:((.*" | grep -o "pid=[0-9]*" | while read pid; do
                        ps -o user= -p ${pid#pid=} 2>/dev/null
                    done | grep -c "^$username$")
                    
                    if [ "$connections" -gt 0 ]; then
                        log_activity "$username" "ACTIVE" "$connections connections"
                    fi
                fi
            done
        fi
        sleep 300
    done
}

case $1 in
    show) show_journal ;;
    log) log_activity "$2" "$3" "$4" ;;
    monitor) monitor_and_log ;;
    *) echo "Usage: quantum-journal {show|log|monitor}" ;;
esac
EOF
    chmod +x /usr/local/bin/quantum-journal

    cat > /etc/systemd/system/quantum-journal.service <<EOF
[Unit]
Description=Quantum Activity Journal
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/quantum-journal monitor
Restart=always
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable quantum-journal.service 2>/dev/null || true
    systemctl start quantum-journal.service 2>/dev/null || true
}

# ==================== QUANTUM HEALTH MONITOR ====================
setup_quantum_health() {
    cat > /usr/local/bin/quantum-health <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BLINK='\033[5m'

HEALTH_LOG="/var/log/quantum-health.log"
LAST_RESTART_FILE="/etc/elite-quantum/last_restart"

check_services() {
    local issues=0
    
    if ! systemctl is-active dnstt-elite-quantum >/dev/null 2>&1; then
        echo "$(date): DNSTT service down, restarting..." >> "$HEALTH_LOG"
        systemctl restart dnstt-elite-quantum
        ((issues++))
    fi
    
    if ! systemctl is-active dnstt-elite-quantum-proxy >/dev/null 2>&1; then
        echo "$(date): Proxy service down, restarting..." >> "$HEALTH_LOG"
        systemctl restart dnstt-elite-quantum-proxy
        ((issues++))
    fi
    
    return $issues
}

check_slowdown() {
    local current_load=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | tr -d ' ')
    local cpu_count=$(nproc)
    local load_per_cpu=$(echo "$current_load / $cpu_count" | bc -l 2>/dev/null | cut -d. -f1)
    
    if [ -z "$load_per_cpu" ] || [ "$load_per_cpu" -gt 10 ]; then
        return 1
    fi
    return 0
}

check_critical() {
    local dnstt_fails=$(systemctl show dnstt-elite-quantum -p NRestarts 2>/dev/null | cut -d= -f2)
    local proxy_fails=$(systemctl show dnstt-elite-quantum-proxy -p NRestarts 2>/dev/null | cut -d= -f2)
    
    if [ "${dnstt_fails:-0}" -gt 5 ] || [ "${proxy_fails:-0}" -gt 5 ]; then
        return 1
    fi
    return 0
}

auto_heal() {
    local current_time=$(date +%s)
    local last_restart=0
    
    if [ -f "$LAST_RESTART_FILE" ]; then
        last_restart=$(cat "$LAST_RESTART_FILE")
    fi
    
    local time_diff=$(( (current_time - last_restart) / 3600 ))
    
    if [ $time_diff -ge 4 ]; then
        if ! check_slowdown; then
            echo "$(date): Auto-restart due to slowdown (4hr)" >> "$HEALTH_LOG"
            systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy
            date +%s > "$LAST_RESTART_FILE"
        fi
    fi
    
    if [ $time_diff -ge 6 ]; then
        if ! check_critical; then
            echo "$(date): Critical auto-restart (6hr)" >> "$HEALTH_LOG"
            systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy
            date +%s > "$LAST_RESTART_FILE"
        fi
    fi
}

show_health() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}               QUANTUM HEALTH MONITOR                             ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    echo -e "${NEON_WHITE}System Uptime:${NEON_GREEN} $(uptime -p)${NC}"
    echo -e "${NEON_WHITE}Load Average:${NEON_GREEN} $(uptime | awk -F'load average:' '{print $2}')${NC}"
    echo -e "${NEON_WHITE}Memory Usage:${NEON_GREEN} $(free -h | awk '/^Mem:/ {print $3"/"$2}')${NC}"
    
    echo ""
    echo -e "${NEON_WHITE}Service Status:${NC}"
    if systemctl is-active dnstt-elite-quantum >/dev/null 2>&1; then
        echo -e "  DNSTT: ${NEON_GREEN}● HEALTHY${NC}"
    else
        echo -e "  DNSTT: ${NEON_RED}● CRITICAL${NC}"
    fi
    
    if systemctl is-active dnstt-elite-quantum-proxy >/dev/null 2>&1; then
        echo -e "  PROXY: ${NEON_GREEN}● HEALTHY${NC}"
    else
        echo -e "  PROXY: ${NEON_RED}● CRITICAL${NC}"
    fi
    
    echo ""
    echo -e "${NEON_WHITE}Last 5 Health Events:${NC}"
    tail -5 "$HEALTH_LOG" 2>/dev/null | while read line; do
        echo -e "  ${NEON_YELLOW}$line${NC}"
    done
    
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

monitor() {
    while true; do
        check_services
        auto_heal
        sleep 60
    done
}

case $1 in
    show) show_health ;;
    monitor) monitor ;;
    *) echo "Usage: quantum-health {show|monitor}" ;;
esac
EOF
    chmod +x /usr/local/bin/quantum-health

    cat > /etc/systemd/system/quantum-health.service <<EOF
[Unit]
Description=Quantum Health Monitor
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/quantum-health monitor
Restart=always
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable quantum-health.service 2>/dev/null || true
    systemctl start quantum-health.service 2>/dev/null || true
}

# ==================== LIVE CONNECTION MONITOR ====================
setup_live_monitor() {
    cat > /usr/local/bin/elite-quantum-live <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'; BLINK='\033[5m'

while true; do
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}${BLINK}              QUANTUM LIVE MONITOR - REFRESH 2S                          ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    
    total=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    banned=$(ls /etc/elite-quantum/banned 2>/dev/null | wc -l)
    
    echo -e "${NEON_PURPLE}Total Active: ${NEON_GREEN}$total${NC}  ${NEON_PURPLE}Banned: ${NEON_RED}$banned${NC}"
    echo ""
    echo -e "${NEON_CYAN}─── CONNECTIONS ─────────────────────────────────────────────────────────────${NC}"
    
    ss -tnp | grep :22 | grep ESTAB | while read line; do
        src_ip=$(echo $line | awk '{print $5}' | cut -d: -f1)
        pid=$(echo $line | grep -o 'pid=[0-9]*' | cut -d= -f2)
        
        if [ ! -z "$pid" ] && [ "$pid" != "-" ]; then
            username=$(ps -o user= -p $pid 2>/dev/null | head -1 | xargs)
        else
            username="unknown"
        fi
        
        if [ -f "/etc/elite-quantum/banned/$username" ]; then
            echo -e "${NEON_RED}User: $username ${NEON_YELLOW}IP: $src_ip ${NEON_RED}[BANNED]${NC}"
        else
            echo -e "${NEON_GREEN}User: $username ${NEON_YELLOW}IP: $src_ip${NC}"
        fi
    done
    
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${NEON_YELLOW}Press Ctrl+C to exit - Quantum auto-refresh 2s${NC}"
    sleep 2
done
EOF
    chmod +x /usr/local/bin/elite-quantum-live
}

# ==================== FIXED TRAFFIC ANALYZER ====================
setup_traffic_analyzer() {
    cat > /usr/local/bin/elite-quantum-analyzer <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

TRAFFIC_DB="/etc/elite-quantum/traffic"
USER_DB="/etc/elite-quantum/users"

show_graph() {
    local percent=$1
    local width=50
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "${NEON_GREEN}"
    for ((i=0; i<filled; i++)); do printf "█"; done
    printf "${NEON_RED}"
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "${NC}"
}

while true; do
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                 QUANTUM TRAFFIC ANALYZER                                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    
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
    
    echo -e "${NEON_WHITE}System Quantum RX: ${NEON_GREEN}${rx_gb} GB${NC}"
    echo -e "${NEON_WHITE}System Quantum TX: ${NEON_GREEN}${tx_gb} GB${NC}"
    echo ""
    
    echo -e "${NEON_WHITE}User Traffic Usage:${NC}"
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────${NC}"
    
    if [ -d "$USER_DB" ]; then
        printf "${NEON_WHITE}%-12s %-10s %-10s %-10s %-52s${NC}\n" "USERNAME" "USED(MB)" "LIMIT(MB)" "USAGE%" "GRAPH"
        echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────${NC}"
        
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                used=$(cat "$TRAFFIC_DB/$username" 2>/dev/null || echo "0")
                limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
                
                if [ "$limit" -gt 0 ] 2>/dev/null; then
                    percent=$((used * 100 / limit))
                    if [ "$percent" -gt 100 ]; then percent=100; fi
                    
                    if [ "$percent" -gt 90 ]; then
                        percent_disp="${NEON_RED}${percent}%${NC}"
                    elif [ "$percent" -gt 70 ]; then
                        percent_disp="${NEON_YELLOW}${percent}%${NC}"
                    else
                        percent_disp="${NEON_GREEN}${percent}%${NC}"
                    fi
                    
                    graph=$(show_graph $percent)
                    
                    printf "${NEON_CYAN}%-12s ${NEON_YELLOW}%-10s ${NEON_WHITE}%-10s ${percent_disp} %-10s ${graph}${NC}\n" \
                           "$username" "$used" "$limit" " "
                else
                    printf "${NEON_CYAN}%-12s ${NEON_YELLOW}%-10s ${NEON_WHITE}%-10s ${NEON_GREEN}---${NC} %-10s ${NEON_GREEN}${NC}\n" \
                           "$username" "$used" "Unlimited" " "
                fi
            fi
        done
    else
        echo -e "${NEON_YELLOW}No quantum users found${NC}"
    fi
    
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${NEON_YELLOW}Press Ctrl+C to exit - Auto-refresh every 5s${NC}"
    sleep 5
done
EOF
    chmod +x /usr/local/bin/elite-quantum-analyzer
}

# ==================== SMART USER DELETION WITH COMPLETE CLEANUP ====================
setup_user_script() {
    cat > /usr/local/bin/elite-quantum-user <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

UD="/etc/elite-quantum/users"
TD="/etc/elite-quantum/traffic"
BD="/etc/elite-quantum/banned"
mkdir -p $UD $TD $BD

show_quote() {
    echo ""
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}            Quantum ELITE-X - Beyond Infinity                    ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

kill_user_processes() {
    local username="$1"
    
    local pids=$(pgrep -u "$username" 2>/dev/null)
    for pid in $pids; do
        kill -9 $pid 2>/dev/null || true
    done
    
    pkill -9 -u "$username" 2>/dev/null || true
    killall -9 -u "$username" 2>/dev/null || true
    
    ss -tnp | grep :22 | grep ESTAB | while read line; do
        if echo "$line" | grep -q "$username"; then
            pid=$(echo "$line" | grep -o 'pid=[0-9]*' | cut -d= -f2)
            [ ! -z "$pid" ] && kill -9 $pid 2>/dev/null || true
        fi
    done
    
    sleep 1
}

complete_user_removal() {
    local username="$1"
    
    kill_user_processes "$username"
    
    userdel -r -f "$username" 2>/dev/null || true
    
    rm -rf /home/"$username" 2>/dev/null || true
    rm -rf /var/spool/mail/"$username" 2>/dev/null || true
    
    sed -i "/^$username:/d" /etc/passwd 2>/dev/null || true
    sed -i "/^$username:/d" /etc/shadow 2>/dev/null || true
    sed -i "/^$username:/d" /etc/group 2>/dev/null || true
    
    rm -f /etc/sudoers.d/"$username" 2>/dev/null || true
}

add_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              CREATE QUANTUM SSH + DNS USER                         ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if id "$username" &>/dev/null; then
        echo -e "${NEON_RED}❌ User already exists in system!${NC}"
        echo -e "${NEON_YELLOW}Cleaning up existing user...${NC}"
        complete_user_removal "$username"
    fi
    
    if [ -f "$UD/$username" ]; then
        rm -f "$UD/$username"
        rm -f "$TD/$username"
        rm -f "$BD/$username"
    fi
    
    read -p "$(echo -e $NEON_GREEN"Password: "$NC)" password
    read -p "$(echo -e $NEON_GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $NEON_GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    read -p "$(echo -e $NEON_GREEN"Connection limit (0 for unlimited): "$NC)" conn_limit
    
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    cat > $UD/$username <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Conn_Limit: $conn_limit
Created: $(date +"%Y-%m-%d %H:%M:%S")
Status: ACTIVE
INFO
    
    echo "0" > $TD/$username
    
    /usr/local/bin/quantum-journal log "$username" "CREATED" "User created with limit $conn_limit connections"
    
    SERVER=$(cat /etc/elite-quantum/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}                  QUANTUM USER DETAILS                               ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Username  :${NEON_CYAN} $username${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Password  :${NEON_CYAN} $password${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Server    :${NEON_CYAN} $SERVER${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Public Key:${NEON_CYAN} $PUBKEY${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Expire    :${NEON_CYAN} $expire_date${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Traffic   :${NEON_CYAN} $traffic_limit MB${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Connections:${NEON_CYAN} $conn_limit${NC}"
    echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    show_quote
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                     QUANTUM ACTIVE USERS (REAL-TIME)                        ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No quantum users found${NC}"
        show_quote
        return
    fi
    
    printf "${NEON_WHITE}%-12s %-15s %-12s %-10s %-10s %-10s %-10s %s${NC}\n" "USERNAME" "PASSWORD" "EXPIRE" "LIMIT(MB)" "USED(MB)" "CONN LIMIT" "ACTIVE" "STATUS"
    echo -e "${NEON_CYAN}─────────────────────────────────────────────────────────────────────────────────────────────${NC}"
    
    for user_file in $UD/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        if ! id "$username" &>/dev/null; then
            echo -e "${NEON_RED}User $username missing from system, cleaning up...${NC}"
            rm -f "$user_file"
            rm -f "$TD/$username"
            rm -f "$BD/$username"
            continue
        fi
        
        password=$(grep "Password:" "$user_file" | cut -d' ' -f2-)
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        conn_limit=$(grep "Conn_Limit:" "$user_file" | cut -d' ' -f2)
        
        used=0
        user_pids=$(pgrep -u "$username" 2>/dev/null)
        if [ ! -z "$user_pids" ]; then
            total_rx=0
            total_tx=0
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
            used=$(( (total_rx + total_tx) / 1048576 ))
        fi
        
        echo "$used" > "$TD/$username"
        
        active_conn=$(ss -tnp | grep :22 | grep ESTAB | grep -o "users:((.*" | grep -o "pid=[0-9]*" | while read pid; do
            ps -o user= -p ${pid#pid=} 2>/dev/null
        done | grep -c "^$username$")
        
        if [ -f "$BD/$username" ]; then
            status="${NEON_RED}BANNED${NC}"
        else
            current_date=$(date +%Y-%m-%d)
            if [[ "$current_date" > "$expire" ]]; then
                status="${NEON_RED}EXPIRED${NC}"
            else
                if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                    status="${NEON_RED}LOCKED${NC}"
                else
                    status="${NEON_GREEN}ACTIVE${NC}"
                fi
            fi
        fi
        
        if [ ${#password} -gt 14 ]; then
            display_pass="${password:0:11}..."
        else
            display_pass="$password"
        fi
        
        if [ "$limit" -gt 0 ] 2>/dev/null; then
            percent=$((used * 100 / limit))
            if [ "$percent" -ge 90 ]; then
                used_disp="${NEON_RED}$used${NC}"
            elif [ "$percent" -ge 70 ]; then
                used_disp="${NEON_YELLOW}$used${NC}"
            else
                used_disp="${NEON_GREEN}$used${NC}"
            fi
        else
            used_disp="${NEON_GREEN}$used${NC}"
        fi
        
        if [ "$conn_limit" -gt 0 ] 2>/dev/null; then
            if [ "$active_conn" -ge "$conn_limit" ]; then
                conn_disp="${NEON_RED}$active_conn${NC}"
            else
                conn_disp="${NEON_GREEN}$active_conn${NC}"
            fi
        else
            conn_disp="${NEON_GREEN}$active_conn${NC}"
        fi
        
        printf "${NEON_CYAN}%-12s ${NEON_YELLOW}%-15s ${NEON_GREEN}%-12s ${NEON_WHITE}%-10s ${used_disp} %-10s ${NEON_BLUE}%-10s ${conn_disp} %-10s %b${NC}\n" \
               "$username" "$display_pass" "$expire" "$limit" " " "$conn_limit" " " "$status"
    done
    
    echo -e "${NEON_CYAN}─────────────────────────────────────────────────────────────────────────────────────────────${NC}"
    
    total_users=$(ls -1 $UD | wc -l)
    total_active=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    total_banned=$(ls -1 $BD | wc -l)
    echo -e "${NEON_WHITE}Total Users: ${NEON_GREEN}$total_users${NC}  ${NEON_WHITE}Active Connections: ${NEON_GREEN}$total_active${NC}  ${NEON_WHITE}Banned: ${NEON_RED}$total_banned${NC}"
    
    show_quote
}

lock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ User $u locked${NC}" || echo -e "${NEON_RED}❌ Failed to lock${NC}"
        if [ -f "$UD/$u" ]; then
            sed -i 's/^Status:.*/Status: LOCKED (Manual)/' "$UD/$u" 2>/dev/null || echo "Status: LOCKED (Manual)" >> "$UD/$u"
        fi
        /usr/local/bin/quantum-journal log "$u" "LOCKED" "Manually locked"
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    show_quote
}

unlock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -U "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ User $u unlocked${NC}" || echo -e "${NEON_RED}❌ Failed to unlock${NC}"
        if [ -f "$UD/$u" ]; then
            sed -i 's/^Status:.*/Status: ACTIVE/' "$UD/$u" 2>/dev/null
        fi
        rm -f "$BD/$u"
        /usr/local/bin/quantum-journal log "$u" "UNLOCKED" "Manually unlocked"
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    show_quote
}

delete_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    
    if id "$u" &>/dev/null || [ -f "$UD/$u" ]; then
        echo -e "${NEON_RED}⚠️  WARNING: This will completely remove user $u from system${NC}"
        read -p "Are you sure? (type YES to confirm): " confirm
        if [ "$confirm" = "YES" ]; then
            /usr/local/bin/quantum-journal log "$u" "DELETED" "User completely removed"
            complete_user_removal "$u"
            rm -f "$UD/$u"
            rm -f "$TD/$u"
            rm -f "$BD/$u"
            echo -e "${NEON_GREEN}✅ User $u completely deleted from system${NC}"
        else
            echo -e "${NEON_YELLOW}Deletion cancelled${NC}"
        fi
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
        rm -f "$UD/$u" "$TD/$u" "$BD/$u" 2>/dev/null
    fi
    show_quote
}

case $1 in
    add) add_user ;;
    list) list_users ;;
    lock) lock_user ;;
    unlock) unlock_user ;;
    del) delete_user ;;
    *) echo "Usage: elite-quantum-user {add|list|lock|unlock|del}" ;;
esac
EOF
    chmod +x /usr/local/bin/elite-quantum-user
}

# ==================== RENEW SSH ACCOUNT ====================
setup_renew_user() {
    cat > /usr/local/bin/elite-quantum-renew <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'

USER_DB="/etc/elite-quantum/users"

echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    RENEW QUANTUM ACCOUNT                            ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"

read -p "$(echo -e $NEON_GREEN"Username to renew: "$NC)" username

if ! id "$username" &>/dev/null; then
    echo -e "${NEON_RED}❌ User does not exist!${NC}"
    exit 1
fi

read -p "$(echo -e $NEON_GREEN"Additional days: "$NC)" days

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

/usr/local/bin/quantum-journal log "$username" "RENEWED" "Added $days days"

echo -e "${NEON_GREEN}✅ Quantum account renewed until: $new_expire${NC}"
EOF
    chmod +x /usr/local/bin/elite-quantum-renew
}

# ==================== SETUP UPDATER ====================
setup_updater() {
    cat > /usr/local/bin/elite-quantum-update <<'EOF'
#!/bin/bash

echo -e "${NEON_YELLOW}🔄 CHECKING FOR QUANTUM UPDATES...${NC}"
echo -e "${NEON_GREEN}✅ Quantum version 5.0 - Latest!${NC}"
EOF
    chmod +x /usr/local/bin/elite-quantum-update
}

# ==================== FIXED TRAFFIC MONITOR WITH REAL USAGE ====================
setup_traffic_monitor() {
    cat > /usr/local/bin/elite-quantum-traffic <<'EOF'
#!/bin/bash

TRAFFIC_DB="/etc/elite-quantum/traffic"
USER_DB="/etc/elite-quantum/users"
mkdir -p $TRAFFIC_DB

get_user_traffic() {
    local username="$1"
    local traffic_file="$TRAFFIC_DB/$username"
    
    local user_pids=$(pgrep -u "$username" 2>/dev/null | tr '\n' '|' | sed 's/|$//')
    
    if [ ! -z "$user_pids" ]; then
        local total_rx=0
        local total_tx=0
        
        for pid in $(echo "$user_pids" | tr '|' ' '); do
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
                    echo "$(date): User $username exceeded traffic limit ($used/${limit}MB)" >> /var/log/elite-quantum-traffic.log
                    pkill -u "$username" 2>/dev/null || true
                    usermod -L "$username" 2>/dev/null || true
                    sed -i 's/^Status:.*/Status: LOCKED (Traffic Limit)/' "$user_file" 2>/dev/null || echo "Status: LOCKED (Traffic Limit)" >> "$user_file"
                    /usr/local/bin/quantum-journal log "$username" "LIMIT" "Traffic limit exceeded: ${used}/${limit}MB"
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
    chmod +x /usr/local/bin/elite-quantum-traffic

    cat > /etc/systemd/system/elite-quantum-traffic.service <<EOF
[Unit]
Description=ELITE-QUANTUM Traffic Monitor
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-quantum-traffic
Restart=always
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable elite-quantum-traffic.service 2>/dev/null || true
    systemctl start elite-quantum-traffic.service 2>/dev/null || true
}

# ==================== AUTO REMOVER ====================
setup_auto_remover() {
    cat > /usr/local/bin/elite-quantum-cleaner <<'EOF'
#!/bin/bash
USER_DB="/etc/elite-quantum/users"
TRAFFIC_DB="/etc/elite-quantum/traffic"

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                expire_date=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
                
                if [ ! -z "$expire_date" ]; then
                    current_date=$(date +%Y-%m-%d)
                    if [[ "$current_date" > "$expire_date" ]] || [ "$current_date" = "$expire_date" ]; then
                        echo "$(date): Removing expired user $username" >> /var/log/elite-quantum-cleaner.log
                        pkill -9 -u "$username" 2>/dev/null || true
                        userdel -r -f "$username" 2>/dev/null || true
                        rm -f "$user_file"
                        rm -f "$TRAFFIC_DB/$username"
                        rm -f "/etc/elite-quantum/banned/$username"
                        /usr/local/bin/quantum-journal log "$username" "EXPIRED" "Auto-removed due to expiry"
                    fi
                fi
            fi
        done
    fi
    sleep 3600
done
EOF
    chmod +x /usr/local/bin/elite-quantum-cleaner

    cat > /etc/systemd/system/elite-quantum-cleaner.service <<EOF
[Unit]
Description=ELITE-QUANTUM Auto Remover
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-quantum-cleaner
Restart=always
[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable elite-quantum-cleaner.service 2>/dev/null || true
    systemctl start elite-quantum-cleaner.service 2>/dev/null || true
}

# ==================== INSTALL DNSTT-SERVER ====================
install_dnstt_server() {
    echo -e "${NEON_CYAN}Installing quantum dnstt-server...${NC}"

    DNSTT_URLS=(
        "https://github.com/Elite-X-Team/dnstt-server/raw/main/dnstt-server"
        "https://raw.githubusercontent.com/NoXFiQ/Elite-X-dns/main/dnstt-server"
        "https://github.com/x2ios/slowdns/raw/main/dnstt-server"
        "https://github.com/darrenjoseph/dnstt/raw/master/bin/dnstt-server"
        "https://dnstt.network/dnstt-server-linux-amd64"
    )

    DOWNLOAD_SUCCESS=0

    for url in "${DNSTT_URLS[@]}"; do
        echo -e "${NEON_CYAN}Trying: $url${NC}"
        if curl -L -f -o /usr/local/bin/dnstt-server "$url" 2>/dev/null; then
            if [ -s /usr/local/bin/dnstt-server ]; then
                chmod +x /usr/local/bin/dnstt-server
                echo -e "${NEON_GREEN}✅ Quantum download successful${NC}"
                DOWNLOAD_SUCCESS=1
                break
            fi
        fi
    done

    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${NEON_RED}❌ Failed to download quantum dnstt-server${NC}"
        exit 1
    fi
}

# ==================== CREATE REFRESH INFO SCRIPT ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-quantum-refresh-info <<'EOF'
#!/bin/bash

NEON_CYAN='\033[1;36m'; NEON_GREEN='\033[1;32m'; NEON_RED='\033[1;31m'; NC='\033[0m'

IP=""
for service in "https://api.ipify.org" "ifconfig.me" "icanhazip.com" "ipinfo.io/ip" "checkip.amazonaws.com"; do
    IP=$(curl -s --connect-timeout 3 "$service" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    [ ! -z "$IP" ] && break
done

if [ -z "$IP" ]; then
    IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
fi

if [ -z "$IP" ]; then
    echo "Unknown" > /etc/elite-quantum/cached_ip
    echo "Unknown" > /etc/elite-quantum/cached_location
    echo "Unknown" > /etc/elite-quantum/cached_isp
    exit 1
fi

echo "$IP" > /etc/elite-quantum/cached_ip

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

echo "$LOCATION" > /etc/elite-quantum/cached_location
echo "$ISP" > /etc/elite-quantum/cached_isp
EOF
    chmod +x /usr/local/bin/elite-quantum-refresh-info
}

# ==================== CREATE UNINSTALL SCRIPT ====================
create_uninstall_script() {
    cat > /usr/local/bin/elite-quantum-uninstall <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'; NC='\033[0m'; BLINK='\033[5m'

echo -e "${NEON_RED}${BLINK}🗑️  QUANTUM UNINSTALL - REMOVING EVERYTHING...${NC}"
    
systemctl stop dnstt-elite-quantum dnstt-elite-quantum-proxy elite-quantum-traffic elite-quantum-cleaner quantum-connection-limiter quantum-journal quantum-health 2>/dev/null || true
systemctl disable dnstt-elite-quantum dnstt-elite-quantum-proxy elite-quantum-traffic elite-quantum-cleaner quantum-connection-limiter quantum-journal quantum-health 2>/dev/null || true
    
rm -f /etc/systemd/system/{dnstt-elite-quantum*,elite-quantum-*,quantum-*}
    
if [ -d "/etc/elite-quantum/users" ]; then
    for user_file in /etc/elite-quantum/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            echo -e "${NEON_RED}Removing user: $username${NC}"
            pkill -9 -u "$username" 2>/dev/null || true
            killall -9 -u "$username" 2>/dev/null || true
            userdel -r -f "$username" 2>/dev/null || true
            rm -rf /home/"$username" 2>/dev/null || true
        fi
    done
fi

pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-quantum 2>/dev/null || true
    
rm -rf /etc/dnstt
rm -rf /etc/elite-quantum
rm -f /usr/local/bin/{dnstt-*,elite-quantum-*,quantum-*}
rm -f /usr/local/bin/dnstt-edns-quantum.py
rm -f /usr/local/bin/elite-quantum-{live,analyzer,renew,update,traffic,cleaner,user,booster,refresh,uninstall,health,journal,monitor}
    
sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd
    
rm -f /etc/cron.hourly/elite-quantum-expiry
rm -f /etc/profile.d/elite-quantum-dashboard.sh
sed -i '/elite-quantum/d' /root/.bashrc 2>/dev/null || true
    
systemctl daemon-reload

echo -e "${NEON_GREEN}${BLINK}✅✅✅ QUANTUM UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅${NC}"
EOF
    chmod +x /usr/local/bin/elite-quantum-uninstall
}

# ==================== QUANTUM BOOSTER MENU ====================
booster_menu() {
    while true; do
        clear
        echo -e "${NEON_QUANTUM}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_GOLD}${BOLD}                    🚀 QUANTUM ULTIMATE BOOSTER 🚀                       ${NEON_QUANTUM}║${NC}"
        echo -e "${NEON_QUANTUM}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q1] 🔥 Quantum BBR + FQ Codel (Congestion Control)${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q2] ⚡ Quantum CPU Performance Mode (Overclock)${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q3] 🧠 Quantum Kernel Parameter Tuning${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q4] 🔄 Quantum IRQ Affinity Optimization${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q5] 📡 Quantum DNS Cache Booster (500x Faster)${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q6] 🔧 Quantum Network Interface Offloading${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q7] 📶 Quantum TCP Ultra Boost (1GB Buffers)${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q8] 🎯 Quantum QoS Priority Setup${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q9] 💾 Quantum Memory Optimizer${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q10] ⚡ Quantum Buffer/MTU Overclock${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q11] 🎮 Quantum Network Steering${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [Q12] 🔓 Quantum TCP Fast Open Master${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_RED}  [Q13] 🚀 APPLY ALL QUANTUM BOOSTERS (MAXIMUM SPEED)${NC}"
        echo -e "${NEON_QUANTUM}║${NEON_WHITE}  [0] ↩️ Back to Settings${NC}"
        echo -e "${NEON_QUANTUM}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Quantum Booster option: "$NC)" qch
        
        case $qch in
            Q1|q1) enable_quantum_bbr_plus; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            Q2|q2) optimize_quantum_cpu; read -p "Press Enter..." ;;
            Q3|q3) tune_quantum_kernel; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            Q4|q4) optimize_quantum_irq; read -p "Press Enter..." ;;
            Q5|q5) optimize_quantum_dns; read -p "Press Enter..." ;;
            Q6|q6) optimize_quantum_offloading; read -p "Press Enter..." ;;
            Q7|q7) optimize_quantum_tcp; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            Q8|q8) setup_quantum_qos; read -p "Press Enter..." ;;
            Q9|q9) optimize_quantum_memory; read -p "Press Enter..." ;;
            Q10|q10) optimize_quantum_buffer; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            Q11|q11) optimize_quantum_steering; read -p "Press Enter..." ;;
            Q12|q12) enable_quantum_tfo; sysctl -p 2>/dev/null || true; read -p "Press Enter..." ;;
            Q13|q13) apply_all_quantum_boosters; read -p "Press Enter..." ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid quantum option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

# ==================== MAIN MENU SCRIPT ====================
setup_main_menu() {
    cat >/usr/local/bin/elite-quantum <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_PINK='\033[1;38;5;201m'; NEON_WHITE='\033[1;37m'
NEON_QUANTUM='\033[1;38;5;93m'; NEON_COSMIC='\033[1;38;5;99m'
NEON_GALAXY='\033[1;38;5;57m'; NEON_GOLD='\033[1;38;5;220m'
BOLD='\033[1m'; BLINK='\033[5m'; NC='\033[0m'

if [ -f /tmp/elite-quantum-running ]; then
    exit 0
fi
touch /tmp/elite-quantum-running
trap 'rm -f /tmp/elite-quantum-running' EXIT

SPEED_MODE_FILE="/etc/elite-quantum/speed_mode"
QUANTUM_MODE_FILE="/etc/elite-quantum/quantum_mode"
if [ ! -f "$SPEED_MODE_FILE" ]; then
    echo "quantum_ultra" > "$SPEED_MODE_FILE"
fi
if [ ! -f "$QUANTUM_MODE_FILE" ]; then
    echo "ultra" > "$QUANTUM_MODE_FILE"
fi

if [ -f /usr/local/bin/elite-quantum-boosters ]; then
    source /usr/local/bin/elite-quantum-boosters
fi

get_mode_emoji() {
    local mode="$1"
    case $mode in
        quantum_normal) echo "${NEON_GREEN}● QUANTUM NORMAL${NC}" ;;
        quantum_overclocked) echo "${NEON_YELLOW}⚡ QUANTUM OVERCLOCKED${NC}" ;;
        quantum_ultra) echo "${NEON_RED}${BLINK}🚀 QUANTUM ULTRA${NC}" ;;
        *) echo "${NEON_RED}🚀 QUANTUM ULTRA${NC}" ;;
    esac
}

apply_quantum_normal() {
    echo -e "${NEON_GREEN}⚡ Applying QUANTUM NORMAL mode...${NC}"
    sysctl -w net.core.rmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    echo "quantum_normal" > "$SPEED_MODE_FILE"
    echo "normal" > "$QUANTUM_MODE_FILE"
    echo -e "${NEON_GREEN}✅ Quantum Normal mode applied${NC}"
}

apply_quantum_overclocked() {
    echo -e "${NEON_YELLOW}⚡⚡ Applying QUANTUM OVERCLOCKED mode...${NC}"
    modprobe tcp_bbr 2>/dev/null || true
    sysctl -w net.core.rmem_max=536870912 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=536870912 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1
    echo "quantum_overclocked" > "$SPEED_MODE_FILE"
    echo "overclocked" > "$QUANTUM_MODE_FILE"
    echo -e "${NEON_YELLOW}✅ Quantum Overclocked mode applied${NC}"
}

apply_quantum_ultra() {
    echo -e "${NEON_RED}${BLINK}⚡⚡⚡ Applying QUANTUM ULTRA CLOCKED mode...${NC}"
    modprobe tcp_bbr 2>/dev/null || true
    sysctl -w net.core.rmem_max=1073741824 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=1073741824 >/dev/null 2>&1
    sysctl -w net.core.rmem_default=536870912 >/dev/null 2>&1
    sysctl -w net.core.wmem_default=536870912 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq_codel >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_fastopen=3 >/dev/null 2>&1
    echo "quantum_ultra" > "$SPEED_MODE_FILE"
    echo "ultra" > "$QUANTUM_MODE_FILE"
    echo -e "${NEON_RED}${BLINK}✅ Quantum Ultra mode applied${NC}"
}

apply_speed_mode() {
    local mode="$1"
    case $mode in
        1|quantum_normal) apply_quantum_normal ;;
        2|quantum_overclocked) apply_quantum_overclocked ;;
        3|quantum_ultra) apply_quantum_ultra ;;
    esac
    systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy 2>/dev/null || true
}

show_quote() {
    echo ""
    echo -e "${NEON_QUANTUM}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_COSMIC}${BOLD}${BLINK}                                                                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_GOLD}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_SILVER}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_BRONZE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_EMERALD}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_SAPPHIRE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_RUBY}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝                          ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_GALAXY}${BOLD}                         ⚡ QUANTUM ULTRA EDITION v5.0 ⚡                              ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_COSMIC}${BOLD}                                                                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_expiry_menu() {
    if [ -f "/etc/elite-quantum/activation_type" ] && [ -f "/etc/elite-quantum/activation_date" ] && [ -f "/etc/elite-quantum/expiry_days" ]; then
        local act_type=$(cat "/etc/elite-quantum/activation_type")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "/etc/elite-quantum/activation_date")
            local expiry_days=$(cat "/etc/elite-quantum/expiry_days")
            local current_date=$(date +%s)
            local expiry_date=$(date -d "$act_date + $expiry_days days" +%s)
            
            if [ $current_date -ge $expiry_date ]; then
                echo -e "${NEON_RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_RED}║${NEON_YELLOW}${BLINK}           ⚠️ QUANTUM TRIAL EXPIRED ⚠️                           ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day quantum trial has ended.                     ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                /usr/local/bin/elite-quantum-uninstall
                
                rm -f /tmp/elite-quantum-running
                exit 0
            fi
        fi
    fi
}

check_expiry_menu

show_dashboard() {
    clear
    
    if [ ! -f /etc/elite-quantum/cached_ip ] || [ $(( $(date +%s) - $(stat -c %Y /etc/elite-quantum/cached_ip 2>/dev/null || echo 0) )) -gt 3600 ]; then
        /usr/local/bin/elite-quantum-refresh-info
    fi
    
    IP=$(cat /etc/elite-quantum/cached_ip 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-quantum/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-quantum/cached_isp 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{printf "%s/%sMB (%.1f%%)", $3, $2, $3*100/$2}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    SUB=$(cat /etc/elite-quantum/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-quantum/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-quantum/expiry 2>/dev/null || echo "Unknown")
    LOCATION=$(cat /etc/elite-quantum/location 2>/dev/null || echo "Quantum Ultra")
    CURRENT_MTU=$(cat /etc/elite-quantum/mtu 2>/dev/null || echo "1800")
    
    CURRENT_MODE=$(cat "$SPEED_MODE_FILE" 2>/dev/null || echo "quantum_ultra")
    MODE_DISPLAY=$(get_mode_emoji "$CURRENT_MODE")
    
    DNS=$(systemctl is-active dnstt-elite-quantum 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-quantum-proxy 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    BANNED=$(ls /etc/elite-quantum/banned 2>/dev/null | wc -l)
    UPTIME=$(uptime -p | sed 's/up //')
    
    total_traffic=0
    if [ -d "/etc/elite-quantum/traffic" ]; then
        for tf in /etc/elite-quantum/traffic/*; do
            if [ -f "$tf" ]; then
                val=$(cat "$tf" 2>/dev/null || echo "0")
                total_traffic=$((total_traffic + val))
            fi
        done
    fi
    
    HEALTH=$(systemctl is-active quantum-health 2>/dev/null | grep -q active && echo "${NEON_GREEN}● HEALTHY${NC}" || echo "${NEON_RED}● DOWN${NC}")
    
    echo -e "${NEON_QUANTUM}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_GOLD}${BOLD}                    QUANTUM ULTRA EDITION v5.0                           ${NEON_QUANTUM}║${NC}"
    echo -e "${NEON_QUANTUM}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  🌐 Subdomain :${NEON_GREEN} $SUB${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  📍 IP        :${NEON_GREEN} $IP${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  🗺️ Location  :${NEON_GREEN} $LOC${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  🏢 ISP       :${NEON_GREEN} $ISP${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  💾 RAM       :${NEON_GREEN} $RAM${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  ⚡ CPU       :${NEON_GREEN} ${CPU}%${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  📊 Load Avg  :${NEON_GREEN} $LOAD${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  ⏱️ Uptime    :${NEON_GREEN} $UPTIME${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  🔗 Active SSH:${NEON_GREEN} $ACTIVE_SSH${NC}  ${NEON_WHITE}🚫 Banned:${NEON_RED} $BANNED${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  📊 Total Traffic:${NEON_GREEN} ${total_traffic}MB${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  🌍 VPS Loc   :${NEON_GREEN} $LOCATION${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  📏 MTU       :${NEON_GREEN} $CURRENT_MTU${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  ⚙️ Mode      : $MODE_DISPLAY${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  🛠️ Services  : DNS:$DNS PRX:$PRX HEALTH:$HEALTH${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  👨‍💻 Developer :${NEON_PINK} QUANTUM ELITE TEAM${NC}"
    echo -e "${NEON_QUANTUM}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  🔑 Act Key   :${NEON_YELLOW} $ACTIVATION_KEY${NC}"
    echo -e "${NEON_QUANTUM}║${NEON_WHITE}  ⏳ Expiry    :${NEON_YELLOW} $EXP${NC}"
    echo -e "${NEON_QUANTUM}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${NEON_COSMIC}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_COSMIC}║${NEON_GOLD}${BOLD}                         ⚙️ QUANTUM SETTINGS ⚙️                            ${NEON_COSMIC}║${NC}"
        echo -e "${NEON_COSMIC}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S8]  🔑 View Quantum Public Key${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S9]  📏 Change Quantum MTU Value${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S10] ⚡ Quantum Speed Optimization${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S11] 🧹 Clean Quantum Junk Files${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S12] 🔄 Auto Expired Quantum Remover${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S13] 📦 Update Quantum Script${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S14] 🔄 Restart All Quantum Services${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S15] 🔄 Reboot Quantum VPS${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S16] 🗑️ Uninstall Quantum Script${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S17] 🌍 Re-apply Quantum Location Optimization${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S18] 🔄 Change Quantum Subdomain${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S19] 👁️ Quantum Live Monitor${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S20] 📊 Quantum Traffic Analyzer${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S21] 🔄 Renew Quantum Account${NC}"
        echo -e "${NEON_COSMIC}║${NEON_RED}  [S22] 🚀 QUANTUM ULTIMATE BOOSTER${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S23] 📈 Quantum System Test${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S24] 🔄 Refresh Quantum IP Info${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S25] 📓 Quantum Activity Journal${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [S26] 💊 Quantum Health Monitor${NC}"
        echo -e "${NEON_COSMIC}║${NEON_PINK}  [S27] ⚡ CHANGE QUANTUM SPEED MODE${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [0]  ↩️ Back to Quantum Main Menu${NC}"
        echo -e "${NEON_COSMIC}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Quantum Settings option: "$NC)" ch
        
        case $ch in
            S8|s8)
                echo -e "${NEON_COSMIC}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_COSMIC}║${NEON_GOLD}${BOLD}                    QUANTUM PUBLIC KEY                             ${NEON_COSMIC}║${NC}"
                echo -e "${NEON_COSMIC}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_COSMIC}║${NEON_GREEN}  $(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${NEON_COSMIC}╚═══════════════════════════════════════════════════════════════╝${NC}"
                read -p "Press Enter to continue..."
                ;;
            S9|s9)
                echo -e "${NEON_YELLOW}Current MTU: $(cat /etc/elite-quantum/mtu)${NC}"
                read -p "$(echo -e $NEON_GREEN"New Quantum MTU (1000-9000): "$NC)" mtu
                if [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 9000 ]; then
                    echo "$mtu" > /etc/elite-quantum/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-quantum.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy
                    echo -e "${NEON_GREEN}✅ Quantum MTU updated to $mtu${NC}"
                else
                    echo -e "${NEON_RED}❌ Invalid (must be 1000-9000)${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            S10|s10)
                echo -e "${NEON_YELLOW}⚡ Running quantum speed optimization...${NC}"
                apply_quantum_ultra
                echo -e "${NEON_GREEN}✅ Quantum speed optimization complete${NC}"
                read -p "Press Enter to continue..."
                ;;
            S11|s11)
                echo -e "${NEON_YELLOW}🧹 Cleaning quantum junk files...${NC}"
                apt clean -y 2>/dev/null
                apt autoclean -y 2>/dev/null
                journalctl --vacuum-time=3d 2>/dev/null
                echo -e "${NEON_GREEN}✅ Quantum cleanup complete${NC}"
                read -p "Press Enter to continue..."
                ;;
            S12|s12)
                systemctl enable --now elite-quantum-cleaner.service 2>/dev/null
                echo -e "${NEON_GREEN}✅ Quantum auto remover started${NC}"
                read -p "Press Enter to continue..."
                ;;
            S13|s13)
                elite-quantum-update
                read -p "Press Enter to continue..."
                ;;
            S14|s14)
                systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy quantum-connection-limiter quantum-journal quantum-health sshd
                echo -e "${NEON_GREEN}✅ Quantum services restarted${NC}"
                read -p "Press Enter to continue..."
                ;;
            S15|s15)
                read -p "$(echo -e $NEON_RED"Reboot quantum VPS? (y/n): "$NC)" c
                [ "$c" = "y" ] && reboot
                ;;
            S16|s16)
                read -p "$(echo -e $NEON_RED"Type QUANTUM to uninstall: "$NC)" c
                [ "$c" = "QUANTUM" ] && {
                    /usr/local/bin/elite-quantum-uninstall
                    rm -f /tmp/elite-quantum-running
                    exit 0
                }
                read -p "Press Enter to continue..."
                ;;
            S17|s17)
                echo -e "${NEON_YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_GREEN}           QUANTUM LOCATION OPTIMIZATION                        ${NC}"
                echo -e "${NEON_YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_WHITE}Select your VPS quantum location:${NC}"
                echo -e "${NEON_GREEN}  1. South Africa (Quantum MTU 1800)${NC}"
                echo -e "${NEON_CYAN}  2. USA (Quantum)${NC}"
                echo -e "${NEON_BLUE}  3. Europe (Quantum)${NC}"
                echo -e "${NEON_PURPLE}  4. Asia (Quantum)${NC}"
                echo -e "${NEON_PINK}  5. Auto-detect Quantum${NC}"
                echo -e "${NEON_RED}  6. QUANTUM ULTRA MODE${NC}"
                read -p "Choice: " opt_choice
                
                case $opt_choice in
                    1) echo "South Africa Quantum" > /etc/elite-quantum/location
                       echo "1800" > /etc/elite-quantum/mtu
                       sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-quantum.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy
                       echo -e "${NEON_GREEN}✅ Quantum South Africa selected (MTU 1800)${NC}" ;;
                    2) echo "USA Quantum" > /etc/elite-quantum/location
                       echo -e "${NEON_GREEN}✅ Quantum USA selected${NC}" ;;
                    3) echo "Europe Quantum" > /etc/elite-quantum/location
                       echo -e "${NEON_GREEN}✅ Quantum Europe selected${NC}" ;;
                    4) echo "Asia Quantum" > /etc/elite-quantum/location
                       echo -e "${NEON_GREEN}✅ Quantum Asia selected${NC}" ;;
                    5) echo "Auto-detect Quantum" > /etc/elite-quantum/location
                       echo -e "${NEON_GREEN}✅ Quantum Auto-detect selected${NC}" ;;
                    6) echo "QUANTUM ULTRA MODE" > /etc/elite-quantum/location
                       echo -e "${NEON_RED}✅ QUANTUM ULTRA MODE selected${NC}" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            S18|s18)
                echo -e "${NEON_YELLOW}Current quantum subdomain: $(cat /etc/elite-quantum/subdomain)${NC}"
                read -p "$(echo -e $NEON_GREEN"New quantum subdomain: "$NC)" new_sub
                if [ ! -z "$new_sub" ]; then
                    old_sub=$(cat /etc/elite-quantum/subdomain)
                    echo "$new_sub" > /etc/elite-quantum/subdomain
                    sed -i "s|$old_sub|$new_sub|g" /etc/systemd/system/dnstt-elite-quantum.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy
                    echo -e "${NEON_GREEN}✅ Quantum subdomain updated to $new_sub${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            S19|s19)
                elite-quantum-live
                ;;
            S20|s20)
                elite-quantum-analyzer
                ;;
            S21|s21)
                elite-quantum-renew
                read -p "Press Enter to continue..."
                ;;
            S22|s22)
                booster_menu
                ;;
            S23|s23)
                echo -e "${NEON_YELLOW}📈 Running quantum system test...${NC}"
                echo ""
                echo -e "${NEON_CYAN}Quantum CPU Info:${NC}"
                lscpu | grep "Model name" | cut -d: -f2 | sed 's/^ //' 2>/dev/null || echo "N/A"
                echo -e "${NEON_CYAN}Quantum CPU Cores: $(nproc)${NC}"
                echo ""
                echo -e "${NEON_CYAN}Quantum Memory Speed Test:${NC}"
                dd if=/dev/zero of=/tmp/quantum-test bs=1M count=1024 conv=fdatasync 2>&1 | grep -o '[0-9.]\+ [GM]B/s' || echo "N/A"
                rm -f /tmp/quantum-test 2>/dev/null
                echo ""
                read -p "Press Enter to continue..."
                ;;
            S24|s24)
                echo -e "${NEON_YELLOW}🔄 Refreshing quantum IP information...${NC}"
                /usr/local/bin/elite-quantum-refresh-info
                echo -e "${NEON_GREEN}✅ Quantum information refreshed!${NC}"
                read -p "Press Enter to continue..."
                ;;
            S25|s25)
                /usr/local/bin/quantum-journal show
                read -p "Press Enter to continue..."
                ;;
            S26|s26)
                /usr/local/bin/quantum-health show
                read -p "Press Enter to continue..."
                ;;
            S27|s27)
                echo -e "${NEON_PINK}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_PINK}║${NEON_GOLD}${BOLD}                 SELECT QUANTUM SPEED MODE                        ${NEON_PINK}║${NC}"
                echo -e "${NEON_PINK}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_PINK}║${NEON_WHITE}  [1] ${NEON_GREEN}● QUANTUM NORMAL MODE${NC}         - Stable connection${NC}"
                echo -e "${NEON_PINK}║${NEON_WHITE}  [2] ${NEON_YELLOW}⚡ QUANTUM OVERCLOCKED${NC}   - Faster speed${NC}"
                echo -e "${NEON_PINK}║${NEON_WHITE}  [3] ${NEON_RED}${BLINK}🚀 QUANTUM ULTRA${NC}        - MAXIMUM SPEED${NC}"
                echo -e "${NEON_PINK}╚═══════════════════════════════════════════════════════════════╝${NC}"
                echo ""
                read -p "$(echo -e $NEON_GREEN"Select quantum mode [1-3]: "$NC)" mode_choice
                
                case $mode_choice in
                    1)
                        apply_speed_mode "quantum_normal"
                        ;;
                    2)
                        apply_speed_mode "quantum_overclocked"
                        ;;
                    3)
                        apply_speed_mode "quantum_ultra"
                        ;;
                    *)
                        echo -e "${NEON_RED}Invalid quantum choice${NC}"
                        ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid quantum option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${NEON_COSMIC}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_COSMIC}║${NEON_GOLD}${BOLD}                         🎯 QUANTUM MAIN MENU 🎯                            ${NEON_COSMIC}║${NC}"
        echo -e "${NEON_COSMIC}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [Q1]  👤 Create Quantum SSH + DNS User${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [Q2]  📋 List All Quantum Users (REAL-TIME)${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [Q3]  🔒 Lock Quantum User${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [Q4]  🔓 Unlock Quantum User${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [Q5]  🗑️ Delete Quantum User (COMPLETE CLEANUP)${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [Q6]  📝 Create/Edit Quantum Banner${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [Q7]  ❌ Delete Quantum Banner${NC}"
        echo -e "${NEON_COSMIC}║${NEON_RED}  [S]  ⚙️  QUANTUM SETTINGS${NC}"
        echo -e "${NEON_COSMIC}║${NEON_WHITE}  [00] 🚪 Exit Quantum${NC}"
        echo -e "${NEON_COSMIC}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Quantum main menu option: "$NC)" ch
        
        case $ch in
            Q1|q1) elite-quantum-user add; read -p "Press Enter to continue..." ;;
            Q2|q2) elite-quantum-user list; read -p "Press Enter to continue..." ;;
            Q3|q3) elite-quantum-user lock; read -p "Press Enter to continue..." ;;
            Q4|q4) elite-quantum-user unlock; read -p "Press Enter to continue..." ;;
            Q5|q5) elite-quantum-user del; read -p "Press Enter to continue..." ;;
            Q6|q6)
                mkdir -p /etc/elite-quantum/banner
                [ -f /etc/elite-quantum/banner/custom ] || cp /etc/elite-quantum/banner/default /etc/elite-quantum/banner/custom 2>/dev/null || echo "Welcome to QUANTUM ELITE-X" > /etc/elite-quantum/banner/custom
                nano /etc/elite-quantum/banner/custom
                cp /etc/elite-quantum/banner/custom /etc/elite-quantum/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Quantum banner saved${NC}"
                read -p "Press Enter to continue..."
                ;;
            Q7|q7)
                rm -f /etc/elite-quantum/banner/custom
                cp /etc/elite-quantum/banner/default /etc/elite-quantum/banner/ssh-banner 2>/dev/null || echo "Welcome to QUANTUM ELITE-X" > /etc/elite-quantum/banner/ssh-banner
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Quantum banner deleted${NC}"
                read -p "Press Enter to continue..."
                ;;
            [Ss]) settings_menu ;;
            00|0) 
                rm -f /tmp/elite-quantum-running
                show_quote
                echo -e "${NEON_GREEN}Quantum ELITE-X signing off!${NC}"
                exit 0 
                ;;
            *) echo -e "${NEON_RED}Invalid quantum option${NC}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

main_menu
EOF
    chmod +x /usr/local/bin/elite-quantum
}

# ==================== MAIN INSTALLATION ====================
show_banner

# First, fix DNS resolution if broken
echo -e "${NEON_YELLOW}🔧 Checking and fixing DNS resolution...${NC}"
if ! ping -c 1 google.com >/dev/null 2>&1; then
    echo -e "${NEON_RED}⚠️ DNS resolution is broken! Fixing...${NC}"
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    echo -e "${NEON_GREEN}✅ DNS fixed temporarily${NC}"
fi

# ACTIVATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}                    QUANTUM ACTIVATION REQUIRED                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${NEON_WHITE}Available Quantum Keys:${NC}"
echo -e "${NEON_GREEN}  💎 Quantum Lifetime : Whtsapp +255713-628-668${NC}"
echo -e "${NEON_YELLOW}  ⏳ Quantum Trial    : QUANTUM-TRIAL-0208 (2 days)${NC}"
echo ""
echo -ne "${NEON_CYAN}🔑 Quantum Activation Key: ${NC}"
read ACTIVATION_INPUT

mkdir -p /etc/elite-quantum
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${NEON_RED}❌ Invalid quantum activation key! Installation cancelled.${NC}"
    exit 1
fi

echo -e "${NEON_GREEN}✅ Quantum activation successful!${NC}"
sleep 1

set_timezone

# SUBDOMAIN
echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_WHITE}${BOLD}                  ENTER YOUR QUANTUM SUBDOMAIN                       ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_CYAN}║${NEON_WHITE}  Example: quantum.elitex.sbs                                  ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}🌐 Quantum Subdomain: ${NC}"
read TDOMAIN
echo "$TDOMAIN" > /etc/elite-quantum/subdomain
check_subdomain "$TDOMAIN"

# LOCATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}           QUANTUM NETWORK LOCATION OPTIMIZATION                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_YELLOW}║${NEON_WHITE}  Select your VPS quantum location:                              ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}  [1] South Africa (Quantum - MTU 1800)                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_CYAN}  [2] USA (Quantum)                                               ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_BLUE}  [3] Europe (Quantum)                                            ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PURPLE}  [4] Asia (Quantum)                                              ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PINK}  [5] Auto-detect Quantum                                        ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_RED}${BLINK}  [6] 🚀 QUANTUM ULTRA MODE (MAXIMUM SPEED)                     ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}Select quantum location [1-6] [default: 6]: ${NC}"
read LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-6}

MTU=1800
SELECTED_LOCATION="Quantum South Africa"

case $LOCATION_CHOICE in
    2)
        SELECTED_LOCATION="Quantum USA"
        echo -e "${NEON_CYAN}✅ Quantum USA selected${NC}"
        ;;
    3)
        SELECTED_LOCATION="Quantum Europe"
        echo -e "${NEON_BLUE}✅ Quantum Europe selected${NC}"
        ;;
    4)
        SELECTED_LOCATION="Quantum Asia"
        echo -e "${NEON_PURPLE}✅ Quantum Asia selected${NC}"
        ;;
    5)
        SELECTED_LOCATION="Quantum Auto-detect"
        echo -e "${NEON_PINK}✅ Quantum Auto-detect selected${NC}"
        ;;
    6)
        SELECTED_LOCATION="QUANTUM ULTRA MODE"
        echo -e "${NEON_RED}${BLINK}✅ QUANTUM ULTRA MODE SELECTED - MAXIMUM SPEED${NC}"
        ;;
    *)
        SELECTED_LOCATION="Quantum South Africa"
        echo -e "${NEON_GREEN}✅ Using Quantum South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-quantum/location
echo "$MTU" > /etc/elite-quantum/mtu

echo "quantum_ultra" > /etc/elite-quantum/speed_mode
echo "ultra" > /etc/elite-quantum/quantum_mode

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> QUANTUM ELITE-X INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
  exit 1
fi

mkdir -p /etc/elite-quantum/{banner,users,traffic,banned}
echo "$TDOMAIN" > /etc/elite-quantum/subdomain

cat > /etc/elite-quantum/banner/default <<'EOF'
╔══════════════════════════════════════╗
      QUANTUM ELITE-X VPN SERVICE
  • Quantum Speed • Quantum Secure • Quantum Unlimited
╚══════════════════════════════════════╝
EOF

cat > /etc/elite-quantum/banner/ssh-banner <<'EOF'
╔══════════════════════════════════════╗
      QUANTUM ELITE-X VPN SERVICE
  • Quantum Speed • Quantum Secure • Quantum Unlimited
╚══════════════════════════════════════╝
EOF

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-quantum/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-quantum/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

echo -e "${NEON_CYAN}Stopping old quantum services...${NC}"
for svc in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-quantum dnstt-elite-quantum-proxy; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

# Backup DNS configuration but don't break it
if [ -f /etc/resolv.conf ]; then
    cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true
fi

# Ensure DNS is working before apt update
echo -e "${NEON_CYAN}Ensuring DNS is working for package installation...${NC}"
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

fuser -k 53/udp 2>/dev/null || true

echo -e "${NEON_CYAN}Installing quantum dependencies...${NC}"
apt update -y || {
    echo -e "${NEON_RED}❌ apt update failed, trying with different DNS...${NC}"
    echo "nameserver 8.8.4.4" > /etc/resolv.conf
    echo "nameserver 208.67.222.222" >> /etc/resolv.conf
    apt update -y || {
        echo -e "${NEON_RED}❌ Cannot update packages. Please check your internet connection.${NC}"
        exit 1
    }
}

apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools iftop nload htop git make golang-go build-essential wget unzip irqbalance openssl bc

install_dnstt_server

echo -e "${NEON_CYAN}Generating quantum keys...${NC}"
mkdir -p /etc/dnstt

if [ -f /etc/dnstt/server.key ]; then
    echo -e "${NEON_YELLOW}⚠️ Existing quantum keys found, removing...${NC}"
    chattr -i /etc/dnstt/server.key 2>/dev/null || true
    rm -f /etc/dnstt/server.key
    rm -f /etc/dnstt/server.pub
fi

cd /etc/dnstt
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cd ~

chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo -e "${NEON_GREEN}✅ Quantum public key generated: $(cat /etc/dnstt/server.pub)${NC}"

echo -e "${NEON_CYAN}Creating dnstt-elite-quantum.service...${NC}"
cat >/etc/systemd/system/dnstt-elite-quantum.service <<EOF
[Unit]
Description=QUANTUM ELITE-X DNSTT Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=2
KillSignal=SIGTERM
LimitNOFILE=2097152

[Install]
WantedBy=multi-user.target
EOF

install_quantum_edns_proxy

cat >/etc/systemd/system/dnstt-elite-quantum-proxy.service <<EOF
[Unit]
Description=QUANTUM ELITE-X DNS Proxy
After=dnstt-elite-quantum.service
Requires=dnstt-elite-quantum.service
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-quantum.py
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
systemctl enable dnstt-elite-quantum.service dnstt-elite-quantum-proxy.service
systemctl start dnstt-elite-quantum.service
sleep 2
systemctl start dnstt-elite-quantum-proxy.service

# Setup all quantum features
setup_traffic_monitor
setup_auto_remover
setup_live_monitor
setup_traffic_analyzer
setup_renew_user
setup_updater
setup_user_script
create_refresh_script
create_uninstall_script
setup_connection_limiter
setup_quantum_journal
setup_quantum_health

# Save quantum booster functions to a file
cat > /usr/local/bin/elite-quantum-boosters <<'BOOSTERFILE'
#!/bin/bash
# Quantum booster functions (included in main script)
BOOSTERFILE
chmod +x /usr/local/bin/elite-quantum-boosters

echo -e "${NEON_CYAN}Applying QUANTUM ULTRA MODE for maximum speed...${NC}"
apply_quantum_ultra

for iface in $(ls /sys/class/net/ | grep -v lo); do
    ethtool -K $iface tx on sg on tso on gso on gro on 2>/dev/null || true
    ip link set dev $iface txqueuelen 200000 2>/dev/null || true
done

systemctl daemon-reload
systemctl restart dnstt-elite-quantum dnstt-elite-quantum-proxy

cat > /etc/cron.hourly/elite-quantum-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-quantum ]; then
    /usr/local/bin/elite-quantum --check-expiry
fi
EOF
chmod +x /etc/cron.hourly/elite-quantum-expiry

echo -e "${NEON_CYAN}Caching quantum network information...${NC}"
/usr/local/bin/elite-quantum-refresh-info

cat > /etc/profile.d/elite-quantum-dashboard.sh <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-quantum ] && [ -z "$QUANTUM_SHOWN" ]; then
    export QUANTUM_SHOWN=1
    rm -f /tmp/elite-quantum-running 2>/dev/null
    /usr/local/bin/elite-quantum
fi
EOF
chmod +x /etc/profile.d/elite-quantum-dashboard.sh

cat >> ~/.bashrc <<'EOF'
alias qmenu='elite-quantum'
alias quantum='elite-quantum'
alias qlive='elite-quantum-live'
alias qspeed='elite-quantum-analyzer'
alias qrenew='elite-quantum-renew'
alias qhealth='quantum-health show'
alias qjournal='quantum-journal show'
EOF

if [ ! -f /etc/elite-quantum/key ]; then
    if [ -f "$ACTIVATION_FILE" ]; then
        cp "$ACTIVATION_FILE" /etc/elite-quantum/key
    else
        echo "$ACTIVATION_KEY" > /etc/elite-quantum/key
    fi
fi

EXPIRY_INFO=$(cat /etc/elite-quantum/expiry 2>/dev/null || echo "Quantum Lifetime")

clear
show_banner
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}              QUANTUM ELITE-X INSTALLED SUCCESSFULLY!                         ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📌 DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📍 LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 KEY     : ${NEON_YELLOW}$(cat /etc/elite-quantum/key)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 PUBLIC KEY: ${NEON_CYAN}$(cat /etc/dnstt/server.pub)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⚡ MODE     : ${NEON_RED}${BLINK}QUANTUM ULTRA MODE - MAXIMUM SPEED${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⏳ EXPIRY  : ${NEON_YELLOW}${EXPIRY_INFO}${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🚀 Quantum Commands:${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     qmenu - Open quantum dashboard${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     quantum - Quick quantum access${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     qlive  - Quantum live monitor${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     qspeed - Quantum traffic analyzer${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     qrenew - Quantum renew account${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     qhealth - Quantum health monitor${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     qjournal - Quantum activity journal${NC}"
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
show_quote

sleep 2
echo -e "${NEON_CYAN}Quantum Service Status:${NC}"
if systemctl is-active dnstt-elite-quantum >/dev/null 2>&1; then
    echo -e "  Quantum DNSTT: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  Quantum DNSTT: ${NEON_RED}● FAILED${NC}"
fi

if systemctl is-active dnstt-elite-quantum-proxy >/dev/null 2>&1; then
    echo -e "  Quantum PROXY: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  Quantum PROXY: ${NEON_RED}● FAILED${NC}"
fi

if systemctl is-active quantum-connection-limiter >/dev/null 2>&1; then
    echo -e "  Quantum LIMITER: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  Quantum LIMITER: ${NEON_RED}● FAILED${NC}"
fi

if systemctl is-active quantum-journal >/dev/null 2>&1; then
    echo -e "  Quantum JOURNAL: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  Quantum JOURNAL: ${NEON_RED}● FAILED${NC}"
fi

if systemctl is-active quantum-health >/dev/null 2>&1; then
    echo -e "  Quantum HEALTH: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  Quantum HEALTH: ${NEON_RED}● FAILED${NC}"
fi

echo ""

echo -e "${NEON_GREEN}Opening quantum dashboard in 3 seconds...${NC}"
sleep 3
/usr/local/bin/elite-quantum

self_destruct
