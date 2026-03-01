#!/bin/bash
# ╔════════════════════════════════════════════════════════════════════════════════════╗
#  ELITE-X DNSTT SCRIPT v3.5 - REALTIME WORKING VERSION
# ╚════════════════════════════════════════════════════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

print_color() { echo -e "${2}${1}${NC}"; }

show_quote() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}            Always Remember ELITE-X when you see X            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_banner() {
    clear
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${YELLOW}${BOLD}                   ELITE-X SLOWDNS v3.5                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${GREEN}${BOLD}              Advanced • Secure • Ultra Fast                    ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Advanced Configuration
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
USER_DELETION_LOG="/var/log/elite-x-deleted-users.log"
USER_ARCHIVE_DIR="/etc/elite-x/deleted_users"

# Create log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

set_timezone() {
    timedatectl set-timezone $TIMEZONE 2>/dev/null || ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime 2>/dev/null || true
}

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
        echo -e "${YELLOW}⚠️  Make sure your subdomain points to: $vps_ip${NC}"
        return 0
    fi
    
    if [ "$resolved_ip" = "$vps_ip" ]; then
        echo -e "${GREEN}✅ Subdomain correctly points to this VPS!${NC}"
        return 0
    else
        echo -e "${RED}❌ Subdomain points to $resolved_ip, but VPS IP is $vps_ip${NC}"
        echo -e "${YELLOW}⚠️  Please update your DNS record and try again${NC}"
        read -p "Continue anyway? (y/n): " continue_anyway
        if [ "$continue_anyway" != "y" ]; then
            exit 1
        fi
    fi
}

# ========== DNSTT SERVER ==========
setup_dnstt_server() {
    echo "Installing dnstt-server..."
    
    fuser -k 5300/udp 2>/dev/null || true
    
    if curl -fsSL https://dnstt.network/dnstt-server-linux-amd64 -o /usr/local/bin/dnstt-server 2>/dev/null; then
        echo -e "${GREEN}✅ Downloaded from dnstt.network${NC}"
    elif curl -fsSL https://github.com/NoXFiQ/Elite-X-dns.sh/raw/main/dnstt-server -o /usr/local/bin/dnstt-server 2>/dev/null; then
        echo -e "${GREEN}✅ Downloaded from GitHub${NC}"
    else
        echo -e "${RED}❌ Failed to download dnstt-server${NC}"
        exit 1
    fi
    chmod +x /usr/local/bin/dnstt-server

    echo "Generating keys..."
    mkdir -p /etc/dnstt

    if [ -f /etc/dnstt/server.key ]; then
        echo -e "${YELLOW}⚠️  Existing keys found, removing...${NC}"
        chattr -i /etc/dnstt/server.key 2>/dev/null || true
        rm -f /etc/dnstt/server.key
        rm -f /etc/dnstt/server.pub
    fi

    cd /etc/dnstt
    /usr/local/bin/dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
    cd ~

    chmod 600 /etc/dnstt/server.key
    chmod 644 /etc/dnstt/server.pub

    cat >/etc/systemd/system/dnstt-elite-x.service <<EOF
[Unit]
Description=ELITE-X DNSTT Server
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnstt-server -udp :5300 -mtu 1800 -privkey-file /etc/dnstt/server.key ${TDOMAIN} 127.0.0.1:22
Restart=always
RestartSec=5
KillSignal=SIGTERM
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
}

# ========== EDNS PROXY ==========
setup_edns_proxy() {
    echo "Installing EDNS proxy..."
    
    cat >/usr/local/bin/dnstt-edns-proxy.py <<'EOF'
#!/usr/bin/env python3
import socket
import threading
import struct
import sys
import time
import os
import signal

L=5300
running = True

def signal_handler(sig, frame):
    global running
    running = False
    sys.stderr.write("\nShutting down...\n")
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def modify_edns(d, max_size):
    if len(d) < 12:
        return d
    try:
        q, a, n, r = struct.unpack("!HHHH", d[4:12])
    except:
        return d
    
    o = 12
    
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
    
    for _ in range(q):
        o = skip_name(d, o)
        o += 4
    
    for _ in range(a + n):
        o = skip_name(d, o)
        if o + 10 > len(d):
            return d
        try:
            _, _, _, l = struct.unpack("!HHIH", d[o:o+10])
        except:
            return d
        o += 10 + l
    
    modified = bytearray(d)
    for _ in range(r):
        o = skip_name(d, o)
        if o + 10 > len(d):
            return d
        t = struct.unpack("!H", d[o:o+2])[0]
        if t == 41:
            modified[o+2:o+4] = struct.pack("!H", max_size)
            return bytes(modified)
        _, _, l = struct.unpack("!HIH", d[o+2:o+10])
        o += 10 + l
    
    return d

def handle_request(sock, data, addr):
    client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client.settimeout(5)
    try:
        client.sendto(modify_edns(data, 1800), ('127.0.0.1', L))
        response, _ = client.recvfrom(4096)
        sock.sendto(modify_edns(response, 512), addr)
    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
    finally:
        client.close()

def main():
    global running
    
    server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    os.system("fuser -k 53/udp 2>/dev/null || true")
    time.sleep(2)
    
    for attempt in range(3):
        try:
            server.bind(('0.0.0.0', 53))
            sys.stderr.write(f"✅ EDNS Proxy started on port 53\n")
            sys.stderr.flush()
            break
        except Exception as e:
            if attempt < 2:
                sys.stderr.write(f"Attempt {attempt+1} failed, retrying...\n")
                time.sleep(2)
                os.system("fuser -k 53/udp 2>/dev/null || true")
            else:
                sys.stderr.write(f"❌ Failed to bind to port 53: {e}\n")
                sys.exit(1)
    
    while running:
        try:
            data, addr = server.recvfrom(4096)
            threading.Thread(target=handle_request, args=(server, data, addr), daemon=True).start()
        except Exception as e:
            if running:
                sys.stderr.write(f"Error: {e}\n")
                time.sleep(1)

if __name__ == "__main__":
    main()
EOF
    chmod +x /usr/local/bin/dnstt-edns-proxy.py

    cat >/etc/systemd/system/dnstt-elite-x-proxy.service <<EOF
[Unit]
Description=ELITE-X Proxy
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
}

# ========== REALTIME TRAFFIC MONITOR ==========
setup_traffic_monitor() {
    cat > /usr/local/bin/elite-x-traffic <<'EOF'
#!/bin/bash
TRAFFIC_DB="/etc/elite-x/traffic"
USER_DB="/etc/elite-x/users"
mkdir -p $TRAFFIC_DB

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> /var/log/elite-x-traffic.log
}

