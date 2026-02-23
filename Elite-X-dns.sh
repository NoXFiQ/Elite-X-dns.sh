#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v3.6 - FASTDNS EDITION
#              Support: FastDNS over UDP + All V3.5 Features
# ═════════════════════════════════════════════════════════════════

set -euo pipefail

# ==================== COLOR PALETTE ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; BOLD='\033[1m'
NC='\033[0m'

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NC='\033[0m'

print_color() { echo -e "${2}${1}${NC}"; }

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

# FastDNS Configuration
FASTDNS_PORT="5353"
FASTDNS_CONFIG="/etc/fastdns"
FASTDNS_BIN="/usr/local/bin/fastdns"

# ==================== LOG FUNCTION ====================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ==================== SELF DESTRUCT ====================
self_destruct() {
    echo -e "${YELLOW}🧹 Cleaning installation traces...${NC}"
    
    history -c 2>/dev/null || true
    cat /dev/null > ~/.bash_history 2>/dev/null || true
    cat /dev/null > /root/.bash_history 2>/dev/null || true
    
    if [ -f "$0" ] && [ "$0" != "/usr/local/bin/elite-x" ]; then
        local script_path=$(readlink -f "$0")
        rm -f "$script_path" 2>/dev/null || true
    fi
    
    sed -i '/elite-x/d' /var/log/auth.log 2>/dev/null || true
    
    echo -e "${GREEN}✅ Cleanup complete!${NC}"
}

