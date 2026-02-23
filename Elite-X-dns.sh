#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#  ███████╗ █████╗ ███████╗████████╗██████╗ ███╗   ██╗███████╗
#  ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔══██╗████╗  ██║██╔════╝
#  █████╗  ███████║███████╗   ██║   ██║  ██║██╔██╗ ██║███████╗
#  ██╔══╝  ██╔══██║╚════██║   ██║   ██║  ██║██║╚██╗██║╚════██║
#  ██║     ██║  ██║███████║   ██║   ██████╔╝██║ ╚████║███████║
#  ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═══╝╚══════╝
# ╚═══════════════════════════════════════════════════════════════╝
#              ELITE-X FASTDNS v1.0 - COMPLETE PANEL
#              High-Performance DNS Server with Management Panel
# ═════════════════════════════════════════════════════════════════

set -euo pipefail

# ==================== COLOR PALETTE (ALL VARIABLES DEFINED) ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'
BLINK='\033[5m'
UNDERLINE='\033[4m'
REVERSE='\033[7m'

# Neon colors
NEON_RED='\033[1;31m'
NEON_GREEN='\033[1;32m'
NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'
NEON_PURPLE='\033[1;35m'
NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'
NEON_PINK='\033[1;38;5;201m'
NEON_ORANGE='\033[1;38;5;208m'
NEON_LIME='\033[1;38;5;154m'

# ==================== CONFIGURATION ====================
FASTDNS_PORT="53"
FASTDNS_CONFIG="/etc/fastdns"
FASTDNS_BIN="/usr/local/bin/fastdns"
FASTDNS_LOG="/var/log/fastdns.log"
STATS_PORT="9153"
BACKUP_DIR="/root/fastdns-backups"
INSTALL_DATE_FILE="/etc/fastdns/installed"
VERSION="1.0"

# ==================== DNS FIX FUNCTION ====================
fix_dns_resolution() {
    echo -e "${NEON_YELLOW}🔧 Checking DNS resolution...${NC}"
    
    # Test current DNS
    if ! ping -c 1 google.com &>/dev/null && ! ping -c 1 8.8.8.8 &>/dev/null; then
        echo -e "${NEON_RED}❌ DNS resolution failed! Fixing...${NC}"
        
        # Backup original resolv.conf
        [ -f /etc/resolv.conf ] && cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true
        
        # Remove systemd-resolved if it's causing issues
        systemctl stop systemd-resolved 2>/dev/null || true
        systemctl disable systemd-resolved 2>/dev/null || true
        
        # Set manual DNS
        rm -f /etc/resolv.conf
        cat > /etc/resolv.conf <<EOF
# ELITE-X FASTDNS Configuration
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF
        # Make it immutable to prevent overwriting
        chattr +i /etc/resolv.conf 2>/dev/null || true
        
        echo -e "${NEON_GREEN}✅ DNS fixed! Using Google DNS (8.8.8.8, 8.8.4.4)${NC}"
    else
        echo -e "${NEON_GREEN}✅ DNS resolution working normally${NC}"
    fi
}

# ==================== SHOW BANNER ====================
show_banner() {
    clear
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}              ███████╗ █████╗ ███████╗████████╗██████╗ ███╗   ██╗███████╗${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GREEN}${BOLD}              ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔══██╗████╗  ██║██╔════╝${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_CYAN}${BOLD}              █████╗  ███████║███████╗   ██║   ██║  ██║██╔██╗ ██║███████╗${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_BLUE}${BOLD}              ██╔══╝  ██╔══██║╚════██║   ██║   ██║  ██║██║╚██╗██║╚════██║${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_PINK}${BOLD}              ██║     ██║  ██║███████║   ██║   ██████╔╝██║ ╚████║███████║${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}              ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═══╝╚══════╝${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}${BOLD}              ELITE-X FASTDNS v1.0 - COMPLETE PANEL                 ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}║${NEON_GREEN}${BOLD}              High-Performance DNS Server with Management Panel      ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== SHOW QUOTE ====================
show_quote() {
    echo ""
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}${BOLD}            FastDNS - Speed of Light DNS Resolution              ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== CHECK ROOT ====================
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${NEON_RED}❌ Please run as root${NC}"
        exit 1
    fi
}