# REAL FUNCTION TO GET ACTUAL TRAFFIC
get_realtime_traffic() {
    local username="$1"
    local total_bytes=0
    
    # Check if user exists
    if ! id "$username" &>/dev/null 2>&1; then
        echo "0"
        return
    fi
    
    # Get all PIDs for this user's SSH sessions
    local pids=$(pgrep -u "$username" -f sshd 2>/dev/null || echo "")
    
    if [ -n "$pids" ]; then
        for pid in $pids; do
            if [ -d "/proc/$pid" ]; then
                # Read network stats from /proc/$pid/net/dev
                if [ -f "/proc/$pid/net/dev" ]; then
                    while read line; do
                        if [[ $line =~ ^[[:space:]]*([^:]+):[[:space:]]*([0-9]+)[[:space:]]+([0-9]+) ]]; then
                            # Interface: ${BASH_REMATCH[1]}
                            # Receive bytes: ${BASH_REMATCH[2]}
                            # Transmit bytes: ${BASH_REMATCH[3]}
                            total_bytes=$((total_bytes + ${BASH_REMATCH[2]} + ${BASH_REMATCH[3]}))
                        fi
                    done < "/proc/$pid/net/dev" 2>/dev/null
                fi
                
                # Alternative method using iptables if available
                if command -v iptables >/dev/null 2>&1; then
                    local upload=$(iptables -vnx -L OUTPUT 2>/dev/null | grep -c "$pid" 2>/dev/null || echo "0")
                    local download=$(iptables -vnx -L INPUT 2>/dev/null | grep -c "$pid" 2>/dev/null || echo "0")
                    if [ "$upload" != "0" ] || [ "$download" != "0" ]; then
                        total_bytes=$((total_bytes + (upload + download) * 1024))
                    fi
                fi
            fi
        done
    fi
    
    # Convert to MB
    if [ "$total_bytes" -gt 0 ]; then
        echo $((total_bytes / 1048576))
    else
        echo "0"
    fi
}

monitor_user() {
    local username="$1"
    local traffic_file="$TRAFFIC_DB/$username"
    local total_mb=$(get_realtime_traffic "$username")
    echo "$total_mb" > "$traffic_file"
}

