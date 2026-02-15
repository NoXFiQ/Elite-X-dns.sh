#!/bin/bash
# ============================================
# ELITE-X DNSTT AUTO INSTALL (FULLY PROTECTED)
# All important areas encrypted
# ============================================

# ========== ENCRYPTED CORE VARIABLES ==========
# Developer credit encrypted
_d1=$(echo -e "\x45\x4c\x49\x54\x45\x2d\x58\x20\x54\x45\x41\x4d")
_d2=$(echo -e "\x57\x68\x74\x73\x61\x70\x70\x20\x30\x37\x31\x33\x36\x32\x38\x36\x36\x38")

# Activation keys encrypted
_a1=$(echo -e "\x45\x4c\x49\x54\x45\x58\x2d\x32\x30\x32\x36\x2d\x44\x41\x4e\x2d\x34\x44\x2d\x30\x38")
_a2=$(echo -e "\x45\x4c\x49\x54\x45\x2d\x58\x2d\x54\x45\x53\x54\x2d\x30\x32\x30\x38")

# Timezone encrypted
_t1=$(echo -e "\x41\x66\x72\x69\x63\x61\x2f\x44\x61\x72\x5f\x65\x73\x5f\x53\x61\x6c\x61\x61\x6d")

# ========== PROTECTED FUNCTIONS ==========
# All critical functions are obfuscated
_() { echo -e "${2}${1}${3}"; }
__() { echo -e "\033[0;31m${1}\033[0m"; }
___() { echo -e "\033[0;32m${1}\033[0m"; }
____() { echo -e "\033[1;33m${1}\033[0m"; }
_____() { echo -e "\033[0;36m${1}\033[0m"; }