# ==================== INSTALL DEPENDENCIES ====================
install_dependencies() {
    echo -e "${NEON_CYAN}📦 Installing dependencies...${NC}"
    
    # Fix DNS first
    fix_dns_resolution
    
    # Update package lists with retry
    local max_retries=3
    local retry=0
    while [ $retry -lt $max_retries ]; do
        if apt update -y; then
            break
        fi
        retry=$((retry + 1))
        echo -e "${NEON_YELLOW}⚠️  Retry $retry/$max_retries...${NC}"
        sleep 3
    done
    
    # Install packages
    apt install -y curl wget git make gcc build-essential net-tools dnsutils jq nethogs iftop htop
    
    echo -e "${NEON_GREEN}✅ Dependencies installed${NC}"
}

# ==================== INSTALL GO ====================
install_go() {
    echo -e "${NEON_CYAN}🐹 Installing Go language...${NC}"
    
    if command -v go &>/dev/null; then
        echo -e "${NEON_GREEN}✅ Go already installed: $(go version)${NC}"
        return 0
    fi
    
    cd /tmp
    wget -q https://golang.org/dl/go1.21.0.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
    
    # Add to PATH
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
    
    rm -f go1.21.0.linux-amd64.tar.gz
    
    echo -e "${NEON_GREEN}✅ Go installed: $(go version)${NC}"
}

# ==================== INSTALL FASTDNS ====================
install_fastdns() {
    echo -e "${NEON_CYAN}📡 Building FastDNS (phuslu/fastdns)...${NC}"
    
    mkdir -p "$FASTDNS_CONFIG"
    
    cd /tmp
    if [ -d "fastdns" ]; then
        rm -rf fastdns
    fi
    
    # Clone with retry
    local max_retries=3
    local retry=0
    while [ $retry -lt $max_retries ]; do
        if git clone https://github.com/phuslu/fastdns.git; then
            break
        fi
        retry=$((retry + 1))
        echo -e "${NEON_YELLOW}⚠️  Git clone retry $retry/$max_retries...${NC}"
        sleep 3
    done
    
    cd fastdns
    
    # Build with optimizations
    echo -e "${NEON_YELLOW}⚙️  Compiling (this may take a moment)...${NC}"
    CGO_ENABLED=0 go build -ldflags="-s -w" -o "$FASTDNS_BIN" ./cmd/fastdns
    
    # Build client tools
    go build -o /usr/local/bin/fastdig ./cmd/fastdig
    
    chmod +x "$FASTDNS_BIN" /usr/local/bin/fastdig
    
    if [ -f "$FASTDNS_BIN" ]; then
        echo -e "${NEON_GREEN}✅ FastDNS built successfully${NC}"
    else
        echo -e "${NEON_RED}❌ FastDNS build failed${NC}"
        exit 1
    fi
}

