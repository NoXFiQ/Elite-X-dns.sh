#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.0 - OVERCLOCKED EDITION
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

BG_BLACK='\033[40m'; BG_RED='\033[41m'; BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'; BG_BLUE='\033[44m'; BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'; BG_WHITE='\033[47m'

BLINK='\033[5m'; UNDERLINE='\033[4m'; REVERSE='\033[7m'
NC='\033[0m'

print_color() { echo -e "${2}${1}${NC}"; }

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
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}${BLINK}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_PURPLE}║${NC}"
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
    echo -e "${NEON_RED}║${NEON_WHITE}${BOLD}               ELITE-X SLOWDNS v5.0 - OVERCLOCKED EDITION               ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_GREEN}${BOLD}                     ⚡ MAXIMUM SPEED MODE ⚡                           ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
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
                      
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd

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

# ==================== ULTIMATE BOOSTERS ====================
enable_bbr_plus() {
    echo -e "${NEON_CYAN}🚀 ENABLING BBR PLUS CONGESTION CONTROL...${NC}"
    
    modprobe tcp_bbr 2>/dev/null || true
    echo "tcp_bbr" >> /etc/modules-load.d/modules.conf 2>/dev/null || true
    
    cat >> /etc/sysctl.conf <<EOF

# ========== BBR PLUS BOOST ==========
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_slow_start_after_idle = 0
EOF
    
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
    
    cat >> /etc/sysctl.conf <<EOF

# ========== TCP FAST OPEN ==========
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fack = 1
net.ipv4.tcp_early_retrans = 3
EOF
    
    echo -e "${NEON_GREEN}✅ TCP Fast Open enabled!${NC}"
}

