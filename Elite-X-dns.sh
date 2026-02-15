#!/bin/bash
# ============================================
# ELITE-X DNSTT AUTO INSTALL 
# ============================================

_d1=$(echo -e "\x45\x4c\x49\x54\x45\x2d\x58\x20\x54\x45\x41\x4d")
_d2=$(echo -e "\x57\x68\x74\x73\x61\x70\x70\x20\x30\x37\x31\x33\x36\x32\x38\x36\x36\x38")

_a1=$(echo -e "\x45\x4c\x49\x54\x45\x58\x2d\x32\x30\x32\x36\x2d\x44\x41\x4e\x2d\x34\x44\x2d\x30\x38")
_a2=$(echo -e "\x45\x4c\x49\x54\x45\x2d\x58\x2d\x54\x45\x53\x54\x2d\x30\x32\x30\x38")

_t1=$(echo -e "\x41\x66\x72\x69\x63\x61\x2f\x44\x61\x72\x5f\x65\x73\x5f\x53\x61\x6c\x61\x61\x6d")

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

p() { echo -e "${2}${1}${NC}"; }
p_red() { echo -e "${RED}${1}${NC}"; }
p_green() { echo -e "${GREEN}${1}${NC}"; }
p_yellow() { echo -e "${YELLOW}${1}${NC}"; }
p_cyan() { echo -e "${CYAN}${1}${NC}"; }