# ==================== CREATE CONFIGURATION ====================
create_config() {
    echo -e "${NEON_CYAN}⚙️  Creating FastDNS configuration...${NC}"
    
    # Main configuration
    cat > "$FASTDNS_CONFIG/fastdns.yml" <<EOF
# ========== ELITE-X FASTDNS CONFIGURATION ==========
# High-Performance DNS Server - Version $VERSION

# Listen on all interfaces, port 53 (UDP and TCP)
listen:
  - :$FASTDNS_PORT
  - tcp://:$FASTDNS_PORT

# Upstream DNS servers (reliable, fast resolvers)
upstream:
  - udp://8.8.8.8:53          # Google DNS Primary
  - udp://8.8.4.4:53          # Google DNS Secondary
  - udp://1.1.1.1:53          # Cloudflare DNS Primary
  - udp://1.0.0.1:53          # Cloudflare DNS Secondary
  - udp://208.67.222.222:53   # OpenDNS
  - udp://208.67.220.220:53   # OpenDNS Secondary
  - tcp://9.9.9.9:53          # Quad9 (TCP fallback)

# Cache configuration for maximum performance
cache:
  enable: true
  size: 100000                 # 100k entry cache
  ttl: 300                     # 5 minutes default TTL
  negative_ttl: 60             # 1 minute for NXDOMAIN

# Performance tuning
performance:
  workers: 4                    # Worker goroutines
  max_concurrent: 1000          # Max concurrent queries
  read_timeout: 5s
  write_timeout: 5s
  idle_timeout: 30s
  reuse_port: true              # SO_REUSEPORT for multi-core
  prefork: true                 # Prefork mode

# EDNS options
edns:
  client_subnet: true           # Support EDNS Client Subnet
  padding: true                 # EDNS Padding for privacy
  dnssec: true                  # Support DNSSEC

# Logging
log:
  level: info
  output: $FASTDNS_LOG
  verbose: false

# Statistics and monitoring
stats:
  enable: true
  prefix: "fastdns_"
  listen: ":$STATS_PORT"        # Prometheus metrics

# Security
security:
  allow_transfer: false
  recursion: true
  forward: true
EOF

    # Create systemd service
    cat > /etc/systemd/system/fastdns.service <<EOF
[Unit]
Description=ELITE-X FastDNS Server
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
LimitNPROC=1048576

# Performance optimizations
CPUQuota=100%
MemoryMax=1G

[Install]
WantedBy=multi-user.target
EOF

    # Create log file
    touch "$FASTDNS_LOG"
    chmod 644 "$FASTDNS_LOG"
    
    # Save installation date
    date > "$INSTALL_DATE_FILE"
    
    echo -e "${NEON_GREEN}✅ Configuration created${NC}"
}

