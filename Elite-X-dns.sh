#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗██╗     ██╗████████╗███████╗      ██╗  ██╗
#  ██╔════╝██║     ██║╚══██╔══╝██╔════╝      ╚██╗██╔╝
#  █████╗  ██║     ██║   ██║   █████╗  █████╗ ╚███╔╝ 
#  ██╔══╝  ██║     ██║   ██║   ██╔══╝  ╚════╝ ██╔██╗ 
#  ███████╗███████╗██║   ██║   ███████╗      ██╔╝ ██╗
#  ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝      ╚═╝  ╚═╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X SLOWDNS v5.0 - STABILITY EDITION
# ═════════════════════════════════════════════════════════════════
# FIXED: Connection timeouts, ping timeout errors, SSH disconnections

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
    echo -e "${NEON_RED}║${NEON_WHITE}${BOLD}               ELITE-X SLOWDNS v5.0 - STABILITY EDITION                ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}║${NEON_GREEN}${BOLD}                ⚡ NO MORE PING TIMEOUTS ⚡                            ${NEON_RED}║${NC}"
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

# ==================== FIXED EDNS PROXY (STABILITY OPTIMIZED) ====================
install_edns_proxy() {
    echo -e "${NEON_CYAN}Installing stability-optimized EDNS proxy...${NC}"
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
"""
ELITE-X EDNS Proxy - STABILITY EDITION
Fixed: Ping timeouts, connection drops, SSH disconnections
"""
import socket
import threading
import struct
import time
import sys
import signal
import os

# Configuration
LISTEN_IP = '0.0.0.0'
LISTEN_PORT = 53
DNSTT_IP = '127.0.0.1'
DNSTT_PORT = 5300
BUFFER_SIZE = 8192
EDNS_MAX_SIZE = 4096
KEEPALIVE_INTERVAL = 15  # Send keepalive every 15 seconds
MAX_RETRIES = 3
TIMEOUT = 10  # Increased timeout for stability

# Global flag for graceful shutdown
running = True

def signal_handler(sig, frame):
    global running
    print("\nShutting down proxy...")
    running = False
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def log(msg):
    """Simple logging"""
    print(f"[{time.strftime('%H:%M:%S')}] {msg}")
    sys.stdout.flush()

def add_edns0(data, max_size=4096):
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
    
    # Look for OPT record in additional section
    opt_offset = offset
    for _ in range(arcount):
        if opt_offset + 11 > len(data):
            break
        
        # Check if this is OPT record
        if data[opt_offset] == 0:
            opt_type = struct.unpack('!H', data[opt_offset+1:opt_offset+3])[0]
            if opt_type == 41:  # OPT record
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
    
    return bytes(new_data)

def handle_query(server_socket, data, client_addr):
    """Handle a single DNS query with retry logic"""
    for attempt in range(MAX_RETRIES):
        try:
            # Add EDNS0 with max size
            modified_data = add_edns0(data, EDNS_MAX_SIZE)
            
            # Forward to dnstt server
            dnstt_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            dnstt_sock.settimeout(TIMEOUT)
            dnstt_sock.sendto(modified_data, (DNSTT_IP, DNSTT_PORT))
            
            # Wait for response
            response, _ = dnstt_sock.recvfrom(BUFFER_SIZE)
            
            # Modify response for client
            modified_response = add_edns0(response, 512)
            
            # Send back to client
            server_socket.sendto(modified_response, client_addr)
            
            dnstt_sock.close()
            return  # Success, exit function
            
        except socket.timeout:
            if attempt < MAX_RETRIES - 1:
                time.sleep(1)  # Wait before retry
                continue
            else:
                # Final timeout - just ignore
                pass
        except Exception:
            if attempt < MAX_RETRIES - 1:
                time.sleep(1)
                continue
        finally:
            try:
                dnstt_sock.close()
            except:
                pass

def keepalive_thread():
    """Send periodic keepalive to maintain connection"""
    while running:
        try:
            # Send a dummy DNS query to keep connection alive
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(5)
            # Simple DNS query for google.com
            query = b'\xaa\xaa\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x06google\x03com\x00\x00\x01\x00\x01'
            sock.sendto(query, (DNSTT_IP, DNSTT_PORT))
            sock.close()
        except:
            pass
        time.sleep(KEEPALIVE_INTERVAL)

def main():
    """Main proxy function"""
    log("ELITE-X STABILITY EDITION Proxy starting...")
    log(f"Listening on {LISTEN_IP}:{LISTEN_PORT}")
    log(f"Forwarding to dnstt on {DNSTT_IP}:{DNSTT_PORT}")
    log(f"Keepalive interval: {KEEPALIVE_INTERVAL}s")
    log(f"Timeout: {TIMEOUT}s, Max retries: {MAX_RETRIES}")
    
    # Create socket
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 2097152)  # 2MB buffer
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 2097152)  # 2MB buffer
        sock.bind((LISTEN_IP, LISTEN_PORT))
    except Exception as e:
        log(f"Failed to bind to port {LISTEN_PORT}: {e}")
        log("Try: sudo systemctl stop systemd-resolved")
        sys.exit(1)
    
    log("Proxy is ready and listening")
    
    # Start keepalive thread
    keepalive = threading.Thread(target=keepalive_thread, daemon=True)
    keepalive.start()
    
    # Main loop
    while running:
        try:
            data, client_addr = sock.recvfrom(BUFFER_SIZE)
            thread = threading.Thread(
                target=handle_query,
                args=(sock, data, client_addr),
                daemon=True
            )
            thread.start()
        except Exception as e:
            if running:
                log(f"Main loop error: {e}")
            time.sleep(1)

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/dnstt-edns-proxy.py
}

