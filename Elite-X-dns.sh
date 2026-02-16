#!/bin/bash
# ============================================
# ELITE-X DNSTT AUTO INSTALL (ULTRA MTU EDITION)
# Supports MTU up to 5000 on Halotel
# ============================================

# ========== ENCRYPTED CORE VARIABLES ==========
# Developer credit encrypted
_d1=$(echo -e "\x45\x4c\x49\x54\x45\x2d\x58\x20\x54\x45\x41\x4d")
_d2=$(echo -e "\x57\x68\x74\x73\x61\x70\x70\x20\x30\x37\x31\x33\x36\x32\x38\x36\x36\x38")

# Activation keys encrypted - REAL KEY VISIBLE
_a1=$(echo -e "\x45\x4c\x49\x54\x45\x58\x2d\x32\x30\x32\x36\x2d\x44\x41\x4e\x2d\x34\x44\x2d\x30\x38")
_a2=$(echo -e "\x45\x4c\x49\x54\x45\x2d\x58\x2d\x54\x45\x53\x54\x2d\x30\x32\x30\x38")

# Timezone encrypted
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

# ========== PROTECTED FUNCTIONS ==========
p() { echo -e "${2}${1}${NC}"; }
p_red() { echo -e "${RED}${1}${NC}"; }
p_green() { echo -e "${GREEN}${1}${NC}"; }
p_yellow() { echo -e "${YELLOW}${1}${NC}"; }
p_cyan() { echo -e "${CYAN}${1}${NC}"; }
p_blue() { echo -e "${BLUE}${1}${NC}"; }
p_purple() { echo -e "${PURPLE}${1}${NC}"; }

# ========== PROTECTED BANNER ==========
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
    echo "║                 Version 3.0 - ULTRA MTU                      ║"
    echo "║                   Supports MTU up to 5000                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# ========== PROTECTED ACTIVATION ==========
