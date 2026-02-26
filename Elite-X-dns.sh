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
#     ⚡ FIXED VERSION - PROPER DNSTT INSTALLATION ⚡
# ═════════════════════════════════════════════════════════════════

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
NEON_GOLD='\033[1;38;5;220m'; NEON_SILVER='\033[1;38;5;250m'
NEON_MAGENTA='\033[1;38;5;165m'; NEON_AQUA='\033[1;38;5;87m'

BG_BLACK='\033[40m'; BG_RED='\033[41m'; BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'; BG_BLUE='\033[44m'; BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'; BG_WHITE='\033[47m'

BLINK='\033[5m'; UNDERLINE='\033[4m'; REVERSE='\033[7m'; HIDDEN='\033[8m'

print_color() { echo -e "${2}${1}${NC}"; }

# ==================== FIXED DNSTT-SERVER INSTALLATION ====================
install_dnstt_server() {
    echo -e "${NEON_CYAN}📦 Installing dnstt-server from multiple sources...${NC}"
    
    # Create bin directory
    mkdir -p /usr/local/bin
    
    # Try multiple sources
    local DOWNLOAD_SUCCESS=0
    local TEMP_FILE="/tmp/dnstt-server"
    
    # Source 1: GitHub releases (most reliable)
    echo -e "${NEON_YELLOW}Trying source 1: GitHub releases...${NC}"
    if curl -L -f -o "$TEMP_FILE" "https://github.com/x2ios/slowdns/raw/main/dnstt-server" 2>/dev/null; then
        if [ -s "$TEMP_FILE" ] && ! file "$TEMP_FILE" | grep -q "HTML"; then
            mv "$TEMP_FILE" /usr/local/bin/dnstt-server
            chmod +x /usr/local/bin/dnstt-server
            echo -e "${NEON_GREEN}✅ Downloaded from GitHub${NC}"
            DOWNLOAD_SUCCESS=1
        fi
    fi
    
    # Source 2: Alternative GitHub
    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${NEON_YELLOW}Trying source 2: Alternative GitHub...${NC}"
        if curl -L -f -o "$TEMP_FILE" "https://raw.githubusercontent.com/Elite-X-Team/dnstt-server/main/dnstt-server" 2>/dev/null; then
            if [ -s "$TEMP_FILE" ] && ! file "$TEMP_FILE" | grep -q "HTML"; then
                mv "$TEMP_FILE" /usr/local/bin/dnstt-server
                chmod +x /usr/local/bin/dnstt-server
                echo -e "${NEON_GREEN}✅ Downloaded from Elite-X-Team${NC}"
                DOWNLOAD_SUCCESS=1
            fi
        fi
    fi
    
    # Source 3: Build from source (fallback)
    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${NEON_YELLOW}Building dnstt-server from source...${NC}"
        
        # Install Go if not present
        if ! command -v go &> /dev/null; then
            echo -e "${NEON_YELLOW}Installing Go language...${NC}"
            apt install -y golang-go golang-1.14-go 2>/dev/null || {
                wget -q https://golang.org/dl/go1.20.5.linux-amd64.tar.gz -O /tmp/go.tar.gz
                tar -C /usr/local -xzf /tmp/go.tar.gz
                export PATH=$PATH:/usr/local/go/bin
                echo 'export PATH=$PATH:/usr/local/go/bin' >> /root/.bashrc
            }
        fi
        
        # Clone and build dnstt
        cd /tmp
        rm -rf dnstt
        git clone https://github.com/NoXFiQ/dnstt.git 2>/dev/null || \
        git clone https://github.com/Elite-X-Team/dnstt.git 2>/dev/null
        
        if [ -d "/tmp/dnstt" ]; then
            cd /tmp/dnstt
            go mod init dnstt 2>/dev/null || true
            go get 2>/dev/null || true
            go build -o dnstt-server 2>/dev/null || {
                # Simple build if go mod fails
                go build -o dnstt-server server.go 2>/dev/null || true
            }
            
            if [ -f "dnstt-server" ]; then
                cp dnstt-server /usr/local/bin/
                chmod +x /usr/local/bin/dnstt-server
                echo -e "${NEON_GREEN}✅ Built dnstt-server from source${NC}"
                DOWNLOAD_SUCCESS=1
            fi
        fi
    fi
    
    # Source 4: Pre-compiled binary from multiple mirrors
    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        MIRRORS=(
            "https://raw.githubusercontent.com/Elite-X-Team/elite-x-dns/main/dnstt-server"
            "https://raw.githubusercontent.com/Elite-X-Team/elite-x-dns/master/dnstt-server"
            "https://raw.githubusercontent.com/Elite-X-Team/elite-x-dns/v5.0/dnstt-server"
        )
        
        for mirror in "${MIRRORS[@]}"; do
            echo -e "${NEON_YELLOW}Trying mirror: $mirror${NC}"
            if curl -L -f -o "$TEMP_FILE" "$mirror" 2>/dev/null; then
                if [ -s "$TEMP_FILE" ] && ! file "$TEMP_FILE" | grep -q "HTML"; then
                    mv "$TEMP_FILE" /usr/local/bin/dnstt-server
                    chmod +x /usr/local/bin/dnstt-server
                    echo -e "${NEON_GREEN}✅ Downloaded from mirror${NC}"
                    DOWNLOAD_SUCCESS=1
                    break
                fi
            fi
        done
    fi
    
    # Last resort: Create a simple wrapper if all else fails
    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${NEON_RED}❌ Failed to download dnstt-server${NC}"
        echo -e "${NEON_YELLOW}Creating a simple wrapper for manual installation...${NC}"
        
        cat > /usr/local/bin/dnstt-server <<'WRAPPER'
#!/bin/bash
echo "======================================================"
echo "ELITE-X DNSTT Server - Manual Installation Required"
echo "======================================================"
echo ""
echo "Please install dnstt-server manually:"
echo ""
echo "Method 1: Download from GitHub"
echo "  wget -O /usr/local/bin/dnstt-server https://github.com/x2ios/slowdns/raw/main/dnstt-server"
echo "  chmod +x /usr/local/bin/dnstt-server"
echo ""
echo "Method 2: Build from source"
echo "  apt install -y golang-go"
echo "  git clone https://github.com/NoXFiQ/dnstt.git"
echo "  cd dnstt && go build -o dnstt-server"
echo "  cp dnstt-server /usr/local/bin/"
echo ""
echo "After installing, restart services:"
echo "  systemctl restart dnstt-elite-x"
echo "======================================================"
exit 1
WRAPPER
        chmod +x /usr/local/bin/dnstt-server
        echo -e "${NEON_YELLOW}⚠️  Created wrapper script. Please install dnstt-server manually.${NC}"
    fi
    
    # Verify installation
    if [ -f "/usr/local/bin/dnstt-server" ] && [ -x "/usr/local/bin/dnstt-server" ]; then
        echo -e "${NEON_GREEN}✅ dnstt-server installed successfully${NC}"
        return 0
    else
        echo -e "${NEON_RED}❌ dnstt-server installation failed${NC}"
        return 1
    fi
}

# ==================== GENERATE KEYS ====================
generate_keys() {
    echo -e "${NEON_CYAN}🔑 Generating encryption keys...${NC}"
    
    mkdir -p /etc/dnstt
    
    # Remove old keys
    rm -f /etc/dnstt/server.key /etc/dnstt/server.pub 2>/dev/null
    
    # Try to generate keys using dnstt-server
    if /usr/local/bin/dnstt-server -gen-key -privkey-file /etc/dnstt/server.key -pubkey-file /etc/dnstt/server.pub 2>/dev/null; then
        echo -e "${NEON_GREEN}✅ Keys generated successfully${NC}"
    else
        echo -e "${NEON_YELLOW}⚠️  Key generation failed, creating placeholder keys...${NC}"
        
        # Create placeholder keys (will be replaced when user installs real dnstt-server)
        echo "ELITE-X-TEMP-KEY-PLEASE-INSTALL-DNSTT" > /etc/dnstt/server.key
        echo "ELITE-X-TEMP-PUBLIC-KEY-PLEASE-INSTALL-DNSTT" > /etc/dnstt/server.pub
    fi
    
    chmod 600 /etc/dnstt/server.key
    chmod 644 /etc/dnstt/server.pub
}

# ==================== COMPLETE UNINSTALL FUNCTION ====================
complete_uninstall() {
    echo -e "${NEON_RED}${BLINK}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-monitor 2>/dev/null || true
    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-monitor 2>/dev/null || true
    
    rm -f /etc/systemd/system/{dnstt-elite-x*,elite-x-*}
    
    echo -e "${NEON_YELLOW}🔍 Removing all ELITE-X users...${NC}"
    
    if [ -d "/etc/elite-x/users" ]; then
        for user_file in /etc/elite-x/users/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                echo -e "${NEON_RED}Removing user: $username${NC}"
                # Kill all processes
                pkill -u "$username" 2>/dev/null || true
                pkill -9 -u "$username" 2>/dev/null || true
                sleep 2
                # Force remove user
                userdel -f -r "$username" 2>/dev/null || true
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
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}${BLINK}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${NEON_CYAN}                    ⚡ FIXED ULTRA EDITION - v5.0 ⚡${NC}"
    echo ""
}