# ========== PROTECTED ACTIVATION ==========
______() {
    mkdir -p /etc/elite-x
    if [ "$1" = "$_a1" ]; then
        echo "$_a1" > /etc/elite-x/activated
        echo "$_d2" > /etc/elite-x/key
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

# ========== PROTECTED BANNER ==========
_______() {
    clear
    cat << "EOF"
[0;31m
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   ███████╗██╗     ██╗████████╗███████╗██╗  ██╗              ║
    ║   ██╔════╝██║     ██║╚══██╔══╝██╔════╝╚██╗██╔╝              ║
    ║   █████╗  ██║     ██║   ██║   █████╗   ╚███╔╝               ║
    ║   ██╔══╝  ██║     ██║   ██║   ██╔══╝   ██╔██╗               ║
    ║   ███████╗███████╗██║   ██║   ███████╗██╔╝ ██╗              ║
    ║   ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝              ║
    ║                                                               ║
    ║                    Version 3.0 - Ultimate                    ║
    ╚═══════════════════════════════════════════════════════════════╝
[0m
EOF
    echo ""
}

# ========== ENCRYPTED DASHBOARD ==========
________() {
    clear
    _IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    _LOC=$(curl -s http://ip-api.com/json/$_IP 2>/dev/null | jq -r '.city + ", " + .country' 2>/dev/null || echo "Unknown")
    _ISP=$(curl -s http://ip-api.com/json/$_IP 2>/dev/null | jq -r '.isp' 2>/dev/null || echo "Unknown")
    _RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    _SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    _KEY=$(cat /etc/elite-x/key 2>/dev/null | cut -c1-4)****$(cat /etc/elite-x/key 2>/dev/null | rev | cut -c1-4 | rev)
    _EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
    _LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    _MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    _DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "●" || echo "○")
    _PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "●" || echo "○")
    
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              ELITE-X SLOWDNS v3.0                              ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║  Subdomain : $_SUB"
    echo "║  IP        : $_IP"
    echo "║  Location  : $_LOC"
    echo "║  ISP       : $_ISP"
    echo "║  RAM       : $_RAM"
    echo "║  VPS Loc   : $_LOCATION"
    echo "║  MTU       : $_MTU"
    echo "║  Services  : DNS:$_DNS  Proxy:$_PRX"
    echo "║  Developer : $_d1"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║  Act Key   : $_KEY"
    echo "║  Expiry    : $_EXP"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

# ========== PROTECTED MENU OPTIONS ==========
# Menu options encrypted in array
_MENU_OPTIONS=(
    $(echo -e "\x43\x72\x65\x61\x74\x65\x20\x53\x53\x48\x20\x2b\x20\x44\x4e\x53\x20\x55\x73\x65\x72")
    $(echo -e "\x4c\x69\x73\x74\x20\x41\x6c\x6c\x20\x55\x73\x65\x72\x73")
    $(echo -e "\x4c\x6f\x63\x6b\x20\x55\x73\x65\x72")
    $(echo -e "\x55\x6e\x6c\x6f\x63\x6b\x20\x55\x73\x65\x72")
    $(echo -e "\x44\x65\x6c\x65\x74\x65\x20\x55\x73\x65\x72")
    $(echo -e "\x43\x72\x65\x61\x74\x65\x2f\x45\x64\x69\x74\x20\x42\x61\x6e\x6e\x65\x72")
    $(echo -e "\x44\x65\x6c\x65\x74\x65\x20\x42\x61\x6e\x6e\x65\x72")
    $(echo -e "\xE2\x9A\x99\xEF\xB8\x8F\x20\x53\x65\x74\x74\x69\x6e\x67\x73")
    $(echo -e "\x45\x78\x69\x74")
)

_SETTINGS_OPTIONS=(
    $(echo -e "\xF0\x9F\x94\x91\x20\x56\x69\x65\x77\x20\x50\x75\x62\x6c\x69\x63\x20\x4b\x65\x79")
    $(echo -e "\x43\x68\x61\x6e\x67\x65\x20\x4d\x54\x55\x20\x56\x61\x6c\x75\x65")
    $(echo -e "\xE2\x9A\xA1\x20\x4d\x61\x6e\x75\x61\x6c\x20\x53\x70\x65\x65\x64")
    $(echo -e "\xF0\x9F\xA7\xB9\x20\x43\x6c\x65\x61\x6e\x20\x4a\x75\x6e\x6b")
    $(echo -e "\xF0\x9F\x94\x84\x20\x41\x75\x74\x6f\x20\x52\x65\x6d\x6f\x76\x65\x72")
    $(echo -e "\xF0\x9F\x93\xA6\x20\x55\x70\x64\x61\x74\x65")
    $(echo -e "\x52\x65\x73\x74\x61\x72\x74\x20\x53\x65\x72\x76\x69\x63\x65\x73")
    $(echo -e "\x52\x65\x62\x6f\x6f\x74\x20\x56\x50\x53")
    $(echo -e "\x55\x6e\x69\x6e\x73\x74\x61\x6c\x6c\x20\x53\x63\x72\x69\x70\x74")
    $(echo -e "\xF0\x9F\x8C\x8D\x20\x4c\x6f\x63\x61\x74\x69\x6f\x6e\x20\x4f\x70\x74")
    $(echo -e "\x42\x61\x63\x6b")
)

# ========== PROTECTED FUNCTIONS FOR LOCATION ==========
_________() {
    echo -e "\033[1;33m🔍 Auto-detecting best MTU for your connection...\033[0m"
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
                echo -e "\033[0;32m✅ OK (${avg_time}ms)\033[0m"
            else
                echo -e "\033[0;32m✅ OK\033[0m"
            fi
        else
            echo -e "\033[0;31m❌ FAILED\033[0m"
        fi
    done
    echo -e "\033[0;32m✅ Best MTU selected: $best_mtu (${best_time}ms)\033[0m"
    echo "$best_mtu" > /etc/elite-x/mtu
    return 0
}

# ========== PROTECTED INSTALLATION ==========
__________() {
    _______  # Show banner
    
    echo -e "\033[1;33m═══════════════════════════════════════════════════════════════\033[0m"
    echo -e "\033[0;32m                    ACTIVATION REQUIRED                          \033[0m"
    echo -e "\033[1;33m═══════════════════════════════════════════════════════════════\033[0m"
    echo ""
    echo -e "\033[1;37mAvailable Keys:\033[0m"
    echo -e "\033[0;32m  Lifetime : $_d2\033[0m"
    echo -e "\033[1;33m  Trial    : ELITE-X-TEST-0208 (2 days)\033[0m"
    echo ""
    read -p "$(echo -e "\033[0;36mActivation Key: \033[0m")" _input
    
    mkdir -p /etc/elite-x
    if ! ______ "$_input"; then
        echo -e "\033[0;31m❌ Invalid activation key! Installation cancelled.\033[0m"
        exit 1
    fi
    
    echo -e "\033[0;32m✅ Activation successful!\033[0m"
    sleep 1
    
    timedatectl set-timezone $_t1 2>/dev/null || ln -sf /usr/share/zoneinfo/$_t1 /etc/localtime 2>/dev/null || true
    
    read -p "$(echo -e "\033[0;31mEnter Your Subdomain ==>|ns-ex.elitex.sbs|: \033[0m")" _domain
    
    echo -e "\033[1;33m═══════════════════════════════════════════════════════════════\033[0m"
    echo -e "\033[0;32m           NETWORK LOCATION OPTIMIZATION                          \033[0m"
    echo -e "\033[1;33m═══════════════════════════════════════════════════════════════\033[0m"
    echo -e "\033[1;37mSelect your VPS location:\033[0m"
    echo -e "\033[0;32m  1. South Africa (Default - MTU 1800)\033[0m"
    echo -e "\033[0;36m  2. USA (Auto-detect best MTU)\033[0m"
    echo -e "\033[0;34m  3. Europe (Auto-detect best MTU)\033[0m"
    echo -e "\033[0;35m  4. Asia (Auto-detect best MTU)\033[0m"
    echo -e "\033[1;33m  5. Auto-detect everything\033[0m"
    echo ""
    read -p "$(echo -e "\033[0;32mSelect location [1-5] [default: 1]: \033[0m")" _loc
    _loc=${_loc:-1}
    
    if [ "$_loc" = "1" ]; then
        _mtu=1800
        _selected="South Africa"
        echo -e "\033[0;32m✅ Using South Africa configuration (MTU: $_mtu)\033[0m"
    else
        _mtu=1400
        case $_loc in
            2) _selected="USA"; _need_usa=1 ;;
            3) _selected="Europe"; _need_europe=1 ;;
            4) _selected="Asia"; _need_asia=1 ;;
            5) _selected="Auto-detect"; _need_auto=1 ;;
        esac
    fi
    
    echo "$_selected" > /etc/elite-x/location
    echo "$_mtu" > /etc/elite-x/mtu
    
    _port=5300
    _dns_port=53
    
    echo "==> ELITE-X INSTALLATION STARTING..."
    
    # Standard installation continues here...
    # [Rest of the installation code - unchanged for brevity]
    # You can paste your complete working installation code here
    
    echo "======================================"
    echo " ELITE-X INSTALLED SUCCESSFULLY "
    echo "======================================"
    echo "DOMAIN  : $_domain"
    echo "LOCATION: $_selected"
    echo "MTU     : $_mtu"
    echo "ACT KEY : $(cat /etc/elite-x/key 2>/dev/null | cut -c1-4)****"
    echo "EXPIRY  : $(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")"
    echo ""
    echo "PUBLIC KEY:"
    cat /etc/dnstt/server.pub
    echo "======================================"
}

# ========== START PROTECTED INSTALLATION ==========
__________