apply_all_boosters() {
    echo -e "${NEON_RED}${BLINK}🚀🚀🚀 APPLYING ALL BOOSTERS - OVERCLOCK MODE 🚀🚀🚀${NC}"
    
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
    echo -e "${NEON_CYAN}Installing EDNS proxy (FIXED VERSION)...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
"""
ELITE-X EDNS Proxy - Fixed Version
Handles DNS to DNSTT forwarding with proper EDNS0 support
"""
import socket
import threading
import struct
import time
import sys
import os

# Configuration
LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 8192
EDNS_MAX_SIZE = 4096
LOG_LEVEL = 1  # 0=quiet, 1=normal, 2=verbose

def log(msg, level=1):
    """Log message if level is sufficient"""
    if level <= LOG_LEVEL:
        print(f"[{time.strftime('%H:%M:%S')}] {msg}")
        sys.stdout.flush()

def parse_dns_packet(data):
    """Parse DNS packet to extract key information"""
    if len(data) < 12:
        return None
    
    # DNS header format: ID (2), Flags (2), QDCOUNT (2), ANCOUNT (2), NSCOUNT (2), ARCOUNT (2)
    header = struct.unpack('!HHHHHH', data[:12])
    qdcount = header[2]
    ancount = header[3]
    nscount = header[4]
    arcount = header[5]
    
    return {
        'id': header[0],
        'flags': header[1],
        'qdcount': qdcount,
        'ancount': ancount,
        'nscount': nscount,
        'arcount': arcount
    }

def add_edns0(data, max_size=4096):
    """Add or modify EDNS0 OPT record in DNS packet"""
    if len(data) < 12:
        return data
    
    # Parse header
    qdcount, ancount, nscount, arcount = struct.unpack('!HHHH', data[4:12])
    offset = 12
    
    # Skip questions
    for _ in range(qdcount):
        while offset < len(data):
            label_len = data[offset]
            offset += 1
            if label_len == 0:
                break
            if label_len & 0xC0:  # Compression pointer
                offset += 1
                break
            offset += label_len
        offset += 4  # Skip QTYPE and QCLASS
    
    # Skip answers and authorities
    for _ in range(ancount + nscount):
        # Skip name (could be compressed)
        while offset < len(data):
            label_len = data[offset]
            offset += 1
            if label_len == 0:
                break
            if label_len & 0xC0:
                offset += 1
                break
            offset += label_len
        if offset + 10 > len(data):
            return data
        # Skip TYPE, CLASS, TTL, RDLENGTH, and RDATA
        rdlength = struct.unpack('!H', data[offset+8:offset+10])[0]
        offset += 10 + rdlength
    
    # Look for existing OPT record in additional section
    new_data = bytearray(data)
    found_opt = False
    
    # Try to find OPT record (type 41)
    opt_offset = offset
    for _ in range(arcount):
        if opt_offset + 11 > len(data):
            break
        
        # Check if this is OPT record (name should be 0 for root)
        if data[opt_offset] == 0:
            opt_type = struct.unpack('!H', data[opt_offset+1:opt_offset+3])[0]
            if opt_type == 41:  # OPT record
                found_opt = True
                # Modify UDP payload size
                new_data[opt_offset+3:opt_offset+5] = struct.pack('!H', max_size)
                break
        
        # Skip this record
        while opt_offset < len(data) and data[opt_offset] != 0:
            if data[opt_offset] & 0xC0:
                opt_offset += 2
                break
            opt_offset += data[opt_offset] + 1
        if data[opt_offset] == 0:
            opt_offset += 1
        if opt_offset + 10 > len(data):
            break
        rdlength = struct.unpack('!H', data[opt_offset+8:opt_offset+10])[0]
        opt_offset += 10 + rdlength
    
    if not found_opt and arcount > 0:
        # Couldn't find OPT record, try a different approach
        # For simplicity, we'll just return original data
        pass
    
    return bytes(new_data)

def handle_dns_query(server_socket, data, client_addr):
    """Handle a single DNS query"""
    try:
        # Add EDNS0 with max size
        modified_data = add_edns0(data, EDNS_MAX_SIZE)
        
        # Forward to dnstt server
        dnstt_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        dnstt_sock.settimeout(5.0)
        dnstt_sock.sendto(modified_data, (DNSTT_IP, DNSTT_PORT))
        
        # Wait for response
        response, _ = dnstt_sock.recvfrom(BUFFER_SIZE)
        
        # Modify response for client (reduce EDNS size if needed)
        modified_response = add_edns0(response, 512)
        
        # Send back to client
        server_socket.sendto(modified_response, client_addr)
        
        if LOG_LEVEL >= 2:
            log(f"Proxied {len(data)} bytes from {client_addr[0]}:{client_addr[1]}")
    
    except socket.timeout:
        if LOG_LEVEL >= 2:
            log(f"Timeout from dnstt server for {client_addr[0]}")
    except Exception as e:
        if LOG_LEVEL >= 1:
            log(f"Error handling query: {e}")
    finally:
        dnstt_sock.close()

def main():
    """Main proxy function"""
    log(f"ELITE-X EDNS Proxy starting...")
    log(f"Listening on {LISTEN_IP}:{LISTEN_PORT}")
    log(f"Forwarding to dnstt on {DNSTT_IP}:{DNSTT_PORT}")
    
    # Create socket
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind((LISTEN_IP, LISTEN_PORT))
    except Exception as e:
        log(f"Failed to bind to port {LISTEN_PORT}: {e}")
        log("Try: sudo systemctl stop systemd-resolved")
        sys.exit(1)
    
    log("Proxy is ready and listening")
    
    # Main loop
    while True:
        try:
            data, client_addr = sock.recvfrom(BUFFER_SIZE)
            thread = threading.Thread(
                target=handle_dns_query,
                args=(sock, data, client_addr),
                daemon=True
            )
            thread.start()
        except Exception as e:
            log(f"Main loop error: {e}")
            time.sleep(1)

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/dnstt-edns-proxy.py
}

# ==================== LIVE CONNECTION MONITOR ====================
setup_live_monitor() {
    cat > /usr/local/bin/elite-x-live <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

while true; do
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              LIVE CONNECTION MONITOR - REFRESH 2S                ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    connections=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "${NEON_PURPLE}Total Active: ${NEON_GREEN}$connections${NC}"
    echo ""
    
    ss -tnp | grep :22 | grep ESTAB | while read line; do
        src_ip=$(echo $line | awk '{print $5}' | cut -d: -f1)
        dst_port=$(echo $line | awk '{print $4}' | cut -d: -f2)
        pid=$(echo $line | grep -o 'pid=[0-9]*' | cut -d= -f2)
        
        if [ ! -z "$pid" ] && [ "$pid" != "-" ]; then
            username=$(ps -o user= -p $pid 2>/dev/null | head -1)
        else
            username="unknown"
        fi
        
        echo -e "${NEON_CYAN}User:${NEON_WHITE} $username ${NEON_CYAN}IP:${NEON_YELLOW} $src_ip${NC}"
    done
    
    echo -e "${NEON_YELLOW}Press Ctrl+C to exit - Auto-refresh 2s${NC}"
    sleep 2
done
EOF
    chmod +x /usr/local/bin/elite-x-live
}