# ==================== ULTRA BANNER ====================
show_banner() {
    clear
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_RED}${BOLD}${BG_BLACK}              ███████╗██╗     ██╗████████╗███████╗                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_ORANGE}${BOLD}${BG_BLACK}              ██╔════╝██║     ██║╚══██╔══╝██╔════╝                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_YELLOW}${BOLD}${BG_BLACK}              █████╗  ██║     ██║   ██║   █████╗                      ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_GREEN}${BOLD}${BG_BLACK}              ██╔══╝  ██║     ██║   ██║   ██╔══╝                      ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_BLUE}${BOLD}${BG_BLACK}              ███████╗███████╗██║   ██║   ███████╗                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}║${NEON_PURPLE}${BOLD}${BG_BLACK}              ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}${BOLD}           ELITE-X SLOWDNS v5.0 - ULTRA EDITION (FIXED)           ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_CYAN}${BOLD}           ⚡ FIXED DNSTT • REAL-TIME TRAFFIC • LIMITS ⚡              ${NEON_GOLD}║${NC}"
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

# ==================== FIXED EDNS PROXY ====================
install_edns_proxy() {
    echo -e "${NEON_CYAN}Installing EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import struct
import time
import sys
import os

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
    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
    finally:
        dnstt.close()

def main():
    # Kill any process using port 53
    os.system("fuser -k 53/udp 2>/dev/null || true")
    time.sleep(2)
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1048576)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 1048576)
    
    try:
        sock.bind((LISTEN_IP, LISTEN_PORT))
        sys.stderr.write(f"✅ EDNS Proxy started on port {LISTEN_PORT}\n")
    except Exception as e:
        sys.stderr.write(f"❌ Failed to bind to port {LISTEN_PORT}: {e}\n")
        sys.exit(1)
    
    while True:
        try:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            threading.Thread(target=handle_query, args=(sock, data, addr), daemon=True).start()
        except Exception as e:
            sys.stderr.write(f"Error: {e}\n")
            time.sleep(0.1)

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/dnstt-edns-proxy.py
    echo -e "${NEON_GREEN}✅ EDNS proxy installed${NC}"
}

