#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════╗
#              ELITE-X FASTDNS v1.0 - STANDALONE EDITION
#              High-Performance DNS Server - FastDNS Only
# ╚═══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ==================== COLOR PALETTE ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

# ==================== CONFIGURATION ====================
FASTDNS_PORT="53"
FASTDNS_CONFIG="/etc/fastdns"
FASTDNS_BIN="/usr/local/bin/fastdns"
FASTDNS_LOG="/var/log/fastdns.log"

# ==================== SHOW BANNER ====================
show_banner() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}              ELITE-X FASTDNS v1.0 - STANDALONE                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN}              High-Performance DNS Server (FastDNS Only)           ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==================== INSTALL DEPENDENCIES ====================
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    apt update -y
    apt install -y curl git make gcc build-essential
}

# ==================== INSTALL FASTDNS (phuslu/fastdns) ====================
install_fastdns() {
    echo -e "${CYAN}📡 Installing FastDNS (phuslu/fastdns)...${NC}"
    
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
    
    echo -e "${YELLOW}Building fastdns (zero-allocation DNS server)...${NC}"
    
    # Build with optimizations
    CGO_ENABLED=0 go build -ldflags="-s -w" -o "$FASTDNS_BIN" ./cmd/fastdns
    
    if [ ! -f "$FASTDNS_BIN" ]; then
        echo -e "${RED}Build failed, trying pre-compiled binary...${NC}"
        cd /tmp
        wget -q https://github.com/phuslu/fastdns/releases/latest/download/fastdns-linux-amd64 -O "$FASTDNS_BIN"
    fi
    
    chmod +x "$FASTDNS_BIN"
    
    # Verify installation
    if [ -f "$FASTDNS_BIN" ]; then
        echo -e "${GREEN}✅ FastDNS built successfully${NC}"
    else
        echo -e "${RED}❌ FastDNS installation failed${NC}"
        exit 1
    fi
}

# ==================== CREATE FASTDNS CONFIGURATION ====================
create_config() {
    echo -e "${CYAN}Creating FastDNS configuration...${NC}"
    
    # Create YAML configuration [citation:3][citation:7]
    cat > "$FASTDNS_CONFIG/fastdns.yml" <<EOF
# FastDNS Configuration - High-Performance DNS Server
# Features: Zero-allocation, 1.4M QPS capable, EDNS support [citation:3][citation:7]

# Listen on all interfaces, port 53 (UDP and TCP)
listen:
  - :$FASTDNS_PORT           # UDP
  - tcp://:$FASTDNS_PORT     # TCP

# Upstream DNS servers (for recursive resolution) [citation:7]
upstream:
  - udp://8.8.8.8:53         # Google DNS
  - udp://8.8.4.4:53         # Google DNS Secondary
  - udp://1.1.1.1:53         # Cloudflare DNS
  - udp://1.0.0.1:53         # Cloudflare DNS Secondary
  - tcp://208.67.222.222:53  # OpenDNS (TCP fallback)

# Cache settings for performance [citation:1][citation:2]
cache:
  enable: true                # Enable DNS caching
  size: 100000                # Cache up to 100,000 entries
  ttl: 300                    # Default TTL for cached entries
  negative_ttl: 60            # TTL for negative responses (NXDOMAIN)

# Performance tuning [citation:7]
performance:
  workers: 4                  # Number of worker goroutines
  max_concurrent: 1000        # Maximum concurrent queries
  read_timeout: 5s            # Read timeout
  write_timeout: 5s           # Write timeout
  idle_timeout: 30s           # Idle connection timeout
  reuse_port: true            # Enable SO_REUSEPORT for multi-core [citation:6]
  prefork: true               # Enable prefork mode [citation:6]

# EDNS options support [citation:5]
edns:
  client_subnet: true         # Support EDNS Client Subnet
  padding: true               # Support EDNS Padding for privacy
  dnssec: true                # Support DNSSEC

# Logging [citation:2]
log:
  level: info                  # Log level: debug, info, warn, error
  output: $FASTDNS_LOG
  verbose: false

# Statistics for monitoring [citation:3][citation:7]
stats:
  enable: true
  prefix: "fastdns_"
  listen: ":9153"              # Prometheus metrics endpoint
EOF

    # Create systemd service
    cat > /etc/systemd/system/fastdns.service <<EOF
[Unit]
Description=FastDNS High-Performance DNS Server
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

# CPU and memory optimizations [citation:6]
CPUQuota=100%
MemoryMax=1G

[Install]
WantedBy=multi-user.target
EOF

    # Create log file
    touch "$FASTDNS_LOG"
    chmod 644 "$FASTDNS_LOG"
    
    echo -e "${GREEN}✅ FastDNS configuration created${NC}"
}