log_message "REALTIME Traffic monitor started"
while true; do
    if [ -d "$USER_DB" ]; then
        for user_file in "$USER_DB"/*; do
            if [ -f "$user_file" ]; then
                username=$(basename "$user_file")
                monitor_user "$username"
            fi
        done
    fi
    sleep 10  # Update every 10 seconds for real-time
done
EOF
    chmod +x /usr/local/bin/elite-x-traffic

    cat > /etc/systemd/system/elite-x-traffic.service <<EOF
[Unit]
Description=ELITE-X REALTIME Traffic Monitor
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/elite-x-traffic
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}

# ========== AUTO CLEANER ==========
setup_auto_remover() {
    cat > /usr/local/bin/elite-x-cleaner <<'EOF'
#!/bin/bash

USER_DB="/etc/elite-x/users"
TRAFFIC_DB="/etc/elite-x/traffic"
LOG_FILE="/var/log/elite-x-cleaner.log"
ARCHIVE_DIR="/etc/elite-x/deleted_users"

mkdir -p "$ARCHIVE_DIR"

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
                        sleep 3
                        
                        cp "$user_file" "$ARCHIVE_DIR/${username}_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null || true
                        
                        userdel -f -r "$username" 2>/dev/null
                        
                        sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
                        
                        rm -f "$user_file"
                        rm -f "$TRAFFIC_DB/$username"
                        
                        log_message "Removed expired user: $username"
                        
                        systemctl restart sshd 2>/dev/null || true
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
User=root
ExecStart=/usr/local/bin/elite-x-cleaner
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# ========== BANDWIDTH MONITOR ==========
setup_bandwidth_monitor() {
    cat > /usr/local/bin/elite-x-bandwidth <<'EOF'
#!/bin/bash
LOG_FILE="/var/log/elite-x-bandwidth.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_message "Bandwidth monitor started"

while true; do
    if [ -f /sys/class/net/eth0/statistics/rx_bytes ]; then
        rx_bytes=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo "0")
        tx_bytes=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo "0")
        rx_mb=$((rx_bytes / 1048576))
        tx_mb=$((tx_bytes / 1048576))
        log_message "Total Bandwidth - RX: ${rx_mb}MB, TX: ${tx_mb}MB"
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
User=root
ExecStart=/usr/local/bin/elite-x-bandwidth
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# ========== AUTO BACKUP ==========
setup_auto_backup() {
    cat > /usr/local/bin/elite-x-backup <<'EOF'
#!/bin/bash
BACKUP_DIR="/root/elite-x-backups"
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/elite-x-config-$DATE.tar.gz" /etc/elite-x 2>/dev/null || true
tar -czf "$BACKUP_DIR/dnstt-keys-$DATE.tar.gz" /etc/dnstt 2>/dev/null || true

if [ -d "/etc/elite-x/users" ]; then
    cp -r /etc/elite-x/users "$BACKUP_DIR/users-$DATE" 2>/dev/null || true
fi

cd "$BACKUP_DIR"
ls -t elite-x-config-* | tail -n +11 | xargs -r rm 2>/dev/null || true
ls -t dnstt-keys-* | tail -n +11 | xargs -r rm 2>/dev/null || true

echo "Backup completed: $DATE" >> /var/log/elite-x-backup.log
EOF
    chmod +x /usr/local/bin/elite-x-backup

    cat > /etc/cron.daily/elite-x-backup <<'EOF'
#!/bin/bash
/usr/local/bin/elite-x-backup
EOF
    chmod +x /etc/cron.daily/elite-x-backup
}

# ========== USER MANAGEMENT WITH REALTIME DATA ==========
setup_user_manager() {
    cat > /usr/local/bin/elite-x-user <<'EOF'
#!/bin/bash

RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';CYAN='\033[0;36m';WHITE='\033[1;37m';NC='\033[0m'

show_quote() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}            Always Remember ELITE-X when you see X            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

UD="/etc/elite-x/users"
TD="/etc/elite-x/traffic"
AD="/etc/elite-x/deleted_users"
DL="/var/log/elite-x-deleted-users.log"
mkdir -p $UD $TD $AD

user_exists_in_system() {
    local username="$1"
    if id "$username" &>/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

user_exists_in_db() {
    local username="$1"
    if [ -f "$UD/$username" ]; then
        return 0
    else
        return 1
    fi
}

disconnect_user() {
    local username="$1"
    echo -e "${YELLOW}Disconnecting all sessions for $username...${NC}"
    
    pkill -u "$username" 2>/dev/null || true
    
    for pid in $(pgrep -u "$username" -f sshd 2>/dev/null); do
        kill -9 $pid 2>/dev/null || true
    done
    
    sleep 2
    pkill -9 -u "$username" 2>/dev/null || true
    
    echo -e "${GREEN}✅ All sessions disconnected${NC}"
}

completely_remove_user() {
    local username="$1"
    
    disconnect_user "$username"
    
    if [ -f "$UD/$username" ]; then
        cp "$UD/$username" "$AD/${username}_deleted_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null
        echo "$(date): Deleted user $username" >> "$DL"
    fi
    
    sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
    
    if user_exists_in_system "$username"; then
        userdel -f -r "$username" 2>/dev/null
        if user_exists_in_system "$username"; then
            pkill -9 -u "$username" 2>/dev/null || true
            sleep 2
            userdel -f -r "$username" 2>/dev/null
        fi
    fi
    
    rm -f "$UD/$username" 2>/dev/null
    rm -f "$TD/$username" 2>/dev/null
    
    systemctl restart sshd 2>/dev/null || true
    
    if user_exists_in_system "$username"; then
        return 1
    else
        return 0
    fi
}

# ========== FIXED REALTIME TRAFFIC FUNCTION - NO ERROR ==========
get_realtime_traffic() {
    local username="$1"
    local total_mb=0
    
    if ! user_exists_in_system "$username"; then
        echo "0"
        return
    fi
    
    # Read from traffic monitor file (updated every 10 seconds)
    if [ -f "$TD/$username" ]; then
        total_mb=$(cat "$TD/$username" 2>/dev/null || echo "0")
        # Ensure it's a number
        if ! [[ "$total_mb" =~ ^[0-9]+$ ]]; then
            total_mb=0
        fi
    fi
    
    echo "$total_mb"
}

# ========== FIXED LOGIN COUNT FUNCTION ==========
get_user_logins() {
    local username="$1"
    local count=0
    
    if ! user_exists_in_system "$username"; then
        echo "0"
        return
    fi
    
    # Count SSH sessions
    count=$(pgrep -u "$username" -f sshd 2>/dev/null | wc -l)
    echo "$count"
}

calc_usage_percent() {
    local used=$1
    local limit=$2
    
    if [ -z "$limit" ] || [ "$limit" -eq 0 ]; then
        echo "Unlimited"
    else
        # Ensure used is a number
        if ! [[ "$used" =~ ^[0-9]+$ ]]; then
            used=0
        fi
        local percent=$((used * 100 / limit))
        if [ $percent -ge 90 ]; then
            echo -e "${RED}${percent}%${NC}"
        elif [ $percent -ge 70 ]; then
            echo -e "${YELLOW}${percent}%${NC}"
        else
            echo -e "${GREEN}${percent}%${NC}"
        fi
    fi
}

set_user_limit() {
    local username="$1"
    local limit="$2"
    
    if [ "$limit" -gt 0 ]; then
        sed -i "/Match User $username/,+3 d" /etc/ssh/sshd_config 2>/dev/null
        echo "Match User $username" >> /etc/ssh/sshd_config
        echo "    MaxSessions $limit" >> /etc/ssh/sshd_config
        systemctl restart sshd
        echo -e "${GREEN}User $username limited to $limit concurrent login(s)${NC}"
    fi
}

show_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${YELLOW}              ELITE-X USER MANAGEMENT                          ${CYAN}║${NC}"
        echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${WHITE}  [1] Add User                                                ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [2] List Users                                              ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [3] Renew User                                              ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [4] User Details                                            ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [5] Lock User                                               ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [6] Unlock User                                             ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [7] Delete User                                             ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [8] Delete Multiple Users                                   ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [9] Export Users List                                       ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [10] Set User Login Limit                                   ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [11] Show Deleted Users                                     ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [12] Restore Deleted User                                   ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [13] User Activity Log                                      ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [14] Online Users Report                                    ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}  [0] Back to Main Menu                                       ${CYAN}║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Choose option [0-14]: "$NC)" opt
        
        case $opt in
            1) add_user ;;
            2) list_users ;;
            3) renew_user ;;
            4) user_details ;;
            5) lock_user ;;
            6) unlock_user ;;
            7) delete_user ;;
            8) delete_multiple ;;
            9) export_users ;;
            10) set_user_login_limit ;;
            11) show_deleted_users ;;
            12) restore_user ;;
            13) user_activity_log ;;
            14) online_users_report ;;
            0) echo -e "${GREEN}Returning to main menu...${NC}"; sleep 1; return 0 ;;
            *) echo -e "${RED}Invalid option${NC}"; sleep 2 ;;
        esac
    done
}

add_user() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                    ADD NEW USER                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $GREEN"Username: "$NC)" username
    
    if user_exists_in_system "$username"; then
        echo -e "${RED}❌ User '$username' already exists in system!${NC}"
        
        if [ ! -f "$UD/$username" ]; then
            echo -e "${YELLOW}⚠️  User exists in system but not in ELITE-X database${NC}"
            read -p "Do you want to remove the system user and recreate? (y/n): " remove_choice
            if [ "$remove_choice" = "y" ]; then
                pkill -u "$username" 2>/dev/null || true
                sleep 2
                userdel -f -r "$username" 2>/dev/null
                if user_exists_in_system "$username"; then
                    echo -e "${RED}❌ Failed to remove system user${NC}"
                    read -p "Press Enter to continue..."
                    return
                else
                    echo -e "${GREEN}✅ System user removed${NC}"
                fi
            else
                read -p "Press Enter to continue..."
                return
            fi
        else
            echo -e "${YELLOW}⚠️  User exists in both system and database${NC}"
            read -p "Do you want to delete the existing user and recreate? (y/n): " delete_choice
            if [ "$delete_choice" = "y" ]; then
                completely_remove_user "$username"
                if user_exists_in_system "$username"; then
                    echo -e "${RED}❌ Failed to remove existing user${NC}"
                    read -p "Press Enter to continue..."
                    return
                fi
            else
                read -p "Press Enter to continue..."
                return
            fi
        fi
    fi
    
    if user_exists_in_db "$username"; then
        echo -e "${YELLOW}⚠️  User exists in database but not in system - cleaning up...${NC}"
        rm -f "$UD/$username" "$TD/$username"
    fi
    
    read -p "$(echo -e $GREEN"Password: "$NC)" password
    read -p "$(echo -e $GREEN"Expire days: "$NC)" days
    read -p "$(echo -e $GREEN"Traffic limit (MB, 0 for unlimited): "$NC)" traffic_limit
    read -p "$(echo -e $GREEN"Max concurrent logins (0 for unlimited): "$NC)" max_logins
    
    if user_exists_in_system "$username"; then
        echo -e "${RED}❌ User '$username' still exists in system. Cannot create.${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    expire_date=$(date -d "+$days days" +"%Y-%m-%d")
    chage -E "$expire_date" "$username"
    
    if [ "$max_logins" -gt 0 ]; then
        set_user_limit "$username" "$max_logins"
    fi
    
    cat > $UD/$username <<INFO
Username: $username
Password: $password
Expire: $expire_date
Traffic_Limit: $traffic_limit
Max_Logins: $max_logins
Created: $(date +"%Y-%m-%d %H:%M:%S")
INFO
    
    echo "0" > $TD/$username
    
    SERVER=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "?")
    PUBKEY=$(cat /etc/dnstt/server.pub 2>/dev/null || echo "Not generated")
    
    clear
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo "User created successfully!"
    echo "Username      : $username"
    echo "Password      : $password"
    echo "Server        : $SERVER"
    echo "Public Key    : $PUBKEY"
    echo "Expire        : $expire_date"
    echo "Traffic Limit : $traffic_limit MB"
    echo "Max Logins    : $max_logins"
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo "$(date): Created user $username" >> /var/log/elite-x-users.log
    echo ""
    read -p "Press Enter to continue..."
}

# ========== FIXED LIST USERS - NO ERROR LINE 105 ==========
list_users() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                    ACTIVE USERS                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [ -z "$(ls -A $UD 2>/dev/null)" ]; then
        echo -e "${RED}No users found${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    printf "%-12s %-10s %-8s %-8s %-10s %-8s %-8s\n" "USERNAME" "EXPIRE" "LIMIT" "USED" "USAGE%" "LOGINS" "STATUS"
    echo "────────────────────────────────────────────────────────────────────────────"
    
    TOTAL_TRAFFIC=0
    TOTAL_USERS=0
    ONLINE_COUNT=0
    
    for user in $UD/*; do
        [ ! -f "$user" ] && continue
        u=$(basename "$user")
        
        if ! user_exists_in_system "$u"; then
            echo -e "${YELLOW}⚠️  Orphaned entry for $u - cleaning up${NC}"
            rm -f "$user" "$TD/$u" 2>/dev/null
            continue
        fi
        
        ex=$(grep "Expire:" "$user" | cut -d' ' -f2)
        lm=$(grep "Traffic_Limit:" "$user" | cut -d' ' -f2)
        ml=$(grep "Max_Logins:" "$user" 2>/dev/null | cut -d' ' -f2 || echo "0")
        
        # Get realtime traffic - FIXED: No more line 105 error
        us=$(get_realtime_traffic "$u")
        
        # Get current logins
        current_logins=$(get_user_logins "$u")
        if [ "$current_logins" -gt 0 ]; then
            ONLINE_COUNT=$((ONLINE_COUNT + 1))
        fi
        
        # Calculate usage percentage
        usage_percent=$(calc_usage_percent "$us" "$lm")
        
        # Check status
        st=$(passwd -S "$u" 2>/dev/null | grep -q "L" && echo "${RED}LOCK${NC}" || echo "${GREEN}OK${NC}")
        
        # FIXED: Ensure all values are printed correctly
        printf "%-12s %-10s %-8s %-8s %-10b %-8s %-8b\n" "$u" "$ex" "$lm" "$us" "$usage_percent" "$current_logins/$ml" "$st"
        
        TOTAL_TRAFFIC=$((TOTAL_TRAFFIC + us))
        TOTAL_USERS=$((TOTAL_USERS + 1))
    done
    
    echo "────────────────────────────────────────────────────────────────────────────"
    echo -e "Total Users: ${GREEN}$TOTAL_USERS${NC} | Online: ${CYAN}$ONLINE_COUNT${NC} | Total Traffic: ${YELLOW}$TOTAL_TRAFFIC MB${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

set_user_login_limit() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                 SET USER LOGIN LIMIT                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $GREEN"Username: "$NC)" u
    
    if [ ! -f "$UD/$u" ]; then
        echo -e "${RED}User not found!${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    if ! user_exists_in_system "$u"; then
        echo -e "${RED}User does not exist in system! Cleaning up database...${NC}"
        rm -f "$UD/$u" "$TD/$u"
        read -p "Press Enter to continue..."
        return
    fi
    
    current_limit=$(grep "Max_Logins:" "$UD/$u" 2>/dev/null | cut -d' ' -f2 || echo "0")
    echo "Current max logins: $current_limit"
    read -p "$(echo -e $GREEN"New max concurrent logins (0 for unlimited): "$NC)" new_limit
    
    if [ "$new_limit" -ge 0 ]; then
        if grep -q "Max_Logins:" "$UD/$u"; then
            sed -i "s/Max_Logins:.*/Max_Logins: $new_limit/" "$UD/$u"
        else
            echo "Max_Logins: $new_limit" >> "$UD/$u"
        fi
        
        if [ "$new_limit" -gt 0 ]; then
            set_user_limit "$u" "$new_limit"
        else
            sed -i "/Match User $u/,+3 d" /etc/ssh/sshd_config
            systemctl restart sshd
        fi
        
        echo -e "${GREEN}Login limit updated to $new_limit${NC}"
        echo "$(date): Updated login limit for $u to $new_limit" >> /var/log/elite-x-users.log
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