activate_script() {
    mkdir -p /etc/elite-x
    if [ "$1" = "$_a1" ] || [ "$1" = "$_d2" ]; then
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

# ========== TIMEZONE FUNCTION ==========
set_timezone() {
    timedatectl set-timezone "$_t1" 2>/dev/null || ln -sf /usr/share/zoneinfo/"$_t1" /etc/localtime 2>/dev/null || true
}

# ========== EXPIRY CHECK ==========
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

# ========== ULTRA MTU DETECTION (UP TO 5000) ==========
detect_best_mtu() {
    p_yellow "🔍 ULTRA MTU detection for Halotel network (testing up to 5000)..."
    
    # Test massive MTU values
    local test_mtus="5000 4800 4600 4400 4200 4000 3800 3600 3400 3200 3000 2800 2600 2400 2200 2000 1800 1500"
    local best_mtu=1500
    local best_speed=0
    local working_mtus=""
    local max_success=0

    echo "Testing ultra-large MTU values for maximum throughput..."
    
    for mtu in $test_mtus; do
        echo -n "  Testing MTU $mtu... "
        
        # First test with fragmentation allowed (some networks need this)
        if timeout 3 ping -M dont -c 2 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
            # Now test with DF set (no fragmentation)
            if timeout 3 ping -M do -c 3 -s $((mtu-28)) 8.8.8.8 >/dev/null 2>&1; then
                # Measure average response time
                local avg_time=$(ping -c 3 -s $((mtu-28)) 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}' | cut -d. -f1)
                avg_time=${avg_time:-100}
                
                # Calculate approximate speed (inverse of time with MTU bonus)
                local speed=$(( (mtu * 1000) / avg_time / 10 ))
                
                if [ $speed -gt $best_speed ]; then
                    best_speed=$speed
                    best_mtu=$mtu
                    working_mtus="$working_mtus $mtu"
                    max_success=$mtu
                    p_green "✅ ULTRA - Speed: ${speed} Mbps"
                else
                    p_green "✅ OK"
                fi
            else
                # Works with fragmentation only
                p_yellow "⚠️  Works with fragmentation"
                working_mtus="$working_mtus $mtu"
            fi
        else
            p_red "❌ FAILED"
        fi
    done

    # If we found working MTUs, pick the highest stable one
    if [ $max_success -gt 0 ]; then
        best_mtu=$max_success
        p_green "✅ Best MTU selected: $best_mtu (Estimated speed: ${best_speed} Mbps)"
    else
        p_yellow "⚠️  No ultra MTU found, using standard 1500"
        best_mtu=1500
    fi
    
    echo "$best_mtu" > /etc/elite-x/mtu
    return 0
}

# ========== SUPER MSS CLAMPING FOR LARGE MTU ==========
apply_advanced_mss_clamping() {
    p_yellow "🔧 Applying advanced MSS clamping for MTU up to 5000..."
    
    # Clear existing rules
    iptables -t mangle -F 2>/dev/null || true
    
    # Add MSS clamping for all traffic
    iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true
    iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true
    iptables -t mangle -A OUTPUT -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true
    iptables -t mangle -A INPUT -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true
    
    # Set explicit MSS values for different MTU ranges
    iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -m mss --mss 1300:1536 -j TCPMSS --set-mss 1460 2>/dev/null || true
    iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -m mss --mss 1537:2048 -j TCPMSS --set-mss 2000 2>/dev/null || true
    iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -m mss --mss 2049:3072 -j TCPMSS --set-mss 3000 2>/dev/null || true
    iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -m mss --mss 3073:4096 -j TCPMSS --set-mss 4000 2>/dev/null || true
    iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -m mss --mss 4097:5000 -j TCPMSS --set-mss 4900 2>/dev/null || true
    
    # Save rules
    if command -v iptables-save >/dev/null 2>&1; then
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
    fi
    
    p_green "✅ Advanced MSS clamping applied for MTU up to 5000"
}

# ========== ENABLE JUMBO FRAMES AND GIANT FRAMES ==========
enable_giant_frames() {
    p_yellow "📦 Enabling jumbo and giant frame support (up to 9000)..."
    
    # Enable giant frames on network interfaces
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        # Try increasing MTU step by step
        ip link set dev $iface mtu 9000 2>/dev/null && p_green "✅ 9000 MTU on $iface" || \
        ip link set dev $iface mtu 8000 2>/dev/null && p_green "✅ 8000 MTU on $iface" || \
        ip link set dev $iface mtu 7000 2>/dev/null && p_green "✅ 7000 MTU on $iface" || \
        ip link set dev $iface mtu 6000 2>/dev/null && p_green "✅ 6000 MTU on $iface" || \
        ip link set dev $iface mtu 5000 2>/dev/null && p_green "✅ 5000 MTU on $iface" || \
        p_yellow "⚠️  Could not increase MTU on $iface"
    done
    
    p_green "✅ Giant frame support configured"
}

# ========== KERNEL NETWORK OPTIMIZATIONS FOR ULTRA MTU ==========
optimize_kernel_for_ultra_mtu() {
    p_yellow "⚙️  Applying kernel optimizations for ultra MTU..."
    
    cat >> /etc/sysctl.conf <<EOF
# ELITE-X Ultra MTU Optimizations
net.core.rmem_max = 268435456
net.core.wmem_max = 268435456
net.ipv4.tcp_rmem = 4096 87380 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
net.core.netdev_max_backlog = 10000
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_notsent_lowat = 32768
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 2
net.ipv4.tcp_base_mss = 1460
net.ipv4.tcp_mtu_probing_floor = 1024
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_moderate_rcvbuf = 1
net.core.optmem_max = 25165824
net.core.rmem_default = 134217728
net.core.wmem_default = 134217728
EOF

    sysctl -p 2>/dev/null
    p_green "✅ Kernel optimized for ultra MTU"
}

# ========== ENHANCED EDNS PROXY FOR LARGE PACKETS ==========
create_ultra_edns_proxy() {
    p_yellow "📡 Creating ultra EDNS proxy for large packets..."
    
    cat > /usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket, threading, struct, time

LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = 53
UPSTREAM_HOST = "127.0.0.1"
UPSTREAM_PORT = 5300

# Ultra-large buffer sizes for MTU up to 5000
EXTERNAL_EDNS_SIZE = 8192
INTERNAL_EDNS_SIZE = 8192
SOCKET_BUFFER_SIZE = 2097152  # 2MB buffer
THREAD_POOL_SIZE = 200

class ConnectionPool:
    def __init__(self, max_size=100):
        self.pool = []
        self.max_size = max_size
        self.lock = threading.Lock()
    
    def get(self):
        with self.lock:
            if self.pool:
                return self.pool.pop()
        return socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    def put(self, sock):
        with self.lock:
            if len(self.pool) < self.max_size:
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, SOCKET_BUFFER_SIZE)
                sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SOCKET_BUFFER_SIZE)
                self.pool.append(sock)
            else:
                sock.close()