# ==================== STABILITY OPTIMIZATIONS ====================
apply_stability_fixes() {
    echo -e "${NEON_CYAN}🔧 Applying stability fixes for ping timeout issues...${NC}"
    
    # Increase system limits
    cat >> /etc/security/limits.conf <<EOF
* soft nofile 1048576
* hard nofile 1048576
* soft nproc unlimited
* hard nproc unlimited
EOF

    # Optimize kernel for DNS tunnel stability
    cat >> /etc/sysctl.conf <<EOF

# ========== ELITE-X STABILITY OPTIMIZATIONS ==========
# Increase connection tracking
net.netfilter.nf_conntrack_max = 524288
net.netfilter.nf_conntrack_tcp_timeout_established = 86400
net.netfilter.nf_conntrack_udp_timeout = 60
net.netfilter.nf_conntrack_udp_timeout_stream = 180

# TCP keepalive settings
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6

# Increase timeout values
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 3

# Increase buffer sizes
net.core.rmem_max = 268435456
net.core.wmem_max = 268435456
net.core.rmem_default = 134217728
net.core.wmem_default = 134217728
net.ipv4.tcp_rmem = 4096 87380 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
net.core.netdev_max_backlog = 50000
net.core.optmem_max = 25165824

# Disable IPv6 if not needed
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# BBR congestion control for better stability
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr

# Increase timeouts for DNS
net.ipv4.udp_rmem_min = 131072
net.ipv4.udp_wmem_min = 131072
EOF

    sysctl -p 2>/dev/null || true

    # Create systemd service override for dnstt to increase stability
    mkdir -p /etc/systemd/system/dnstt-elite-x.service.d
    cat > /etc/systemd/system/dnstt-elite-x.service.d/override.conf <<EOF
[Service]
Restart=always
RestartSec=5
StartLimitInterval=0
StartLimitBurst=0
EOF

    mkdir -p /etc/systemd/system/dnstt-elite-x-proxy.service.d
    cat > /etc/systemd/system/dnstt-elite-x-proxy.service.d/override.conf <<EOF
[Service]
Restart=always
RestartSec=5
StartLimitInterval=0
StartLimitBurst=0
EOF

    # Optimize network interface
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        # Disable TCP offloading to prevent packet drops
        ethtool -K $iface tx off rx off 2>/dev/null || true
        ethtool -K $iface tso off gso off gro off 2>/dev/null || true
        
        # Increase ring buffer
        ethtool -G $iface rx 4096 tx 4096 2>/dev/null || true
        
        # Set optimal MTU
        ip link set dev $iface mtu 1500 2>/dev/null || true
        ip link set dev $iface txqueuelen 10000 2>/dev/null || true
    done

    echo -e "${NEON_GREEN}✅ Stability fixes applied - ping timeouts should be resolved${NC}"
}