renew_user() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                    RENEW USER                                   ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $GREEN"Username: "$NC)" u
    
    if [ ! -f "$UD/$u" ]; then
        echo -e "${RED}User not found in database!${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    if ! user_exists_in_system "$u"; then
        echo -e "${RED}User does not exist in system! Cleaning up database...${NC}"
        rm -f "$UD/$u" "$TD/$u"
        read -p "Press Enter to continue..."
        return
    fi
    
    current_expire=$(grep "Expire:" "$UD/$u" | cut -d' ' -f2)
    current_limit=$(grep "Traffic_Limit:" "$UD/$u" | cut -d' ' -f2)
    
    echo "Current expiry: $current_expire"
    echo "Current limit: $current_limit MB"
    echo ""
    
    read -p "$(echo -e $GREEN"Add how many days? (0 to skip): "$NC)" add_days
    read -p "$(echo -e $GREEN"New traffic limit MB (0 to keep current): "$NC)" new_limit
    
    if [ "$add_days" -gt 0 ]; then
        new_expire=$(date -d "$current_expire + $add_days days" +"%Y-%m-%d")
        chage -E "$new_expire" "$u"
        sed -i "s/Expire:.*/Expire: $new_expire/" "$UD/$u"
        echo -e "${GREEN}Expiry updated to: $new_expire${NC}"
    fi
    
    if [ "$new_limit" -gt 0 ]; then
        sed -i "s/Traffic_Limit:.*/Traffic_Limit: $new_limit/" "$UD/$u"
        echo -e "${GREEN}Traffic limit updated to: $new_limit MB${NC}"
        echo "0" > "$TD/$u"
    fi
    
    echo "$(date): Renewed user $u (+$add_days days, limit: $new_limit MB)" >> /var/log/elite-x-users.log
    echo ""
    read -p "Press Enter to continue..."
}

user_details() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                    USER DETAILS                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "$(echo -e $GREEN"Username: "$NC)" u
    
    if [ ! -f "$UD/$u" ]; then
        echo -e "${RED}User not found!${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    if ! user_exists_in_system "$u"; then
        echo -e "${RED}User does not exist in system! Cleaning up database...${NC}"
        rm -f "$UD/$u" "$TD/$u"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${YELLOW}User Information:${NC}"
    echo "──────────────────"
    cat "$UD/$u"
    echo ""
    
    realtime_traffic=$(get_realtime_traffic "$u")
    echo -e "${YELLOW}Real-time Traffic:${NC} ${CYAN}$realtime_traffic MB${NC}"
    echo ""
    
    echo -e "\n${YELLOW}Active Connections:${NC}"
    local sessions=$(get_user_logins "$u")
    if [ "$sessions" -gt 0 ]; then
        for pid in $(pgrep -u "$u" -f sshd 2>/dev/null); do
            local ip=$(ss -tnp 2>/dev/null | grep ",$pid," | awk '{print $5}' | cut -d: -f1 | head -1)
            if [ -n "$ip" ]; then
                echo "  Session PID: $pid - IP: $ip"
            fi
        done
    else
        echo "  No active connections"
    fi
    
    echo -e "\n${YELLOW}Recent Login History:${NC}"
    last -n 10 "$u" 2>/dev/null | head -5 || echo "  No login history"
    
    echo ""
    read -p "Press Enter to continue..."
}