pool = ConnectionPool()

def patch_edns(data, size):
    """Enhanced EDNS patching for large packets"""
    if len(data) < 12:
        return data
    
    try:
        qd, an, ns, ar = struct.unpack("!HHHH", data[4:12])
    except:
        return data
    
    offset = 12
    
    def skip_name(b, off):
        while off < len(b):
            l = b[off]
            off += 1
            if l == 0:
                break
            if l & 0xC0 == 0xC0:
                off += 1
                break
            off += l
        return off
    
    # Skip questions
    for _ in range(qd):
        offset = skip_name(data, offset)
        offset += 4
    
    # Skip answers and authority
    for _ in range(an + ns):
        offset = skip_name(data, offset)
        if offset + 10 > len(data):
            return data
        _, _, _, rdlength = struct.unpack("!HHIH", data[offset:offset + 10])
        offset += 10 + rdlength
    
    # Modify EDNS
    new_data = bytearray(data)
    for _ in range(ar):
        offset = skip_name(data, offset)
        if offset + 10 > len(data):
            return data
        t, = struct.unpack("!H", data[offset:offset + 2])
        if t == 41:  # EDNS option
            new_data[offset + 2:offset + 4] = struct.pack("!H", size)
            return bytes(new_data)
        _, _, rdlength = struct.unpack("!HIH", data[offset + 2:offset + 10])
        offset += 10 + rdlength
    
    return data

def handle_client(data, addr):
    """Handle DNS query with ultra-large packet support"""
    sock = pool.get()
    sock.settimeout(3)
    
    try:
        # Send with ultra-large EDNS
        sock.sendto(patch_edns(data, INTERNAL_EDNS_SIZE), (UPSTREAM_HOST, UPSTREAM_PORT))
        
        # Receive with large buffer
        response, _ = sock.recvfrom(65535)
        
        # Send response with ultra-large EDNS
        client_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        client_sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, SOCKET_BUFFER_SIZE)
        client_sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SOCKET_BUFFER_SIZE)
        client_sock.sendto(patch_edns(response, EXTERNAL_EDNS_SIZE), addr)
        client_sock.close()
        
    except socket.timeout:
        pass
    except Exception as e:
        print(f"Error: {e}")
    finally:
        pool.put(sock)

def main():
    """Main server loop with ultra-large packet support"""
    server_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, SOCKET_BUFFER_SIZE)
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SOCKET_BUFFER_SIZE)
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    if hasattr(socket, 'SO_REUSEPORT'):
        server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    
    server_sock.bind((LISTEN_HOST, LISTEN_PORT))
    
    print(f"ULTRA EDNS Proxy running on port {LISTEN_PORT}")
    print(f"Supporting MTU up to 5000 with {INTERNAL_EDNS_SIZE} byte buffers")
    
    while True:
        try:
            data, addr = server_sock.recvfrom(65535)
            thread = threading.Thread(target=handle_client, args=(data, addr))
            thread.daemon = True
            thread.start()
        except Exception as e:
            print(f"Server error: {e}")

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/dnstt-edns-proxy.py
    p_green "✅ Ultra EDNS proxy created"
}