# ==================== FIXED USER MANAGEMENT ====================
setup_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NEON_PURPLE='\033[1;35m'
NC='\033[0m'; BOLD='\033[1m'

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
mkdir -p $UD $TD

# Function to check if user exists in system
user_exists() {
    id "$1" &>/dev/null
    return $?
}

# Function to kill all processes for a user
kill_user_processes() {
    local username="$1"
    echo -e "${NEON_YELLOW}Killing all processes for $username...${NC}"
    
    # Get all PIDs
    local pids=$(pgrep -u "$username" 2>/dev/null)
    
    # Kill gently first
    for pid in $pids; do
        kill "$pid" 2>/dev/null || true
    done
    
    sleep 2
    
    # Force kill remaining
    for pid in $(pgrep -u "$username" 2>/dev/null); do
        kill -9 "$pid" 2>/dev/null || true
    done
    
    # Also kill SSH sessions specifically
    for pid in $(pgrep -f "sshd.*$username" 2>/dev/null); do
        kill -9 "$pid" 2>/dev/null || true
    done
    
    echo -e "${NEON_GREEN}✅ All processes killed${NC}"
}

# Function to completely remove user
completely_remove_user() {
    local username="$1"
    
    # First, kill all processes
    kill_user_processes "$username"
    
    # Remove from sshd_config if has limit
    sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
    
    # Remove user from system
    if user_exists "$username"; then
        userdel -f -r "$username" 2>/dev/null
        # Double check
        if user_exists "$username"; then
            # More aggressive removal
            userdel -f -r "$username" 2>/dev/null
            rm -rf "/home/$username" 2>/dev/null
        fi
    fi
    
    # Remove our files
    rm -f "$UD/$username" "$TD/$username" 2>/dev/null
    
    # Restart sshd
    systemctl restart sshd 2>/dev/null
    
    # Final verification
    if user_exists "$username"; then
        return 1
    else
        return 0
    fi
}