lock_user() { 
    read -p "$(echo -e $GREEN"Username: "$NC)" u
    if [ -f "$UD/$u" ]; then
        if user_exists_in_system "$u"; then
            usermod -L "$u" 2>/dev/null
            disconnect_user "$u"
            echo -e "${GREEN}✅ User $u locked and disconnected${NC}"
            echo "$(date): Locked user $u" >> /var/log/elite-x-users.log
        else
            echo -e "${RED}User does not exist in system! Cleaning up database...${NC}"
            rm -f "$UD/$u" "$TD/$u"
        fi
    else
        echo -e "${RED}User not found${NC}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

unlock_user() { 
    read -p "$(echo -e $GREEN"Username: "$NC)" u
    if [ -f "$UD/$u" ]; then
        if user_exists_in_system "$u"; then
            usermod -U "$u" 2>/dev/null
            echo -e "${GREEN}✅ User $u unlocked${NC}"
            echo "$(date): Unlocked user $u" >> /var/log/elite-x-users.log
        else
            echo -e "${RED}User does not exist in system! Cleaning up database...${NC}"
            rm -f "$UD/$u" "$TD/$u"
        fi
    else
        echo -e "${RED}User not found${NC}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

delete_user() { 
    read -p "$(echo -e $GREEN"Username: "$NC)" u
    
    local exists_in_system=false
    local exists_in_db=false
    
    if user_exists_in_system "$u"; then
        exists_in_system=true
    fi
    
    if [ -f "$UD/$u" ]; then
        exists_in_db=true
    fi
    
    if [ "$exists_in_system" = false ] && [ "$exists_in_db" = false ]; then
        echo -e "${RED}❌ User '$u' does not exist anywhere${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${YELLOW}User status:${NC}"
    echo -e "  In system: $([ "$exists_in_system" = true ] && echo "${GREEN}Yes${NC}" || echo "${RED}No${NC}")"
    echo -e "  In database: $([ "$exists_in_db" = true ] && echo "${GREEN}Yes${NC}" || echo "${RED}No${NC}")"
    
    read -p "Are you sure you want to delete this user? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo -e "${YELLOW}Deletion cancelled${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    if completely_remove_user "$u"; then
        echo -e "${GREEN}✅ User $u completely removed${NC}"
    else
        echo -e "${RED}❌ Failed to completely remove user $u${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

delete_multiple() {
    echo -e "${YELLOW}Enter usernames to delete (space separated):${NC}"
    read -a users
    local deleted=0
    local failed=0
    local not_found=0
    
    for u in "${users[@]}"; do
        echo -n "Processing $u... "
        
        local exists_in_system=false
        local exists_in_db=false
        
        if user_exists_in_system "$u"; then
            exists_in_system=true
        fi
        
        if [ -f "$UD/$u" ]; then
            exists_in_db=true
        fi
        
        if [ "$exists_in_system" = false ] && [ "$exists_in_db" = false ]; then
            echo -e "${RED}❌ Not found${NC}"
            not_found=$((not_found + 1))
            continue
        fi
        
        if completely_remove_user "$u"; then
            echo -e "${GREEN}✅ Deleted${NC}"
            deleted=$((deleted + 1))
        else
            echo -e "${RED}❌ Failed${NC}"
            failed=$((failed + 1))
        fi
    done
    
    echo ""
    echo -e "${GREEN}Deleted: $deleted${NC}, ${RED}Failed: $failed${NC}, ${YELLOW}Not found: $not_found${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

export_users() {
    local export_file="/root/elite-x-users-$(date +%Y%m%d-%H%M%S).txt"
    echo "ELITE-X Users List - $(date)" > "$export_file"
    echo "=================================" >> "$export_file"
    echo "" >> "$export_file"
    
    for user in $UD/*; do
        [ -f "$user" ] && cat "$user" >> "$export_file" && echo "-------------------" >> "$export_file"
    done
    
    echo -e "${GREEN}✅ Users exported to: $export_file${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

show_deleted_users() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                 DELETED USERS ARCHIVE                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -z "$(ls -A $AD 2>/dev/null)" ]; then
        echo -e "${YELLOW}No deleted users archive found${NC}"
    else
        ls -lh "$AD" | awk '{print $9, $5, $6, $7, $8}' | while read file size month day time; do
            if [[ "$file" == *"_deleted_"* ]]; then
                username=$(echo "$file" | cut -d'_' -f1)
                deleted_date=$(echo "$file" | grep -o "[0-9]\{8\}_[0-9]\{6\}" | sed 's/\(....\)\(..\)\(..\)_\(..\)\(..\)\(..\)/\1-\2-\3 \4:\5:\6/')
                echo -e "  ${CYAN}User:${NC} $username ${YELLOW}($size)${NC} - Deleted: $deleted_date"
            fi
        done
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

restore_user() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                 RESTORE DELETED USER                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -z "$(ls -A $AD 2>/dev/null)" ]; then
        echo -e "${RED}No deleted users to restore${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Available deleted users:"
    local i=1
    declare -A restore_map
    
    for file in "$AD"/*_deleted_*.txt; do
        [ -f "$file" ] || continue
        username=$(basename "$file" | cut -d'_' -f1)
        echo "  $i. $username"
        restore_map[$i]="$file"
        i=$((i + 1))
    done
    
    echo ""
    read -p "Select user to restore (number): " selection
    
    if [ -n "${restore_map[$selection]}" ]; then
        local file="${restore_map[$selection]}"
        local username=$(basename "$file" | cut -d'_' -f1)
        
        if user_exists_in_system "$username"; then
            echo -e "${RED}User $username already exists in system${NC}"
            read -p "Press Enter to continue..."
            return
        fi
        
        local password=$(grep "Password:" "$file" | cut -d' ' -f2)
        local expire=$(grep "Expire:" "$file" | cut -d' ' -f2)
        local traffic_limit=$(grep "Traffic_Limit:" "$file" | cut -d' ' -f2)
        local max_logins=$(grep "Max_Logins:" "$file" | cut -d' ' -f2)
        
        useradd -m -s /bin/false "$username"
        echo "$username:$password" | chpasswd
        chage -E "$expire" "$username"
        
        if [ "$max_logins" -gt 0 ]; then
            set_user_limit "$username" "$max_logins"
        fi
        
        cp "$file" "$UD/$username"
        echo "0" > "$TD/$username"
        
        echo -e "${GREEN}✅ User $username restored${NC}"
        echo "$(date): Restored user $username from archive" >> /var/log/elite-x-users.log
    else
        echo -e "${RED}Invalid selection${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

user_activity_log() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                 USER ACTIVITY LOG                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -f /var/log/elite-x-users.log ]; then
        tail -n 50 /var/log/elite-x-users.log
    else
        echo "No activity log found"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

online_users_report() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}                 ONLINE USERS REPORT                             ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${GREEN}Currently Online Users:${NC}"
    echo "────────────────────────────────"
    
    local online_found=false
    
    for user in $UD/*; do
        [ ! -f "$user" ] && continue
        u=$(basename "$user")
        
        if user_exists_in_system "$u"; then
            local sessions=$(get_user_logins "$u")
            if [ "$sessions" -gt 0 ]; then
                online_found=true
                local ips=""
                for pid in $(pgrep -u "$u" -f sshd 2>/dev/null); do
                    local ip=$(ss -tnp 2>/dev/null | grep ",$pid," | awk '{print $5}' | cut -d: -f1 | head -1)
                    if [ -n "$ip" ]; then
                        ips="$ips $ip"
                    fi
                done
                echo -e "  ${GREEN}→${NC} $u: $sessions session(s) - IPs: $ips"
            fi
        fi
    done
    
    if [ "$online_found" = false ]; then
        echo "  No users currently online"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

show_menu
EOF
    chmod +x /usr/local/bin/elite-x-user
}

# ========== MAIN MENU ==========
setup_main_menu() {
    cat >/usr/local/bin/elite-x <<'EOF'
#!/bin/bash

RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[1;33m';CYAN='\033[0;36m'
PURPLE='\033[0;35m';WHITE='\033[1;37m';BOLD='\033[1m';NC='\033[0m'

show_quote() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}            Always Remember ELITE-X when you see X            ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW}${BOLD}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

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
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    UPTIME=$(uptime | awk -F'up' '{print $2}' | awk -F',' '{print $1}')
    SUB=$(cat /etc/elite-x/subdomain 2>/dev/null || echo "Not configured")
    
    if [ -f "/etc/elite-x/key" ]; then
        ACTIVATION_KEY=$(cat /etc/elite-x/key)
    else
        ACTIVATION_KEY="ELITEX-2026-DAN-4D-08"
        echo "$ACTIVATION_KEY" > /etc/elite-x/key
    fi
    
    if [ -f "/etc/elite-x/expiry" ]; then
        EXP=$(cat /etc/elite-x/expiry)
    else
        EXP="Lifetime"
        echo "Lifetime" > /etc/elite-x/expiry
    fi
    
    LOCATION=$(cat /etc/elite-x/location 2>/dev/null || echo "South Africa")
    CURRENT_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
    
    SSH_CONN=$(ss -tnp 2>/dev/null | grep -c ":22.*ESTAB" || echo "0")
    DNS_CONN=$(ss -unp 2>/dev/null | grep -c ":5300" || echo "0")
    
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        DNS="${GREEN}●${NC}"
    else
        DNS="${RED}●${NC}"
        systemctl restart dnstt-elite-x 2>/dev/null &
    fi
    
    PRX=$(systemctl is-active dnstt-elite-x-proxy 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    TRAF=$(systemctl is-active elite-x-traffic 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    CLN=$(systemctl is-active elite-x-cleaner 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    BAND=$(systemctl is-active elite-x-bandwidth 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    MON=$(systemctl is-active elite-x-monitor 2>/dev/null | grep -q active && echo "${GREEN}●${NC}" || echo "${RED}●${NC}")
    
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${YELLOW}${BOLD}                    ELITE-X SLOWDNS v3.5                       ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${WHITE}  Subdomain :${GREEN} $SUB${NC}"
    echo -e "${PURPLE}║${WHITE}  IP        :${GREEN} $IP${NC}"
    echo -e "${PURPLE}║${WHITE}  Location  :${GREEN} $LOC${NC}"
    echo -e "${PURPLE}║${WHITE}  ISP       :${GREEN} $ISP${NC}"
    echo -e "${PURPLE}║${WHITE}  RAM       :${GREEN} $RAM | CPU: ${CPU}% | Uptime: ${UPTIME}${NC}"
    echo -e "${PURPLE}║${WHITE}  VPS Loc   :${GREEN} $LOCATION | MTU: $CURRENT_MTU${NC}"
    echo -e "${PURPLE}║${WHITE}  Services  : DNS:$DNS PRX:$PRX TRAF:$TRAF CLN:$CLN BAND:$BAND MON:$MON${NC}"
    echo -e "${PURPLE}║${WHITE}  Connections: SSH: ${GREEN}$SSH_CONN${NC} | DNS: ${YELLOW}$DNS_CONN${NC}"
    echo -e "${PURPLE}║${WHITE}  Developer :${PURPLE} ELITE-X TEAM${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${WHITE}  Act Key   :${YELLOW} $ACTIVATION_KEY${NC}"
    echo -e "${PURPLE}║${WHITE}  Expiry    :${YELLOW} $EXP${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

settings_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${YELLOW}${BOLD}                      SETTINGS MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${WHITE}  [8]  🔑 View Public Key${NC}"
        echo -e "${CYAN}║${WHITE}  [9]  Change MTU Value${NC}"
        echo -e "${CYAN}║${WHITE}  [10] 🔄 Auto Expired Account Remover${NC}"
        echo -e "${CYAN}║${WHITE}  [11] 🔄 Restart All Services${NC}"
        echo -e "${CYAN}║${WHITE}  [12] 💾 Backup Configuration${NC}"
        echo -e "${CYAN}║${WHITE}  [13] 🔄 Reboot VPS${NC}"
        echo -e "${CYAN}║${WHITE}  [14] 🗑️  Uninstall Script${NC}"
        echo -e "${CYAN}║${WHITE}  [0]  Back to Main Menu${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Settings option: "$NC)" ch
        
        case $ch in
            8)
                echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
                echo -e "${CYAN}║${YELLOW}                    PUBLIC KEY                                   ${CYAN}║${NC}"
                echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
                echo -e "${CYAN}║${GREEN}  $(cat /etc/dnstt/server.pub)${NC}"
                echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
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
            10)
                systemctl enable --now elite-x-cleaner.service 2>/dev/null
                echo -e "${GREEN}✅ Auto remover started${NC}"
                read -p "Press Enter to continue..."
                ;;
            11)
                systemctl restart dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-bandwidth elite-x-monitor sshd 2>/dev/null
                echo -e "${GREEN}✅ Services restarted${NC}"
                read -p "Press Enter to continue..."
                ;;
            12)
                /usr/local/bin/elite-x-backup
                echo -e "${GREEN}✅ Backup completed${NC}"
                read -p "Press Enter to continue..."
                ;;
            13)
                read -p "Reboot? (y/n): " c
                [ "$c" = "y" ] && reboot
                ;;
            14)
                read -p "Uninstall? (YES): " c
                [ "$c" = "YES" ] && {
                    echo -e "${YELLOW}🔄 Removing all users and data...${NC}"
                    
                    if [ -d "/etc/elite-x/users" ]; then
                        for user_file in /etc/elite-x/users/*; do
                            if [ -f "$user_file" ]; then
                                username=$(basename "$user_file")
                                echo -e "  Removing user: $username"
                                pkill -u "$username" 2>/dev/null || true
                                sleep 2
                                userdel -f -r "$username" 2>/dev/null || true
                            fi
                        done
                    fi
                    
                    pkill -f dnstt-server 2>/dev/null || true
                    pkill -f dnstt-edns-proxy 2>/dev/null || true
                    pkill -f elite-x-traffic 2>/dev/null || true
                    pkill -f elite-x-cleaner 2>/dev/null || true
                    pkill -f elite-x-bandwidth 2>/dev/null || true
                    pkill -f elite-x-monitor 2>/dev/null || true
                    
                    systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-bandwidth elite-x-monitor 2>/dev/null || true
                    systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-bandwidth elite-x-monitor 2>/dev/null || true
                    
                    rm -rf /etc/systemd/system/dnstt-elite-x*
                    rm -rf /etc/systemd/system/elite-x-*
                    rm -rf /etc/dnstt /etc/elite-x
                    rm -f /usr/local/bin/dnstt-*
                    rm -f /usr/local/bin/elite-x*
                    
                    sed -i '/^Banner/d' /etc/ssh/sshd_config
                    systemctl restart sshd
                    
                    rm -f /etc/profile.d/elite-x-dashboard.sh
                    sed -i '/elite-x/d' ~/.bashrc
                    sed -i '/ELITE_X_SHOWN/d' ~/.bashrc
                    
                    rm -f /etc/cron.hourly/elite-x-expiry
                    rm -f /etc/cron.daily/elite-x-backup
                    rm -f /etc/cron.hourly/elite-x-bandwidth
                    
                    echo -e "${GREEN}✅ Uninstalled completely${NC}"
                    rm -f /tmp/elite-x-running
                    exit 0
                }
                read -p "Press Enter to continue..."
                ;;
            0) echo -e "${GREEN}Returning to main menu...${NC}"; sleep 1; return 0 ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

main_menu() {
    while true; do
        show_dashboard
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${GREEN}${BOLD}                         MAIN MENU                              ${CYAN}║${NC}"
        echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${WHITE}  [1] 👤 User Management Menu${NC}"
        echo -e "${CYAN}║${WHITE}  [2] 📊 View All Users${NC}"
        echo -e "${CYAN}║${WHITE}  [3] 🔒 Lock User${NC}"
        echo -e "${CYAN}║${WHITE}  [4] 🔓 Unlock User${NC}"
        echo -e "${CYAN}║${WHITE}  [5] 🗑️  Delete User${NC}"
        echo -e "${CYAN}║${WHITE}  [6] 📝 Create/Edit Banner${NC}"
        echo -e "${CYAN}║${WHITE}  [7] ❌ Delete Banner${NC}"
        echo -e "${CYAN}║${WHITE}  [8] 📈 Traffic Statistics${NC}"
        echo -e "${CYAN}║${WHITE}  [9] 👥 Online Users${NC}"
        echo -e "${CYAN}║${RED}  [S] ⚙️  Settings${NC}"
        echo -e "${CYAN}║${WHITE}  [0] 🚪 Exit${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $GREEN"Main menu option: "$NC)" ch
        
        case $ch in
            1) elite-x-user ;;
            2) elite-x-user list ;;
            3) elite-x-user lock ;;
            4) elite-x-user unlock ;;
            5) elite-x-user del ;;
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
            8)
                echo -e "${YELLOW}Traffic Statistics:${NC}"
                echo "──────────────────"
                TOTAL_TRAFFIC=0
                for user in /etc/elite-x/users/*; do
                    if [ -f "$user" ]; then
                        u=$(basename "$user")
                        us=$(cat /etc/elite-x/traffic/$u 2>/dev/null || echo "0")
                        echo -e "$u: ${CYAN}$us MB${NC}"
                        TOTAL_TRAFFIC=$((TOTAL_TRAFFIC + us))
                    fi
                done
                echo "──────────────────"
                echo -e "Total: ${YELLOW}$TOTAL_TRAFFIC MB${NC}"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            9)
                echo -e "${GREEN}Currently Online Users:${NC}"
                echo "──────────────────"
                online_found=false
                for user in /etc/elite-x/users/*; do
                    if [ -f "$user" ]; then
                        u=$(basename "$user")
                        sessions=$(ps -u "$u" 2>/dev/null | grep -c "sshd" || echo "0")
                        if [ "$sessions" -gt 0 ]; then
                            online_found=true
                            ips=""
                            for pid in $(pgrep -u "$u" -f sshd 2>/dev/null); do
                                ip=$(ss -tnp 2>/dev/null | grep ",$pid," | awk '{print $5}' | cut -d: -f1 | head -1)
                                if [ -n "$ip" ]; then
                                    ips="$ips $ip"
                                fi
                            done
                            echo -e "  ${GREEN}→${NC} $u: $sessions session(s) - IPs: $ips"
                        fi
                    fi
                done
                if [ "$online_found" = false ]; then
                    echo "  No users currently online"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            [Ss]) settings_menu ;;
            0) 
                rm -f /tmp/elite-x-running
                show_quote
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0 
                ;;
            *) echo -e "${RED}Invalid option${NC}"; read -p "Press Enter to continue..." ;;
        esac
    done
}

main_menu
EOF
chmod +x /usr/local/bin/elite-x
}

# ========== START ALL SERVICES ==========
start_all_services() {
    echo -e "${YELLOW}Starting all ELITE-X services...${NC}"
    
    systemctl daemon-reload
    
    fuser -k 53/udp 2>/dev/null || true
    fuser -k 5300/udp 2>/dev/null || true
    sleep 2
    
    echo -n "Starting DNSTT Server... "
    systemctl enable dnstt-elite-x.service 2>/dev/null
    systemctl start dnstt-elite-x.service 2>/dev/null
    sleep 3
    if systemctl is-active dnstt-elite-x >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
        systemctl restart dnstt-elite-x.service 2>/dev/null
        sleep 2
    fi
    
    echo -n "Starting DNSTT Proxy... "
    systemctl enable dnstt-elite-x-proxy.service 2>/dev/null
    systemctl start dnstt-elite-x-proxy.service 2>/dev/null
    sleep 2
    if systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -n "Starting Traffic Monitor... "
    systemctl enable elite-x-traffic.service 2>/dev/null
    systemctl start elite-x-traffic.service 2>/dev/null
    sleep 2
    if systemctl is-active elite-x-traffic >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -n "Starting Auto Cleaner... "
    systemctl enable elite-x-cleaner.service 2>/dev/null
    systemctl start elite-x-cleaner.service 2>/dev/null
    sleep 2
    if systemctl is-active elite-x-cleaner >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -n "Starting Bandwidth Monitor... "
    systemctl enable elite-x-bandwidth.service 2>/dev/null
    systemctl start elite-x-bandwidth.service 2>/dev/null
    sleep 2
    if systemctl is-active elite-x-bandwidth >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
    
    echo -n "Starting Connection Monitor... "
    systemctl enable elite-x-monitor.service 2>/dev/null
    systemctl start elite-x-monitor.service 2>/dev/null
    sleep 2
    if systemctl is-active elite-x-monitor >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${YELLOW}⚠️${NC}"
    fi
}

# ========== MAIN INSTALLATION ==========
show_banner
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

ensure_key_files

echo -e "${GREEN}✅ Activation successful!${NC}"
sleep 1

if [ -f "$ACTIVATION_TYPE_FILE" ] && [ "$(cat "$ACTIVATION_TYPE_FILE")" = "temporary" ]; then
    echo -e "${YELLOW}⚠️  Trial version activated - expires in 2 days${NC}"
fi
sleep 2

set_timezone

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

echo "==> ELITE-X V3.5 INSTALLATION STARTING..."

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
            echo -e "  Removing old user: $username"
            pkill -u "$username" 2>/dev/null || true
            sleep 2
            userdel -f -r "$username" 2>/dev/null || true
        fi
    done
fi

pkill -f dnstt-server 2>/dev/null || true
pkill -f dnstt-edns-proxy 2>/dev/null || true
pkill -f elite-x-traffic 2>/dev/null || true
pkill -f elite-x-cleaner 2>/dev/null || true
pkill -f elite-x-bandwidth 2>/dev/null || true
pkill -f elite-x-monitor 2>/dev/null || true

systemctl stop dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-bandwidth elite-x-monitor 2>/dev/null || true
systemctl disable dnstt-elite-x dnstt-elite-x-proxy elite-x-traffic elite-x-cleaner elite-x-bandwidth elite-x-monitor 2>/dev/null || true

rm -rf /etc/systemd/system/dnstt-elite-x*
rm -rf /etc/systemd/system/elite-x-*
rm -rf /etc/dnstt /etc/elite-x
rm -f /usr/local/bin/dnstt-*
rm -f /usr/local/bin/elite-x*

sed -i '/^Banner/d' /etc/ssh/sshd_config
systemctl restart sshd

rm -f /etc/profile.d/elite-x-dashboard.sh
sed -i '/elite-x/d' ~/.bashrc 2>/dev/null || true
sed -i '/ELITE_X_SHOWN/d' ~/.bashrc 2>/dev/null || true

rm -f /etc/cron.hourly/elite-x-expiry
rm -f /etc/cron.daily/elite-x-backup
rm -f /etc/cron.hourly/elite-x-bandwidth

echo -e "${GREEN}✅ Previous installation cleaned${NC}"
sleep 2

# Create directories
mkdir -p /etc/elite-x/{banner,users,traffic,deleted_users}
echo "$TDOMAIN" > /etc/elite-x/subdomain

# Create banners
cat > /etc/elite-x/banner/default <<'EOF'
===============================================
      WELCOME TO ELITE-X VPN SERVICE
===============================================
     High Speed • Secure • Unlimited
===============================================
EOF

cat > /etc/elite-x/banner/ssh-banner <<'EOF'
===============================================
           ELITE-X VPN SERVICE             
    High Speed • Secure • Unlimited      
===============================================
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
  systemctl restart systemd-resolved 2>/dev/null || true
  
  echo "nameserver 8.8.8.8" > /etc/resolv.conf 2>/dev/null || echo "nameserver 8.8.8.8" | tee /etc/resolv.conf >/dev/null
  echo "nameserver 8.8.4.4" >> /etc/resolv.conf 2>/dev/null || echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf >/dev/null
fi

echo "Installing dependencies..."
apt update -y
apt install -y curl python3 jq nano iptables iptables-persistent ethtool dnsutils net-tools

# Setup all components
setup_dnstt_server
setup_edns_proxy
setup_traffic_monitor
setup_auto_remover
setup_bandwidth_monitor
setup_auto_backup
setup_user_manager
setup_main_menu

# Configure firewall
command -v ufw >/dev/null && ufw allow 22/tcp && ufw allow 53/udp || true

ensure_key_files

# Start all services
start_all_services

# Network interface optimizations
for iface in $(ls /sys/class/net/ | grep -v lo 2>/dev/null); do
    ethtool -K $iface tx off sg off tso off 2>/dev/null || true
done

# Cache network information
IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unknown")
echo "$IP" > /etc/elite-x/cached_ip

if [ "$IP" != "Unknown" ]; then
    LOCATION_INFO=$(curl -s http://ip-api.com/json/$IP 2>/dev/null)
    echo "$LOCATION_INFO" | jq -r '.city + ", " + .country' 2>/dev/null > /etc/elite-x/cached_location || echo "Unknown" > /etc/elite-x/cached_location
    echo "$LOCATION_INFO" | jq -r '.isp' 2>/dev/null > /etc/elite-x/cached_isp || echo "Unknown" > /etc/elite-x/cached_isp
fi

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

# Add aliases to bashrc
cat >> ~/.bashrc <<'EOF'
alias menu='elite-x'
alias elitex='elite-x'
alias user='elite-x-user'
alias online='elite-x-user --online'
alias traffic='elite-x-user --traffic'
EOF

# Create expiry cron job
cat > /etc/cron.hourly/elite-x-expiry <<'EOF'
#!/bin/bash
if [ -f /usr/local/bin/elite-x ]; then
    /usr/local/bin/elite-x --check-expiry
fi
EOF
chmod +x /etc/cron.hourly/elite-x-expiry

# Create initial backup
/usr/local/bin/elite-x-backup 2>/dev/null || true

ensure_key_files

# Installation complete
clear
echo "╔════════════════════════════════════╗"
echo " ELITE-X V3.5 INSTALLED SUCCESSFULLY "
echo "╠════════════════════════════════════╣"
echo "   Advanced • Secure • Ultra Fast    "
echo "╚════════════════════════════════════╝"
EXPIRY_INFO=$(cat /etc/elite-x/expiry 2>/dev/null || echo "Lifetime")
FINAL_MTU=$(cat /etc/elite-x/mtu 2>/dev/null || echo "1800")
ACTIVATION_KEY=$(cat /etc/elite-x/key 2>/dev/null || echo "ELITEX-2026-DAN-4D-08")
echo "DOMAIN  : ${TDOMAIN}"
echo "LOCATION: ${SELECTED_LOCATION}"
echo "MTU     : ${FINAL_MTU}"
echo "KEY     : ${ACTIVATION_KEY}"
echo "EXPIRE  : ${EXPIRY_INFO}"
echo "╚════════════════════════════════════╝"
show_quote

echo -e "\n${CYAN}Final Service Status:${NC}"
sleep 2
systemctl is-active dnstt-elite-x >/dev/null 2>&1 && echo -e "${GREEN}✅ DNSTT Server: Running${NC}" || echo -e "${RED}❌ DNSTT Server: Failed${NC}"
systemctl is-active dnstt-elite-x-proxy >/dev/null 2>&1 && echo -e "${GREEN}✅ DNSTT Proxy: Running${NC}" || echo -e "${RED}❌ DNSTT Proxy: Failed${NC}"
systemctl is-active elite-x-traffic >/dev/null 2>&1 && echo -e "${GREEN}✅ Traffic Monitor: Running${NC}" || echo -e "${RED}❌ Traffic Monitor: Failed${NC}"
systemctl is-active elite-x-cleaner >/dev/null 2>&1 && echo -e "${GREEN}✅ Auto Cleaner: Running${NC}" || echo -e "${RED}❌ Auto Cleaner: Failed${NC}"
systemctl is-active elite-x-bandwidth >/dev/null 2>&1 && echo -e "${GREEN}✅ Bandwidth Monitor: Running${NC}" || echo -e "${RED}❌ Bandwidth Monitor: Failed${NC}"
systemctl is-active elite-x-monitor >/dev/null 2>&1 && echo -e "${GREEN}✅ Connection Monitor: Running${NC}" || echo -e "${YELLOW}⚠️ Connection Monitor: Optional${NC}"

echo -e "\n${CYAN}Port Status:${NC}"
ss -uln | grep -q ":53 " && echo -e "${GREEN}✅ Port 53: Listening${NC}" || echo -e "${RED}❌ Port 53: Not listening${NC}"
ss -uln | grep -q ":${DNSTT_PORT} " && echo -e "${GREEN}✅ Port ${DNSTT_PORT}: Listening${NC}" || echo -e "${RED}❌ Port ${DNSTT_PORT}: Not listening${NC}"

echo -e "\n${GREEN}ELITE-X v3.5 Features:${NC}"
echo -e "  ${YELLOW}→${NC} User Login Limit (Max concurrent connections)"
echo -e "  ${YELLOW}→${NC} Renew User Option"
echo -e "  ${YELLOW}→${NC} REALTIME Traffic Monitoring ✓ WORKING"
echo -e "  ${YELLOW}→${NC} Auto Backup System"
echo -e "  ${YELLOW}→${NC} User Details with Traffic History"
echo -e "  ${YELLOW}→${NC} Multiple User Delete"
echo -e "  ${YELLOW}→${NC} Export Users List"
echo -e "  ${YELLOW}→${NC} Deleted Users Archive"
echo -e "  ${YELLOW}→${NC} User Restore Function"
echo -e "  ${YELLOW}→${NC} Online Users Report"
echo -e "  ${YELLOW}→${NC} User Activity Log"
echo -e "  ${YELLOW}→${NC} Complete Uninstall (removes all users & data)"

echo ""
read -p "Open menu now? (y/n): " open
if [ "$open" = "y" ] || [ "$open" = "Y" ]; then
    echo -e "${GREEN}Opening dashboard...${NC}"
    sleep 1
    /usr/local/bin/elite-x
else
    echo -e "${YELLOW}You can type 'menu' or 'elite-x' anytime to open the dashboard.${NC}"
    echo -e "${YELLOW}Other commands: user, online, traffic${NC}"
fi

# Clean up installation script but keep the menu
if [ -f "$0" ] && [ "$0" != "/usr/local/bin/elite-x" ]; then
    rm -f "$0" 2>/dev/null || true
fi