# ========== HALOTEL ULTRA OPTIMIZATION ==========
optimize_halotel_ultra() {
    p_yellow "📱 Applying Halotel ULTRA optimizations (MTU up to 5000)..."
    
    # Apply all ultra optimizations
    optimize_kernel_for_ultra_mtu
    enable_giant_frames
    apply_advanced_mss_clamping
    create_ultra_edns_proxy
    
    # Halotel-specific ultra settings
    cat >> /etc/sysctl.conf <<EOF
# Halotel ULTRA Optimizations
net.ipv4.conf.all.forwarding = 1
net.ipv4.ip_forward = 1
net.ipv4.tcp_limit_output_bytes = 1048576
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 8
EOF
    
    sysctl -p 2>/dev/null
    
    p_green "✅ Halotel ULTRA optimizations complete (supports MTU up to 5000)"
}

# ========== PROTECTED DASHBOARD ==========
show_dashboard() {
    clear

    # Get cached system information with error handling
    IP=$(cat /etc/elite-x/cached_ip 2>/dev/null || echo "Unknown")
    LOC=$(cat /etc/elite-x/cached_location 2>/dev/null || echo "Unknown")
    ISP=$(cat /etc/elite-x/cached_isp 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")

    # Service status with proper color codes
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        DNS="${GREEN}●${NC}"
    else
        DNS="${RED}●${NC}"
    fi
    
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        PRX="${GREEN}●${NC}"
    else
        PRX="${RED}●${NC}"
    fi

    # Display dashboard
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                    ELITE-X SLOWDNS v3.0                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  Subdomain :${GREEN} $SUB${NC}"
    echo -e "${CYAN}║${WHITE}  IP        :${GREEN} $IP${NC}"
    echo -e "${CYAN}║${WHITE}  Location  :${GREEN} $LOC${NC}"
    echo -e "${CYAN}║${WHITE}  ISP       :${GREEN} $ISP${NC}"
    echo -e "${CYAN}║${WHITE}  RAM       :${GREEN} $RAM${NC}"
    echo -e "${CYAN}║${WHITE}  VPS Loc   :${GREEN} $LOCATION${NC}"
    echo -e "${CYAN}║${WHITE}  MTU       :${GREEN} $MTU ${YELLOW}(Ultra Mode)${NC}"
    echo -e "${CYAN}║${WHITE}  Services  : DNS:$DNS PRX:$PRX${NC}"
    echo -e "${CYAN}║${WHITE}  Developer :${PURPLE} $_d1${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE}  Act Key   :${YELLOW} $KEY${NC}"
    echo -e "${CYAN}║${WHITE}  Expiry    :${YELLOW} $EXP${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ========== SETTINGS MENU ==========
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
        echo -e "${CYAN}║${WHITE}  [18] ⚡ Ultra MTU Detection (5000)${NC}"
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
                    echo -e "${GREEN}✅ MTU updated to $mtu${NC}"
                } || echo -e "${RED}❌ Invalid (must be 1000-5000)${NC}"
                read -p "Press Enter to continue..."
                ;;
            10) /usr/local/bin/elite-x-speed manual; read -p "Press Enter to continue..." ;;
            11) /usr/local/bin/elite-x-speed clean; read -p "Press Enter to continue..." ;;
            12)
                systemctl enable --now elite-x-cleaner.service
                echo -e "${GREEN}✅ Auto remover started${NC}"
                read -p "Press Enter to continue..."
                ;;
            13) /usr/local/bin/elite-x-update; read -p "Press Enter to continue..." ;;
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
                echo -e "${CYAN}  2. USA (Ultra MTU up to 5000)${NC}"
                echo -e "${BLUE}  3. Europe (Ultra MTU up to 5000)${NC}"
                echo -e "${PURPLE}  4. Asia (Ultra MTU up to 5000)${NC}"
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
                       optimize_halotel_ultra
                       detect_best_mtu
                       local detected_mtu=$(cat /etc/elite-x/mtu)
                       sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${GREEN}✅ USA optimized with MTU $detected_mtu${NC}" ;;
                    3) echo "Europe" > /etc/elite-x/location
                       optimize_halotel_ultra
                       detect_best_mtu
                       local detected_mtu=$(cat /etc/elite-x/mtu)
                       sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${GREEN}✅ Europe optimized with MTU $detected_mtu${NC}" ;;
                    4) echo "Asia" > /etc/elite-x/location
                       optimize_halotel_ultra
                       detect_best_mtu
                       local detected_mtu=$(cat /etc/elite-x/mtu)
                       sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${GREEN}✅ Asia optimized with MTU $detected_mtu${NC}" ;;
                    5) echo "Auto-detect" > /etc/elite-x/location
                       optimize_halotel_ultra
                       detect_best_mtu
                       local detected_mtu=$(cat /etc/elite-x/mtu)
                       sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
                       systemctl daemon-reload
                       systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                       echo -e "${GREEN}✅ Auto-detected MTU $detected_mtu${NC}" ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            18)
                optimize_halotel_ultra
                detect_best_mtu
                local detected_mtu=$(cat /etc/elite-x/mtu)
                sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
                systemctl daemon-reload
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${GREEN}✅ Ultra MTU detection complete! Best MTU: $detected_mtu${NC}"
                read -p "Press Enter to continue..."
                ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