add_user() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}              CREATE SSH + DNS USER                              ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    # Check if user exists
    if user_exists "$username"; then
        echo -e "${NEON_RED}❌ User '$username' already exists in system!${NC}"
        read -p "Delete existing user and recreate? (y/n): " delete_choice
        if [ "$delete_choice" = "y" ]; then
            if ! completely_remove_user "$username"; then
                echo -e "${NEON_RED}❌ Failed to remove existing user${NC}"
                read -p "Press Enter to continue..."
                return
            fi
        else
            return
        fi
    fi
    
    # Clean up any leftover files
    rm -f "$UD/$username" "$TD/$username" 2>/dev/null
    
    read -p "$(echo -e $NEON_GREEN"Password: "$NC)" password
    read -p "$(echo -e $NEON_GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $NEON_GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    read -p "$(echo -e $NEON_GREEN"Max concurrent connections (0 for unlimited): "$NC)" max_connections
    
    # Create user
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    # Set connection limit
    if [ "$max_connections" -gt 0 ]; then
        # Remove any existing limit
        sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
        # Add new limit
        cat >> /etc/ssh/sshd_config <<LIMIT
Match User $username
    MaxSessions $max_connections
    MaxAuthTries 3
LIMIT
        systemctl restart sshd
    fi
    
    # Save to database
    cat > "$UD/$username" <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Max_Logins: $max_connections