show_banner() {
    clear
    echo -e "${RED}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║   ███████╗██╗     ██╗████████╗███████╗██╗  ██╗              ║"
    echo "║   ██╔════╝██║     ██║╚══██╔══╝██╔════╝╚██╗██╔╝              ║"
    echo "║   █████╗  ██║     ██║   ██║   █████╗   ╚███╔╝               ║"
    echo "║   ██╔══╝  ██║     ██║   ██║   ██╔══╝   ██╔██╗               ║"
    echo "║   ███████╗███████╗██║   ██║   ███████╗██╔╝ ██╗              ║"
    echo "║   ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝              ║"
    echo "║                                                               ║"
    echo "║                    Version 3.0 - Ultimate                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

activate_script() {
    mkdir -p /etc/elite-x
    if [ "$1" = "$_a1" ]; then
        echo "$_a1" > /etc/elite-x/activated
        echo "$_a1" > /etc/elite-x/key
        echo "lifetime" > /etc/elite-x/activation_type
        echo "Lifetime" > /etc/elite-x/expiry
        return 0
    elif [ "$1" = "$_a2" ]; then
        echo "$_a2" > /etc/elite-x/activated
        echo "$_a2" > /etc/elite-x/key
        echo "temporary" > /etc/elite-x/activation_type
        echo "$(date +%Y-%m-%d)" > /etc/elite-x/activation_date
        echo "2" > /etc/elite-x/expiry_days
        echo "2 Days Trial" > /etc/elite-x/expiry
        return 0
    fi
    return 1
}

set_timezone() {
    timedatectl set-timezone "$_t1" 2>/dev/null || ln -sf /usr/share/zoneinfo/"$_t1" /etc/localtime 2>/dev/null || true
}

check_expiry() {
    if [ -f "/etc/elite-x/activation_type" ] && [ -f "/etc/elite-x/activation_date" ] && [ -f "/etc/elite-x/expiry_days" ]; then
        local atype=$(cat "/etc/elite-x/activation_type")
        if [ "$atype" = "temporary" ]; then
            local adate=$(cat "/etc/elite-x/activation_date")
            local adays=$(cat "/etc/elite-x/expiry_days")
            local now=$(date +%s)
            local expiry=$(date -d "$adate + $adays days" +%s)

            if [ $now -ge $expiry ]; then
                p_yellow "═══════════════════════════════════════════════════════════════"
                p_yellow "⚠️  TRIAL PERIOD EXPIRED ⚠️"
                p_red "Your 2-day trial has ended."
                p_red "Script will now uninstall itself..."
                p_yellow "═══════════════════════════════════════════════════════════════"
                sleep 3

                systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner 2>/dev/null || true
                rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                rm -rf /etc/dnstt /etc/elite-x
                rm -f /usr/local/bin/{dnstt-*,elite-x*}
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd

                rm -f "$0"
                p_green "✅ ELITE-X has been uninstalled."
                exit 0
            else
                local days=$(( ($expiry - $now) / 86400 ))
                local hours=$(( (($expiry - $now) % 86400) / 3600 ))
                p_yellow "⚠️  Trial: $days days $hours hours remaining"
            fi
        fi
    fi
}


detect_best_mtu() {
    p_yellow "🔍 Auto-detecting best MTU for your connection..."

    local test_mtus="1500 1450 1400 1350 1300"
    local best_mtu=1400
    local best_time=999999

    for mtu in $test_mtus; do
        echo -n "  Testing MTU $mtu... "

        if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
            local avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
            if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
                best_time=$avg_time
                best_mtu=$mtu
                p_green "✅ OK (${avg_time}ms)"
            else
                p_green "✅ OK"
            fi
        else
            p_red "❌ FAILED"
        fi
    done

    p_green "✅ Best MTU selected: $best_mtu (${best_time}ms)"
    echo "$best_mtu" > /etc/elite-x/mtu
    return 0
}

show_dashboard() {
    clear

    IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | jq -r '.city + ", " + .country' 2>/dev/null || echo "Unknown")
    ISP=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | jq -r '.isp' 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")

    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                    ELITE-X SLOWDNS v3.0                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  Subdomain :${GREEN} $SUB${NC}"
    echo -e "${CYAN}║${WHITE}  IP        :${GREEN} $IP${NC}"
    echo -e "${CYAN}║${WHITE}  Location  :${GREEN} $LOC${NC}"
    echo -e "${CYAN}║${WHITE}  ISP       :${GREEN} $ISP${NC}"
    echo -e "${CYAN}║${WHITE}  RAM       :${GREEN} $RAM${NC}"
    echo -e "${CYAN}║${WHITE}  VPS Loc   :${GREEN} $LOCATION${NC}"
    echo -e "${CYAN}║${WHITE}  MTU       :${GREEN} $MTU${NC}"
    echo -e "${CYAN}║${WHITE}  Services  : DNS:$DNS PRX:$PRX${NC}"
    echo -e "${CYAN}║${WHITE}  Developer :${PURPLE} $_d1${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  Act Key   :${YELLOW} $KEY${NC}"
    echo -e "${CYAN}║${WHITE}  Expiry    :${YELLOW} $EXP${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}


settings_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${YELLOW}${BOLD}                      SETTINGS MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${WHITE}  [8]  🔑 View Public Key${NC}"
        echo -e "${CYAN}║${WHITE}  [9]  Change MTU Value (Manual)${NC}"
        echo -e "${CYAN}║${WHITE}  [10] ⚡ Manual Speed Optimization${NC}"
        echo -e "${CYAN}║${WHITE}  [11] 🧹 Clean Junk Files${NC}"
        echo -e "${CYAN}║${WHITE}  [12] 🔄 Auto Expired Account Remover${NC}"
        echo -e "${CYAN}║${WHITE}  [13] 📦 Update Script${NC}"
        echo -e "${CYAN}║${WHITE}  [14] Restart All Services${NC}"
        echo -e "${CYAN}║${WHITE}  [15] Reboot VPS${NC}"
        echo -e "${CYAN}║${WHITE}  [16] Uninstall Script${NC}"
        echo -e "${CYAN}║${WHITE}  [17] 🌍 Re-apply Location Optimization${NC}"
        echo -e "${CYAN}║${WHITE}  [0]  Back to Main Menu${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e ${GREEN}"Settings option: "${NC})" ch

        case $ch in
            8)
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${YELLOW}PUBLIC KEY (FULL):${NC}"
                echo -e "${GREEN}$(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
                read -p "Press Enter to continue..."
                ;;
            9)
                echo "Current MTU: $(cat /etc/elite-x/mtu)"
                read -p "New MTU (1000-5000): " mtu
                [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ] && {
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${GREEN}✅ MTU updated${NC}"
                } || echo -e "${RED}❌ Invalid${NC}"
                read -p "Press Enter to continue..."
                ;;
            10) elite-x-speed manual; read -p "Press Enter to continue..." ;;
            11) elite-x-speed clean; read -p "Press Enter to continue..." ;;
            12)
                systemctl enable --now elite-x-cleaner.service
                echo -e "${GREEN}✅ Auto remover started${NC}"
                read -p "Press Enter to continue..."
                ;;
            13) elite-x-update; read -p "Press Enter to continue..." ;;
            14)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
                echo -e "${GREEN}✅ Services restarted${NC}"
                read -p "Press Enter to continue..."
                ;;
            15)
                read -p "Reboot? (y/n): " c
                [ "$c" = "y" ] && reboot
                ;;
            16)
                read -p "Uninstall? (YES): " c
                [ "$c" = "YES" ] && {
                    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner
                    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner
                    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
                    rm -rf /etc/dnstt /etc/elite-x
                    rm -f /usr/local/bin/{dnstt-*,elite-x*}
                    sed -i '/^Banner/d' /etc/ssh/sshd_config
                    systemctl restart sshd
                    echo -e "${GREEN}✅ Uninstalled${NC}"
                    exit 0
                }
                read -p "Press Enter to continue..."
                ;;
            17)
                echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${GREEN}           RE-APPLY LOCATION OPTIMIZATION                        ${NC}"
                echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${WHITE}Select your VPS location:${NC}"
                echo -e "${GREEN}  1. South Africa (MTU 1800)${NC}"
                echo -e "${CYAN}  2. USA (Auto-detect best MTU)${NC}"
                echo -e "${BLUE}  3. Europe (Auto-detect best MTU)${NC}"
                echo -e "${PURPLE}  4. Asia (Auto-detect best MTU)${NC}"
                echo -e "${YELLOW}  5. Auto-detect everything${NC}"
                read -p "Choice: " opt_choice
                
                case $opt_choice in
                    1) echo "South Africa" > /etc/elite-x/location
                       echo "1800" > /etc/elite-x/mtu
                       sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${GREEN}✅ South Africa selected (MTU 1800)${NC}" ;;
                    2) echo "USA" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-usa ;;
                    3) echo "Europe" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-europe ;;
                    4) echo "Asia" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-asia ;;
                    5) echo "Auto-detect" > /etc/elite-x/location
                       /usr/local/bin/elite-x-optimize-auto ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
        esac
    done
}