# ========== MAIN MENU ==========
main_menu() {
    # Check if menu already running
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
            1) /usr/local/bin/elite-x-user add; read -p "Press Enter to continue..." ;;
            2) /usr/local/bin/elite-x-user list; read -p "Press Enter to continue..." ;;
            3) /usr/local/bin/elite-x-user lock; read -p "Press Enter to continue..." ;;
            4) /usr/local/bin/elite-x-user unlock; read -p "Press Enter to continue..." ;;
            5) /usr/local/bin/elite-x-user del; read -p "Press Enter to continue..." ;;
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

# ========== CREATE USER MANAGEMENT ==========
create_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'ENDSCRIPT'
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
ENDSCRIPT
    chmod +x /usr/local/bin/elite-x-user
}

# ========== CREATE SPEED OPTIMIZER ==========
create_speed_optimizer() {
    cat > /usr/local/bin/elite-x-speed <<'ENDSCRIPT'
#!/bin/bash
R='\033[0;31m';G='\033[0;32m';Y='\033[1;33m';N='\033[0m'
o() {
    sysctl -w net.core.rmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 268435456" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 268435456" >/dev/null 2>&1
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
ENDSCRIPT
    chmod +x /usr/local/bin/elite-x-speed
}

# ========== CREATE TRAFFIC MONITOR ==========
create_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'ENDSCRIPT'
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
ENDSCRIPT
    chmod +x /usr/local/bin/elite-x-traffic

    cat > /etc/systemd/system/elite-x-traffic.service <<'ENDSCRIPT'
[Unit]
Description=ELITE-X Traffic Monitor
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
[Install]
WantedBy=multi-user.target
ENDSCRIPT
    systemctl daemon-reload
    systemctl enable elite-x-traffic.service
    systemctl start elite-x-traffic.service
}

# ========== CREATE AUTO REMOVER ==========
create_auto_remover() {
    cat > /usr/local/bin/elite-x-cleaner <<'ENDSCRIPT'
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
ENDSCRIPT
    chmod +x /usr/local/bin/elite-x-cleaner

    cat > /etc/systemd/system/elite-x-cleaner.service <<'ENDSCRIPT'
[Unit]
Description=ELITE-X Auto Remover
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
[Install]
WantedBy=multi-user.target
ENDSCRIPT
    systemctl daemon-reload
    systemctl enable elite-x-cleaner.service
    systemctl start elite-x-cleaner.service
}