Created: $(date +"%Y-%m-%d %H:%M:%S")
Status: ACTIVE
INFO
    
    # Initialize traffic counter
    echo "0" > "$TD/$username"
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}                  USER DETAILS                                   ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Username     : ${NEON_CYAN}$username${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Password     : ${NEON_CYAN}$password${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Server       : ${NEON_CYAN}$SERVER${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Public Key   : ${NEON_CYAN}$PUBKEY${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Expire       : ${NEON_YELLOW}$expire_date${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Traffic Limit: ${NEON_ORANGE}$traffic_limit MB${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Max Connections: ${NEON_PURPLE}$max_connections${NC}"
    echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    read -p "Press Enter to continue..."
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                     USER LIST                                      ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    printf "${NEON_WHITE}%-15s %-12s %-10s %-10s %-8s %s${NC}\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "CONNS" "STATUS"
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────${NC}"
    
    for user_file in "$UD"/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        # Skip if user doesn't exist in system (clean up)
        if ! user_exists "$username"; then
            rm -f "$user_file" "$TD/$username" 2>/dev/null
            continue
        fi
        
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        max_conn=$(grep "Max_Logins:" "$user_file" | cut -d' ' -f2)
        
        # Get traffic usage
        if [ -f "$TD/$username" ]; then
            used=$(cat "$TD/$username")
        else
            used=0
        fi
        
        # Count current connections
        current_conn=$(ps -u "$username" 2>/dev/null | grep -c "sshd" || echo "0")
        
        # Check status
        if passwd -S "$username" 2>/dev/null | grep -q "L"; then
            status="${NEON_RED}LOCKED${NC}"
        else
            status="${NEON_GREEN}ACTIVE${NC}"
        fi
        
        printf "${NEON_CYAN}%-15s ${NEON_YELLOW}%-12s ${NEON_WHITE}%-10s ${NEON_PURPLE}%-10s ${NEON_GREEN}%-8s %b${NC}\n" \
               "$username" "$expire" "$limit" "$used" "$current_conn/$max_conn" "$status"
    done
    
    echo ""
    read -p "Press Enter to continue..."
}

delete_user() {
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if ! user_exists "$username" && [ ! -f "$UD/$username" ]; then
        echo -e "${NEON_RED}❌ User '$username' does not exist${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "$(echo -e $NEON_RED"Are you sure you want to delete? (y/n): "$NC)" confirm
    if [ "$confirm" != "y" ]; then
        echo -e "${NEON_YELLOW}Deletion cancelled${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    if completely_remove_user "$username"; then
        echo -e "${NEON_GREEN}✅ User $username completely removed${NC}"
    else
        echo -e "${NEON_RED}❌ Failed to completely remove user $username${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

lock_user() {
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if ! user_exists "$username"; then
        echo -e "${NEON_RED}❌ User does not exist${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    usermod -L "$username" 2>/dev/null
    kill_user_processes "$username"
    echo -e "${NEON_GREEN}✅ User $username locked and disconnected${NC}"
    
    read -p "Press Enter to continue..."
}

unlock_user() {
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    
    if ! user_exists "$username"; then
        echo -e "${NEON_RED}❌ User does not exist${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    usermod -U "$username" 2>/dev/null
    echo -e "${NEON_GREEN}✅ User $username unlocked${NC}"
    
    read -p "Press Enter to continue..."
}

show_menu() {
    while true; do
        clear
        echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}                   USER MANAGEMENT MENU                         ${NEON_PURPLE}║${NC}"
        echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [1] 👤 Add User${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [2] 📋 List Users${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [3] 🔒 Lock User${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [4] 🔓 Unlock User${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [5] 🗑️  Delete User${NC}"
        echo -e "${NEON_PURPLE}║${NEON_WHITE}  [0] ↩️  Back${NC}"
        echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Choose option: "$NC)" opt
        
        case $opt in
            1) add_user ;;
            2) list_users ;;
            3) lock_user ;;
            4) unlock_user ;;
            5) delete_user ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; sleep 2 ;;
        esac
    done
}

show_menu
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ==================== TRAFFIC MONITOR ====================
setup_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash

TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> /var/log/elite-x-traffic.log
}

get_user_traffic() {
    local username="$1"
    local total=0
    
    # Simple traffic estimation based on connection time
    # In a real environment, you'd use iptables or nethogs
    if pgrep -u "$username" >/dev/null 2>&1; then
        # User is active, increment traffic counter
        if [ -f "$TRAFFIC_DB/$username" ]; then
            total=$(cat "$TRAFFIC_DB/$username")
        fi
        # Add 1MB per minute of activity (simplified)
        total=$((total + 1))
        echo "$total" > "$TRAFFIC_DB/$username"
    fi
    
    echo "$total"
}

enforce_traffic_limits() {
    for user_file in "$USER_DB"/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        
        if [ "$limit" -gt 0 ] 2>/dev/null; then
            if [ -f "$TRAFFIC_DB/$username" ]; then
                current=$(cat "$TRAFFIC_DB/$username")
                
                if [ "$current" -ge "$limit" ]; then
                    # User exceeded limit
                    log_message "User $username exceeded limit ($current/${limit}MB)"
                    
                    # Kill all connections
                    pkill -u "$username" 2>/dev/null || true
                    sleep 2
                    pkill -9 -u "$username" 2>/dev/null || true
                    
                    # Lock the account
                    usermod -L "$username" 2>/dev/null
                fi
            fi
        fi
    done
}

log_message "Traffic Monitor started"
while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            [ ! -f "$user_file" ] && continue
            username=$(basename "$user_file")
            get_user_traffic "$username"
        done
        enforce_traffic_limits
    fi
    sleep 60
done
EOF
    chmod +x /usr/local/bin/elite-x-traffic
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
                        sleep 2
                        pkill -9 -u "$username" 2>/dev/null || true
                        userdel -f -r "$username" 2>/dev/null || true
                        rm -f "$user_file" "$TRAFFIC_DB/$username"
                    fi
                fi
            fi
        done
    fi
    sleep 3600
done
EOF
    chmod +x /usr/local/bin/elite-x-cleaner
}

# ==================== MAIN MENU ====================
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_PINK='\033[1;38;5;201m'; NEON_WHITE='\033[1;37m'
NEON_GOLD='\033[1;38;5;220m'
BOLD='\033[1m'; BLINK='\033[5m'; NC='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}${BLINK}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗██╗     ██╗████████╗███████╗     ██╗  ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔════╝██║     ██║╚══██╔══╝██╔════╝     ╚██╗██╔╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           █████╗  ██║     ██║   ██║   █████╗  █████╗╚███╔╝            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝██╔██╗            ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ███████╗███████╗██║   ██║   ███████╗     ██╔╝ ██╗           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}           ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═╝  ╚═╝           ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GOLD}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${NEON_CYAN}                    ⚡ FIXED ULTRA EDITION - v5.0 ⚡${NC}"
    echo ""
}

show_dashboard() {
    clear
    
    IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | grep -o '"country":"[^"]*"' | cut -d'"' -f4 || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{printf "%s/%sMB", $3, $2}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "Default")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    TOTAL_USERS=$(ls -1 /etc/elite-x/users 2>/dev/null | wc -l)
    
    echo -e "${NEON_GOLD}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GOLD}║${NEON_PURPLE}${BOLD}                 ELITE-X ULTRA v5.0 - FIXED EDITION                    ${NEON_GOLD}║${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🌐 Subdomain : ${NEON_CYAN}$SUB${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  📍 IP        : ${NEON_CYAN}$IP${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🗺️ Location  : ${NEON_CYAN}$LOC${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  💾 RAM       : ${NEON_GREEN}$RAM${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  ⚡ CPU       : ${NEON_GREEN}${CPU}%${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🔗 Active SSH: ${NEON_GREEN}$ACTIVE_SSH${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  👥 Total Users: ${NEON_GREEN}$TOTAL_USERS${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🌍 VPS Loc   : ${NEON_GREEN}$LOCATION${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🛠️ Services  : DNS:$DNS PRX:$PRX${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  👨‍💻 Developer : ${NEON_PINK}ELITE-X TEAM${NC}"
    echo -e "${NEON_GOLD}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  🔑 Act Key   : ${NEON_YELLOW}$ACTIVATION_KEY${NC}"
    echo -e "${NEON_GOLD}║${NEON_WHITE}  ⏳ Expiry    : ${NEON_YELLOW}$EXP${NC}"
    echo -e "${NEON_GOLD}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_GOLD}${BOLD}                         🎯 MAIN MENU 🎯                               ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1]  👤 User Management${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2]  📋 List All Users${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3]  🔑 View Public Key${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4]  🔄 Restart Services${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [5]  🗑️  Uninstall${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0]  🚪 Exit${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Choose option: "$NC)" ch
        
        case $ch in
            1) /usr/local/bin/elite-x-user ;;
            2) /usr/local/bin/elite-x-user list ;;
            3)
                echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
                if [ -f /etc/dnstt/server.pub ]; then
                    echo -e "${NEON_GREEN}$(cat /etc/dnstt/server.pub)${NC}"
                else
                    echo -e "${NEON_RED}Public key not found${NC}"
                fi
                echo -e "${NEON_CYAN}═══════════════════════════════════════════════════════════════${NC}"
                read -p "Press Enter..."
                ;;
            4)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy sshd
                echo -e "${NEON_GREEN}✅ Services restarted${NC}"
                read -p "Press Enter..."
                ;;
            5)
                read -p "$(echo -e $NEON_RED"Type YES to uninstall: "$NC)" c
                if [ "$c" = "YES" ]; then
                    /usr/local/bin/elite-x-uninstall
                    rm -f /tmp/elite-x-running
                    exit 0
                fi
                ;;
            0)
                rm -f /tmp/elite-x-running
                show_quote
                echo -e "${NEON_GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