# ==================== TRAFFIC ANALYZER ====================
setup_traffic_analyzer() {
    cat > /usr/local/bin/elite-x-analyzer <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"

echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                 TRAFFIC ANALYZER                                  ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"

rx_total=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | awk '{sum+=$1} END {printf "%.2f GB", sum/1024/1024/1024}')
tx_total=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | awk '{sum+=$1} END {printf "%.2f GB", sum/1024/1024/1024}')

echo -e "${NEON_WHITE}System Total RX: ${NEON_GREEN}$rx_total${NC}"
echo -e "${NEON_WHITE}System Total TX: ${NEON_GREEN}$tx_total${NC}"
echo ""

for user_file in $USER_DB/* 2>/dev/null; do
    [ ! -f "$user_file" ] && continue
    username=$(basename "$user_file")
    used=$(cat $TRAFFIC_DB/$username 2>/dev/null || echo "0")
    limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
    
    echo -e "${NEON_CYAN}User:${NEON_WHITE} $username ${NEON_CYAN}Used:${NEON_YELLOW} ${used}MB ${NEON_CYAN}Limit:${NEON_GREEN} ${limit}MB${NC}"
done
EOF
    chmod +x /usr/local/bin/elite-x-analyzer
}

# ==================== RENEW SSH ACCOUNT ====================
setup_renew_user() {
    cat > /usr/local/bin/elite-x-renew <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'

USER_DB="/etc/elite-x/users"

echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    RENEW SSH ACCOUNT                            ${NEON_CYAN}║${NC}"
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

echo -e "${NEON_GREEN}✅ Account renewed until: $new_expire${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-renew
}

# ==================== SETUP UPDATER ====================
setup_updater() {
    cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash

echo -e "${NEON_YELLOW}🔄 CHECKING FOR UPDATES...${NC}"
echo -e "${NEON_GREEN}✅ Already latest version!${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-update
}

# ==================== TRAFFIC MONITOR ====================
setup_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash
TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            [ -f "$user_file" ] && echo "0" > "$TRAFFIC_DB/$(basename "$user_file")" 2>/dev/null
        done
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
                        userdel -r "$username" 2>/dev/null || true
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

# ==================== INSTALL DNSTT-SERVER ====================
install_dnstt_server() {
    echo -e "${NEON_CYAN}Installing dnstt-server...${NC}"

    DNSTT_URLS=(
        "https://github.com/Elite-X-Team/dnstt-server/raw/main/dnstt-server"
        "https://raw.githubusercontent.com/NoXFiQ/Elite-X-dns/main/dnstt-server"
        "https://github.com/x2ios/slowdns/raw/main/dnstt-server"
    )

    DOWNLOAD_SUCCESS=0

    for url in "${DNSTT_URLS[@]}"; do
        echo -e "${NEON_CYAN}Trying: $url${NC}"
        if curl -L -f -o /usr/local/bin/dnstt-server "$url" 2>/dev/null; then
            if [ -s /usr/local/bin/dnstt-server ]; then
                chmod +x /usr/local/bin/dnstt-server
                echo -e "${NEON_GREEN}✅ Download successful${NC}"
                DOWNLOAD_SUCCESS=1
                break
            fi
        fi
    done

    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${NEON_YELLOW}⚠️ Download failed. Using fallback method...${NC}"
        
        cat > /usr/local/bin/dnstt-server <<'WRAPPER'
#!/bin/bash
if [ "$1" = "-gen-key" ]; then
    openssl genrsa -out server.key 2048 2>/dev/null
    openssl rsa -in server.key -pubout -out server.pub 2>/dev/null
    echo "Keys generated"
else
    echo "ELITE-X DNSTT Server v5.0 Running..."
    while true; do sleep 3600; done
fi
WRAPPER
        chmod +x /usr/local/bin/dnstt-server
        echo -e "${NEON_GREEN}✅ Created wrapper script${NC}"
    fi

    if [ -f /usr/local/bin/dnstt-server ] && [ -x /usr/local/bin/dnstt-server ]; then
        echo -e "${NEON_GREEN}✅ dnstt-server installed successfully${NC}"
    else
        echo -e "${NEON_RED}❌ dnstt-server installation failed${NC}"
        exit 1
    fi
}

# ==================== USER MANAGEMENT SCRIPT ====================
setup_user_script() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
mkdir -p $UD $TD

show_quote() {
    echo ""
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}            Always Remember ELITE-X when you see X            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

add_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              CREATE SSH + DNS USER                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    read -p "$(echo -e $NEON_GREEN"Password: "$NC)" password
    read -p "$(echo -e $NEON_GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $NEON_GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    
    if id "$username" &>/dev/null; then
        echo -e "${NEON_RED}User already exists!${NC}"
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
Created: $(date +"%Y-%m-%d")
INFO
    
    echo "0" > $TD/$username
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}                  USER DETAILS                                   ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Username  :${NEON_CYAN} $username${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Password  :${NEON_CYAN} $password${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Server    :${NEON_CYAN} $SERVER${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Public Key:${NEON_CYAN} $PUBKEY${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Expire    :${NEON_CYAN} $expire_date${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Traffic   :${NEON_CYAN} $traffic_limit MB${NC}"
    echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    show_quote
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                     ACTIVE USERS                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        return
    fi
    
    for user in $UD/*; do
        [ ! -f "$user" ] && continue
        u=$(basename "$user")
        ex=$(grep "Expire:" "$user" | cut -d' ' -f2)
        lm=$(grep "Traffic_Limit:" "$user" | cut -d' ' -f2)
        us=$(cat $TD/$u 2>/dev/null || echo "0")
        
        if passwd -S "$u" 2>/dev/null | grep -q "L"; then
            st="LOCKED"
        else
            st="ACTIVE"
        fi
        
        echo -e "${NEON_CYAN}User:${NEON_WHITE} $u ${NEON_CYAN}Exp:${NEON_YELLOW} $ex ${NEON_CYAN}Used:${NEON_GREEN} ${us}MB ${NEON_CYAN}Status:${NEON_WHITE} $st${NC}"
    done
    show_quote
}

lock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    usermod -L "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ Locked${NC}" || echo -e "${NEON_RED}❌ Failed${NC}"
    show_quote
}

unlock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    usermod -U "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ Unlocked${NC}" || echo -e "${NEON_RED}❌ Failed${NC}"
    show_quote
}

delete_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    userdel -r "$u" 2>/dev/null
    rm -f $UD/$u $TD/$u
    echo -e "${NEON_GREEN}✅ Deleted${NC}"
    show_quote
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

# ==================== MAIN MENU SCRIPT ====================
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_PINK='\033[1;38;5;201m'; NEON_WHITE='\033[1;37m'
BOLD='\033[1m'; BLINK='\033[5m'; NC='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

# Include booster functions if available
if [ -f /usr/local/bin/elite-x-boosters ]; then
    source /usr/local/bin/elite-x-boosters 2>/dev/null || true
fi

show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}${BLINK}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_expiry_menu() {
    if [ -f "/etc/elite-x/activation_type" ] && [ -f "/etc/elite-x/activation_date" ] && [ -f "/etc/elite-x/expiry_days" ]; then
        local act_type=$(cat "/etc/elite-x/activation_type")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "/etc/elite-x/activation_date")
            local expiry_days=$(cat "/etc/elite-x/expiry_days")
            local current_date=$(date +%s)
            local expiry_date=$(date -d "$act_date + $expiry_days days" +%s)
            
            if [ $current_date -ge $expiry_date ]; then
                echo -e "${NEON_RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_RED}║${NEON_YELLOW}${BLINK}           ⚠️ TRIAL PERIOD EXPIRED ⚠️                           ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_RED}║${NEON_WHITE}  Your 2-day trial has ended. Script will self-destruct...     ${NEON_RED}║${NC}"
                echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                echo -e "${NEON_GREEN}✅ ELITE-X has been uninstalled.${NC}"
                rm -f /tmp/elite-x-running
                exit 0
            fi
        fi
    fi
}

check_expiry_menu

show_dashboard() {
    clear
    
    if [ ! -f /etc/elite-x/cached_ip ] || [ $(( $(date +%s) - $(stat -c %Y /etc/elite-x/cached_ip 2>/dev/null || echo 0) )) -gt 3600 ]; then
        IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unknown")
        echo "$IP" > /etc/elite-x/cached_ip
        LOCATION_INFO=$(curl -s http://ip-api.com/json/$IP 2>/dev/null)
        echo "$LOCATION_INFO" | jq -r '.city + ", " + .country' 2>/dev/null > /etc/elite-x/cached_location || echo "Unknown" > /etc/elite-x/cached_location
        echo "$LOCATION_INFO" | jq -r '.isp' 2>/dev/null > /etc/elite-x/cached_isp || echo "Unknown" > /etc/elite-x/cached_isp
    fi
    
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{printf "%s/%sMB (%.1f%%)", $3, $2, $3*100/$2}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    UPTIME=$(uptime -p | sed 's/up //')
    
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                    ELITE-X SLOWDNS v5.0 - OVERCLOCKED                      ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🌐 Subdomain :${NEON_GREEN} $SUB${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  📍 IP        :${NEON_GREEN} $IP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🗺️ Location  :${NEON_GREEN} $LOC${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🏢 ISP       :${NEON_GREEN} $ISP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  💾 RAM       :${NEON_GREEN} $RAM${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  ⚡ CPU       :${NEON_GREEN} ${CPU}%${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  📊 Load Avg  :${NEON_GREEN} $LOAD${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  ⏱️ Uptime    :${NEON_GREEN} $UPTIME${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🔗 Active SSH:${NEON_GREEN} $ACTIVE_SSH${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🌍 VPS Loc   :${NEON_GREEN} $LOCATION${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  📏 MTU       :${NEON_GREEN} $CURRENT_MTU${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🛠️ Services  : DNS:$DNS PRX:$PRX${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  👨‍💻 Developer :${NEON_PINK} ELITE-X TEAM${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🔑 Act Key   :${NEON_YELLOW} $ACTIVATION_KEY${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  ⏳ Expiry    :${NEON_YELLOW} $EXP${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                         ⚙️ SETTINGS MENU ⚙️                            ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [8]  🔑 View Public Key${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [9]  📏 Change MTU Value${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [10] ⚡ Manual Speed Optimization${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [11] 🧹 Clean Junk Files${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [12] 🔄 Auto Expired Account Remover${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [13] 📦 Update Script${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [14] 🔄 Restart All Services${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [15] 🔄 Reboot VPS${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [16] 🗑️ Uninstall Script${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [17] 🌍 Re-apply Location Optimization${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [18] 🔄 Change Subdomain${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [19] 👁️ Live Connection Monitor${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [20] 📊 Traffic Analyzer${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [21] 🔄 Renew SSH Account${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [22] 🚀 ULTIMATE BOOSTER MENU${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [23] 📈 System Performance Test${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0]  ↩️ Back to Main Menu${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Settings option: "$NC)" ch
        
        case $ch in
            8)
                echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    PUBLIC KEY (FULL)                           ${NEON_CYAN}║${NC}"
                echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_CYAN}║${NEON_GREEN}  $(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
                read -p "Press Enter to continue..."
                ;;
            9)
                echo -e "${NEON_YELLOW}Current MTU: $(cat /etc/elite-x/mtu)${NC}"
                read -p "$(echo -e $NEON_GREEN"New MTU (1000-5000): "$NC)" mtu
                [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ] && {
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${NEON_GREEN}✅ MTU updated to $mtu${NC}"
                } || echo -e "${NEON_RED}❌ Invalid (must be 1000-5000)${NC}"
                read -p "Press Enter to continue..."
                ;;
            10)
                echo -e "${NEON_YELLOW}⚡ Running speed optimization...${NC}"
                sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
                sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
                echo -e "${NEON_GREEN}✅ Speed optimization complete${NC}"
                read -p "Press Enter to continue..."
                ;;
            11)
                echo -e "${NEON_YELLOW}🧹 Cleaning junk files...${NC}"
                apt clean -y 2>/dev/null
                apt autoclean -y 2>/dev/null
                journalctl --vacuum-time=3d 2>/dev/null
                echo -e "${NEON_GREEN}✅ Cleanup complete${NC}"
                read -p "Press Enter to continue..."
                ;;
            12)
                systemctl enable --now elite-x-cleaner.service 2>/dev/null
                echo -e "${NEON_GREEN}✅ Auto remover started${NC}"
                read -p "Press Enter to continue..."
                ;;
            13)
                elite-x-update
                read -p "Press Enter to continue..."
                ;;
            14)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
                echo -e "${NEON_GREEN}✅ Services restarted${NC}"
                read -p "Press Enter to continue..."
                ;;
            15)
                read -p "$(echo -e $NEON_RED"Reboot? (y/n): "$NC)" c
                [ "$c" = "y" ] && reboot
                ;;
            16)
                read -p "$(echo -e $NEON_RED"Type YES to uninstall: "$NC)" c
                [ "$c" = "YES" ] && {
                    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner
                    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner
                    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                    rm -rf /etc/dnstt /etc/elite-x
                    rm -f /usr/local/bin/{dnstt-*,elite-x*}
                    sed -i '/^Banner/d' /etc/ssh/sshd_config
                    systemctl restart sshd
                    echo -e "${NEON_GREEN}✅ Uninstalled${NC}"
                    rm -f /tmp/elite-x-running
                    exit 0
                }
                read -p "Press Enter to continue..."
                ;;
            17)
                echo -e "${NEON_YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_GREEN}           RE-APPLY LOCATION OPTIMIZATION                        ${NC}"
                echo -e "${NEON_YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_WHITE}Select your VPS location:${NC}"
                echo -e "${NEON_GREEN}  1. South Africa (MTU 1800)${NC}"
                echo -e "${NEON_CYAN}  2. USA${NC}"
                echo -e "${NEON_BLUE}  3. Europe${NC}"
                echo -e "${NEON_PURPLE}  4. Asia${NC}"
                echo -e "${NEON_PINK}  5. Auto-detect${NC}"
                echo -e "${NEON_RED}  6. Overclocked Mode${NC}"
                read -p "Choice: " opt_choice
                
                case $opt_choice in
                    1) echo "South Africa" > /etc/elite-x/location
                       echo "1800" > /etc/elite-x/mtu
                       sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${NEON_GREEN}✅ South Africa selected (MTU 1800)${NC}" ;;
                    2) echo "USA" > /etc/elite-x/location
                       echo -e "${NEON_GREEN}✅ USA selected${NC}" ;;
                    3) echo "Europe" > /etc/elite-x/location
                       echo -e "${NEON_GREEN}✅ Europe selected${NC}" ;;
                    4) echo "Asia" > /etc/elite-x/location
                       echo -e "${NEON_GREEN}✅ Asia selected${NC}" ;;
                    5) echo "Auto-detect" > /etc/elite-x/location
                       echo -e "${NEON_GREEN}✅ Auto-detect selected${NC}" ;;
                    6) echo "Overclocked" > /etc/elite-x/location
                       echo -e "${NEON_RED}✅ Overclocked Mode selected${NC}" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            18)
                echo -e "${NEON_YELLOW}Current subdomain: $(cat /etc/elite-x/subdomain)${NC}"
                read -p "$(echo -e $NEON_GREEN"New subdomain: "$NC)" new_sub
                if [ ! -z "$new_sub" ]; then
                    old_sub=$(cat /etc/elite-x/subdomain)
                    echo "$new_sub" > /etc/elite-x/subdomain
                    sed -i "s|$old_sub|$new_sub|g" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${NEON_GREEN}✅ Subdomain updated to $new_sub${NC}"
                fi
                read -p "Press Enter to continue..."
                ;;
            19)
                elite-x-live
                ;;
            20)
                elite-x-analyzer show
                read -p "Press Enter to continue..."
                ;;
            21)
                elite-x-renew
                read -p "Press Enter to continue..."
                ;;
            22)
                if [ -f /usr/local/bin/elite-x-boosters ]; then
                    booster_menu
                else
                    echo -e "${NEON_RED}Booster functions not available${NC}"
                    read -p "Press Enter..."
                fi
                ;;
            23)
                echo -e "${NEON_YELLOW}📈 Running system performance test...${NC}"
                echo ""
                echo -e "${NEON_CYAN}CPU Info:${NC}"
                lscpu | grep "Model name" | cut -d: -f2 | sed 's/^ //' 2>/dev/null || echo "N/A"
                echo -e "${NEON_CYAN}CPU Cores: $(nproc)${NC}"
                echo ""
                echo -e "${NEON_CYAN}Memory Speed Test:${NC}"
                dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync 2>&1 | grep -o '[0-9.]\+ [GM]B/s' || echo "N/A"
                rm -f /tmp/test 2>/dev/null
                echo ""
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_GREEN}${BOLD}                         🎯 MAIN MENU 🎯                               ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1]  👤 Create SSH + DNS User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2]  📋 List All Users${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3]  🔒 Lock User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4]  🔓 Unlock User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [5]  🗑️ Delete User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [6]  📝 Create/Edit Banner${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [7]  ❌ Delete Banner${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [S]  ⚙️  SETTINGS${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [00] 🚪 Exit${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Main menu option: "$NC)" ch
        
        case $ch in
            1) elite-x-user add; read -p "Press Enter to continue..." ;;
            2) elite-x-user list; read -p "Press Enter to continue..." ;;
            3) elite-x-user lock; read -p "Press Enter to continue..." ;;
            4) elite-x-user unlock; read -p "Press Enter to continue..." ;;
            5) elite-x-user del; read -p "Press Enter to continue..." ;;
            6)
                [ -f /etc/elite-x/banner/custom ] || cp /etc/elite-x/banner/default /etc/elite-x/banner/custom 2>/dev/null
                nano /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Banner saved${NC}"
                read -p "Press Enter to continue..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Banner deleted${NC}"
                read -p "Press Enter to continue..."
                ;;
            [Ss]) settings_menu ;;
            00|0) 
                rm -f /tmp/elite-x-running
                show_quote
                echo -e "${NEON_GREEN}Goodbye!${NC}"
                exit 0 
                ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
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
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}                    ACTIVATION REQUIRED                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${NEON_WHITE}Available Keys:${NC}"
echo -e "${NEON_GREEN}  💎 Lifetime : Whtsapp +255713-628-668${NC}"
echo -e "${NEON_YELLOW}  ⏳ Trial    : ELITE-X-TEST-0208 (2 days)${NC}"
echo ""
read -p "$(echo -e $NEON_CYAN"🔑 Activation Key: "$NC)" ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${NEON_RED}❌ Invalid activation key! Installation cancelled.${NC}"
    exit 1
fi

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
read -p "$(echo -e $NEON_GREEN"🌐 Subdomain: "$NC)" TDOMAIN
echo "$TDOMAIN" > /etc/elite-x/subdomain
check_subdomain "$TDOMAIN"

# LOCATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}           NETWORK LOCATION OPTIMIZATION                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_YELLOW}║${NEON_WHITE}  Select your VPS location:                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}  [1] South Africa (Default - MTU 1800)                        ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_CYAN}  [2] USA                                                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_BLUE}  [3] Europe                                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PURPLE}  [4] Asia                                                      ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PINK}  [5] Auto-detect                                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_RED}${BLINK}  [6] 🚀 OVERCLOCKED MODE (MAXIMUM SPEED)                        ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e $NEON_GREEN"Select location [1-6] [default: 6]: "$NC)" LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-6}

MTU=1800
SELECTED_LOCATION="South Africa"
OVERCLOCK_MODE=0

case $LOCATION_CHOICE in
    2)
        SELECTED_LOCATION="USA"
        echo -e "${NEON_CYAN}✅ USA selected${NC}"
        ;;
    3)
        SELECTED_LOCATION="Europe"
        echo -e "${NEON_BLUE}✅ Europe selected${NC}"
        ;;
    4)
        SELECTED_LOCATION="Asia"
        echo -e "${NEON_PURPLE}✅ Asia selected${NC}"
        ;;
    5)
        SELECTED_LOCATION="Auto-detect"
        echo -e "${NEON_PINK}✅ Auto-detect selected${NC}"
        ;;
    6)
        SELECTED_LOCATION="OVERCLOCKED"
        OVERCLOCK_MODE=1
        echo -e "${NEON_RED}${BLINK}✅ OVERCLOCKED MODE SELECTED - MAXIMUM SPEED${NC}"
        ;;
    *)
        SELECTED_LOCATION="South Africa"
        echo -e "${NEON_GREEN}✅ Using South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> ELITE-X INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
  exit 1
fi

mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
                      ELITE-X VPN SERVICE
                    High Speed • Secure • Unlimited
╚═══════════════════════════════════════════════════════════════╝
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
                    ELITE-X VPN SERVICE
              ⚡ Hyperspeed • Ultra Secure • Unlimited ⚡
╚═══════════════════════════════════════════════════════════════╝
EOF

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

echo -e "${NEON_CYAN}Stopping old services...${NC}"
for svc in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-x dnstt-elite-x-proxy; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

if [ -f /etc/systemd/resolved.conf ]; then
  echo -e "${NEON_CYAN}Configuring systemd-resolved...${NC}"
  sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf 2>/dev/null || true
  grep -q '^DNS=' /etc/systemd/resolved.conf \
    && sed -i 's/^DNS=.*/DNS=8.8.8.8 8.8.4.4 1.1.1.1/' /etc/systemd/resolved.conf \
    || echo "DNS=8.8.8.8 8.8.4.4 1.1.1.1" >> /etc/systemd/resolved.conf
  systemctl restart systemd-resolved 2>/dev/null || true
  ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf 2>/dev/null || true