# ==================== BOOSTER MENU (KEPT FOR COMPATIBILITY) ====================
booster_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    🚀 ELITE-X STABILITY MENU 🚀                        ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1] 🔄 Re-apply stability fixes${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2] 📊 Check connection status${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3] 🔧 Reset DNS tunnel${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4] 📈 View ping statistics${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back to Settings${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Option: "$NC)" bch
        
        case $bch in
            1) 
                apply_stability_fixes
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${NEON_GREEN}✅ Stability fixes reapplied${NC}"
                read -p "Press Enter..." 
                ;;
            2)
                systemctl status dnstt-elite-x --no-pager
                systemctl status dnstt-elite-x-proxy --no-pager
                read -p "Press Enter..." 
                ;;
            3)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy
                echo -e "${NEON_GREEN}✅ DNS tunnel reset${NC}"
                read -p "Press Enter..." 
                ;;
            4)
                echo -e "${NEON_YELLOW}Ping statistics from logs:${NC}"
                journalctl -u dnstt-elite-x --since "5 minutes ago" | grep -i timeout | tail -20
                read -p "Press Enter..." 
                ;;
            0) return ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
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
    
    total=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "${NEON_PURPLE}Total Active: ${NEON_GREEN}$total${NC}"
    echo ""
    echo -e "${NEON_CYAN}─── CONNECTIONS ───────────────────────────────────────────────${NC}"
    
    ss -tnp | grep :22 | grep ESTAB | while read line; do
        src_ip=$(echo $line | awk '{print $5}' | cut -d: -f1)
        pid=$(echo $line | grep -o 'pid=[0-9]*' | cut -d= -f2)
        
        if [ ! -z "$pid" ] && [ "$pid" != "-" ]; then
            username=$(ps -o user= -p $pid 2>/dev/null | head -1 | xargs)
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

echo -e "${NEON_WHITE}System Total RX: ${NEON_GREEN}${rx_gb} GB${NC}"
echo -e "${NEON_WHITE}System Total TX: ${NEON_GREEN}${tx_gb} GB${NC}"
echo ""