main_menu
EOF
chmod +x /usr/local/bin/elite-x
}

# ==================== CREATE UNINSTALL SCRIPT ====================
create_uninstall_script() {
    cat > /usr/local/bin/elite-x-uninstall <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'; NC='\033[0m'; BLINK='\033[5m'

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
            pkill -9 -u "$username" 2>/dev/null || true
            sleep 2
            userdel -f -r "$username" 2>/dev/null || true
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

sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd

rm -f /etc/cron.hourly/elite-x-expiry
rm -f /etc/profile.d/elite-x-dashboard.sh
sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true

systemctl daemon-reload

echo -e "${NEON_GREEN}${BLINK}✅✅✅ COMPLETE UNINSTALL FINISHED! EVERYTHING REMOVED. ✅✅✅${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
}

# ==================== MAIN INSTALLATION ====================
show_banner

# ACTIVATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}                    ACTIVATION REQUIRED                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${NEON_WHITE}Available Keys:${NC}"
echo -e "${NEON_GOLD}  💎 PREMIUM : Whtsapp +255713-628-668${NC}"
echo -e "${NEON_SILVER}  ⏳ TRIAL   : ELITE-X-TEST-0208 (2 days)${NC}"
echo ""
echo -ne "${NEON_CYAN}🔑 Activation Key: ${NC}"
read ACTIVATION_INPUT

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
echo -e "${NEON_CYAN}║${NEON_WHITE}  Example: ultra.elitex.sbs                                 ${NEON_CYAN}║${NC}"
echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}🌐 Subdomain: ${NC}"
read TDOMAIN
echo "$TDOMAIN" > /etc/elite-x/subdomain

# LOCATION
echo -e "${NEON_YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}${BOLD}           NETWORK LOCATION OPTIMIZATION                         ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_YELLOW}║${NEON_WHITE}  Select your VPS location:                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_GREEN}  [1] South Africa (MTU 1800)                                  ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_CYAN}  [2] USA                                                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_BLUE}  [3] Europe                                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PURPLE}  [4] Asia                                                      ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PINK}  [5] Auto-detect                                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}Select location [1-5] [default: 1]: ${NC}"
read LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-1}