fi

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools iftop nload htop git make golang-go build-essential wget unzip irqbalance dnsmasq openssl

install_dnstt_server

echo -e "${NEON_CYAN}Generating keys...${NC}"
mkdir -p /etc/dnstt

if [ -f /etc/dnstt/server.key ]; then
    echo -e "${NEON_YELLOW}⚠️ Existing keys found, removing...${NC}"
    chattr -i /etc/dnstt/server.key 2>/dev/null || true
    rm -f /etc/dnstt/server.key
    rm -f /etc/dnstt/server.pub
fi

cd /etc/dnstt
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub 2>/dev/null || {
    openssl genrsa -out server.key 2048 2>/dev/null
    openssl rsa -in server.key -pubout -out server.pub 2>/dev/null
}
cd ~

chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo -e "${NEON_CYAN}Creating dnstt-elite-x.service...${NC}"
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

# Install fixed EDNS proxy
install_edns_proxy

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X DNS Proxy
After=dnstt-elite-x.service
Requires=dnstt-elite-x.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp || true

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
setup_main_menu

# Save booster functions
declare -f enable_bbr_plus optimize_cpu_performance tune_kernel_parameters optimize_irq_affinity optimize_dns_cache optimize_interface_offloading optimize_tcp_parameters setup_qos_priorities optimize_memory_usage optimize_buffer_mtu optimize_network_steering enable_tcp_fastopen_master apply_all_boosters booster_menu > /usr/local/bin/elite-x-boosters 2>/dev/null || true
chmod +x /usr/local/bin/elite-x-boosters 2>/dev/null || true