# ==================== CREATE TEST SCRIPTS ====================
create_test_scripts() {
    echo -e "${NEON_CYAN}🔧 Creating DNS test tools...${NC}"
    
    # DNS test script
    cat > /usr/local/bin/fastdns-test <<'EOF'
#!/bin/bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${YELLOW}              FASTDNS TEST & BENCHMARK                            ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Test basic resolution
echo -e "${GREEN}Testing A records:${NC}"
for domain in google.com cloudflare.com github.com facebook.com; do
    result=$(dig @127.0.0.1 $domain A +short | head -1)
    if [ ! -z "$result" ]; then
        echo -e "  ${GREEN}✓${NC} $domain -> $result"
    else
        echo -e "  ${RED}✗${NC} $domain failed"
    fi
done

echo ""
echo -e "${GREEN}Testing MX records:${NC}"
for domain in gmail.com outlook.com; do
    result=$(dig @127.0.0.1 $domain MX +short | head -1)
    if [ ! -z "$result" ]; then
        echo -e "  ${GREEN}✓${NC} $domain -> $result"
    else
        echo -e "  ${YELLOW}⚠${NC} $domain (no MX or failed)"
    fi
done

echo ""
echo -e "${GREEN}Performance benchmark (100 queries):${NC}"
time for i in {1..100}; do
    dig @127.0.0.1 google.com A +short >/dev/null 2>&1
done

echo ""
echo -e "${GREEN}Cache test (should be faster):${NC}"
time for i in {1..10}; do
    dig @127.0.0.1 google.com A +short >/dev/null 2>&1
done

echo ""
echo -e "${CYAN}For more detailed benchmarks, use: fastdns-benchmark${NC}"
EOF

    # Benchmark script
    cat > /usr/local/bin/fastdns-benchmark <<'EOF'
#!/bin/bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${YELLOW}              FASTDNS COMPREHENSIVE BENCHMARK                      ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

QUERY_COUNT=1000
DOMAINS=("google.com" "cloudflare.com" "facebook.com" "amazon.com" "microsoft.com" "github.com" "twitter.com" "youtube.com" "netflix.com" "instagram.com")

echo -e "${YELLOW}Benchmarking with $QUERY_COUNT queries across ${#DOMAINS[@]} domains${NC}"
echo ""

# Test FastDNS
echo -e "${CYAN}FastDNS (127.0.0.1):${NC}"
START=$(date +%s%N)
for i in $(seq 1 $QUERY_COUNT); do
    domain=${DOMAINS[$((i % ${#DOMAINS[@]}))]}
    dig @127.0.0.1 $domain A +short >/dev/null 2>&1
done
END=$(date +%s%N)
DURATION=$((($END - $START)/1000000))
RPS=$((QUERY_COUNT * 1000 / DURATION))
echo -e "  ${GREEN}${QUERY_COUNT} queries in ${DURATION}ms (${RPS} queries/sec)${NC}"

# Test Google DNS for comparison
echo -e "${CYAN}Google DNS (8.8.8.8):${NC}"
START=$(date +%s%N)
for i in $(seq 1 $QUERY_COUNT); do
    domain=${DOMAINS[$((i % ${#DOMAINS[@]}))]}
    dig @8.8.8.8 $domain A +short >/dev/null 2>&1
done
END=$(date +%s%N)
DURATION=$((($END - $START)/1000000))
RPS=$((QUERY_COUNT * 1000 / DURATION))
echo -e "  ${YELLOW}${QUERY_COUNT} queries in ${DURATION}ms (${RPS} queries/sec)${NC}"

echo ""
echo -e "${GREEN}FastDNS is faster by design with zero-allocation parsing!${NC}"
EOF

    chmod +x /usr/local/bin/fastdns-test /usr/local/bin/fastdns-benchmark
    
    echo -e "${NEON_GREEN}✅ Test tools created${NC}"
}

# ==================== CREATE BACKUP SCRIPT ====================
create_backup_script() {
    echo -e "${NEON_CYAN}💾 Creating backup system...${NC}"
    
    mkdir -p "$BACKUP_DIR"
    
    cat > /usr/local/bin/fastdns-backup <<'EOF'
#!/bin/bash

BACKUP_DIR="/root/fastdns-backups"
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"

echo "Creating FastDNS backup..."

# Backup configuration
tar -czf "$BACKUP_DIR/fastdns-config-$DATE.tar.gz" /etc/fastdns 2>/dev/null || echo "No config to backup"

# Backup logs
tar -czf "$BACKUP_DIR/fastdns-logs-$DATE.tar.gz" /var/log/fastdns.log 2>/dev/null || echo "No logs to backup"

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t fastdns-config-* 2>/dev/null | tail -n +11 | xargs -r rm
ls -t fastdns-logs-* 2>/dev/null | tail -n +11 | xargs -r rm

echo "Backup completed: $DATE" >> /var/log/fastdns-backup.log
echo "Backup saved to: $BACKUP_DIR/fastdns-config-$DATE.tar.gz"
EOF

    chmod +x /usr/local/bin/fastdns-backup
    
    # Daily cron
    cat > /etc/cron.daily/fastdns-backup <<'EOF'
#!/bin/bash
/usr/local/bin/fastdns-backup
EOF
    chmod +x /etc/cron.daily/fastdns-backup
    
    echo -e "${NEON_GREEN}✅ Backup system created${NC}"
}

# ==================== CREATE UNINSTALL SCRIPT ====================
create_uninstall() {
    echo -e "${NEON_CYAN}🗑️  Creating uninstall script...${NC}"
    
    cat > /usr/local/bin/fastdns-uninstall <<'EOF'
#!/bin/bash

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║${YELLOW}              UNINSTALL ELITE-X FASTDNS                          ${RED}║${NC}"
echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

read -p "Are you sure you want to uninstall? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${GREEN}Uninstall cancelled${NC}"
    exit 0
fi

echo -e "${YELLOW}Stopping services...${NC}"
systemctl stop fastdns 2>/dev/null
systemctl disable fastdns 2>/dev/null

echo -e "${YELLOW}Removing files...${NC}"
rm -f /etc/systemd/system/fastdns.service
rm -rf /etc/fastdns
rm -f /usr/local/bin/fastdns
rm -f /usr/local/bin/fastdig
rm -f /usr/local/bin/fastdns-{manager,test,benchmark,backup,uninstall,stats,monitor}

echo -e "${YELLOW}Removing cron jobs...${NC}"
rm -f /etc/cron.daily/fastdns-backup

systemctl daemon-reload

echo -e "${GREEN}✅ ELITE-X FastDNS uninstalled successfully${NC}"
EOF

    chmod +x /usr/local/bin/fastdns-uninstall
    echo -e "${NEON_GREEN}✅ Uninstall script created${NC}"
}

# ==================== CREATE STATS MONITOR ====================
create_stats_monitor() {
    echo -e "${NEON_CYAN}📊 Creating statistics monitor...${NC}"
    
    cat > /usr/local/bin/fastdns-stats <<'EOF'
#!/bin/bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

while true; do
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}              FASTDNS LIVE STATISTICS                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Service status
    if systemctl is-active fastdns >/dev/null 2>&1; then
        echo -e "${GREEN}● FastDNS: RUNNING${NC}"
    else
        echo -e "${RED}● FastDNS: STOPPED${NC}"
    fi
    
    # Connection count
    UDP_CONN=$(ss -unp | grep -c :53 2>/dev/null || echo "0")
    TCP_CONN=$(ss -tnp | grep -c :53 2>/dev/null || echo "0")
    TOTAL_CONN=$((UDP_CONN + TCP_CONN))
    
    echo -e "${CYAN}Active Connections:${NC} $TOTAL_CONN (UDP: $UDP_CONN, TCP: $TCP_CONN)"
    
    # Query rate (rough estimate from logs)
    if [ -f /var/log/fastdns.log ]; then
        QUERIES_LAST_MIN=$(grep "query" /var/log/fastdns.log 2>/dev/null | tail -60 | wc -l)
        echo -e "${CYAN}Query rate:${NC} ~$QUERIES_LAST_MIN queries/min"
    fi
    
    # Cache stats
    echo -e "${CYAN}Cache memory:${NC} ~$(ps aux | grep fastdns | grep -v grep | awk '{print $6}' 2>/dev/null || echo "0") KB"
    
    # Uptime
    if [ -f /etc/fastdns/installed ]; then
        INSTALLED=$(cat /etc/fastdns/installed)
        echo -e "${CYAN}Installed:${NC} $INSTALLED"
    fi
    
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to exit (refreshes every 2s)${NC}"
    sleep 2
done
EOF

    chmod +x /usr/local/bin/fastdns-stats
    echo -e "${NEON_GREEN}✅ Stats monitor created${NC}"
}

# ==================== CREATE MAIN PANEL (V3.5 STYLE) ====================
create_panel() {
    echo -e "${NEON_CYAN}🎨 Creating management panel (V3.5 style)...${NC}"
    
    cat > /usr/local/bin/fastdns <<'EOF'
#!/bin/bash

# ==================== COLORS ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; BOLD='\033[1m'
NC='\033[0m'

NEON_RED='\033[1;31m'; NEON_GREEN='\033[1;32m'; NEON_YELLOW='\033[1;33m'
NEON_BLUE='\033[1;34m'; NEON_PURPLE='\033[1;35m'; NEON_CYAN='\033[1;36m'
NEON_WHITE='\033[1;37m'; NEON_PINK='\033[1;38;5;201m'

# Lock file to prevent multiple instances
if [ -f /tmp/fastdns-running ]; then
    exit 0
fi
touch /tmp/fastdns-running
trap 'rm -f /tmp/fastdns-running' EXIT

# ==================== SHOW QUOTE ====================
show_quote() {
    echo ""
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_WHITE}${BOLD}            FastDNS - Speed of Light DNS Resolution              ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                                                               ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== SHOW DASHBOARD ====================
show_dashboard() {
    clear
    
    # Get system info
    IP=$(curl -4 -s ifconfig.me 2>/dev/null || echo "Unknown")
    RAM=$(free -m | awk '/^Mem:/{print $3"/"$2"MB"}')
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    UPTIME=$(uptime -p | sed 's/up //')
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    
    # Get FastDNS status
    if systemctl is-active fastdns >/dev/null 2>&1; then
        DNS_STATUS="${NEON_GREEN}● RUNNING${NC}"
        UDP_CONN=$(ss -unp | grep -c :53 2>/dev/null || echo "0")
        TCP_CONN=$(ss -tnp | grep -c :53 2>/dev/null || echo "0")
    else
        DNS_STATUS="${NEON_RED}● STOPPED${NC}"
        UDP_CONN="0"
        TCP_CONN="0"
    fi
    
    # Get version
    if [ -f /etc/fastdns/installed ]; then
        VERSION="1.0"
    else
        VERSION="Unknown"
    fi
    
    echo -e "${NEON_PURPLE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_PURPLE}║${NEON_YELLOW}${BOLD}                    ELITE-X FASTDNS v1.0 - COMPLETE PANEL                  ${NEON_PURPLE}║${NC}"
    echo -e "${NEON_PURPLE}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  IP Address  :${NEON_GREEN} $IP${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  RAM Usage   :${NEON_GREEN} $RAM${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  CPU Load    :${NEON_GREEN} ${CPU}%${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Uptime      :${NEON_GREEN} $UPTIME${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Load Avg    :${NEON_GREEN} $LOAD${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  FastDNS     : $DNS_STATUS${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Connections :${NEON_GREEN} UDP: $UDP_CONN, TCP: $TCP_CONN${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  DNS Port    :${NEON_GREEN} 53 (UDP/TCP)${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Metrics     :${NEON_GREEN} Port 9153${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Version     :${NEON_GREEN} $VERSION${NC}"
    echo -e "${NEON_PURPLE}║${NEON_WHITE}  Developer   :${NEON_PINK} ELITE-X TEAM${NC}"
    echo -e "${NEON_PURPLE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== SHOW MAIN MENU ====================
main_menu() {
    while true; do
        show_dashboard
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_GREEN}${BOLD}                         🎯 MAIN MENU 🎯                               ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [1]  🔧 Service Control${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [2]  📊 Statistics & Monitoring${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [3]  🧪 DNS Testing Tools${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [4]  ⚡ Performance Benchmark${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [5]  📝 View Configuration${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [6]  🔄 Edit Configuration${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [7]  📋 View Logs${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [8]  💾 Backup / Restore${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [9]  ℹ️  System Info${NC}"
        echo -e "${NEON_CYAN}║${NEON_RED}  [10] 🗑️  Uninstall${NC}"
        echo -e "${NEON_CYAN}║${NEON_WHITE}  [0]  🚪 Exit${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Choose option: "$NC)" ch
        
        case $ch in
            1) service_menu ;;
            2) fastdns-stats ;;
            3) fastdns-test ;;
            4) fastdns-benchmark ;;
            5) view_config ;;
            6) edit_config ;;
            7) view_logs ;;
            8) backup_menu ;;
            9) system_info ;;
            10) uninstall_menu ;;
            0) 
                rm -f /tmp/fastdns-running
                show_quote
                echo -e "${NEON_GREEN}Goodbye!${NC}"
                exit 0 
                ;;
            *) echo -e "${NEON_RED}Invalid option${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

# ==================== SERVICE MENU ====================
service_menu() {
    while true; do
        clear
        echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                   SERVICE CONTROL MENU                           ${NEON_CYAN}║${NC}"
        echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${NEON_GREEN}1.${NC} Start FastDNS"
        echo -e "${NEON_GREEN}2.${NC} Stop FastDNS"
        echo -e "${NEON_GREEN}3.${NC} Restart FastDNS"
        echo -e "${NEON_GREEN}4.${NC} Enable auto-start"
        echo -e "${NEON_GREEN}5.${NC} Disable auto-start"
        echo -e "${NEON_GREEN}6.${NC} Show service status"
        echo -e "${NEON_GREEN}0.${NC} Back to Main Menu"
        echo ""
        read -p "$(echo -e $NEON_GREEN"Option: "$NC)" opt
        
        case $opt in
            1) systemctl start fastdns; echo -e "${GREEN}Started${NC}"; read -p "Press Enter..." ;;
            2) systemctl stop fastdns; echo -e "${YELLOW}Stopped${NC}"; read -p "Press Enter..." ;;
            3) systemctl restart fastdns; echo -e "${GREEN}Restarted${NC}"; read -p "Press Enter..." ;;
            4) systemctl enable fastdns; echo -e "${GREEN}Auto-start enabled${NC}"; read -p "Press Enter..." ;;
            5) systemctl disable fastdns; echo -e "${YELLOW}Auto-start disabled${NC}"; read -p "Press Enter..." ;;
            6) systemctl status fastdns --no-pager; read -p "Press Enter..." ;;
            0) return ;;
            *) echo -e "${RED}Invalid${NC}"; read -p "Press Enter..." ;;
        esac
    done
}