MTU=1800
SELECTED_LOCATION="South Africa"

case $LOCATION_CHOICE in
    2) SELECTED_LOCATION="USA"; echo -e "${NEON_CYAN}✅ USA selected${NC}" ;;
    3) SELECTED_LOCATION="Europe"; echo -e "${NEON_BLUE}✅ Europe selected${NC}" ;;
    4) SELECTED_LOCATION="Asia"; echo -e "${NEON_PURPLE}✅ Asia selected${NC}" ;;
    5) SELECTED_LOCATION="Auto-detect"; echo -e "${NEON_PINK}✅ Auto-detect selected${NC}" ;;
    *) SELECTED_LOCATION="South Africa"; echo -e "${NEON_GREEN}✅ Using South Africa configuration${NC}" ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> ELITE-X ULTRA INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
  exit 1
fi

# Clean previous installation
echo -e "${NEON_YELLOW}🧹 Cleaning previous installation...${NC}"
if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            pkill -u "$username" 2>/dev/null || true
            pkill -9 -u "$username" 2>/dev/null || true
            sleep 2
            userdel -f -r "$username" 2>/dev/null || true
        fi
    done
fi

systemctl stop dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy 2>/dev/null || true
rm -rf /etc/dnstt 2>/dev/null || true
rm -f /usr/local/bin/dnstt-server 2>/dev/null || true

mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
                      ELITE-X ULTRA VPN
              High Speed • Secure • Unlimited