# ========== CREATE UPDATER ==========
create_updater() {
    cat > /usr/local/bin/elite-x-update <<'ENDSCRIPT'
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
ENDSCRIPT
    chmod +x /usr/local/bin/elite-x-update
}

# ========== AUTO-SHOW DASHBOARD ==========
create_autoshow() {
    cat > /etc/profile.d/elite-x-dashboard.sh <<'ENDSCRIPT'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ] && [ -t 0 ]; then
    export ELITE_X_SHOWN=1
    /usr/local/bin/elite-x
fi
ENDSCRIPT
    chmod +x /etc/profile.d/elite-x-dashboard.sh

    cat >> ~/.bashrc <<'ENDSCRIPT'
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    /usr/local/bin/elite-x
fi
ENDSCRIPT

    echo "alias menu='elite-x'" >> ~/.bashrc
    echo "alias elitex='elite-x'" >> ~/.bashrc
    
    source ~/.bashrc 2>/dev/null || true
}

# ========== CACHE NETWORK INFO ==========
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

# ========== MAIN INSTALLATION ==========
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
    echo -e "${CYAN}  2. USA (Ultra MTU up to 5000)${NC}"
    echo -e "${BLUE}  3. Europe (Ultra MTU up to 5000)${NC}"
    echo -e "${PURPLE}  4. Asia (Ultra MTU up to 5000)${NC}"
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
            2) selected="USA"; need_ultra=1 ;;
            3) selected="Europe"; need_ultra=1 ;;
            4) selected="Asia"; need_ultra=1 ;;
            5) selected="Auto-detect"; need_ultra=1 ;;
        esac
    fi

    echo "$selected" > /etc/elite-x/location
    echo "$mtu" > /etc/elite-x/mtu

    port=5300
    dns_port=53

    echo "==> ELITE-X ULTRA INSTALLATION STARTING..."

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

    # Create all helper scripts
    create_traffic_monitor
    create_speed_optimizer
    create_auto_remover
    create_updater
    create_user_manager

    # Apply ultra optimizations if needed
    if [ ! -z "${need_ultra:-}" ]; then
        optimize_halotel_ultra
        detect_best_mtu
        local detected_mtu=$(cat /etc/elite-x/mtu)
        sed -i "s/-mtu [0-9]*/-mtu $detected_mtu/" /etc/systemd/system/dnstt-elite-x.service
        systemctl daemon-reload
        systemctl restart dnstt-elite-x dnstt-elite-x-proxy
    fi

    # Create expiry checker
    cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
    chmod +x /etc/cron.hourly/elite-x-expiry

    # Cache network info
    cache_network_info
    
    # Create auto-show
    create_autoshow

    # Copy this script to /usr/local/bin/elite-x
    cp "$0" /usr/local/bin/elite-x 2>/dev/null || {
        cat > /usr/local/bin/elite-x <<'INNEREOF'
#!/bin/bash
if [ -f /root/Elite-X-dns.sh ]; then
    /root/Elite-X-dns.sh --menu
else
    echo "ELITE-X script not found!"
fi
INNEREOF
    }
    chmod +x /usr/local/bin/elite-x

    # Display success message
    echo "======================================"
    echo " ELITE-X ULTRA INSTALLED SUCCESSFULLY "
    echo "======================================"
    exp_info=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
    final_mtu=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    act_key=$(cat /etc/elite-x/key 2>/dev/null || echo "$_a1")
    echo "DOMAIN  : $domain"
    echo "LOCATION: $selected"
    echo "MTU     : $final_mtu ${YELLOW}(Ultra Mode)${NC}"
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

# ========== CHECK IF BEING SOURCED OR RUN AS MENU ==========
if [ "$1" = "--menu" ]; then
    main_menu
elif [ "$0" = "/usr/local/bin/elite-x" ] || [ "$1" = "--check-expiry" ]; then
    if [ "$1" = "--check-expiry" ]; then
        check_expiry
    else
        main_menu
    fi
else
    main_installation
fi