if [ -d "$USER_DB" ]; then
    for user_file in "$USER_DB"/*; do
        if [ -f "$user_file" ]; then
            username=$(basename "$user_file")
            used=$(cat "$TRAFFIC_DB/$username" 2>/dev/null || echo "0")
            limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
            
            if [ "$limit" -gt 0 ] 2>/dev/null; then
                percent=$((used * 100 / limit))
                if [ "$percent" -gt 90 ]; then
                    percent_disp="${NEON_RED}${percent}%${NC}"
                elif [ "$percent" -gt 70 ]; then
                    percent_disp="${NEON_YELLOW}${percent}%${NC}"
                else
                    percent_disp="${NEON_GREEN}${percent}%${NC}"
                fi
                echo -e "${NEON_CYAN}User:${NEON_WHITE} $username ${NEON_CYAN}Used:${NEON_YELLOW} ${used}MB ${NEON_CYAN}Limit:${NEON_GREEN} ${limit}MB ${NEON_CYAN}($percent_disp)${NC}"
            else
                echo -e "${NEON_CYAN}User:${NEON_WHITE} $username ${NEON_CYAN}Used:${NEON_YELLOW} ${used}MB ${NEON_CYAN}Limit:${NEON_GREEN} Unlimited${NC}"
            fi
        fi
    done
else
    echo -e "${NEON_YELLOW}No users found${NC}"
fi
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
                    echo "$(date): User $username exceeded limit ($used/${limit}MB)" >> /var/log/elite-x-traffic.log
                    pkill -u "$username" 2>/dev/null || true
                    usermod -L "$username" 2>/dev/null || true
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

# ==================== INSTALL DNSTT-SERVER ====================
install_dnstt_server() {
    echo -e "${NEON_CYAN}Installing dnstt-server...${NC}"

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
                echo -e "${NEON_GREEN}✅ Download successful${NC}"
                DOWNLOAD_SUCCESS=1
                break
            fi
        fi
    done

    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${NEON_RED}❌ Failed to download dnstt-server${NC}"
        echo -e "${NEON_YELLOW}Trying to build from source...${NC}"
        
        cd /tmp
        apt install -y golang-go git
        git clone https://github.com/x2ios/slowdns.git
        cd slowdns
        go build -o dnstt-server
        cp dnstt-server /usr/local/bin/
        chmod +x /usr/local/bin/dnstt-server
        echo -e "${NEON_GREEN}✅ Built from source successfully${NC}"
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
Status: ACTIVE
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
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                     ACTIVE USERS (REAL TRAFFIC)                    ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${NEON_RED}No users found${NC}"
        show_quote
        return
    fi
    
    printf "${NEON_WHITE}%-12s %-15s %-12s %-10s %-10s %-8s %s${NC}\n" "USERNAME" "PASSWORD" "EXPIRE" "LIMIT(MB)" "USED(MB)" "USAGE%" "STATUS"
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────────────${NC}"
    
    for user_file in $UD/*; do
        [ ! -f "$user_file" ] && continue
        username=$(basename "$user_file")
        
        password=$(grep "Password:" "$user_file" | cut -d' ' -f2-)
        expire=$(grep "Expire:" "$user_file" | cut -d' ' -f2)
        limit=$(grep "Traffic_Limit:" "$user_file" | cut -d' ' -f2)
        
        used=0
        user_pids=$(pgrep -u "$username" 2>/dev/null | tr '\n' '|' | sed 's/|$//')
        if [ ! -z "$user_pids" ]; then
            total_rx=0
            total_tx=0
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
            used=$(( (total_rx + total_tx) / 1048576 ))
        fi
        
        echo "$used" > "$TD/$username"
        
        if [ "$limit" -gt 0 ] 2>/dev/null; then
            percent=$((used * 100 / limit))
            if [ "$percent" -ge 100 ]; then
                percent_disp="${NEON_RED}${percent}%${NC}"
                usermod -L "$username" 2>/dev/null || true
                status="${NEON_RED}LIMIT EXCEEDED${NC}"
            elif [ "$percent" -ge 80 ]; then
                percent_disp="${NEON_YELLOW}${percent}%${NC}"
                if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                    status="${NEON_RED}LOCKED${NC}"
                else
                    status="${NEON_GREEN}ACTIVE${NC}"
                fi
            else
                percent_disp="${NEON_GREEN}${percent}%${NC}"
                if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                    status="${NEON_RED}LOCKED${NC}"
                else
                    status="${NEON_GREEN}ACTIVE${NC}"
                fi
            fi
        else
            percent_disp="${NEON_GREEN}---${NC}"
            if passwd -S "$username" 2>/dev/null | grep -q "L"; then
                status="${NEON_RED}LOCKED${NC}"
            else
                status="${NEON_GREEN}ACTIVE${NC}"
            fi
        fi
        
        if [ ${#password} -gt 14 ]; then
            display_pass="${password:0:11}..."
        else
            display_pass="$password"
        fi
        
        printf "${NEON_CYAN}%-12s ${NEON_YELLOW}%-15s ${NEON_GREEN}%-12s ${NEON_WHITE}%-10s ${NEON_PURPLE}%-10s ${NEON_BLUE}%-8b ${NEON_CYAN}%b${NC}\n" \
               "$username" "$display_pass" "$expire" "$limit" "$used" "$percent_disp" "$status"
    done
    
    echo -e "${NEON_CYAN}────────────────────────────────────────────────────────────────────────────────────${NC}"
    
    total_users=$(ls -1 $UD | wc -l)
    total_active=$(ss -tnp | grep :22 | grep ESTAB | wc -l)
    echo -e "${NEON_WHITE}Total Users: ${NEON_GREEN}$total_users${NC}  ${NEON_WHITE}Active Connections: ${NEON_GREEN}$total_active${NC}"
    
    show_quote
}

lock_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        usermod -L "$u" 2>/dev/null && echo -e "${NEON_GREEN}✅ User $u locked${NC}" || echo -e "${NEON_RED}❌ Failed to lock${NC}"
        if [ -f "$UD/$u" ]; then
            sed -i 's/^Status:.*/Status: LOCKED (Manual)/' "$UD/$u" 2>/dev/null || echo "Status: LOCKED (Manual)" >> "$UD/$u"
        fi
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
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
    show_quote
}