# ==================== SHOW QUOTE ====================
show_quote() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}            Always Remember ELITE-X when you see X            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== SHOW BANNER ====================
show_banner() {
    clear
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${YELLOW}${BOLD}               ELITE-X SLOWDNS v3.6 - FASTDNS EDITION            ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${GREEN}${BOLD}              High Speed • FastDNS UDP • Advanced                  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== SET TIMEZONE ====================
set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

# ==================== CHECK EXPIRY ====================
check_expiry() {
    if [ -f "$ACTIVATION_TYPE_FILE" ] && [ -f "$ACTIVATION_DATE_FILE" ] && [ -f "$EXPIRY_DAYS_FILE" ]; then
        local act_type=$(cat "$ACTIVATION_TYPE_FILE")
        if [ "$act_type" = "temporary" ]; then
            local act_date=$(cat "$ACTIVATION_DATE_FILE")
            local expiry_days=$(cat "$EXPIRY_DAYS_FILE")
            local current_date=$(date +%s)
            local expiry_date=$(date -d "$act_date + $expiry_days days" +%s)
            
            if [ $current_date -ge $expiry_date ]; then
                echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${RED}║${YELLOW}           TRIAL PERIOD EXPIRED                                  ${RED}║${NC}"
                echo -e "${RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${RED}║${WHITE}  Your 2-day trial has ended.                                  ${RED}║${NC}"
                echo -e "${RED}║${WHITE}  Script will now uninstall itself...                         ${RED}║${NC}"
                echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
                sleep 3
                
                # Complete uninstall
                echo -e "${YELLOW}🔄 Removing all users and data...${NC}"
                
                # Remove all SSH users
                if [ -d "/etc/elite-x/users" ]; then
                    for user_file in /etc/elite-x/users/*; do
                        if [ -f "$user_file" ]; then
                            username=$(basename "$user_file")
                            userdel -r "$username" 2>/dev/null || true
                            pkill -u "$username" 2>/dev/null || true
                        fi
                    done
                fi
                
                # Kill all processes
                pkill -f dnstt-server 2>/dev/null || true
                pkill -f dnstt-edns-proxy 2>/dev/null || true
                pkill -f fastdns 2>/dev/null || true
                
                # Stop services
                systemctl stop dnstt-elite-x dnstt-elite-x-proxy fastdns 2>/dev/null || true
                systemctl disable dnstt-elite-x dnstt-elite-x-proxy fastdns 2>/dev/null || true
                
                # Remove files
                rm -rf /etc/systemd/system/dnstt-elite-x*
                rm -rf /etc/systemd/system/fastdns*
                rm -rf /etc/dnstt /etc/elite-x /etc/fastdns
                rm -f /usr/local/bin/{dnstt-*,elite-x*,fastdns*}
                
                # Remove SSH banner
                sed -i '/^Banner/d' /etc/ssh/sshd_config
                systemctl restart sshd
                
                echo -e "${GREEN}✅ ELITE-X has been uninstalled.${NC}"
                rm -f "$0"
                exit 0
            else
                local days_left=$(( (expiry_date - current_date) / 86400 ))
                local hours_left=$(( ((expiry_date - current_date) % 86400) / 3600 ))
                echo -e "${YELLOW}⚠️  Trial: $days_left days $hours_left hours remaining${NC}"
            fi
        fi
    fi
}

# ==================== ACTIVATE SCRIPT ====================
activate_script() {
    local input_key="$1"
    mkdir -p /etc/elite-x
    
    if [ "$input_key" = "$ACTIVATION_KEY" ] || [ "$input_key" = "Whtsapp 0713628668" ]; then
        echo "$ACTIVATION_KEY" > "$ACTIVATION_FILE"
        echo "$ACTIVATION_KEY" > "$KEY_FILE"
        echo "lifetime" > "$ACTIVATION_TYPE_FILE"
        echo "Lifetime" > "$EXPIRY_FILE"
        log "Lifetime activation recorded"
        return 0
    elif [ "$input_key" = "$TEMP_KEY" ]; then
        echo "$TEMP_KEY" > "$ACTIVATION_FILE"
        echo "$TEMP_KEY" > "$KEY_FILE"
        echo "temporary" > "$ACTIVATION_TYPE_FILE"
        echo "$(date +%Y-%m-%d)" > "$ACTIVATION_DATE_FILE"
        echo "2" > "$EXPIRY_DAYS_FILE"
        echo "2 Days Trial" > "$EXPIRY_FILE"
        log "Trial activation recorded (2 days)"
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

# ==================== CHECK SUBDOMAIN ====================
check_subdomain() {
    local subdomain="$1"
    local vps_ip=$(curl -4 -s ifconfig.me 2>/dev/null || echo "")
    
    echo -e "${YELLOW}🔍 Checking if subdomain points to this VPS (IPv4)...${NC}"
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}  Subdomain: $subdomain${NC}"
    echo -e "${CYAN}║${WHITE}  VPS IPv4 : $vps_ip${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$vps_ip" ]; then
        echo -e "${YELLOW}⚠️  Could not detect VPS IPv4, continuing anyway...${NC}"
        return 0
    fi

    local resolved_ip=$(dig +short -4 "$subdomain" 2>/dev/null | head -1)
    
    if [ -z "$resolved_ip" ]; then
        echo -e "${YELLOW}⚠️  Could not resolve subdomain, continuing anyway...${NC}"
        return 0
    fi
    
    if [ "$resolved_ip" = "$vps_ip" ]; then
        echo -e "${GREEN}✅ Subdomain correctly points to this VPS!${NC}"
        return 0
    else
        echo -e "${RED}❌ Subdomain points to $resolved_ip, but VPS IP is $vps_ip${NC}"
        read -p "Continue anyway? (y/n): " continue_anyway
        [ "$continue_anyway" != "y" ] && exit 1
    fi
}

# ==================== INSTALL FASTDNS (phuslu/fastdns) ====================
install_fastdns() {
    echo -e "${NEON_CYAN}📡 Installing FastDNS (phuslu/fastdns) over UDP...${NC}"
    
    mkdir -p "$FASTDNS_CONFIG"
    
    # Check if Go is installed
    if ! command -v go &>/dev/null; then
        echo -e "${YELLOW}Installing Go language...${NC}"
        wget -q https://golang.org/dl/go1.21.0.linux-amd64.tar.gz
        tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
        export PATH=$PATH:/usr/local/go/bin
        rm -f go1.21.0.linux-amd64.tar.gz
    fi
    
    # Clone and build fastdns
    cd /tmp
    if [ -d "fastdns" ]; then
        rm -rf fastdns
    fi
    
    echo -e "${YELLOW}Downloading fastdns source...${NC}"
    git clone https://github.com/phuslu/fastdns.git
    cd fastdns
    
    echo -e "${YELLOW}Building fastdns (this may take a moment)...${NC}"
    go build -o "$FASTDNS_BIN" ./cmd/fastdns 2>/dev/null || {
        # Try alternative build method
        CGO_ENABLED=0 go build -o "$FASTDNS_BIN" -ldflags="-s -w" ./cmd/fastdns
    }
    
    if [ ! -f "$FASTDNS_BIN" ]; then
        # If build fails, download pre-compiled binary
        echo -e "${YELLOW}Build failed, trying pre-compiled binary...${NC}"
        cd /tmp
        wget -q https://github.com/phuslu/fastdns/releases/latest/download/fastdns-linux-amd64 -O "$FASTDNS_BIN"
    fi
    
    chmod +x "$FASTDNS_BIN"
    
    # Create FastDNS configuration for UDP
    cat > "$FASTDNS_CONFIG/fastdns.yml" <<EOF
# FastDNS Configuration - ELITE-X v3.6
listen:
  - :$FASTDNS_PORT   # UDP port for FastDNS

# Upstream DNS servers (Google, Cloudflare, OpenDNS)
upstream:
  - udp://8.8.8.8:53
  - udp://8.8.4.4:53
  - udp://1.1.1.1:53
  - udp://1.0.0.1:53
  - udp://208.67.222.222:53
  - udp://208.67.220.220:53

# Cache settings
cache:
  enable: true
  size: 100000
  ttl: 300

# Performance tuning
performance:
  workers: 4
  max_concurrent: 1000
  read_timeout: 5s
  write_timeout: 5s
  idle_timeout: 30s

# Logging
log:
  level: info
  output: /var/log/fastdns.log
EOF

    # Create systemd service for FastDNS
    cat > /etc/systemd/system/fastdns.service <<EOF
[Unit]
Description=FastDNS High-Performance DNS Resolver
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$FASTDNS_CONFIG
ExecStart=$FASTDNS_BIN -config $FASTDNS_CONFIG/fastdns.yml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

    # Create log file
    touch /var/log/fastdns.log
    chmod 644 /var/log/fastdns.log

    echo -e "${NEON_GREEN}✅ FastDNS installed successfully on UDP port $FASTDNS_PORT${NC}"
}

# ==================== MODIFIED EDNS PROXY TO USE FASTDNS ====================
install_edns_proxy_with_fastdns() {
    echo -e "${NEON_CYAN}Installing EDNS proxy with FastDNS integration...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
"""
ELITE-X EDNS Proxy with FastDNS Integration
Forward DNS queries to both dnstt and FastDNS for optimal performance
"""
import socket
import threading
import struct
import time
import sys
import signal
import os
import select

# Configuration
LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
FASTDNS_IP = '127.0.0.1'
FASTDNS_PORT = 5353
BUFFER_SIZE = 8192
EDNS_MAX_SIZE = 4096
TIMEOUT = 5
MAX_RETRIES = 2

running = True

def signal_handler(sig, frame):
    global running
    print("\nShutting down proxy...")
    running = False
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def log(msg):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}")
    sys.stdout.flush()

def modify_edns(data, max_size=4096):
    """Add or modify EDNS0 OPT record in DNS packet"""
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
    
    # Skip questions
    for _ in range(qdcount):
        offset = skip_name(data, offset)
        offset += 4
    
    # Skip answers and authorities
    for _ in range(ancount + nscount):
        offset = skip_name(data, offset)
        if offset + 10 > len(data):
            return data
        rdlength = struct.unpack('!H', data[offset+8:offset+10])[0]
        offset += 10 + rdlength
    
    new_data = bytearray(data)
    
    # Look for OPT record
    for _ in range(arcount):
        if offset + 11 > len(data):
            break
        
        if data[offset] == 0:
            opt_type = struct.unpack('!H', data[offset+1:offset+3])[0]
            if opt_type == 41:  # OPT record
                new_data[offset+3:offset+5] = struct.pack('!H', max_size)
                break
        
        while offset < len(data) and data[offset] != 0:
            if data[offset] & 0xC0:
                offset += 2
                break
            offset += data[offset] + 1
        if data[offset] == 0:
            offset += 1
        if offset + 10 > len(data):
            break
        rdlength = struct.unpack('!H', data[offset+8:offset+10])[0]
        offset += 10 + rdlength
    
    return bytes(new_data)

def forward_to_server(data, server_ip, server_port):
    """Forward DNS query to a specific server and return response"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(TIMEOUT)
    try:
        sock.sendto(data, (server_ip, server_port))
        response, _ = sock.recvfrom(BUFFER_SIZE)
        return response
    except socket.timeout:
        return None
    except Exception as e:
        return None
    finally:
        sock.close()

def handle_query(server_socket, data, client_addr):
    """Handle DNS query using FastDNS first, fallback to dnstt"""
    modified_data = modify_edns(data, EDNS_MAX_SIZE)
    
    # Try FastDNS first (for speed)
    fastdns_response = forward_to_server(modified_data, FASTDNS_IP, FASTDNS_PORT)
    
    if fastdns_response:
        # FastDNS responded, send back to client
        modified_response = modify_edns(fastdns_response, 512)
        server_socket.sendto(modified_response, client_addr)
        return
    
    # If FastDNS fails, try dnstt (for tunnel)
    for attempt in range(MAX_RETRIES):
        dnstt_response = forward_to_server(modified_data, DNSTT_IP, DNSTT_PORT)
        if dnstt_response:
            modified_response = modify_edns(dnstt_response, 512)
            server_socket.sendto(modified_response, client_addr)
            return
        time.sleep(0.5)

def main():
    log(f"ELITE-X v3.6 Proxy starting...")
    log(f"Listening on {LISTEN_IP}:{LISTEN_PORT}")
    log(f"FastDNS: {FASTDNS_IP}:{FASTDNS_PORT}")
    log(f"DNSTT: {DNSTT_IP}:{DNSTT_PORT}")
    
    # Create socket
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 2097152)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 2097152)
        sock.bind((LISTEN_IP, LISTEN_PORT))
    except Exception as e:
        log(f"Failed to bind: {e}")
        sys.exit(1)
    
    log("Proxy is ready")
    
    while running:
        try:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            thread = threading.Thread(
                target=handle_query,
                args=(sock, data, addr),
                daemon=True
            )
            thread.start()
        except Exception as e:
            if running:
                log(f"Error: {e}")
            time.sleep(0.1)

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/dnstt-edns-proxy.py
}

# ==================== SETUP DNSTT SERVER ====================
setup_dnstt_server() {
    echo -e "${NEON_CYAN}Installing dnstt-server...${NC}"
    
    # Kill any process using port 5300
    fuser -k 5300/udp 2>/dev/null || true
    
    # Try multiple sources for dnstt-server
    DNSTT_URLS=(
        "https://github.com/Elite-X-Team/dnstt-server/raw/main/dnstt-server"
        "https://raw.githubusercontent.com/NoXFiQ/Elite-X-dns/main/dnstt-server"
        "https://github.com/x2ios/slowdns/raw/main/dnstt-server"
        "https://dnstt.network/dnstt-server-linux-amd64"
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
        echo -e "${NEON_RED}❌ Failed to download dnstt-server${NC}"
        exit 1
    fi
}

# ==================== GENERATE DNSTT KEYS ====================
generate_dnstt_keys() {
    echo -e "${NEON_CYAN}Generating dnstt keys...${NC}"
    mkdir -p /etc/dnstt
    
    if [ -f /etc/dnstt/server.key ]; then
        echo -e "${YELLOW}⚠️ Existing keys found, removing...${NC}"
        chattr -i /etc/dnstt/server.key 2>/dev/null || true
        rm -f /etc/dnstt/server.key
        rm -f /etc/dnstt/server.pub
    fi
    
    cd /etc/dnstt
    /usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
    cd ~
    
    chmod 600 /etc/dnstt/server.key
    chmod 644 /etc/dnstt/server.pub
    
    echo -e "${NEON_GREEN}✅ Public key: $(cat /etc/dnstt/server.pub)${NC}"
}

# ==================== SETUP TRAFFIC MONITOR ====================
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
                    log_message "User $username exceeded limit ($used/${limit}MB)"
                    pkill -u "$username" 2>/dev/null || true
                    usermod -L "$username" 2>/dev/null || true
                fi
            fi
        fi
    done
}

log_message "Traffic monitor started"
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
}

# ==================== SETUP AUTO REMOVER ====================
setup_auto_remover() {
    cat > /usr/local/bin/elite-x-cleaner <<'EOF'
#!/bin/bash

USER_DB="/etc/elite-x/users"
TRAFFIC_DB="/etc/elite-x/traffic"
LOG_FILE="/var/log/elite-x-cleaner.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_message "Auto cleaner started"

while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                expire_date=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
                
                if [ ! -z "$expire_date" ]; then
                    current_date=$(date +%Y-%m-%d)
                    if [[ "$current_date" > "$expire_date" ]] || [ "$current_date" = "$expire_date" ]; then
                        pkill -u "$username" 2>/dev/null || true
                        sleep 2
                        userdel -r "$username" 2>/dev/null
                        rm -f "$user_file"
                        rm -f "$TRAFFIC_DB/$username"
                        rm -f "$TRAFFIC_DB/${username}.history"
                        log_message "Removed expired user: $username"
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
Description=ELITE-X Auto Remover Service
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SETUP BANDWIDTH MONITOR ====================
setup_bandwidth_monitor() {
    cat > /usr/local/bin/elite-x-bandwidth <<'EOF'
#!/bin/bash
LOG_FILE="/var/log/elite-x-bandwidth.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

while true; do
    if [ -f /sys/class/net/eth0/statistics/rx_bytes ]; then
        rx_bytes=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo "0")
        tx_bytes=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo "0")
        rx_mb=$((rx_bytes / 1048576))
        tx_mb=$((tx_bytes / 1048576))
        total_mb=$((rx_mb + tx_mb))
        
        # Get FastDNS stats if available
        if command -v ss &>/dev/null; then
            dns_connections=$(ss -unp | grep -c ":${FASTDNS_PORT:-5353}" 2>/dev/null || echo "0")
            log_message "FastDNS Connections: $dns_connections"
        fi
        
        log_message "Bandwidth - RX: ${rx_mb}MB, TX: ${tx_mb}MB, Total: ${total_mb}MB"
    fi
    sleep 300
done
EOF
    chmod +x /usr/local/bin/elite-x-bandwidth

    cat > /etc/systemd/system/elite-x-bandwidth.service <<EOF
[Unit]
Description=ELITE-X Bandwidth Monitor
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-bandwidth
Restart=always
[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SETUP CONNECTION MONITOR ====================
setup_connection_monitor() {
    cat > /usr/local/bin/elite-x-monitor <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NC='\033[0m'

while true; do
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}              ELITE-X v3.6 CONNECTION MONITOR                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${NEON_GREEN}SSH Connections (Port 22):${NC}"
    echo "─────────────────────────────────"
    ss -tnp | grep ":22" | grep ESTAB | while read line; do
        IP=$(echo "$line" | awk '{print $5}' | cut -d: -f1)
        USER=$(ps -o user= -p $(echo "$line" | grep -o "pid=[0-9]*" | cut -d= -f2) 2>/dev/null || echo "unknown")
        echo -e "  ${NEON_GREEN}→${NC} $IP ($USER)"
    done | head -20
    
    echo -e "\n${NEON_YELLOW}DNS Tunnel (Port 5300):${NC}"
    echo "─────────────────────────────────"
    ss -unp | grep ":5300" 2>/dev/null | while read line; do
        IP=$(echo "$line" | awk '{print $5}' | cut -d: -f1)
        echo -e "  ${NEON_YELLOW}→${NC} $IP"
    done | head -10
    
    echo -e "\n${NEON_CYAN}FastDNS UDP (Port 5353):${NC}"
    echo "─────────────────────────────────"
    ss -unp | grep ":5353" 2>/dev/null | while read line; do
        IP=$(echo "$line" | awk '{print $5}' | cut -d: -f1)
        echo -e "  ${NEON_CYAN}→${NC} $IP"
    done | head -10
    
    SSH_COUNT=$(ss -tnp | grep -c ":22.*ESTAB" 2>/dev/null || echo "0")
    DNS_COUNT=$(ss -unp | grep -c ":5300" 2>/dev/null || echo "0")
    FASTDNS_COUNT=$(ss -unp | grep -c ":5353" 2>/dev/null || echo "0")
    
    echo -e "\n${NEON_WHITE}Total: SSH: $SSH_COUNT, Tunnel: $DNS_COUNT, FastDNS: $FASTDNS_COUNT${NC}"
    echo -e "${NEON_YELLOW}Press 'q' to exit, any key to refresh${NC}"
    read -t 5 -n 1 key
    if [[ $key = q ]]; then 
        break
    fi
done
EOF
    chmod +x /usr/local/bin/elite-x-monitor

    cat > /etc/systemd/system/elite-x-monitor.service <<EOF
[Unit]
Description=ELITE-X Connection Monitor
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/elite-x-monitor
Restart=always
[Install]
WantedBy=multi-user.target
EOF
}

# ==================== SETUP SPEED OPTIMIZATION ====================
setup_speed_optimization() {
    cat > /usr/local/bin/elite-x-speed <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NC='\033[0m'

show_menu() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}              ELITE-X v3.6 SPEED OPTIMIZATION                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${NEON_GREEN}1.${NC} Quick Optimize (Network + CPU + RAM)"
    echo -e "${NEON_GREEN}2.${NC} Network Only (with FastDNS boost)"
    echo -e "${NEON_GREEN}3.${NC} CPU Only"
    echo -e "${NEON_GREEN}4.${NC} RAM Only"
    echo -e "${NEON_GREEN}5.${NC} Clean Junk Files"
    echo -e "${NEON_GREEN}6.${NC} FastDNS Boost (Maximize DNS speed)"
    echo -e "${NEON_GREEN}7.${NC} Show Current System Stats"
    echo -e "${NEON_GREEN}0.${NC} Back"
    echo ""
    read -p "$(echo -e $NEON_YELLOW"Choose option: "$NC)" opt
    
    case $opt in
        1) quick_optimize ;;
        2) optimize_network ;;
        3) optimize_cpu ;;
        4) optimize_ram ;;
        5) clean_junk ;;
        6) fastdns_boost ;;
        7) show_stats ;;
        0) return 0 ;;
        *) echo -e "${NEON_RED}Invalid option${NC}"; sleep 2; show_menu ;;
    esac
}

quick_optimize() {
    echo -e "${NEON_YELLOW}⚡ Quick optimizing system...${NC}"
    optimize_network
    optimize_cpu
    optimize_ram
    clean_junk
    fastdns_boost
    echo -e "${NEON_GREEN}✅ Quick optimization complete!${NC}"
    read -p "Press Enter..."
    show_menu
}

optimize_network() {
    echo -e "${NEON_YELLOW}🌐 Optimizing network...${NC}"
    sysctl -w net.core.rmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.core.wmem_max=268435456 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_rmem="4096 87380 268435456" >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_wmem="4096 65536 268435456" >/dev/null 2>&1
    sysctl -w net.core.netdev_max_backlog=5000 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1
    echo -e "${NEON_GREEN}✅ Network optimized!${NC}"
    sleep 1
}

optimize_cpu() {
    echo -e "${NEON_YELLOW}⚡ Optimizing CPU...${NC}"
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null || true
    done
    echo -e "${NEON_GREEN}✅ CPU optimized!${NC}"
    sleep 1
}

optimize_ram() {
    echo -e "${NEON_YELLOW}💾 Optimizing RAM...${NC}"
    sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    sysctl -w vm.swappiness=10 >/dev/null 2>&1
    echo -e "${NEON_GREEN}✅ RAM optimized!${NC}"
    sleep 1
}

clean_junk() {
    echo -e "${NEON_YELLOW}🧹 Cleaning junk files...${NC}"
    apt clean 2>/dev/null
    apt autoclean 2>/dev/null
    find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
    journalctl --vacuum-time=3d 2>/dev/null || true
    echo -e "${NEON_GREEN}✅ Junk files cleaned!${NC}"
    sleep 1
}

fastdns_boost() {
    echo -e "${NEON_YELLOW}🚀 Boosting FastDNS performance...${NC}"
    systemctl restart fastdns 2>/dev/null
    echo -e "${NEON_GREEN}✅ FastDNS boosted!${NC}"
    sleep 1
}

show_stats() {
    echo -e "${NEON_CYAN}System Statistics:${NC}"
    echo "──────────────────"
    echo -e "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "Memory: $(free -h | awk '/^Mem:/{print $3"/"$2}')"
    echo -e "Disk: $(df -h / | awk 'NR==2{print $3"/"$2}')"
    echo -e "FastDNS: $(systemctl is-active fastdns 2>/dev/null || echo "inactive")"
    echo ""
    read -p "Press Enter..."
    show_menu
}

while true; do
    show_menu
done
EOF
    chmod +x /usr/local/bin/elite-x-speed
}

# ==================== SETUP UPDATER ====================
setup_updater() {
    cat > /usr/local/bin/elite-x-update <<'EOF'
#!/bin/bash

echo -e "${NEON_YELLOW}🔄 Checking for updates...${NC}"
echo -e "${NEON_GREEN}✅ Already latest version!${NC}"
read -p "Press Enter..."
EOF
    chmod +x /usr/local/bin/elite-x-update
}

# ==================== SETUP AUTO BACKUP ====================
setup_auto_backup() {
    cat > /usr/local/bin/elite-x-backup <<'EOF'
#!/bin/bash
BACKUP_DIR="/root/elite-x-backups"
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"

# Backup configurations
tar -czf "$BACKUP_DIR/elite-x-config-$DATE.tar.gz" /etc/elite-x 2>/dev/null || true
tar -czf "$BACKUP_DIR/dnstt-keys-$DATE.tar.gz" /etc/dnstt 2>/dev/null || true
tar -czf "$BACKUP_DIR/fastdns-config-$DATE.tar.gz" /etc/fastdns 2>/dev/null || true

# Backup user list
if [ -d "/etc/elite-x/users" ]; then
    cp -r /etc/elite-x/users "$BACKUP_DIR/users-$DATE" 2>/dev/null || true
fi

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t elite-x-config-* | tail -n +11 | xargs -r rm 2>/dev/null || true
ls -t dnstt-keys-* | tail -n +11 | xargs -r rm 2>/dev/null || true
ls -t fastdns-config-* | tail -n +11 | xargs -r rm 2>/dev/null || true

echo "Backup completed: $DATE" >> /var/log/elite-x-backup.log
EOF
    chmod +x /usr/local/bin/elite-x-backup

    cat > /etc/cron.daily/elite-x-backup <<'EOF'
#!/bin/bash
/usr/local/bin/elite-x-backup
EOF
    chmod +x /etc/cron.daily/elite-x-backup
}

# ==================== SETUP USER MANAGER ====================
setup_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NEON_WHITE='\033[1;37m'; NC='\033[0m'

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
    echo -e "${NEON_CYAN}║${NEON_YELLOW}              CREATE SSH + DNS USER                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" username
    read -p "$(echo -e $NEON_GREEN"Password: "$NC)" password
    read -p "$(echo -e $NEON_GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $NEON_GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    read -p "$(echo -e $NEON_GREEN"Max concurrent logins (0 for unlimited): "$NC)" max_logins
    
    if id "$username" &>/dev/null; then
        echo -e "${NEON_RED}User already exists!${NC}"
        return
    fi
    
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    if [ "$max_logins" -gt 0 ]; then
        sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
        echo "Match User $username" >> /etc/ssh/sshd_config
        echo "    MaxSessions $max_logins" >> /etc/ssh/sshd_config
        systemctl restart sshd
    fi
    
    cat > $UD/$username <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Max_Logins: $max_logins
Created: $(date +"%Y-%m-%d %H:%M:%S")
Status: ACTIVE
INFO
    
    echo "0" > $TD/$username
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${NEON_GREEN}════════════════════════════════════════════${NC}"
    echo "User created successfully!"
    echo "Username      : $username"
    echo "Password      : $password"
    echo "Server        : $SERVER"
    echo "Public Key    : $PUBKEY"
    echo "Expire        : $expire_date"
    echo "Traffic Limit : $traffic_limit MB"
    echo "Max Logins    : $max_logins"
    echo -e "${NEON_GREEN}════════════════════════════════════════════${NC}"
    echo "$(date): Created user $username" >> /var/log/elite-x-users.log
    read -p "Press Enter..."
}

list_users() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}                    ACTIVE USERS                                 ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        read -p "Press Enter..."
        return
    fi
    
    printf "%-12s %-15s %-10s %-8s %-8s %-8s %s\n" "USERNAME" "PASSWORD" "EXPIRE" "LIMIT" "USED" "LOGINS" "STATUS"
    echo "────────────────────────────────────────────────────────────────────────────────"
    
    for user_file in $UD/*; do
        [ ! -f "$user_file" ] && continue
        u=$(basename "$user_file")
        
        pw=$(grep "Password:" "$user_file" | cut -d' ' -f2-)
        ex=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        lm=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        ml=$(grep "Max_Logins:" "$user_file" 2>/dev/null | cut -d' ' -f2 || echo "0")
        
        us=$(cat $TD/$u 2>/dev/null || echo "0")
        current_logins=$(ps -u "$u" 2>/dev/null | grep -c "sshd" || echo "0")
        
        st=$(passwd -S "$u" 2>/dev/null | grep -q "L" && echo "${NEON_RED}LOCK${NC}" || echo "${NEON_GREEN}OK${NC}")
        
        # Truncate password if too long
        if [ ${#pw} -gt 14 ]; then
            pw_disp="${pw:0:11}..."
        else
            pw_disp="$pw"
        fi
        
        printf "%-12s %-15s %-10s %-8s %-8s %s/%-6s %b\n" "$u" "$pw_disp" "$ex" "$lm" "$us" "$current_logins" "$ml" "$st"
    done
    
    echo "────────────────────────────────────────────────────────────────────────────────"
    total_users=$(ls -1 $UD | wc -l)
    total_active=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "Total Users: ${NEON_GREEN}$total_users${NC} | Active: ${NEON_YELLOW}$total_active${NC}"
    read -p "Press Enter..."
}

lock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null
        pkill -u "$u" 2>/dev/null || true
        echo -e "${NEON_GREEN}✅ User $u locked${NC}"
    else
        echo -e "${NEON_RED}❌ User not found${NC}"
    fi
    read -p "Press Enter..."
}

unlock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -U "$u" 2>/dev/null
        echo -e "${NEON_GREEN}✅ User $u unlocked${NC}"
    else
        echo -e "${NEON_RED}❌ User not found${NC}"
    fi
    read -p "Press Enter..."
}

delete_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        pkill -u "$u" 2>/dev/null || true
        userdel -r -f "$u" 2>/dev/null
        rm -f $UD/$u $TD/$u
        echo -e "${NEON_GREEN}✅ User $u deleted${NC}"
    else
        echo -e "${NEON_RED}❌ User not found${NC}"
    fi
    read -p "Press Enter..."
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

# ==================== FASTDNS DIAGNOSTICS ====================
setup_fastdns_diagnostics() {
    cat > /usr/local/bin/elite-x-fastdns <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_CYAN='\033[1;36m'; NC='\033[0m'

show_menu() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}              FASTDNS DIAGNOSTICS TOOL                          ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${NEON_GREEN}1.${NC} Check FastDNS Status"
    echo -e "${NEON_GREEN}2.${NC} Test DNS Resolution (google.com)"
    echo -e "${NEON_GREEN}3.${NC} Show FastDNS Logs"
    echo -e "${NEON_GREEN}4.${NC} Restart FastDNS"
    echo -e "${NEON_GREEN}5.${NC} Benchmark DNS Speed"
    echo -e "${NEON_GREEN}0.${NC} Back"
    echo ""
    read -p "$(echo -e $NEON_YELLOW"Choose option: "$NC)" opt
    
    case $opt in
        1) check_status ;;
        2) test_dns ;;
        3) show_logs ;;
        4) restart_fastdns ;;
        5) benchmark_dns ;;
        0) return 0 ;;
        *) echo -e "${NEON_RED}Invalid option${NC}"; sleep 2; show_menu ;;
    esac
}

check_status() {
    echo -e "${NEON_CYAN}FastDNS Status:${NC}"
    systemctl status fastdns --no-pager | head -15
    echo ""
    echo -e "${NEON_CYAN}Port 5353 listeners:${NC}"
    ss -ulnp | grep :5353 || echo "Not listening"
    read -p "Press Enter..."
    show_menu
}

test_dns() {
    echo -e "${NEON_YELLOW}Testing DNS resolution through FastDNS...${NC}"
    echo ""
    echo -e "${NEON_CYAN}Query: google.com A record${NC}"
    dig @127.0.0.1 -p 5353 google.com A +short
    echo ""
    echo -e "${NEON_CYAN}Query: cloudflare.com A record${NC}"
    dig @127.0.0.1 -p 5353 cloudflare.com A +short
    echo ""
    echo -e "${NEON_CYAN}Query: facebook.com A record${NC}"
    dig @127.0.0.1 -p 5353 facebook.com A +short
    read -p "Press Enter..."
    show_menu
}

show_logs() {
    echo -e "${NEON_YELLOW}Last 20 lines of FastDNS log:${NC}"
    echo ""
    tail -20 /var/log/fastdns.log 2>/dev/null || echo "No log file found"
    read -p "Press Enter..."
    show_menu
}

restart_fastdns() {
    echo -e "${NEON_YELLOW}Restarting FastDNS...${NC}"
    systemctl restart fastdns
    sleep 2
    if systemctl is-active fastdns >/dev/null 2>&1; then
        echo -e "${NEON_GREEN}✅ FastDNS restarted successfully${NC}"
    else
        echo -e "${NEON_RED}❌ Failed to restart FastDNS${NC}"
    fi
    read -p "Press Enter..."
    show_menu
}

benchmark_dns() {
    echo -e "${NEON_YELLOW}Benchmarking DNS speed (10 queries)...${NC}"
    echo ""
    
    # Test against FastDNS
    echo -e "${NEON_CYAN}FastDNS (127.0.0.1:5353):${NC}"
    time for i in {1..10}; do
        dig @127.0.0.1 -p 5353 google.com A +short >/dev/null 2>&1
    done
    
    echo ""
    # Test against Google DNS
    echo -e "${NEON_CYAN}Google DNS (8.8.8.8):${NC}"
    time for i in {1..10}; do
        dig @8.8.8.8 google.com A +short >/dev/null 2>&1
    done
    
    read -p "Press Enter..."
    show_menu
}

while true; do
    show_menu
done
EOF
    chmod +x /usr/local/bin/elite-x-fastdns
}

# ==================== SETUP MAIN MENU ====================
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; BOLD='\033[1m'; NC='\033[0m'

if [ -f /tmp/elite-x-running ]; then
    exit 0
fi
touch /tmp/elite-x-running
trap 'rm -f /tmp/elite-x-running' EXIT

show_quote() {
    echo ""
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                                                               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}            Always Remember ELITE-X when you see X            ${NEON_PURPLE}║${NC}"
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
                
                /usr/local/bin/elite-x-uninstall
                
                rm -f /tmp/elite-x-running
                exit 0
            fi
        fi
    fi
}

check_expiry_menu

show_dashboard() {
    clear
    
    IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unknown")
    LOC=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | jq -r '.city + ", " + .country' 2>/dev/null || echo "Unknown")
    ISP=$(curl -s http://ip-api.com/json/$IP 2>/dev/null | jq -r '.isp' 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "Unknown")
    EXP=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Unknown")
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    DNS=$(systemctl is-active dnstt-elite-x 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    FAST=$(systemctl is-active fastdns 2>/dev/null | grep -q active && echo "${NEON_GREEN}●${NC}" || echo "${NEON_RED}●${NC}")
    
    ACTIVE_SSH=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                    ELITE-X SLOWDNS v3.6 - FASTDNS EDITION               ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Subdomain :${NEON_GREEN} $SUB${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  IP        :${NEON_GREEN} $IP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Location  :${NEON_GREEN} $LOC${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  ISP       :${NEON_GREEN} $ISP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  RAM       :${NEON_GREEN} $RAM | CPU: ${CPU}%${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  VPS Loc   :${NEON_GREEN} $LOCATION | MTU: $CURRENT_MTU${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Services  : DNSTT:$DNS PROXY:$PRX FASTDNS:$FAST${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Connections: SSH: ${NEON_GREEN}$ACTIVE_SSH${NC} | FastDNS Port: 5353${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Developer :${NEON_PURPLE} ELITE-X TEAM${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Act Key   :${NEON_YELLOW} $ACTIVATION_KEY${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Expiry    :${NEON_YELLOW} $EXP${NC}"
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
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [10] ⚡ Speed Optimization Menu${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [11] 🧹 Clean Junk Files${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [12] 🔄 Auto Expired Account Remover${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [13] 📦 Update Script${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [14] 🔄 Restart All Services${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [15] 📊 System Info${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [16] 💾 Backup Configuration${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [17] 👁️ Connection Monitor${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [18] 🔄 Reboot VPS${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [19] 🗑️ Uninstall Script${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [20] 🌍 Re-apply Location Optimization${NC}"
        echo -e "${NEON_CYAN}║${NEON_GREEN}  [21] 📡 FastDNS Diagnostics${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0]  ↩️ Back to Main Menu${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Settings option: "$NC)" ch
        
        case $ch in
            8)
                echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${NEON_CYAN}║${NEON_YELLOW}                    PUBLIC KEY                                   ${NEON_CYAN}║${NC}"
                echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${NEON_CYAN}║${NEON_GREEN}  $(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
                read -p "Press Enter..."
                ;;
            9)
                echo "Current MTU: $(cat /etc/elite-x/mtu)"
                read -p "New MTU (1000-5000): " mtu
                [[ "$mtu" =~ ^[0-9]+$ ]] && [ $mtu -ge 1000 ] && [ $mtu -le 5000 ] && {
                    echo "$mtu" > /etc/elite-x/mtu
                    sed -i "s/-mtu [0-9]*/-mtu $mtu/" /etc/systemd/system/dnstt-elite-x.service
                    systemctl daemon-reload
                    systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                    echo -e "${NEON_GREEN}✅ MTU updated to $mtu${NC}"
                } || echo -e "${NEON_RED}❌ Invalid (must be 1000-5000)${NC}"
                read -p "Press Enter..."
                ;;
            10) elite-x-speed ;;
            11) 
                echo -e "${NEON_YELLOW}🧹 Cleaning junk files...${NC}"
                apt clean -y 2>/dev/null
                apt autoclean -y 2>/dev/null
                journalctl --vacuum-time=3d 2>/dev/null
                echo -e "${NEON_GREEN}✅ Cleanup complete${NC}"
                read -p "Press Enter..."
                ;;
            12)
                systemctl enable --now elite-x-cleaner.service 2>/dev/null
                echo -e "${NEON_GREEN}✅ Auto remover started${NC}"
                read -p "Press Enter..."
                ;;
            13) elite-x-update ;;
            14)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy fastdns sshd 2>/dev/null
                echo -e "${NEON_GREEN}✅ Services restarted${NC}"
                read -p "Press Enter..."
                ;;
            15)
                echo -e "${NEON_GREEN}System Information:${NC}"
                echo "──────────────────"
                echo -e "OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
                echo -e "Kernel: $(uname -r)"
                echo -e "Uptime: $(uptime -p | sed 's/up //')"
                echo -e "Load: $(uptime | awk -F'load average:' '{print $2}')"
                read -p "Press Enter..."
                ;;
            16)
                /usr/local/bin/elite-x-backup
                echo -e "${NEON_GREEN}✅ Backup completed${NC}"
                read -p "Press Enter..."
                ;;
            17) 
                echo -e "${NEON_YELLOW}Starting connection monitor...${NC}"
                sleep 2
                /usr/local/bin/elite-x-monitor
                ;;
            18)
                read -p "Reboot? (y/n): " c
                [ "$c" = "y" ] && reboot
                ;;
            19)
                read -p "Type YES to uninstall: " c
                [ "$c" = "YES" ] && {
                    /usr/local/bin/elite-x-uninstall
                    rm -f /tmp/elite-x-running
                    exit 0
                }
                read -p "Press Enter..."
                ;;
            20)
                echo -e "${NEON_YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_GREEN}           RE-APPLY LOCATION OPTIMIZATION                        ${NC}"
                echo -e "${NEON_YELLOW}═══════════════════════════════════════════════════════════════${NC}"
                echo -e "${NEON_WHITE}Select your VPS location:${NC}"
                echo -e "${NEON_GREEN}  1. South Africa (MTU 1800)${NC}"
                echo -e "${NEON_CYAN}  2. USA${NC}"
                echo -e "${NEON_BLUE}  3. Europe${NC}"
                echo -e "${NEON_PURPLE}  4. Asia${NC}"
                echo -e "${NEON_YELLOW}  5. Auto-detect${NC}"
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
                esac
                read -p "Press Enter..."
                ;;
            21) elite-x-fastdns ;;
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
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1]  👤 User Management Menu${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2]  📋 View All Users${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3]  🔒 Lock User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4]  🔓 Unlock User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [5]  🗑️ Delete User${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [6]  📝 Create/Edit Banner${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [7]  ❌ Delete Banner${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [8]  📊 Traffic Statistics${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [S]  ⚙️  SETTINGS${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0]  🚪 Exit${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Main menu option: "$NC)" ch
        
        case $ch in
            1) elite-x-user ;;
            2) elite-x-user list ;;
            3) elite-x-user lock ;;
            4) elite-x-user unlock ;;
            5) elite-x-user del ;;
            6)
                mkdir -p /etc/elite-x/banner
                [ -f /etc/elite-x/banner/custom ] || cp /etc/elite-x/banner/default /etc/elite-x/banner/custom 2>/dev/null
                nano /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Banner saved${NC}"
                read -p "Press Enter..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Banner deleted${NC}"
                read -p "Press Enter..."
                ;;
            8)
                echo -e "${NEON_YELLOW}Traffic Statistics:${NC}"
                echo "──────────────────"
                for user in /etc/elite-x/users/*; do
                    if [ -f "$user" ]; then
                        u=$(basename "$user")
                        us=$(cat /etc/elite-x/traffic/$u 2>/dev/null || echo "0")
                        echo -e "$u: ${NEON_CYAN}$us MB${NC}"
                    fi
                done
                read -p "Press Enter..."
                ;;
            [Ss]) settings_menu ;;
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

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${NEON_RED}🗑️  COMPLETE UNINSTALL - REMOVING EVERYTHING...${NC}"
    
systemctl stop dnstt-elite-x dnstt-elite-x-proxy fastdns elite-x-traffic elite-x-cleaner elite-x-bandwidth elite-x-monitor 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy fastdns elite-x-traffic elite-x-cleaner elite-x-bandwidth elite-x-monitor 2>/dev/null || true
    
rm -f /etc/systemd/system/{dnstt-elite-x*,fastdns*,elite-x-*}
    
echo -e "${NEON_YELLOW}Removing all ELITE-X users...${NC}"

if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            pkill -u "$username" 2>/dev/null || true
            userdel -r -f "$username" 2>/dev/null || true
        fi
    done
fi

pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-proxy 2>/dev/null || true
pkill -f fastdns 2>/dev/null || true
    
rm -rf /etc/dnstt /etc/elite-x /etc/fastdns
rm -f /usr/local/bin/{dnstt-*,elite-x*,fastdns*}
rm -f /usr/local/bin/dnstt-edns-proxy.py
    
sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd
    
rm -f /etc/cron.hourly/elite-x-expiry
rm -f /etc/cron.daily/elite-x-backup
rm -f /etc/profile.d/elite-x-dashboard.sh
sed -i '/elite-x/d' /root/.bashrc 2>/dev/null || true
    
systemctl daemon-reload

echo -e "${NEON_GREEN}✅ COMPLETE UNINSTALL FINISHED!${NC}"
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
}

# ==================== CREATE REFRESH INFO SCRIPT ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
#!/bin/bash

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
EOF
    chmod +x /usr/local/bin/elite-x-refresh-info
}

# ==================== MAIN INSTALLATION ====================
show_banner

# ACTIVATION
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${GREEN}                    ACTIVATION REQUIRED                          ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Available Keys:${NC}"
echo -e "${GREEN}  Lifetime : Whtsapp 0713628668${NC}"
echo -e "${YELLOW}  Trial    : ELITE-X-TEST-0208 (2 days)${NC}"
echo ""
read -p "$(echo -e $CYAN"Activation Key: "$NC)" ACTIVATION_INPUT

mkdir -p /etc/elite-x
if ! activate_script "$ACTIVATION_INPUT"; then
    echo -e "${RED}❌ Invalid activation key! Installation cancelled.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Activation successful!${NC}"
sleep 1

if [ -f "$ACTIVATION_TYPE_FILE" ] && [ "$(cat "$ACTIVATION_TYPE_FILE")" = "temporary" ]; then
    echo -e "${YELLOW}⚠️  Trial version activated - expires in 2 days${NC}"
fi
sleep 2

set_timezone

# SUBDOMAIN
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}                  ENTER YOUR SUBDOMAIN                          ${CYAN}║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${WHITE}  Example: ns-ex.elitex.sbs                                 ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e $GREEN"Subdomain: "$NC)" TDOMAIN

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}  You entered: ${GREEN}$TDOMAIN${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

check_subdomain "$TDOMAIN"

# LOCATION
echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${GREEN}           NETWORK LOCATION OPTIMIZATION                          ${YELLOW}║${NC}"
echo -e "${YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${YELLOW}║${WHITE}  Select your VPS location:                                    ${YELLOW}║${NC}"
echo -e "${YELLOW}║${GREEN}  [1] South Africa (Default - MTU 1800)                        ${YELLOW}║${NC}"
echo -e "${YELLOW}║${CYAN}  [2] USA                                                       ${YELLOW}║${NC}"
echo -e "${YELLOW}║${BLUE}  [3] Europe                                                    ${YELLOW}║${NC}"
echo -e "${YELLOW}║${PURPLE}  [4] Asia                                                      ${YELLOW}║${NC}"
echo -e "${YELLOW}║${YELLOW}  [5] Auto-detect                                                ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -p "$(echo -e $GREEN"Select location [1-5] [default: 1]: "$NC)" LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-1}

MTU=1800
SELECTED_LOCATION="South Africa"

case $LOCATION_CHOICE in
    2)
        SELECTED_LOCATION="USA"
        echo -e "${CYAN}✅ USA selected${NC}"
        ;;
    3)
        SELECTED_LOCATION="Europe"
        echo -e "${BLUE}✅ Europe selected${NC}"
        ;;
    4)
        SELECTED_LOCATION="Asia"
        echo -e "${PURPLE}✅ Asia selected${NC}"
        ;;
    5)
        SELECTED_LOCATION="Auto-detect"
        echo -e "${YELLOW}✅ Auto-detect selected${NC}"
        ;;
    *)
        SELECTED_LOCATION="South Africa"
        echo -e "${GREEN}✅ Using South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo "==> ELITE-X V3.6 FASTDNS EDITION INSTALLATION STARTING..."

if [ "$(id -u)" -ne 0 ]; then
  echo "[-] Run as root"
  exit 1
fi

# Clean previous installation
echo -e "${YELLOW}🔄 Cleaning previous installation...${NC}"

if [ -d "/etc/elite-x/users" ]; then
    for user_file in /etc/elite-x/users/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            userdel -r "$username" 2>/dev/null || true
            pkill -u "$username" 2>/dev/null || true
        fi
    done
fi

pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-proxy 2>/dev/null || true
pkill -f fastdns 2>/dev/null || true

systemctl stop dnstt-elite-x dnstt-elite-x-proxy fastdns 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy fastdns 2>/dev/null || true

rm -rf /etc/systemd/system/dnstt-elite-x*
rm -rf /etc/systemd/system/fastdns*
rm -rf /etc/dnstt /etc/elite-x /etc/fastdns
rm -f /usr/local/bin/{dnstt-*,elite-x*,fastdns*}

sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd

echo -e "${GREEN}✅ Previous installation cleaned${NC}"
sleep 2

# Create directories
mkdir -p /etc/elite-x/{banner,users,traffic}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
===============================================
      WELCOME TO ELITE-X VPN SERVICE
===============================================
     High Speed • FastDNS UDP • Unlimited
===============================================
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
===============================================
           ELITE-X VPN SERVICE             
    High Speed • FastDNS UDP • Unlimited      
===============================================
EOF

if ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/elite-x/banner/ssh-banner" >> /etc/ssh/sshd_config
else
    sed -i 's|^Banner.*|Banner /etc/elite-x/banner/ssh-banner|' /etc/ssh/sshd_config
fi
systemctl restart sshd

# Configure systemd-resolved
if [ -f /etc/systemd/resolved.conf ]; then
  echo "Configuring systemd-resolved..."
  sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf || true
  systemctl restart systemd-resolved 2>/dev/null || true
fi

# Set DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

fuser -k 53/udp 2>/dev/null || true

echo "Installing dependencies..."
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools git make golang-go build-essential wget unzip

# Install components
setup_dnstt_server
generate_dnstt_keys
install_fastdns
install_edns_proxy_with_fastdns

# Create service files
cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/dnstt-server -udp :${DNSTT_PORT} -mtu ${MTU} -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=3
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy with FastDNS Integration
After=dnstt-elite-x.service fastdns.service
Requires=dnstt-elite-x.service fastdns.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/dnstt-edns-proxy.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Configure firewall
command -v ufw >/dev/null && {
    ufw allow 22/tcp
    ufw allow 53/udp
    ufw allow 5353/udp
    ufw reload 2>/dev/null || true
}

# Start services
systemctl daemon-reload
systemctl enable dnstt-elite-x.service dnstt-elite-x-proxy.service fastdns.service
systemctl start dnstt-elite-x.service
sleep 3
systemctl start fastdns.service
sleep 2
systemctl start dnstt-elite-x-proxy.service

# Setup all features
setup_traffic_monitor
setup_auto_remover
setup_bandwidth_monitor
setup_connection_monitor
setup_speed_optimization
setup_updater
setup_auto_backup
setup_user_manager
setup_fastdns_diagnostics
setup_main_menu
create_refresh_script
create_uninstall_script

# Apply optimizations
for iface in $(ls /sys/class/net/ | grep -v lo 2>/dev/null); do
    ethtool -K $iface tx off sg off tso off 2>/dev/null || true
done

# Create expiry cron
cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
chmod +x /etc/cron.hourly/elite-x-expiry

# Create initial backup
/usr/local/bin/elite-x-backup 2>/dev/null || true

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
alias fast='elite-x-fastdns'
alias live='elite-x-monitor'
EOF

ensure_key_files

# Installation complete
clear
show_banner
echo "╔═══════════════════════════════════════════════════════════════╗"
echo " ELITE-X V3.6 FASTDNS EDITION INSTALLED SUCCESSFULLY "
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "   FastDNS UDP on port 5353 • High Performance • All V3.5 Features   "
echo "╚═══════════════════════════════════════════════════════════════╝"
EXPIRY_INFO=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
FINAL_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "ELITEX-2026-DAN-4D-08")
echo "DOMAIN  : ${TDOMAIN}"
echo "LOCATION: ${SELECTED_LOCATION}"
echo "MTU     : ${FINAL_MTU}"
echo "KEY     : ${ACTIVATION_KEY}"
echo "EXPIRE  : ${EXPIRY_INFO}"
echo "FASTDNS : Port 5353 (UDP)"
echo "╚═══════════════════════════════════════════════════════════════╝"
show_quote

# Service status
echo -e "\n${CYAN}Service Status:${NC}"
sleep 2
systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "${GREEN}✅ DNSTT Server: Running${NC}" || echo -e "${RED}❌ DNSTT Server: Failed${NC}"
systemctl is-active fastdns >/dev/null 2>&1 && echo -e "${GREEN}✅ FastDNS: Running on port 5353${NC}" || echo -e "${RED}❌ FastDNS: Failed${NC}"
systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "${GREEN}✅ Proxy: Running${NC}" || echo -e "${RED}❌ Proxy: Failed${NC}"

echo -e "\n${CYAN}Port Status:${NC}"
ss -uln | grep -q ":53 " && echo -e "${GREEN}✅ Port 53: Listening${NC}" || echo -e "${RED}❌ Port 53: Not listening${NC}"
ss -uln | grep -q ":${DNSTT_PORT} " && echo -e "${GREEN}✅ Port ${DNSTT_PORT}: Listening${NC}" || echo -e "${RED}❌ Port ${DNSTT_PORT}: Not listening${NC}"
ss -uln | grep -q ":5353 " && echo -e "${GREEN}✅ Port 5353 (FastDNS): Listening${NC}" || echo -e "${RED}❌ Port 5353: Not listening${NC}"

echo -e "\n${GREEN}ELITE-X v3.6 New Features:${NC}"
echo -e "  ${YELLOW}→${NC} FastDNS over UDP on port 5353"
echo -e "  ${YELLOW}→${NC} Hybrid DNS resolution (FastDNS first, fallback to tunnel)"
echo -e "  ${YELLOW}→${NC} FastDNS diagnostics tool (elite-x-fastdns)"
echo -e "  ${YELLOW}→${NC} DNS speed benchmark"
echo -e "  ${YELLOW}→${NC} All V3.5 features preserved"

read -p "Open menu now? (5 features preserved"

read -p "Open menu now? (y/n): " open
ify/n): " open
if [ "$open" = "y" ]; then
    echo [ "$open" = "y" ]; then
    echo -e "${G -e "${GREEN}Opening dashboard...${NC}"
    sleep 1REEN}Opening dashboard...${NC}"
    sleep 1
    /usr/local/bin/elite-x
else
   
    /usr/local/bin/elite-x
else
    echo -e "${YELLOW}Commands: menu echo -e "${YELLOW}Commands: menu, elite, fast (FastDNS tool, elite, fast (FastDNS tool), live${NC}"
fi

self_destruct