main_menu() {
    
    if [ -f /tmp/elite-x-running ]; then
        exit 0
    fi
    touch /tmp/elite-x-running
    trap 'rm -f /tmp/elite-x-running' EXIT

    while true; do
        show_dashboard
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${GREEN}${BOLD}                         MAIN MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${WHITE}  [1] Create SSH + DNS User${NC}"
        echo -e "${CYAN}║${WHITE}  [2] List All Users${NC}"
        echo -e "${CYAN}║${WHITE}  [3] Lock User${NC}"
        echo -e "${CYAN}║${WHITE}  [4] Unlock User${NC}"
        echo -e "${CYAN}║${WHITE}  [5] Delete User${NC}"
        echo -e "${CYAN}║${WHITE}  [6] Create/Edit Banner${NC}"
        echo -e "${CYAN}║${WHITE}  [7] Delete Banner${NC}"
        echo -e "${CYAN}║${WHITE}  [S] ⚙️  Settings${NC}"
        echo -e "${CYAN}║${WHITE}  [00] Exit${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e ${GREEN}"Main menu option: "${NC})" ch

        case $ch in
            1) elite-x-user add; read -p "Press Enter to continue..." ;;
            2) elite-x-user list; read -p "Press Enter to continue..." ;;
            3) elite-x-user lock; read -p "Press Enter to continue..." ;;
            4) elite-x-user unlock; read -p "Press Enter to continue..." ;;
            5) elite-x-user del; read -p "Press Enter to continue..." ;;
            6)
                [ -f /etc/elite-x/banner/custom ] || cp /etc/elite-x/banner/default /etc/elite-x/banner/custom
                nano /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${GREEN}✅ Banner saved${NC}"
                read -p "Press Enter to continue..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner
                systemctl restart sshd
                echo -e "${GREEN}✅ Banner deleted${NC}"
                read -p "Press Enter to continue..."
                ;;
            [Ss]) settings_menu ;;
            00|0) 
                rm -f /tmp/elite-x-running
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0 
                ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
        esac
    done
}


optimize_usa_halotel() {
    p_yellow "🔄 Optimizing USA → Halotel connection..."
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X USA Halotel Optimization
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
    sysctl -p
    systemctl daemon-reload
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    p_green "✅ USA optimized with MTU $detected_mtu"
}

optimize_europe_halotel() {
    p_yellow "🔄 Optimizing Europe → Halotel connection..."
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X Europe Halotel Optimization
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
    sysctl -p
    systemctl daemon-reload
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    p_green "✅ Europe optimized with MTU $detected_mtu"
}