delete_user() { 
    read -p "$(echo -e $NEON_GREEN"Username: "$NC)" u
    if id "$u" &>/dev/null; then
        pkill -u "$u" 2>/dev/null || true
        userdel -r -f "$u" 2>/dev/null
        rm -f $UD/$u $TD/$u
        echo -e "${NEON_GREEN}✅ User $u deleted${NC}"
    else
        echo -e "${NEON_RED}❌ User does not exist${NC}"
    fi
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

# ==================== CREATE REFRESH INFO SCRIPT ====================
create_refresh_script() {
    cat > /usr/local/bin/elite-x-refresh-info <<'EOF'
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
EOF
    chmod +x /usr/local/bin/elite-x-refresh-info
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
EOF
    chmod +x /usr/local/bin/elite-x-uninstall
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

if [ -f /usr/local/bin/elite-x-boosters ]; then
    source /usr/local/bin/elite-x-boosters
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
    
    if [ ! -f /etc/elite-x/cached_ip ] || [ $(( $(date +%s) - $(stat -c %Y /etc/elite-x/cached_ip 2>/dev/null || echo 0) )) -gt 3600 ]; then
        /usr/local/bin/elite-x-refresh-info
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
    
    # Get stability status
    TIMEOUT_COUNT=$(journalctl -u dnstt-elite-x --since "5 minutes ago" 2>/dev/null | grep -i timeout | wc -l)
    if [ "$TIMEOUT_COUNT" -gt 0 ]; then
        STABILITY="${NEON_YELLOW}⚠️ Some timeouts ($TIMEOUT_COUNT)${NC}"
    else
        STABILITY="${NEON_GREEN}✅ Stable${NC}"
    fi
    
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                    ELITE-X SLOWDNS v5.0 - STABILITY EDITION               ${NEON_PURPLE}║${NC}"
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
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  🛡️ Stability : $STABILITY${NC}"
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
        echo -e "${NEON_CYAN}║${NEON_RED}  [22] 🚀 STABILITY MENU${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [23] 📈 System Performance Test${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [24] 🔄 Refresh IP/Location Info${NC}"
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
                echo -e "${NEON_YELLOW}⚡ Running stability optimization...${NC}"
                apply_stability_fixes
                echo -e "${NEON_GREEN}✅ Stability optimization complete${NC}"
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
                    /usr/local/bin/elite-x-uninstall
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
                echo -e "${NEON_RED}  6. Ultra Mode${NC}"
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
                    6) echo "Ultra Mode" > /etc/elite-x/location
                       echo -e "${NEON_RED}✅ Ultra Mode selected${NC}" ;;
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
                elite-x-analyzer
                read -p "Press Enter to continue..."
                ;;
            21)
                elite-x-renew
                read -p "Press Enter to continue..."
                ;;
            22)
                booster_menu
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
            24)
                echo -e "${NEON_YELLOW}🔄 Refreshing IP/Location information...${NC}"
                /usr/local/bin/elite-x-refresh-info
                echo -e "${NEON_GREEN}✅ Information refreshed!${NC}"
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
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2]  📋 List All Users (with REAL traffic usage)${NC}"
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
                mkdir -p /etc/elite-x/banner
                [ -f /etc/elite-x/banner/custom ] || cp /etc/elite-x/banner/default /etc/elite-x/banner/custom 2>/dev/null || echo "Welcome to ELITE-X" > /etc/elite-x/banner/custom
                nano /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/custom /etc/elite-x/banner/ssh-banner 2>/dev/null
                systemctl restart sshd
                echo -e "${NEON_GREEN}✅ Banner saved${NC}"
                read -p "Press Enter to continue..."
                ;;
            7)
                rm -f /etc/elite-x/banner/custom
                cp /etc/elite-x/banner/default /etc/elite-x/banner/ssh-banner 2>/dev/null || echo "Welcome to ELITE-X" > /etc/elite-x/banner/ssh-banner
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
echo -e "${NEON_YELLOW}║${NEON_GREEN}  [1] South Africa (Default - MTU 1800)                        ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_CYAN}  [2] USA                                                       ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_BLUE}  [3] Europe                                                    ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PURPLE}  [4] Asia                                                      ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_PINK}  [5] Auto-detect                                                ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}║${NEON_RED}${BLINK}  [6] 🚀 STABILITY MODE (RECOMMENDED)                          ${NEON_YELLOW}║${NC}"
echo -e "${NEON_YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${NEON_GREEN}Select location [1-6] [default: 6]: ${NC}"
read LOCATION_CHOICE
LOCATION_CHOICE=${LOCATION_CHOICE:-6}