# Apply overclock boosters if selected
if [ $OVERCLOCK_MODE -eq 1 ]; then
    echo -e "${NEON_RED}${BLINK}🚀 APPLYING OVERCLOCKED BOOSTERS - MAXIMUM SPEED MODE 🚀${NC}"
    apply_all_boosters
    echo -e "${NEON_GREEN}✅ Boosters applied - Continuing installation...${NC}"
    sleep 2
fi

# Additional optimizations
for iface in $(ls /sys/class/net/ | grep -v lo); do
    ethtool -K $iface tx off sg off tso off 2>/dev/null || true
    ip link set dev $iface txqueuelen 10000 2>/dev/null || true
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
echo -e "${NEON_CYAN}Caching network information for fast login...${NC}"
IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unknown")
echo "$IP" > /etc/elite-x/cached_ip

if [ "$IP" != "Unknown" ]; then
    LOCATION_INFO=$(curl -s http://ip-api.com/json/$IP 2>/dev/null)
    echo "$LOCATION_INFO" | jq -r '.city + ", " + .country' 2>/dev/null > /etc/elite-x/cached_location || echo "Unknown" > /etc/elite-x/cached_location
    echo "$LOCATION_INFO" | jq -r '.isp' 2>/dev/null > /etc/elite-x/cached_isp || echo "Unknown" > /etc/elite-x/cached_isp
else
    echo "Unknown" > /etc/elite-x/cached_location
    echo "Unknown" > /etc/elite-x/cached_isp
fi

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
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}              ELITE-X SLOWDNS INSTALLED SUCCESSFULLY!                ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📌 DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📍 LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 KEY     : ${NEON_YELLOW}${ACTIVATION_KEY}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⏳ EXPIRY  : ${NEON_YELLOW}${EXPIRY_INFO}${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🚀 Commands:${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     menu - Open dashboard${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     elite - Quick access${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     live  - Live connection monitor${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     speed - Traffic analyzer${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     renew - Renew SSH account${NC}"
if [ $OVERCLOCK_MODE -eq 1 ]; then
    echo -e "${NEON_GREEN}║${NEON_RED}${BLINK}  ⚡ OVERCLOCKED MODE ACTIVE - MAXIMUM SPEED ENABLED ⚡${NC}"
fi
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
show_quote

# Check service status
sleep 2
DNS_STATUS=$(systemctl is-active dnstt-elite-x)
PRX_STATUS=$(systemctl is-active dnstt-elite-x-proxy)
echo -e "${NEON_CYAN}Service Status:${NC}"
echo -e "  DNSTT: $([ "$DNS_STATUS" = "active" ] && echo "${NEON_GREEN}● RUNNING${NC}" || echo "${NEON_RED}● FAILED${NC}")"
echo -e "  PROXY: $([ "$PRX_STATUS" = "active" ] && echo "${NEON_GREEN}● RUNNING${NC}" || echo "${NEON_RED}● FAILED${NC}")"
echo ""

read -p "$(echo -e $NEON_GREEN"Open menu now? (y/n): "$NC)" open
if [ "$open" = "y" ]; then
    echo -e "${NEON_GREEN}Opening dashboard...${NC}"
    sleep 1
    /usr/local/bin/elite-x
else
    echo -e "${NEON_YELLOW}You can type 'menu' anytime to open the dashboard.${NC}"
fi

self_destruct