optimize_asia_halotel() {
    p_yellow "🔄 Optimizing Asia → Halotel connection..."
    detect_best_mtu
    local detected_mtu=$(cat /etc/elite-x/mtu)
    sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X Asia Halotel Optimization
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
    sysctl -p
    systemctl daemon-reload
    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    p_green "✅ Asia optimized with MTU $detected_mtu"
}

auto_detect_best_settings() {
    p_yellow "🔍 Auto-detecting best settings..."
    detect_best_mtu
    usa_latency=$(ping -c 2 -W 2 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    europe_latency=$(ping -c 2 -W 2 1.1.1.1 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    asia_latency=$(ping -c 2 -W 2 208.67.222.222 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
    
    if [ ! -z "${usa_latency:-}" ] && [ "${usa_latency:-999}" -lt 200 ]; then
        optimize_usa_halotel
    elif [ ! -z "${europe_latency:-}" ] && [ "${europe_latency:-999}" -lt 250 ]; then
        optimize_europe_halotel
    elif [ ! -z "${asia_latency:-}" ] && [ "${asia_latency:-999}" -lt 300 ]; then
        optimize_asia_halotel
    else
        optimize_usa_halotel
    fi
}


create_helper_scripts() {

    cat > /usr/local/bin/elite-x-optimize-usa <<'EOF'
#!/bin/bash
echo -e "\033[1;33m🔍 Auto-detecting best MTU for USA...\033[0m"
best_mtu=1400
best_time=999999
for mtu in 1500 1450 1400 1350 1300; do
    echo -n "  Testing MTU $mtu... "
    if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
        avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
        if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
            best_time=$avg_time
            best_mtu=$mtu
            echo -e "\033[0;32m✅ OK (${avg_time}ms)\033[0m"
        else
            echo -e "\033[0;32m✅ OK\033[0m"
        fi
    else
        echo -e "\033[0;31m❌ FAILED\033[0m"
    fi
done
echo "$best_mtu" > /etc/elite-x/mtu
sed -i "s/-mtu [0-9]*/-mtu $best_mtu/" /etc/systemd/system/dnstt-elite-x.service
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
sysctl -p
systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy
echo -e "\033[0;32m✅ USA optimized with MTU $best_mtu\033[0m"
EOF

    cat > /usr/local/bin/elite-x-optimize-europe <<'EOF'
#!/bin/bash
echo -e "\033[1;33m🔍 Auto-detecting best MTU for Europe...\033[0m"
best_mtu=1400
best_time=999999
for mtu in 1500 1450 1400 1350 1300; do
    echo -n "  Testing MTU $mtu... "
    if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
        avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
        if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
            best_time=$avg_time
            best_mtu=$mtu
            echo -e "\033[0;32m✅ OK (${avg_time}ms)\033[0m"
        else
            echo -e "\033[0;32m✅ OK\033[0m"
        fi
    else
        echo -e "\033[0;31m❌ FAILED\033[0m"
    fi
done
echo "$best_mtu" > /etc/elite-x/mtu
sed -i "s/-mtu [0-9]*/-mtu $best_mtu/" /etc/systemd/system/dnstt-elite-x.service
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
sysctl -p
systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy
echo -e "\033[0;32m✅ Europe optimized with MTU $best_mtu\033[0m"
EOF

    cat > /usr/local/bin/elite-x-optimize-asia <<'EOF'
#!/bin/bash
echo -e "\033[1;33m🔍 Auto-detecting best MTU for Asia...\033[0m"
best_mtu=1400
best_time=999999
for mtu in 1500 1450 1400 1350 1300; do
    echo -n "  Testing MTU $mtu... "
    if timeout 2 ping -M do -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
        avg_time=$(ping -c 2 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
        if [ ! -z "$avg_time" ] && [ "$avg_time" -lt "$best_time" ]; then
            best_time=$avg_time
            best_mtu=$mtu
            echo -e "\033[0;32m✅ OK (${avg_time}ms)\033[0m"
        else
            echo -e "\033[0;32m✅ OK\033[0m"
        fi
    else
        echo -e "\033[0;31m❌ FAILED\033[0m"
    fi
done
echo "$best_mtu" > /etc/elite-x/mtu
sed -i "s/-mtu [0-9]*/-mtu $best_mtu/" /etc/systemd/system/dnstt-elite-x.service
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF
sysctl -p
systemctl daemon-reload
systemctl restart dnstt-elite-x dnstt-elite-x-proxy
echo -e "\033[0;32m✅ Asia optimized with MTU $best_mtu\033[0m"
EOF

    cat > /usr/local/bin/elite-x-optimize-auto <<'EOF'
#!/bin/bash
echo -e "\033[1;33m🔍 Auto-detecting best location and MTU...\033[0m"
usa_latency=$(ping -c 2 -W 2 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
europe_latency=$(ping -c 2 -W 2 1.1.1.1 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
asia_latency=$(ping -c 2 -W 2 208.67.222.222 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
if [ ! -z "${usa_latency:-}" ] && [ "${usa_latency:-999}" -lt 200 ]; then
    /usr/local/bin/elite-x-optimize-usa
elif [ ! -z "${europe_latency:-}" ] && [ "${europe_latency:-999}" -lt 250 ]; then
    /usr/local/bin/elite-x-optimize-europe
elif [ ! -z "${asia_latency:-}" ] && [ "${asia_latency:-999}" -lt 300 ]; then
    /usr/local/bin/elite-x-optimize-asia
else
    /usr/local/bin/elite-x-optimize-usa
fi
EOF

    chmod +x /usr/local/bin/elite-x-optimize-*
}

create_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

R='\033[0;31m';G='\033[0;32m';Y='\033[1;33m';C='\033[0;36m';W='\033[1;37m';N='\033[0m'
UD="/etc/elite-x/users";TD="/etc/elite-x/traffic";mkdir -p $UD $TD

add_user() {
    clear
    echo -e "${C}═══════════════════════════════════════════════════════════════${N}"
    echo -e "${Y}                     CREATE SSH + DNS USER                      ${N}"
    echo -e "${C}═══════════════════════════════════════════════════════════════${N}"

    read -p "$(echo -e $G"Username: "$N)" u
    read -p "$(echo -e $G"Password: "$N)" p
    read -p "$(echo -e $G"Expire days: "$N)" d
    read -p "$(echo -e $G"Traffic limit (MB, 0 for unlimited): "$N)" l

    if id "$u" &>/dev/null; then
        echo -e "${R}User already exists!${N}"
        return
    fi

    useradd -m -s /bin/false "$u"
    echo "$u:$p" | chpasswd

    ex=$(date -d "+$d days" +"%Y-%m-%d")
    chage -E "$ex" "$u"

    cat > $UD/$u <<INFO
Username: $u
Password: $p
Expire: $ex
Traffic_Limit: $l
Created: $(date +"%Y-%m-%d")
INFO

    echo "0" > $TD/$u

    S=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PK=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")

    clear
    echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
    echo -e "${Y}                  USER DETAILS                                  ${N}"
    echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
    echo -e "${W}Username  :${C} $u${N}"
    echo -e "${W}Password  :${C} $p${N}"
    echo -e "${W}Server    :${C} $S${N}"
    echo -e "${W}Public Key:${C} $PK${N}"
    echo -e "${W}Expire    :${C} $ex${N}"
    echo -e "${W}Traffic   :${C} $l MB${N}"
    echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
}

list_users() {
    clear
    echo -e "${C}═══════════════════════════════════════════════════════════════${N}"
    echo -e "${Y}                     ACTIVE USERS                               ${N}"
    echo -e "${C}═══════════════════════════════════════════════════════════════${N}"

    [ -z "$(ls -A $UD 2>/dev/null)" ] && { echo -e "${R}No users found${N}"; return; }

    printf "%-12s %-10s %-6s %-6s %-8s\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "STATUS"
    echo -e "${C}────────────────────────────────────────────────────────────${N}"

    for f in $UD/*; do
        [ ! -f "$f" ] && continue
        u=$(basename "$f")
        ex=$(grep "Expire:" "$f" | cut -d' ' -f2 | cut -c6-10)
        lm=$(grep "Traffic_Limit:" "$f" | cut -d' ' -f2)
        us=$(cat $TD/$u 2>/dev/null || echo "0")
        st=$(passwd -S "$u" 2>/dev/null | grep -q "L" && echo "${R}LOCK${N}" || echo "${G}OK${N}")
        printf "%-12s %-10s %-6s %-6s %-8b\n" "$u" "$ex" "$lm" "$us" "$st"
    done
    echo -e "${C}═══════════════════════════════════════════════════════════════${N}"
}

lock_user() { read -p "Username: " u; usermod -L "$u" 2>/dev/null && echo -e "${G}✅ Locked${N}" || echo -e "${R}❌ Failed${N}"; }
unlock_user() { read -p "Username: " u; usermod -U "$u" 2>/dev/null && echo -e "${G}✅ Unlocked${N}" || echo -e "${R}❌ Failed${N}"; }
delete_user() {
    read -p "Username: " u
    userdel -r "$u" 2>/dev/null
    rm -f $UD/$u $TD/$u
    echo -e "${G}✅ Deleted${N}"
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


create_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash
TD="/etc/elite-x/traffic";UD="/etc/elite-x/users";mkdir -p $TD
while true; do
    if [ -d "$UD" ]; then
        for f in "$UD"/*; do
            [ -f "$f" ] && {
                u=$(basename "$f")
                command -v iptables >/dev/null && {
                    c=$(iptables -vnx -L OUTPUT | grep "$u" | awk '{s+=$2} END {print s}' 2>/dev/null || echo "0")
                    echo $((c/1048576)) > "$TD/$u"
                }
            }
        done
    fi
    sleep 60
done
EOF
    chmod +x /usr/local/bin/elite-x-traffic

    cat > /etc/systemd/system/elite-x-traffic.service <<EOF
[Unit]
Description=ELITE-X Traffic Monitor
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable elite-x-traffic.service
    systemctl start elite-x-traffic.service
}


create_speed_optimizer() {
    cat > /usr/local/bin/elite-x-speed <<'EOF'
#!/bin/bash
R='\033[0;31m';G='\033[0;32m';Y='\033[1;33m';N='\033[0m'
o() {
    sysctl -w net.core.rmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=134217728 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    echo -e "${G}✅ Network optimized${N}"
}
c() {
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null || true
    done
    echo -e "${G}✅ CPU optimized${N}"
}
r() {
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    echo -e "${G}✅ RAM optimized${N}"
}
j() {
    apt clean 2>/dev/null; apt autoclean 2>/dev/null
    find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
    echo -e "${G}✅ Junk cleaned${N}"
}
case "$1" in
    manual) o;c;r;j ;;
    clean) j ;;
    *) echo "Usage: elite-x-speed {manual|clean}" ;;
esac
EOF
    chmod +x /usr/local/bin/elite-x-speed
}

create_auto_remover() {
    cat > /usr/local/bin/elite-x-cleaner <<'EOF'
#!/bin/bash
UD="/etc/elite-x/users";TD="/etc/elite-x/traffic"
while true; do
    [ -d "$UD" ] && for f in "$UD"/*; do
        [ -f "$f" ] && {
            u=$(basename "$f")
            ex=$(grep "Expire:" "$f" | cut -d' ' -f2)
            [ ! -z "$ex" ] && [ "$(date +%Y-%m-%d)" > "$ex" ] && {
                userdel -r "$u" 2>/dev/null || true
                rm -f "$f" "$TD/$u"
            }
        }
    done
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
    systemctl enable elite-x-cleaner.service
    systemctl start elite-x-cleaner.service
}

create_updater() {
    cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash
echo -e "\033[1;33m🔄 Checking for updates...\033[0m"
BD="/root/elite-x-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BD"
cp -r /etc/elite-x "$BD/" 2>/dev/null || true
cp -r /etc/dnstt "$BD/" 2>/dev/null || true
cd /tmp
rm -rf Elite-X-dns.sh
git clone https://github.com/NoXFiQ/Elite-X-dns.sh.git 2>/dev/null || {
    echo -e "\033[0;31m❌ Failed to download update\033[0m"
    exit 1
}
cd Elite-X-dns.sh
chmod +x *.sh
cp -r "$BD/elite-x" /etc/ 2>/dev/null || true
cp -r "$BD/dnstt" /etc/ 2>/dev/null || true
echo -e "\033[0;32m✅ Update complete!\033[0m"
EOF
    chmod +x /usr/local/bin/elite-x-update
}


create_autoshow() {
    cat > /etc/profile.d/elite-x-dashboard.sh <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    /usr/local/bin/elite-x
fi
EOF
    chmod +x /etc/profile.d/elite-x-dashboard.sh

    cat >> ~/.bashrc <<'EOF'
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    /usr/local/bin/elite-x
fi
EOF

    echo "alias menu='elite-x'" >> ~/.bashrc
    echo "alias elitex='elite-x'" >> ~/.bashrc
}


cache_network_info() {
    echo "Caching network information for fast login..."
    IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    echo "$IP" > /etc/elite-x/cached_ip

    if [ "$IP" != "Unknown" ]; then
        LOC_INFO=$(curl -s http://ip-api.com/json/$IP 2>/dev/null)
        echo "$LOC_INFO" | jq -r '.city + ", " + .country' 2>/dev/null > /etc/elite-x/cached_location || echo "Unknown" > /etc/elite-x/cached_location
        echo "$LOC_INFO" | jq -r '.isp' 2>/dev/null > /etc/elite-x/cached_isp || echo "Unknown" > /etc/elite-x/cached_isp
    else
        echo "Unknown" > /etc/elite-x/cached_location
        echo "Unknown" > /etc/elite-x/cached_isp
    fi
}


main_installation() {
    show_banner
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    ACTIVATION REQUIRED                          ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}Available Keys:${NC}"
    echo -e "${GREEN}  Lifetime : $_d2${NC}"
    echo -e "${YELLOW}  Trial    : ELITE-X-TEST-0208 (2 days)${NC}"
    echo ""
    read -p "$(echo -e ${CYAN}"Activation Key: "${NC})" input_key

    mkdir -p /etc/elite-x
    if ! activate_script "$input_key"; then
        echo -e "${RED}❌ Invalid activation key! Installation cancelled.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Activation successful!${NC}"
    sleep 1

    set_timezone
    
    read -p "$(echo -e ${RED}"Enter Your Subdomain ==>|ns-ex.elitex.sbs|: "${NC})" domain

    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}           NETWORK LOCATION OPTIMIZATION                          ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Select your VPS location:${NC}"
    echo -e "${GREEN}  1. South Africa (Default - MTU 1800)${NC}"
    echo -e "${CYAN}  2. USA (Auto-detect best MTU)${NC}"
    echo -e "${BLUE}  3. Europe (Auto-detect best MTU)${NC}"
    echo -e "${PURPLE}  4. Asia (Auto-detect best MTU)${NC}"
    echo -e "${YELLOW}  5. Auto-detect everything${NC}"
    echo ""
    read -p "$(echo -e ${GREEN}"Select location [1-5] [default: 1]: "${NC})" loc
    loc=${loc:-1}

    if [ "$loc" = "1" ]; then
        mtu=1800
        selected="South Africa"
        echo -e "${GREEN}✅ Using South Africa configuration (MTU: $mtu)${NC}"
    else
        mtu=1400
        case $loc in
            2) selected="USA"; need_usa=1 ;;
            3) selected="Europe"; need_europe=1 ;;
            4) selected="Asia"; need_asia=1 ;;
            5) selected="Auto-detect"; need_auto=1 ;;
        esac
    fi

    echo "$selected" > /etc/elite-x/location
    echo "$mtu" > /etc/elite-x/mtu

    port=5300
    dns_port=53

    echo "==> ELITE-X INSTALLATION STARTING..."

    if [ "$(id -u)" -ne 0 ]; then
        echo "[-] Run as root"
        exit 1
    fi

    mkdir -p /etc/elite-x/{banner,users,traffic}
    echo "$domain" > /etc/elite-x/subdomain

    cat > /etc/elite-x/banner/default <<'EOF'
===============================================
      WELCOME TO ELITE-X VPN SERVICE
===============================================
     High Speed • Secure • Unlimited
===============================================
EOF

    cat > /etc/elite-x/banner/ssh-banner <<'EOF'
************************************************
*         ELITE-X VPN SERVICE                  *
*     High Speed • Secure • Unlimited          *
************************************************
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

    if [ -f /etc/systemd/resolved.conf ]; then
        echo "Configuring systemd-resolved..."
        sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf || true
        grep -q '^DNS=' /etc/systemd/resolved.conf \
            && sed -i 's/^DNS=.*/DNS=8.8.8.8 8.8.4.4/' /etc/systemd/resolved.conf \
            || echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf
        systemctl restart systemd-resolved
        ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    fi

    echo "Installing dependencies..."
    apt update -y
    apt install -y curl python3 jq nano iptables iptables-persistent ethtool

    echo "Installing dnstt-server..."
    curl -fsSL https://dnstt.network/dnstt-server-linux-amd64 -o /usr/local/bin/dnstt-server
    chmod +x /usr/local/bin/dnstt-server

    echo "Generating keys..."
    mkdir -p /etc/dnstt
    if [ ! -f /etc/dnstt/server.key ]; then
        cd /etc/dnstt
        dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
        cd ~
    fi
    chmod 600 /etc/dnstt/server.key
    chmod 644 /etc/dnstt/server.pub

    echo "Creating dnstt-elite-x.service..."
    cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${port} -mtu ${mtu} -privkey-file /etc/dnstt/server.key ${domain} 127.0.0.1:22
Restart=no
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

    echo "Installing EDNS proxy..."
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket,threading,struct
L=5300
def p(d,s):
 if len(d)<12:return d
 try:q,a,n,r=struct.unpack("!HHHH",d[4:12])
 except:return d
 o=12
 def sk(b,o):
  while o<len(b):
   l=b[o];o+=1
   if l==0:break
   if l&0xC0==0xC0:o+=1;break
   o+=l
  return o
 for _ in range(q):o=sk(d,o);o+=4
 for _ in range(a+n):
  o=sk(d,o)
  if o+10>len(d):return d
  _,_,_,l=struct.unpack("!HHIH",d[o:o+10])
  o+=10+l
 n=bytearray(d)
 for _ in range(r):
  o=sk(d,o)
  if o+10>len(d):return d
  t=struct.unpack("!H",d[o:o+2])[0]
  if t==41:
   n[o+2:o+4]=struct.pack("!H",s)
   return bytes(n)
  _,_,l=struct.unpack("!HIH",d[o+2:o+10])
  o+=10+l
 return d
def h(sk,d,ad):
 u=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
 u.settimeout(5)
 try:
  u.sendto(p(d,1800),('127.0.0.1',L))
  r,_=u.recvfrom(4096)
  sk.sendto(p(r,512),ad)
 except:pass
 finally:u.close()
s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
s.bind(('0.0.0.0',53))
while True:
 d,a=s.recvfrom(4096)
 threading.Thread(target=h,args=(s,d,a),daemon=True).start()
EOF
    chmod +x /usr/local/bin/dnstt-edns-proxy.py

    cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy
After=dnstt-elite-x.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=no

[Install]
WantedBy=multi-user.target
EOF

    command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp || true

    systemctl daemon-reload
    systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
    systemctl start dnstt-elite-x.service dnstt-elite-x-proxy.service


    create_traffic_monitor
    create_speed_optimizer
    create_auto_remover
    create_updater
    create_helper_scripts
    create_user_manager

# Apply location optimizations
    if [ ! -z "${need_usa:-}" ]; then
        optimize_usa_halotel
    elif [ ! -z "${need_europe:-}" ]; then
        optimize_europe_halotel
    elif [ ! -z "${need_asia:-}" ]; then
        optimize_asia_halotel
    elif [ ! -z "${need_auto:-}" ]; then
        auto_detect_best_settings
    fi

   
    cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
    chmod +x /etc/cron.hourly/elite-x-expiry

    
    cache_network_info
    
  
    create_autoshow

  
    cp "$0" /usr/local/bin/elite-x 2>/dev/null || cat > /usr/local/bin/elite-x <<'EOF'
#!/bin/bash
# ELITE-X Main Menu - DO NOT MODIFY
EOF
    chmod +x /usr/local/bin/elite-x

    # Display success message
    echo "======================================"
    echo " ELITE-X INSTALLED SUCCESSFULLY "
    echo "======================================"
    exp_info=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
    final_mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    act_key=$(cat /etc/elite-x/key 2>/dev/null || echo "$_a1")
    echo "DOMAIN  : $domain"
    echo "LOCATION: $selected"
    echo "MTU     : $final_mtu"
    echo "ACT KEY : $act_key"
    echo "EXPIRY  : $exp_info"
    echo ""
    echo "PUBLIC KEY:"
    cat /etc/dnstt/server.pub
    echo "======================================"
    echo ""
    echo -e "${GREEN}✅ DASHBOARD WILL NOW SHOW AUTOMATICALLY ON LOGIN${NC}"
    echo -e "${YELLOW}No need to type 'elite-x' or 'menu' - it appears automatically!${NC}"
    echo "======================================"

    read -p "Open menu now? (y/n): " open
    if [ "$open" = "y" ]; then
    
        source ~/.bashrc 2>/dev/null || true
        /usr/local/bin/elite-x
    fi
}

if [ "$0" = "/usr/local/bin/elite-x" ] || [ "$1" = "--check-expiry" ]; then
    # This is being run as the menu
    if [ "$1" = "--check-expiry" ]; then
        check_expiry
    else
        main_menu
    fi
else
    # This is the installer
    main_installation
fi