# ==================== CREATE CLIENT TOOL ====================
create_client_tool() {
    echo -e "${CYAN}Building fastdig client tool...${NC}"
    
    cd /tmp/fastdns
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/fastdig ./cmd/fastdig
    chmod +x /usr/local/bin/fastdig
    
    cat > /usr/local/bin/dns-test <<'EOF'
#!/bin/bash
# Simple DNS testing script

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${YELLOW}Testing FastDNS server...${NC}"
echo ""

# Test A record
echo -e "${GREEN}Testing A record (google.com):${NC}"
dig @127.0.0.1 google.com A +short

echo ""
echo -e "${GREEN}Testing A record (cloudflare.com):${NC}"
dig @127.0.0.1 cloudflare.com A +short

echo ""
echo -e "${GREEN}Testing MX record (gmail.com):${NC}"
dig @127.0.0.1 gmail.com MX +short | head -3

echo ""
echo -e "${GREEN}Performance test (10 queries):${NC}"
time for i in {1..10}; do
    dig @127.0.0.1 google.com A +short >/dev/null 2>&1
done

echo ""
echo -e "${GREEN}Using fastdig client:${NC}"
fastdig google.com A @127.0.0.1
EOF
    chmod +x /usr/local/bin/dns-test
    
    echo -e "${GREEN}✅ Client tools built: fastdig, dns-test${NC}"
}

# ==================== CONFIGURE SYSTEM ====================
configure_system() {
    echo -e "${CYAN}Configuring system for FastDNS...${NC}"
    
    # Stop systemd-resolved if running (it uses port 53)
    if systemctl is-active systemd-resolved &>/dev/null; then
        echo -e "${YELLOW}Stopping systemd-resolved (releases port 53)...${NC}"
        systemctl stop systemd-resolved
        systemctl disable systemd-resolved
    fi
    
    # Kill any process using port 53
    fuser -k 53/udp 2>/dev/null || true
    fuser -k 53/tcp 2>/dev/null || true
    
    # Set system DNS to use local FastDNS (optional)
    cat > /etc/resolv.conf <<EOF
# Generated by ELITE-X FastDNS
nameserver 127.0.0.1
nameserver 8.8.8.8
EOF
    
    # Optimize kernel for high-performance DNS [citation:7]
    cat >> /etc/sysctl.conf <<EOF

# FastDNS Optimizations
net.core.rmem_max = 268435456
net.core.wmem_max = 268435456
net.core.rmem_default = 134217728
net.core.wmem_default = 134217728
net.core.netdev_max_backlog = 50000
net.ipv4.udp_rmem_min = 131072
net.ipv4.udp_wmem_min = 131072
net.ipv4.tcp_rmem = 4096 87380 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
EOF
    
    sysctl -p 2>/dev/null || true
    
    echo -e "${GREEN}✅ System configured${NC}"
}

# ==================== START SERVICE ====================
start_service() {
    echo -e "${CYAN}Starting FastDNS service...${NC}"
    
    systemctl daemon-reload
    systemctl enable fastdns.service
    systemctl start fastdns.service
    
    sleep 3
    
    if systemctl is-active fastdns &>/dev/null; then
        echo -e "${GREEN}✅ FastDNS is running on port 53${NC}"
    else
        echo -e "${RED}❌ FastDNS failed to start${NC}"
        journalctl -u fastdns -n 20 --no-pager
        exit 1
    fi
}