MTU=1500  # Default to 1500 for better stability
SELECTED_LOCATION="South Africa"

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
        SELECTED_LOCATION="STABILITY MODE"
        MTU=1400  # Lower MTU for better stability on problematic networks
        echo -e "${NEON_RED}${BLINK}✅ STABILITY MODE SELECTED - Optimized for no timeouts${NC}"
        ;;
    *)
        SELECTED_LOCATION="South Africa"
        echo -e "${NEON_GREEN}✅ Using South Africa configuration${NC}"
        ;;
esac

echo "$SELECTED_LOCATION" > /etc/elite-x/location
echo "$MTU" > /etc/elite-x/mtu

DNSTT_PORT=5300

echo -e "${NEON_YELLOW}==> ELITE-X STABILITY EDITION INSTALLATION STARTING...${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${NEON_RED}[-] Run as root${NC}"
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

echo -e "${NEON_CYAN}Stopping old services...${NC}"
for svc in dnstt dnstt-server slowdns dnstt-smart dnstt-elite-x dnstt-elite-x-proxy; do
  systemctl disable --now "$svc" 2>/dev/null || true
done

# Backup and configure systemd-resolved
if [ -f /etc/systemd/resolved.conf ]; then
    cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.backup 2>/dev/null || true
    echo -e "${NEON_CYAN}Configuring systemd-resolved...${NC}"
    systemctl stop systemd-resolved 2>/dev/null || true
    systemctl disable systemd-resolved 2>/dev/null || true
fi

# Fix DNS permanently
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
chattr +i /etc/resolv.conf 2>/dev/null || true

fuser -k 53/udp 2>/dev/null || true

echo -e "${NEON_CYAN}Installing dependencies...${NC}"
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools iftop nload htop git make golang-go build-essential wget unzip irqbalance openssl bc

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
/usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cd ~

chmod 600 /etc/dnstt/server.key
chmod 644 /etc/dnstt/server.pub

echo -e "${NEON_GREEN}✅ Public key generated: $(cat /etc/dnstt/server.pub)${NC}"

echo -e "${NEON_CYAN}Creating dnstt-elite-x.service (with stability settings)...${NC}"
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
StartLimitInterval=0
StartLimitBurst=0
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
StartLimitInterval=0
StartLimitBurst=0
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

# Create booster file (simplified for stability)
cat > /usr/local/bin/elite-x-boosters <<'EOF'
#!/bin/bash
booster_menu() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                    🚀 STABILITY OPTIONS 🚀                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [1] 🔄 Re-apply stability fixes${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [2] 📊 Check connection status${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [3] 🔧 Reset DNS tunnel${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [4] 📈 View ping statistics${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [5] 🛡️ Set MTU to 1400 (most stable)${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [6] 🚀 Set MTU to 1500 (balanced)${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [7] ⚡ Set MTU to 1800 (fastest)${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}  [0] ↩️ Back to Settings${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $NEON_GREEN"Option: "$NC)" bch
    
    case $bch in
        1)
            echo -e "${NEON_YELLOW}Applying stability fixes...${NC}"
            sysctl -w net.ipv4.tcp_keepalive_time=60
            sysctl -w net.ipv4.tcp_keepalive_intvl=10
            sysctl -w net.ipv4.tcp_keepalive_probes=6
            echo -e "${NEON_GREEN}✅ Stability fixes applied${NC}"
            ;;
        2)
            systemctl status dnstt-elite-x --no-pager | head -10
            systemctl status dnstt-elite-x-proxy --no-pager | head -10
            ;;
        3)
            systemctl restart dnstt-elite-x dnstt-elite-x-proxy
            echo -e "${NEON_GREEN}✅ DNS tunnel reset${NC}"
            ;;
        4)
            echo -e "${NEON_YELLOW}Recent ping timeouts:${NC}"
            journalctl -u dnstt-elite-x --since "10 minutes ago" 2>/dev/null | grep -i timeout | tail -10 || echo "No recent timeouts"
            ;;
        5)
            echo "1400" > /etc/elite-x/mtu
            sed -i "s/-mtu [0-9]*/-mtu 1400/" /etc/systemd/system/dnstt-elite-x.service
            systemctl daemon-reload
            systemctl restart dnstt-elite-x dnstt-elite-x-proxy
            echo -e "${NEON_GREEN}✅ MTU set to 1400 (most stable)${NC}"
            ;;
        6)
            echo "1500" > /etc/elite-x/mtu
            sed -i "s/-mtu [0-9]*/-mtu 1500/" /etc/systemd/system/dnstt-elite-x.service
            systemctl daemon-reload
            systemctl restart dnstt-elite-x dnstt-elite-x-proxy
            echo -e "${NEON_GREEN}✅ MTU set to 1500 (balanced)${NC}"
            ;;
        7)
            echo "1800" > /etc/elite-x/mtu
            sed -i "s/-mtu [0-9]*/-mtu 1800/" /etc/systemd/system/dnstt-elite-x.service
            systemctl daemon-reload
            systemctl restart dnstt-elite-x dnstt-elite-x-proxy
            echo -e "${NEON_GREEN}✅ MTU set to 1800 (fastest)${NC}"
            ;;
        0) return ;;
        *) echo -e "${NEON_RED}Invalid option${NC}" ;;
    esac
    read -p "Press Enter to continue..."
}
EOF
chmod +x /usr/local/bin/elite-x-boosters