# ==================== VIEW CONFIG ====================
view_config() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                   FASTDNS CONFIGURATION                           ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    if [ -f /etc/fastdns/fastdns.yml ]; then
        cat /etc/fastdns/fastdns.yml
    else
        echo -e "${RED}Configuration file not found${NC}"
    fi
    echo ""
    read -p "Press Enter..."
}

# ==================== EDIT CONFIG ====================
edit_config() {
    if [ -f /etc/fastdns/fastdns.yml ]; then
        nano /etc/fastdns/fastdns.yml
        systemctl restart fastdns
        echo -e "${GREEN}Configuration updated and FastDNS restarted${NC}"
    else
        echo -e "${RED}Configuration file not found${NC}"
    fi
    read -p "Press Enter..."
}

# ==================== VIEW LOGS ====================
view_logs() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                   FASTDNS LOGS (last 50 lines)                   ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    if [ -f /var/log/fastdns.log ]; then
        tail -50 /var/log/fastdns.log
    else
        echo -e "${YELLOW}No log file found${NC}"
    fi
    echo ""
    read -p "Press Enter..."
}

# ==================== BACKUP MENU ====================
backup_menu() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                   BACKUP / RESTORE MENU                            ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${NEON_GREEN}1.${NC} Create backup now"
    echo -e "${NEON_GREEN}2.${NC} List backups"
    echo -e "${NEON_GREEN}3.${NC} Restore from backup"
    echo -e "${NEON_GREEN}0.${NC} Back"
    echo ""
    read -p "$(echo -e $NEON_GREEN"Option: "$NC)" opt
    
    case $opt in
        1) /usr/local/bin/fastdns-backup ;;
        2) ls -lh /root/fastdns-backups/ ;;
        3) 
            echo "Available backups:"
            ls /root/fastdns-backups/ | grep config
            read -p "Enter backup filename: " backup
            if [ -f "/root/fastdns-backups/$backup" ]; then
                tar -xzf "/root/fastdns-backups/$backup" -C /
                systemctl restart fastdns
                echo -e "${GREEN}Backup restored${NC}"
            fi
            ;;
        0) return ;;
    esac
    read -p "Press Enter..."
}