# ==================== CREATE MANAGEMENT SCRIPT ====================
create_manager() {
    cat > /usr/local/bin/fastdns-manager <<'EOF'
#!/bin/bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

show_menu() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YELLOW}              FASTDNS MANAGEMENT TOOL                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} Show FastDNS Status"
    echo -e "${GREEN}2.${NC} Restart FastDNS"
    echo -e "${GREEN}3.${NC} View Logs"
    echo -e "${GREEN}4.${NC} Test DNS Resolution"
    echo -e "${GREEN}5.${NC} Run Performance Benchmark"
    echo -e "${GREEN}6.${NC} Show Statistics"
    echo -e "${GREEN}7.${NC} Edit Configuration"
    echo -e "${GREEN}0.${NC} Exit"
    echo ""
    read -p "$(echo -e $YELLOW"Choose option: "$NC)" opt
    
    case $opt in
        1)
            systemctl status fastdns --no-pager
            ;;
        2)
            systemctl restart fastdns
            echo -e "${GREEN}FastDNS restarted${NC}"
            ;;
        3)
            tail -50 /var/log/fastdns.log
            ;;
        4)
            /usr/local/bin/dns-test
            ;;
        5)
            echo -e "${YELLOW}Running benchmark (1000 queries)...${NC}"
            time for i in {1..1000}; do
                dig @127.0.0.1 google.com A +short >/dev/null 2>&1
            done
            ;;
        6)
            echo -e "${CYAN}FastDNS Statistics:${NC}"
            echo "-------------------"
            echo "Active Connections:"
            ss -unp | grep :53 | wc -l
            echo ""
            echo "Cache Statistics:"
            grep -i cache /var/log/fastdns.log | tail -10
            ;;
        7)
            nano /etc/fastdns/fastdns.yml
            systemctl restart fastdns
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    read -p "Press Enter..."
    show_menu
}

show_menu
EOF
    chmod +x /usr/local/bin/fastdns-manager
    
    # Create alias
    echo "alias fast='fastdns-manager'" >> ~/.bashrc
}

# ==================== CREATE UNINSTALL SCRIPT ====================
create_uninstall() {
    cat > /usr/local/bin/fastdns-uninstall <<'EOF'
#!/bin/bash

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${RED}Uninstalling FastDNS...${NC}"

systemctl stop fastdns
systemctl disable fastdns
rm -f /etc/systemd/system/fastdns.service

rm -rf /etc/fastdns
rm -f /usr/local/bin/fastdns
rm -f /usr/local/bin/fastdig
rm -f /usr/local/bin/dns-test
rm -f /usr/local/bin/fastdns-manager
rm -f /usr/local/bin/fastdns-uninstall

sed -i '/fast/d' ~/.bashrc

systemctl daemon-reload

echo -e "${GREEN}FastDNS uninstalled${NC}"
EOF
    chmod +x /usr/local/bin/fastdns-uninstall
}

# ==================== MAIN INSTALLATION ====================
main() {
    show_banner
    
    # Check root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run as root${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}This will install FastDNS as a standalone high-performance DNS server${NC}"
    echo -e "${YELLOW}Features: [citation:3][citation:7]${NC}"
    echo -e "  - Zero-allocation DNS parsing (0 allocs/op)"
    echo -e "  - 1.4M queries per second capability"
    echo -e "  - EDNS support (Client Subnet, Padding)"
    echo -e "  - Built-in caching (100,000 entries)"
    echo -e "  - Prometheus metrics on port 9153"
    echo -e "  - Prefork + SO_REUSEPORT for multi-core"
    echo ""
    read -p "Continue? (y/n): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    
    install_dependencies
    install_fastdns
    create_config
    create_client_tool
    configure_system
    start_service
    create_manager
    create_uninstall
    
    clear
    show_banner
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${YELLOW}              FASTDNS INSTALLED SUCCESSFULLY!                      ${GREEN}║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${WHITE}  📡 FastDNS: UDP port 53${NC}"
    echo -e "${GREEN}║${WHITE}  📊 Metrics: port 9153${NC}"
    echo -e "${GREEN}║${WHITE}  🔧 Commands:${NC}"
    echo -e "${GREEN}║${WHITE}     fastdns-manager - Management menu${NC}"
    echo -e "${GREEN}║${WHITE}     fast - Quick management${NC}"
    echo -e "${GREEN}║${WHITE}     dns-test - Test DNS resolution${NC}"
    echo -e "${GREEN}║${WHITE}     fastdig - Advanced DNS client${NC}"
    echo -e "${GREEN}║${WHITE}     fastdns-uninstall - Remove FastDNS${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    # Test the installation
    echo -e "\n${YELLOW}Testing FastDNS...${NC}"
    sleep 2
    /usr/local/bin/dns-test
    
    echo -e "\n${GREEN}Opening management menu...${NC}"
    sleep 2
    /usr/local/bin/fastdns-manager
}

# Run main function
main