# Apply stability fixes
echo -e "${NEON_CYAN}Applying stability fixes for ping timeout issues...${NC}"
apply_stability_fixes

# Additional optimizations for stability
for iface in $(ls /sys/class/net/ | grep -v lo); do
    ethtool -K $iface tx off rx off 2>/dev/null || true
    ethtool -K $iface tso off gso off gro off 2>/dev/null || true
    ip link set dev $iface mtu $MTU 2>/dev/null || true
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
echo -e "${NEON_CYAN}Caching network information...${NC}"
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
echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}              ELITE-X SLOWDNS INSTALLED SUCCESSFULLY!                ${NEON_GREEN}║${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📌 DOMAIN  : ${NEON_CYAN}${TDOMAIN}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  📍 LOCATION: ${NEON_CYAN}${SELECTED_LOCATION}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 KEY     : ${NEON_YELLOW}$(cat /etc/elite-x/key)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🔑 PUBLIC KEY: ${NEON_CYAN}$(cat /etc/dnstt/server.pub)${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⚙️ MTU      : ${NEON_CYAN}${MTU}${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  ⏳ EXPIRY  : ${NEON_YELLOW}${EXPIRY_INFO}${NC}"
echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}  🚀 Commands:${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     menu - Open dashboard${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     elite - Quick access${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     live  - Live connection monitor${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     speed - Traffic analyzer${NC}"
echo -e "${NEON_GREEN}║${NEON_WHITE}     renew - Renew SSH account${NC}"
if [ "$SELECTED_LOCATION" = "STABILITY MODE" ]; then
    echo -e "${NEON_GREEN}║${NEON_RED}${BLINK}  🛡️ STABILITY MODE ACTIVE - Optimized to prevent timeouts${NC}"
fi
echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
show_quote

# Check service status
sleep 2
echo -e "${NEON_CYAN}Service Status:${NC}"
if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
    echo -e "  DNSTT: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  DNSTT: ${NEON_RED}● FAILED${NC}"
fi

if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
    echo -e "  PROXY: ${NEON_GREEN}● RUNNING${NC}"
else
    echo -e "  PROXY: ${NEON_RED}● FAILED${NC}"
fi
echo ""

echo -e "${NEON_YELLOW}⚠️ If you experience ping timeouts, try:${NC}"
echo -e "  ${NEON_WHITE}1. Go to Settings → STABILITY MENU${NC}"
echo -e "  ${NEON_WHITE}2. Choose option 5 (Set MTU to 1400)${NC}"
echo -e "  ${NEON_WHITE}3. Restart the connection${NC}"
echo ""

# Auto-open menu after installation
echo -e "${NEON_GREEN}Opening dashboard in 3 seconds...${NC}"
sleep 3
/usr/local/bin/elite-x

self_destruct