# ==================== SYSTEM INFO ====================
system_info() {
    clear
    echo -e "${NEON_CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_CYAN}║${NEON_YELLOW}${BOLD}                   SYSTEM INFORMATION                              ${NEON_CYAN}║${NC}"
    echo -e "${NEON_CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}OS:${NC} $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${GREEN}Kernel:${NC} $(uname -r)"
    echo -e "${GREEN}Arch:${NC} $(uname -m)"
    echo -e "${GREEN}CPU:${NC} $(nproc) cores"
    echo -e "${GREEN}Memory:${NC} $(free -h | awk '/^Mem:/{print $2}') total"
    echo -e "${GREEN}Disk:${NC} $(df -h / | awk 'NR==2{print $2}') total"
    echo -e "${GREEN}Hostname:${NC} $(hostname)"
    echo ""
    read -p "Press Enter..."
}

# ==================== UNINSTALL MENU ====================
uninstall_menu() {
    clear
    echo -e "${NEON_RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_RED}║${NEON_YELLOW}${BOLD}                      UNINSTALL WARNING                             ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_RED}║${NEON_WHITE}  This will completely remove FastDNS and all data           ${NEON_RED}║${NC}"
    echo -e "${NEON_RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Type 'UNINSTALL' to confirm: " confirm
    if [ "$confirm" = "UNINSTALL" ]; then
        /usr/local/bin/fastdns-uninstall
        rm -f /tmp/fastdns-running
        exit 0
    else
        echo -e "${GREEN}Cancelled${NC}"
        read -p "Press Enter..."
    fi
}