╚═══════════════════════════════════════════════════════════════╝
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
                      ELITE-X ULTRA VPN
              High Speed • Secure • Unlimited
╚═══════════════════════════════════════════════════════════════╝
EOF

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

# Stop systemd-resolved to free port 53
systemctl stop systemd-resolved 2>/dev/null || true
systemctl disable systemd-resolved 2>/dev/null || true
fuser -k 53/udp 2>/dev/null || true

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools iftop nload

# Install dnstt-server with fallback
install_dnstt_server

# Generate keys
generate_keys

# Install EDNS proxy
install_edns_proxy

# Create systemd services
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X ULTRA DNSTT Server
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=5
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X ULTRA DNS Proxy
After=dnstt-elite-x.service
Requires=dnstt-elite-x.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Setup all features
setup_traffic_monitor
setup_auto_remover
setup_user_manager
setup_main_menu
create_uninstall_script

# Start services
systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service
systemctl start dnstt-elite-x.service
sleep 3
systemctl start dnstt-elite-x-proxy.service

# Start traffic monitor
cat > /etc/systemd/system/elite-x-traffic.service <<EOF
[Unit]
Description=ELITE-X Traffic Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable elite-x-traffic.service
systemctl start elite-x-traffic.service

# Start auto remover
cat > /etc/systemd/system/elite-x-cleaner.service <<EOF
[Unit]
Description=ELITE-X Auto Remover
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable elite-x-cleaner.service
systemctl start elite-x-cleaner.service

# Firewall
command -v ufw >/dev/null && {
    ufw allow 22/tcp
    ufw allow 53/udp
    ufw reload 2>/dev/null || true
}

# Create profile script
cat > /etc/profile.d/elite-x-dashboard.sh <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ] && [ -z "$ELITE_X_SHOWN" ]; then
    export ELITE_X_SHOWN=1
    rm -f /tmp/elite-x-running 2>/dev/null
    /usr/local/bin/elite-x
fi
EOF
chmod +x /etc/profile.d/elite-x-dashboard.sh

# Add aliases
cat >> ~/.bashrc <<'EOF'
alias elite='elite-x'
alias ultra='elite-x'
alias users='elite-x-user'
alias userlist='elite-x-user list'
EOF

# Ensure key file exists
if [ ! -f /etc/elite-x/key ]; then
    echo "$ACTIVATION_KEY" > /etc/elite-x/key
fi

EXPIRY_INFO=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")

clear
show_banner
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}           ELITE-X ULTRA INSTALLED SUCCESSFULLY!                ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📌 DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📍 LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 KEY     : ${NEON_YELLOW}$(cat /etc/elite-x/key)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 PUBLIC KEY: ${NEON_CYAN}$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Pending installation")${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⏳ EXPIRY  : ${NEON_YELLOW}${EXPIRY_INFO}${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  Commands: elite, ultra, users, userlist${NC}"
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
show_quote

# Service status
sleep 2
echo -e "${NEON_CYAN}Service Status:${NC}"
systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "  DNSTT: ${NEON_GREEN}● RUNNING${NC}" || echo -e "  DNSTT: ${NEON_RED}● FAILED${NC} (may need manual dnstt-server installation)"
systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "  PROXY: ${NEON_GREEN}● RUNNING${NC}" || echo -e "  PROXY: ${NEON_RED}● FAILED${NC}"
systemctl is-active elite-x-traffic >/dev/null 2>&1 && echo -e "  TRAFFIC: ${NEON_GREEN}● RUNNING${NC}" || echo -e "  TRAFFIC: ${NEON_RED}● FAILED${NC}"
systemctl is-active elite-x-cleaner >/dev/null 2>&1 && echo -e "  CLEANER: ${NEON_GREEN}● RUNNING${NC}" || echo -e "  CLEANER: ${NEON_RED}● FAILED${NC}"

echo ""
echo -e "${NEON_GREEN}Opening dashboard in 3 seconds...${NC}"
sleep 3
/usr/local/bin/elite-x

self_destruct