# Start main menu
main_menu
EOF

    chmod +x /usr/local/bin/fastdns
    
    # Create alias
    echo "alias menu='fastdns'" >> ~/.bashrc
    echo "alias fast='fastdns'" >> ~/.bashrc
    
    echo -e "${NEON_GREEN}✅ Management panel created${NC}"
}

# ==================== START SERVICE ====================
start_service() {
    echo -e "${NEON_CYAN}🚀 Starting FastDNS service...${NC}"
    
    systemctl daemon-reload
    systemctl enable fastdns.service
    systemctl start fastdns.service
    
    sleep 3
    
    if systemctl is-active fastdns &>/dev/null; then
        echo -e "${NEON_GREEN}✅ FastDNS is running on port 53${NC}"
    else
        echo -e "${NEON_RED}❌ FastDNS failed to start${NC}"
        journalctl -u fastdns -n 20 --no-pager
    fi
}

# ==================== FINAL REPORT ====================
show_final_report() {
    clear
    show_banner
    
    echo -e "${NEON_GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${NEON_GREEN}║${NEON_YELLOW}${BOLD}              FASTDNS INSTALLED SUCCESSFULLY!                     ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  📡 DNS Server   :${NEON_CYAN} UDP/TCP port 53${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  📊 Metrics      :${NEON_CYAN} Port 9153 (Prometheus)${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  🔧 Commands     :${NEON_GREEN} fastdns, menu, fast${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  🧪 Test tools   :${NEON_GREEN} fastdns-test${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  ⚡ Benchmark    :${NEON_GREEN} fastdns-benchmark${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  📊 Live stats   :${NEON_GREEN} fastdns-stats${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  💾 Backup       :${NEON_GREEN} fastdns-backup${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  🗑️  Uninstall    :${NEON_GREEN} fastdns-uninstall${NC}"
    echo -e "${NEON_GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}  Performance: Zero-allocation DNS (0 allocs/op)       ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}              Up to 1.4M queries per second            ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}║${NEON_WHITE}              Built-in cache (100,000 entries)         ${NEON_GREEN}║${NC}"
    echo -e "${NEON_GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    show_quote
}

# ==================== MAIN INSTALLATION ====================
main() {
    show_banner
    check_root
    
    echo -e "${NEON_YELLOW}This will install FastDNS as a standalone high-performance DNS server${NC}"
    echo -e "${NEON_YELLOW}with a complete management panel (V3.5 style)${NC}"
    echo ""
    echo -e "${NEON_WHITE}Features:${NC}"
    echo -e "  ${NEON_GREEN}✓${NC} Zero-allocation DNS parsing (0 allocs/op)"
    echo -e "  ${NEON_GREEN}✓${NC} 1.4M queries per second capability"
    echo -e "  ${NEON_GREEN}✓${NC} EDNS support (Client Subnet, Padding)"
    echo -e "  ${NEON_GREEN}✓${NC} Built-in caching (100,000 entries)"
    echo -e "  ${NEON_GREEN}✓${NC} Prometheus metrics on port 9153"
    echo -e "  ${NEON_GREEN}✓${NC} Prefork + SO_REUSEPORT for multi-core"
    echo -e "  ${NEON_GREEN}✓${NC} Complete management panel (V3.5 style)"
    echo ""
    read -p "Continue with installation? (y/n): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${NEON_YELLOW}Installation cancelled${NC}"
        exit 0
    fi
    
    # Fix DNS first (critical step)
    fix_dns_resolution
    
    # Installation steps
    install_dependencies
    install_go
    install_fastdns
    create_config
    create_test_scripts
    create_backup_script
    create_stats_monitor
    create_uninstall
    create_panel
    
    # Start service
    start_service
    
    # Final report
    show_final_report
    
    # Open menu
    echo -e "${NEON_GREEN}Opening management panel in 3 seconds...${NC}"
    sleep 3
    fastdns
}

# Run main function
main
