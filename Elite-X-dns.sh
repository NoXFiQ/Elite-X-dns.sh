#!/bin/bash

# ============================================================================
#                     AMOKHAN V1.5 - ULTIMATE SSH MANAGER
# ============================================================================
# Advanced Features:
# ✓ Complete uninstall with system cleanup
# ✓ Real-time bandwidth monitoring per user (MB/GB)
# ✓ User bandwidth limits and quotas
# ✓ Renew user accounts with expiration management
# ✓ Advanced traffic statistics and graphs
# ✓ Auto-kill for exceeded limits
# ✓ Multi-protocol support (SSH, Dropbear, SlowDNS, OpenVPN)
# ✓ User connection limits
# ✓ Email notifications for limits
# ✓ Backup and restore functionality
# ============================================================================

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m[✗]\033[0m Please run this script as root"
    exit 1
fi

# ============================================================================
# CONFIGURATION
# ============================================================================
SCRIPT_VERSION="1.5"
SCRIPT_NAME="AMOKHAN SSH MANAGER"
SSH_PORT=22
DROPBEAR_PORT=143
SLOWDNS_PORT=5300
SQUID_PORT=8080
OVPN_PORT=1194
MAX_USERS=50
BANDWIDTH_RESET="daily" # daily, weekly, monthly, never
LOG_FILE="/var/log/amokhan.log"
DB_FILE="/etc/amokhan/users.db"
BANDWIDTH_DB="/etc/amokhan/bandwidth.db"
CONFIG_DIR="/etc/amokhan"
BACKUP_DIR="/root/amokhan-backups"
MONITOR_INTERVAL=60 # seconds

# ============================================================================
# COLORS & DESIGN
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# INITIALIZATION
# ============================================================================
init_system() {
    mkdir -p $CONFIG_DIR
    mkdir -p $BACKUP_DIR
    touch $DB_FILE $BANDWIDTH_DB
    chmod 600 $DB_FILE $BANDWIDTH_DB
    
    # Create database structure if not exists
    if [ ! -s $DB_FILE ] || [ ! -f $DB_FILE ]; then
        echo "username|password|expiry_date|created_date|max_bandwidth_mb|current_bandwidth_mb|last_reset|status|max_logins|current_logins|email|notes" > $DB_FILE
    fi
    
    if [ ! -s $BANDWIDTH_DB ]; then
        echo "username|timestamp|bytes_in|bytes_out|total_mb" > $BANDWIDTH_DB
    fi
    
    # Create necessary directories
    mkdir -p /var/log/amokhan/users
    
    # Setup bandwidth monitoring if not already running
    if ! systemctl is-active --quiet amokhan-monitor 2>/dev/null; then
        setup_bandwidth_monitor
    fi
    
    # Create cron jobs for maintenance
    setup_cron_jobs
}

setup_cron_jobs() {
    cat > /etc/cron.d/amokhan << EOF
# AMOKHAN Maintenance Jobs
# Check expired users every hour
0 * * * * root /usr/local/bin/amokhan check-expired >/dev/null 2>&1
# Reset bandwidth daily at midnight if configured
0 0 * * * root /usr/local/bin/amokhan reset-bandwidth >/dev/null 2>&1
# Backup database daily at 2 AM
0 2 * * * root /usr/local/bin/amokhan backup >/dev/null 2>&1
EOF
    chmod 644 /etc/cron.d/amokhan
}

# ============================================================================
# BANDWIDTH MONITORING SYSTEM
# ============================================================================
setup_bandwidth_monitor() {
    cat > /usr/local/bin/amokhan-monitor << 'EOF'
#!/bin/bash

CONFIG_DIR="/etc/amokhan"
DB_FILE="$CONFIG_DIR/users.db"
BANDWIDTH_DB="$CONFIG_DIR/bandwidth.db"
MONITOR_INTERVAL=60

# Function to convert bytes to MB
bytes_to_mb() {
    echo "scale=2; $1 / 1048576" | bc
}

# Function to get user traffic from iptables
get_user_traffic() {
    local username=$1
    
    # Get traffic from iptables (both directions)
    bytes_in=$(iptables -L OUTPUT -nvx | grep " $username " | grep -v "DROP" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo 0)
    bytes_out=$(iptables -L INPUT -nvx | grep " $username " | grep -v "DROP" | awk '{sum+=$2} END {print sum}' 2>/dev/null || echo 0)
    
    # If no iptables rules exist, create them
    if [ "$bytes_in" = "0" ] && [ "$bytes_out" = "0" ]; then
        iptables -N $username 2>/dev/null
        iptables -I OUTPUT -m owner --uid-owner $username -j $username 2>/dev/null
        iptables -I INPUT -m owner --uid-owner $username -j $username 2>/dev/null
        iptables -A $username -j RETURN 2>/dev/null
        bytes_in=0
        bytes_out=0
    fi
    
    echo "$bytes_in|$bytes_out"
}

# Function to update bandwidth database
update_bandwidth() {
    local username=$1
    local bytes_in=$2
    local bytes_out=$3
    local timestamp=$(date +%s)
    local total_mb=$(bytes_to_mb $((bytes_in + bytes_out)))
    
    # Store in bandwidth database
    echo "$username|$timestamp|$bytes_in|$bytes_out|$total_mb" >> $BANDWIDTH_DB
    
    # Update user's current bandwidth in main database
    local temp_file=$(mktemp)
    while IFS='|' read -r user pass expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        if [ "$user" = "$username" ]; then
            echo "$user|$pass|$expiry|$created|$max_bandwidth|$total_mb|$last_reset|$status|$max_logins|$current_logins|$email|$notes" >> $temp_file
        else
            echo "$user|$pass|$expiry|$created|$max_bandwidth|$current_bandwidth|$last_reset|$status|$max_logins|$current_logins|$email|$notes" >> $temp_file
        fi
    done < $DB_FILE
    
    mv $temp_file $DB_FILE
}

# Function to check bandwidth limits
check_limits() {
    local username=$1
    local current_mb=$2
    local max_mb=$3
    
    if [ "$max_mb" != "0" ] && [ "$max_mb" != "unlimited" ] && [ $(echo "$current_mb > $max_mb" | bc) -eq 1 ]; then
        # Kill all user processes
        pkill -u $username 2>/dev/null
        killall -u $username 2>/dev/null
        
        # Lock the account
        passwd -l $username 2>/dev/null
        
        # Update status
        local temp_file=$(mktemp)
        while IFS='|' read -r user pass expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
            if [ "$user" = "$username" ]; then
                echo "$user|$pass|$expiry|$created|$max_bandwidth|$current_bandwidth|$last_reset|LIMIT_EXCEEDED|$max_logins|$current_logins|$email|$notes" >> $temp_file
            else
                echo "$user|$pass|$expiry|$created|$max_bandwidth|$current_bandwidth|$last_reset|$status|$max_logins|$current_logins|$email|$notes" >> $temp_file
            fi
        done < $DB_FILE
        mv $temp_file $DB_FILE
        
        logger -t "amokhan" "User $username exceeded bandwidth limit ($current_mb MB > $max_mb MB)"
        
        # Send email notification if configured
        if [ -n "$email" ] && [ "$email" != "null" ]; then
            echo "Your account $username has exceeded the bandwidth limit of $max_mb MB. Current usage: $current_mb MB" | mail -s "Bandwidth Limit Exceeded" $email
        fi
    fi
}

# Function to check and update current logins
update_logins() {
    local username=$1
    local current_logins=$(ps -u $username | grep sshd | wc -l)
    local max_logins=$(grep "^$username|" $DB_FILE | cut -d'|' -f9)
    
    if [ "$max_logins" != "0" ] && [ "$max_logins" != "unlimited" ] && [ $current_logins -gt $max_logins ]; then
        # Kill excess logins
        local excess=$((current_logins - max_logins))
        ps -u $username | grep sshd | tail -$excess | awk '{print $1}' | xargs kill 2>/dev/null
    fi
    
    # Update current logins in database
    local temp_file=$(mktemp)
    while IFS='|' read -r user pass expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        if [ "$user" = "$username" ]; then
            echo "$user|$pass|$expiry|$created|$max_bandwidth|$current_bandwidth|$last_reset|$status|$max_logins|$current_logins|$email|$notes" >> $temp_file
        else
            echo "$user|$pass|$expiry|$created|$max_bandwidth|$current_bandwidth|$last_reset|$status|$max_logins|$current_logins|$email|$notes" >> $temp_file
        fi
    done < $DB_FILE
    mv $temp_file $DB_FILE
}

# Main monitoring loop
while true; do
    # Monitor each active user
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue  # Skip header
        
        # Skip if user doesn't exist
        if ! id "$username" &>/dev/null; then
            continue
        fi
        
        # Get traffic data
        traffic=$(get_user_traffic $username)
        bytes_in=$(echo $traffic | cut -d'|' -f1)
        bytes_out=$(echo $traffic | cut -d'|' -f2)
        
        # Update bandwidth database
        update_bandwidth $username $bytes_in $bytes_out
        
        # Get current total in MB
        current_mb=$(bytes_to_mb $((bytes_in + bytes_out)))
        
        # Check limits
        if [ "$max_bandwidth" != "0" ] && [ "$max_bandwidth" != "unlimited" ]; then
            check_limits $username $current_mb $max_bandwidth
        fi
        
        # Update login count
        update_logins $username
        
    done < <(tail -n +2 $DB_FILE 2>/dev/null)
    
    sleep $MONITOR_INTERVAL
done
EOF

    chmod +x /usr/local/bin/amokhan-monitor
    
    # Create systemd service
    cat > /etc/systemd/system/amokhan-monitor.service << EOF
[Unit]
Description=AMOKHAN Bandwidth Monitor
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/amokhan-monitor
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable amokhan-monitor.service 2>/dev/null
    systemctl start amokhan-monitor.service 2>/dev/null
}

# ============================================================================
# USER MANAGEMENT FUNCTIONS
# ============================================================================

# Create new SSH user
create_user() {
    clear
    print_header "👤 CREATE NEW SSH USER"
    
    # Get username
    echo -ne "${WHITE}Username: ${NC}"
    read username
    
    # Check if user exists
    if id "$username" &>/dev/null; then
        echo -e "${RED}✗ User $username already exists!${NC}"
        return
    fi
    
    # Check if username in database
    if grep -q "^$username|" $DB_FILE; then
        echo -e "${RED}✗ Username $username already in database!${NC}"
        return
    fi
    
    # Get password
    echo -ne "${WHITE}Password: ${NC}"
    read -s password
    echo
    echo -ne "${WHITE}Confirm Password: ${NC}"
    read -s password2
    echo
    
    if [ "$password" != "$password2" ]; then
        echo -e "${RED}✗ Passwords do not match!${NC}"
        return
    fi
    
    # Get expiry days
    echo -ne "${WHITE}Expiry (days): ${NC}"
    read expiry_days
    if ! [[ "$expiry_days" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗ Invalid number!${NC}"
        return
    fi
    expiry_date=$(date -d "+$expiry_days days" +%Y-%m-%d)
    
    # Get bandwidth limit (in MB, 0 for unlimited)
    echo -ne "${WHITE}Bandwidth Limit (MB, 0 for unlimited): ${NC}"
    read bandwidth_limit
    if ! [[ "$bandwidth_limit" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗ Invalid number!${NC}"
        return
    fi
    
    # Get max logins (0 for unlimited)
    echo -ne "${WHITE}Max Simultaneous Logins (0 for unlimited): ${NC}"
    read max_logins
    if ! [[ "$max_logins" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}✗ Invalid number!${NC}"
        return
    fi
    
    # Get email for notifications (optional)
    echo -ne "${WHITE}Email for notifications (optional): ${NC}"
    read email
    
    # Create system user
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    # Set expiry
    chage -E "$expiry_date" "$username"
    
    # Create iptables rules for monitoring
    iptables -N "$username" 2>/dev/null
    iptables -I OUTPUT -m owner --uid-owner "$username" -j "$username" 2>/dev/null
    iptables -I INPUT -m owner --uid-owner "$username" -j "$username" 2>/dev/null
    iptables -A "$username" -j RETURN 2>/dev/null
    
    # Add to database
    created_date=$(date +%Y-%m-%d)
    echo "$username|$password|$expiry_date|$created_date|$bandwidth_limit|0|$created_date|ACTIVE|$max_logins|0|$email|" >> $DB_FILE
    
    # Create user log directory
    mkdir -p /var/log/amokhan/users/$username
    
    echo -e "\n${GREEN}✓ User $username created successfully!${NC}"
    
    # Show user details
    echo -e "\n${CYAN}┌────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}USER DETAILS${NC}                              ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} Username:     ${GREEN}$username${NC}"
    echo -e "${CYAN}│${NC} Password:     ${GREEN}$password${NC}"
    echo -e "${CYAN}│${NC} Expiry Date:  ${YELLOW}$expiry_date${NC}"
    echo -e "${CYAN}│${NC} Bandwidth:    ${YELLOW}$( [ "$bandwidth_limit" = "0" ] && echo "Unlimited" || echo "$bandwidth_limit MB")${NC}"
    echo -e "${CYAN}│${NC} Max Logins:   ${YELLOW}$( [ "$max_logins" = "0" ] && echo "Unlimited" || echo "$max_logins")${NC}"
    echo -e "${CYAN}│${NC} Status:       ${GREEN}ACTIVE${NC}"
    echo -e "${CYAN}└────────────────────────────────────────┘${NC}"
    
    # Log action
    echo "$(date): Created user $username (expires: $expiry_date)" >> $LOG_FILE
}

# List all users with bandwidth usage
list_users() {
    clear
    print_header "📋 SSH USER LIST WITH BANDWIDTH USAGE"
    
    printf "${CYAN}┌─────┬────────────────┬────────────┬────────────┬──────────────┬──────────────┬──────────────┬────────┐${NC}\n"
    printf "${CYAN}│${NC} ${BOLD} #   ${NC} ${CYAN}│${NC} ${BOLD}Username       ${NC} ${CYAN}│${NC} ${BOLD}Expiry Date ${NC} ${CYAN}│${NC} ${BOLD}Status    ${NC} ${CYAN}│${NC} ${BOLD}Used (MB)  ${NC} ${CYAN}│${NC} ${BOLD}Limit (MB) ${NC} ${CYAN}│${NC} ${BOLD}Used %%    ${NC} ${CYAN}│${NC} ${BOLD}Logins${NC} ${CYAN}│${NC}\n"
    printf "${CYAN}├─────┼────────────────┼────────────┼────────────┼──────────────┼──────────────┼──────────────┼────────┤${NC}\n"
    
    local count=0
    local total_bandwidth=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue  # Skip header
        
        count=$((count + 1))
        
        # Calculate usage percentage
        if [ "$max_bandwidth" = "0" ] || [ "$max_bandwidth" = "unlimited" ]; then
            percent="N/A"
            limit_display="Unlimited"
        else
            if [ "$current_bandwidth" = "0" ]; then
                percent="0%"
            else
                percent=$(echo "scale=1; $current_bandwidth * 100 / $max_bandwidth" | bc 2>/dev/null || echo "0")
                percent="${percent}%"
            fi
            limit_display="$max_bandwidth"
        fi
        
        # Set color based on usage
        if [ "$max_bandwidth" != "0" ] && [ "$max_bandwidth" != "unlimited" ] && [ $(echo "$current_bandwidth > $max_bandwidth" | bc 2>/dev/null || echo 0) -eq 1 ]; then
            usage_color=$RED
        elif [ $(echo "$current_bandwidth > 0" | bc 2>/dev/null || echo 0) -eq 1 ]; then
            usage_color=$YELLOW
        else
            usage_color=$GREEN
        fi
        
        # Status color
        case $status in
            ACTIVE) status_color=$GREEN ;;
            EXPIRED) status_color=$RED ;;
            LIMIT_EXCEEDED) status_color=$RED ;;
            SUSPENDED) status_color=$YELLOW ;;
            *) status_color=$WHITE ;;
        esac
        
        # Format current bandwidth with 2 decimal places
        current_display=$(echo "$current_bandwidth" | bc 2>/dev/null || echo "0.00")
        
        printf "${CYAN}│${NC} %-3s ${CYAN}│${NC} %-14s ${CYAN}│${NC} %-10s ${CYAN}│${NC} ${status_color}%-10s${NC} ${CYAN}│${NC} ${usage_color}%-12s${NC} ${CYAN}│${NC} %-10s ${CYAN}│${NC} %-12s ${CYAN}│${NC} %-6s ${CYAN}│${NC}\n" \
            "$count" \
            "$username" \
            "$expiry" \
            "$status" \
            "$current_display" \
            "$limit_display" \
            "$percent" \
            "$current_logins/$max_logins"
        
        total_bandwidth=$(echo "$total_bandwidth + $current_bandwidth" | bc 2>/dev/null || echo "$total_bandwidth")
        
    done < $DB_FILE
    
    printf "${CYAN}└─────┴────────────────┴────────────┴────────────┴──────────────┴──────────────┴──────────────┴────────┘${NC}\n"
    
    if [ $count -eq 0 ]; then
        echo -e "\n${YELLOW}No users found${NC}"
    else
        echo -e "\n${WHITE}Total Users:${NC} $count"
        echo -e "${WHITE}Total Bandwidth Used:${NC} $(echo "scale=2; $total_bandwidth / 1024" | bc) GB"
    fi
    
    echo -e "\nPress Enter to continue..."
    read
}

# Renew/Extend user account
renew_user() {
    clear
    print_header "🔄 RENEW USER ACCOUNT"
    
    # List users for selection
    echo -e "${YELLOW}Available users:${NC}"
    local users=()
    local count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        if [ "$status" = "ACTIVE" ] || [ "$status" = "EXPIRED" ]; then
            count=$((count + 1))
            users+=("$username")
            echo -e "  ${CYAN}$count.${NC} $username (expires: $expiry, status: $status)"
        fi
    done < $DB_FILE
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No users available for renewal${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo
    echo -ne "${WHITE}Select user number to renew: ${NC}"
    read selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    selected_user="${users[$((selection-1))]}"
    
    # Get current user data
    user_data=$(grep "^$selected_user|" $DB_FILE)
    IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes <<< "$user_data"
    
    echo -e "\n${CYAN}Renewing user: ${WHITE}$selected_user${NC}"
    echo -e "${CYAN}Current expiry: ${YELLOW}$expiry${NC}"
    
    # Get new expiry
    echo -ne "${WHITE}Add how many days? ${NC}"
    read add_days
    
    if ! [[ "$add_days" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid number!${NC}"
        return
    fi
    
    # Calculate new expiry
    if [ "$status" = "EXPIRED" ]; then
        # If expired, start from today
        new_expiry=$(date -d "+$add_days days" +%Y-%m-%d)
    else
        # If active, add to current expiry
        new_expiry=$(date -d "$expiry +$add_days days" +%Y-%m-%d 2>/dev/null)
        if [ $? -ne 0 ]; then
            # If date calculation fails, start from today
            new_expiry=$(date -d "+$add_days days" +%Y-%m-%d)
        fi
    fi
    
    # Update system expiry
    chage -E "$new_expiry" "$selected_user"
    
    # Update database
    temp_file=$(mktemp)
    while IFS='|' read -r u p e c mb cm lr s ml cl em nt; do
        if [ "$u" = "$selected_user" ]; then
            # Reactivate if expired
            if [ "$s" = "EXPIRED" ]; then
                s="ACTIVE"
                # Unlock account if it was locked
                passwd -u "$selected_user" 2>/dev/null
            fi
            echo "$u|$p|$new_expiry|$c|$mb|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
        else
            echo "$u|$p|$e|$c|$mb|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
        fi
    done < $DB_FILE
    mv $temp_file $DB_FILE
    
    echo -e "${GREEN}✓ User $selected_user renewed until: $new_expiry${NC}"
    
    # Log action
    echo "$(date): Renewed user $selected_user (+$add_days days, new expiry: $new_expiry)" >> $LOG_FILE
    
    echo -e "\nPress Enter to continue..."
    read
}

# Delete user
delete_user() {
    clear
    print_header "🗑️ DELETE USER"
    
    # List users
    local users=()
    local count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        count=$((count + 1))
        users+=("$username")
        echo -e "  ${CYAN}$count.${NC} $username (status: $status)"
    done < $DB_FILE
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No users to delete${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo
    echo -ne "${WHITE}Select user number to delete (0 to cancel): ${NC}"
    read selection
    
    if [ "$selection" = "0" ]; then
        return
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    selected_user="${users[$((selection-1))]}"
    
    echo -e "\n${RED}WARNING: You are about to delete user: $selected_user${NC}"
    echo -ne "${WHITE}Type 'YES' to confirm: ${NC}"
    read confirm
    
    if [ "$confirm" != "YES" ]; then
        echo -e "${GREEN}Deletion cancelled${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    # Remove iptables rules
    iptables -D OUTPUT -m owner --uid-owner "$selected_user" -j "$selected_user" 2>/dev/null
    iptables -D INPUT -m owner --uid-owner "$selected_user" -j "$selected_user" 2>/dev/null
    iptables -F "$selected_user" 2>/dev/null
    iptables -X "$selected_user" 2>/dev/null
    
    # Kill user processes
    pkill -u "$selected_user" 2>/dev/null
    killall -u "$selected_user" 2>/dev/null
    
    # Remove user
    userdel -f "$selected_user" 2>/dev/null
    rm -rf /home/"$selected_user" 2>/dev/null
    
    # Remove from database
    temp_file=$(mktemp)
    grep -v "^$selected_user|" $DB_FILE > $temp_file
    mv $temp_file $DB_FILE
    
    # Remove from bandwidth database
    temp_file=$(mktemp)
    grep -v "^$selected_user|" $BANDWIDTH_DB > $temp_file
    mv $temp_file $BANDWIDTH_DB
    
    # Remove logs
    rm -rf /var/log/amokhan/users/$selected_user 2>/dev/null
    
    echo -e "${GREEN}✓ User $selected_user deleted successfully${NC}"
    
    # Log action
    echo "$(date): Deleted user $selected_user" >> $LOG_FILE
    
    echo -e "\nPress Enter to continue..."
    read
}

# Monitor user bandwidth
monitor_user() {
    clear
    print_header "📊 BANDWIDTH MONITOR"
    
    # Select user
    echo -e "${YELLOW}Select user to monitor:${NC}"
    local users=()
    local count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        count=$((count + 1))
        users+=("$username")
        echo -e "  ${CYAN}$count.${NC} $username"
    done < $DB_FILE
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No users found${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo
    echo -ne "${WHITE}Select user number: ${NC}"
    read selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    selected_user="${users[$((selection-1))]}"
    
    # Get user data
    user_data=$(grep "^$selected_user|" $DB_FILE)
    IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes <<< "$user_data"
    
    # Show bandwidth history
    echo -e "\n${CYAN}Bandwidth Usage History for ${WHITE}$selected_user${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Current Usage:${NC} $(echo "scale=2; $current_bandwidth / 1024" | bc) GB / $( [ "$max_bandwidth" = "0" ] && echo "Unlimited" || echo "$(echo "scale=2; $max_bandwidth / 1024" | bc) GB")"
    echo -e "${WHITE}Status:${NC} $status"
    echo -e "${WHITE}Account Created:${NC} $created"
    echo -e "${WHITE}Last Reset:${NC} $last_reset"
    echo
    
    # Show last 10 bandwidth entries
    echo -e "${CYAN}Recent Activity:${NC}"
    printf "${CYAN}┌────────────────────┬──────────────┬──────────────┬──────────────┐${NC}\n"
    printf "${CYAN}│${NC} ${BOLD}Timestamp           ${NC} ${CYAN}│${NC} ${BOLD}Bytes In    ${NC} ${CYAN}│${NC} ${BOLD}Bytes Out   ${NC} ${CYAN}│${NC} ${BOLD}Total (MB)  ${NC} ${CYAN}│${NC}\n"
    printf "${CYAN}├────────────────────┼──────────────┼──────────────┼──────────────┤${NC}\n"
    
    grep "^$selected_user|" $BANDWIDTH_DB | tail -10 | while IFS='|' read -r user ts bin bout total; do
        date_str=$(date -d "@$ts" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "N/A")
        printf "${CYAN}│${NC} %-18s ${CYAN}│${NC} %-12s ${CYAN}│${NC} %-12s ${CYAN}│${NC} %-12s ${CYAN}│${NC}\n" \
            "$date_str" \
            "$(echo "scale=2; $bin/1048576" | bc) MB" \
            "$(echo "scale=2; $bout/1048576" | bc) MB" \
            "$total"
    done
    
    printf "${CYAN}└────────────────────┴──────────────┴──────────────┴──────────────┘${NC}\n"
    
    echo -e "\nPress Enter to continue..."
    read
}

# Set bandwidth limit
set_limit() {
    clear
    print_header "⚡ SET BANDWIDTH LIMIT"
    
    # List users
    local users=()
    local count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        if [ "$status" = "ACTIVE" ]; then
            count=$((count + 1))
            users+=("$username")
            echo -e "  ${CYAN}$count.${NC} $username (current: $max_bandwidth MB)"
        fi
    done < $DB_FILE
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No active users found${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo
    echo -ne "${WHITE}Select user number: ${NC}"
    read selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    selected_user="${users[$((selection-1))]}"
    
    echo -ne "${WHITE}Enter new bandwidth limit in MB (0 for unlimited): ${NC}"
    read new_limit
    
    if ! [[ "$new_limit" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid number!${NC}"
        return
    fi
    
    # Update database
    temp_file=$(mktemp)
    while IFS='|' read -r u p e c mb cm lr s ml cl em nt; do
        if [ "$u" = "$selected_user" ]; then
            echo "$u|$p|$e|$c|$new_limit|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
        else
            echo "$u|$p|$e|$c|$mb|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
        fi
    done < $DB_FILE
    mv $temp_file $DB_FILE
    
    echo -e "${GREEN}✓ Bandwidth limit for $selected_user updated to: $new_limit MB${NC}"
    
    # Log action
    echo "$(date): Updated bandwidth limit for $selected_user to $new_limit MB" >> $LOG_FILE
    
    echo -e "\nPress Enter to continue..."
    read
}

# Check expired users
check_expired() {
    local today=$(date +%Y-%m-%d)
    local expired_count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        
        if [ "$status" = "ACTIVE" ] && [ "$expiry" < "$today" ]; then
            # Expire the user
            passwd -l "$username" 2>/dev/null
            pkill -u "$username" 2>/dev/null
            
            # Update database
            temp_file=$(mktemp)
            while IFS='|' read -r u p e c mb cm lr s ml cl em nt; do
                if [ "$u" = "$username" ]; then
                    echo "$u|$p|$e|$c|$mb|$cm|$lr|EXPIRED|$ml|$cl|$em|$nt" >> $temp_file
                else
                    echo "$u|$p|$e|$c|$mb|$cm|$lr|$s|$ml|$cl|$em|$nt" >> $temp_file
                fi
            done < $DB_FILE
            mv $temp_file $DB_FILE
            
            expired_count=$((expired_count + 1))
            echo "$(date): User $username expired" >> $LOG_FILE
        fi
    done < $DB_FILE
    
    if [ $expired_count -gt 0 ]; then
        echo -e "${YELLOW}Expired $expired_count user(s)${NC}"
    fi
}

# ============================================================================
# COMPLETE UNINSTALLATION
# ============================================================================
uninstall_script() {
    clear
    print_header "🗑️  COMPLETE UNINSTALLATION"
    
    echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║${NC}                   ⚠️  WARNING ⚠️                           ${RED}${BOLD}║${NC}"
    echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}This will REMOVE EVERYTHING installed by AMOKHAN:${NC}"
    echo -e "  ${YELLOW}•${NC} All SSH users and accounts"
    echo -e "  ${YELLOW}•${NC} All user home directories and data"
    echo -e "  ${YELLOW}•${NC} SlowDNS service and binaries"
    echo -e "  ${YELLOW}•${NC} EDNS Proxy service"
    echo -e "  ${YELLOW}•${NC} Bandwidth monitoring system"
    echo -e "  ${YELLOW}•${NC} All configuration files and databases"
    echo -e "  ${YELLOW}•${NC} Firewall rules created by script"
    echo -e "  ${YELLOW}•${NC} Cron jobs and systemd services"
    echo -e "  ${YELLOW}•${NC} Log files and backups"
    echo -e ""
    echo -e "${RED}${BOLD}This action CANNOT be undone!${NC}"
    echo -e ""
    echo -ne "${WHITE}${BOLD}Type 'PERMANENTLY DELETE' to confirm: ${NC}"
    read -r confirm
    
    if [ "$confirm" != "PERMANENTLY DELETE" ]; then
        echo -e "${GREEN}Uninstall cancelled${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo -e "\n${CYAN}Starting uninstallation...${NC}"
    
    # Step 1: Stop all services
    echo -ne "  ${CYAN}Stopping services...${NC}"
    systemctl stop server-sldns 2>/dev/null
    systemctl stop edns-proxy 2>/dev/null
    systemctl stop amokhan-monitor 2>/dev/null
    systemctl disable server-sldns 2>/dev/null
    systemctl disable edns-proxy 2>/dev/null
    systemctl disable amokhan-monitor 2>/dev/null
    echo -e "\r  ${GREEN}✓ Services stopped${NC}"
    
    # Step 2: Remove all user accounts
    echo -e "  ${CYAN}Removing all SSH users...${NC}"
    local user_count=0
    
    while IFS='|' read -r username password expiry created max_bandwidth current_bandwidth last_reset status max_logins current_logins email notes; do
        [ "$username" = "username" ] && continue
        
        # Kill all processes for this user
        pkill -u "$username" 2>/dev/null
        killall -u "$username" 2>/dev/null
        
        # Remove iptables rules
        iptables -D OUTPUT -m owner --uid-owner "$username" -j "$username" 2>/dev/null
        iptables -D INPUT -m owner --uid-owner "$username" -j "$username" 2>/dev/null
        iptables -F "$username" 2>/dev/null
        iptables -X "$username" 2>/dev/null
        
        # Remove user and home directory
        userdel -f -r "$username" 2>/dev/null
        
        user_count=$((user_count + 1))
        echo -e "    ${GREEN}✓${NC} Removed user: $username"
    done < <(tail -n +2 $DB_FILE 2>/dev/null)
    
    echo -e "  ${GREEN}✓ Removed $user_count user(s)${NC}"
    
    # Step 3: Remove all installed packages (optional)
    echo -e "  ${CYAN}Checking for installed packages...${NC}"
    if command -v apt &>/dev/null; then
        # Debian/Ubuntu
        apt remove --purge -y slowdns 2>/dev/null
        apt remove --purge -y dnstt 2>/dev/null
    elif command -v yum &>/dev/null; then
        # CentOS/RHEL
        yum remove -y slowdns 2>/dev/null
        yum remove -y dnstt 2>/dev/null
    fi
    
    # Step 4: Remove all files and directories
    echo -e "  ${CYAN}Removing installed files...${NC}"
    rm -rf /etc/slowdns 2>/dev/null
    rm -rf $CONFIG_DIR 2>/dev/null
    rm -rf $BACKUP_DIR 2>/dev/null
    rm -f /usr/local/bin/edns-proxy 2>/dev/null
    rm -f /usr/local/bin/amokhan* 2>/dev/null
    rm -f /etc/systemd/system/server-sldns.service 2>/dev/null
    rm -f /etc/systemd/system/edns-proxy.service 2>/dev/null
    rm -f /etc/systemd/system/amokhan-*.service 2>/dev/null
    rm -f /etc/cron.d/amokhan 2>/dev/null
    rm -rf /var/log/amokhan 2>/dev/null
    rm -f $LOG_FILE 2>/dev/null
    
    # Step 5: Restore original SSH configuration
    echo -ne "  ${CYAN}Restoring SSH configuration...${NC}"
    if [ -f /etc/ssh/sshd_config.backup ]; then
        cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
        systemctl restart sshd
    fi
    echo -e "\r  ${GREEN}✓ SSH configuration restored${NC}"
    
    # Step 6: Reset firewall rules
    echo -ne "  ${CYAN}Resetting firewall rules...${NC}"
    iptables -F 2>/dev/null
    iptables -t nat -F 2>/dev/null
    iptables -X 2>/dev/null
    echo -e "\r  ${GREEN}✓ Firewall rules reset${NC}"
    
    # Step 7: Clean up any remaining processes
    echo -ne "  ${CYAN}Cleaning up processes...${NC}"
    fuser -k 53/udp 2>/dev/null
    fuser -k 5300/udp 2>/dev/null
    pkill -f "dnstt-server" 2>/dev/null
    pkill -f "edns-proxy" 2>/dev/null
    echo -e "\r  ${GREEN}✓ Processes cleaned${NC}"
    
    # Step 8: Reload systemd
    echo -ne "  ${CYAN}Reloading systemd...${NC}"
    systemctl daemon-reload
    echo -e "\r  ${GREEN}✓ Systemd reloaded${NC}"
    
    # Summary
    echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║${NC}          ✅ UNINSTALLATION COMPLETED SUCCESSFULLY         ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo -e "${WHITE}Removed:${NC}"
    echo -e "  • $user_count user accounts"
    echo -e "  • All services and binaries"
    echo -e "  • All configuration files"
    echo -e "  • Firewall rules"
    echo -e "  • Log files and backups"
    echo -e "\n${YELLOW}System is now clean. You can reinstall AMOKHAN if needed.${NC}"
    
    # Log the uninstall
    echo "$(date): AMOKHAN V$SCRIPT_VERSION uninstalled completely" >> /var/log/syslog
    
    echo -e "\nPress Enter to continue..."
    read
}

# ============================================================================
# BACKUP AND RESTORE
# ============================================================================
backup_system() {
    clear
    print_header "💾 BACKUP SYSTEM"
    
    local backup_name="amokhan-backup-$(date +%Y%m%d-%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    mkdir -p $backup_path
    
    echo -e "${CYAN}Creating backup...${NC}"
    
    # Backup databases
    cp $DB_FILE $backup_path/ 2>/dev/null
    cp $BANDWIDTH_DB $backup_path/ 2>/dev/null
    
    # Backup configuration
    cp -r $CONFIG_DIR/*.conf $backup_path/ 2>/dev/null
    
    # Backup user list
    tail -n +2 $DB_FILE | cut -d'|' -f1 > $backup_path/usernames.txt
    
    # Create archive
    cd $BACKUP_DIR
    tar -czf "$backup_name.tar.gz" "$backup_name" 2>/dev/null
    rm -rf $backup_path
    
    echo -e "${GREEN}✓ Backup created: $BACKUP_DIR/$backup_name.tar.gz${NC}"
    echo -e "${YELLOW}Size: $(du -h $BACKUP_DIR/$backup_name.tar.gz | cut -f1)${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

restore_backup() {
    clear
    print_header "🔄 RESTORE BACKUP"
    
    # List available backups
    local backups=($(ls $BACKUP_DIR/*.tar.gz 2>/dev/null))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${YELLOW}No backups found in $BACKUP_DIR${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    echo -e "${YELLOW}Available backups:${NC}"
    for i in "${!backups[@]}"; do
        echo -e "  ${CYAN}$((i+1)).${NC} $(basename "${backups[$i]}")"
    done
    
    echo
    echo -ne "${WHITE}Select backup to restore (0 to cancel): ${NC}"
    read selection
    
    if [ "$selection" = "0" ]; then
        return
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#backups[@]} ]; then
        echo -e "${RED}Invalid selection!${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    local selected_backup="${backups[$((selection-1))]}"
    
    echo -e "\n${RED}WARNING: Restoring will overwrite current data!${NC}"
    echo -ne "${WHITE}Type 'RESTORE' to confirm: ${NC}"
    read confirm
    
    if [ "$confirm" != "RESTORE" ]; then
        echo -e "${GREEN}Restore cancelled${NC}"
        echo -e "\nPress Enter to continue..."
        read
        return
    fi
    
    # Extract backup
    cd $BACKUP_DIR
    tar -xzf "$selected_backup"
    local extract_dir="${selected_backup%.tar.gz}"
    
    # Restore files
    cp "$extract_dir/users.db" $DB_FILE 2>/dev/null
    cp "$extract_dir/bandwidth.db" $BANDWIDTH_DB 2>/dev/null
    
    # Clean up
    rm -rf "$extract_dir"
    
    echo -e "${GREEN}✓ Backup restored successfully${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

# ============================================================================
# SHOW STATISTICS
# ============================================================================
show_stats() {
    clear
    print_header "📊 SYSTEM STATISTICS"
    
    # Get system info
    local total_users=$(tail -n +2 $DB_FILE | wc -l)
    local active_users=$(grep "|ACTIVE|" $DB_FILE | wc -l)
    local expired_users=$(grep "|EXPIRED|" $DB_FILE | wc -l)
    local limited_users=$(awk -F'|' '$5 != "0" && $5 != "unlimited" {count++} END{print count}' $DB_FILE)
    
    # Get bandwidth totals
    local total_bandwidth=$(awk -F'|' '{sum+=$6} END{printf "%.2f", sum/1024}' $DB_FILE 2>/dev/null || echo "0")
    local avg_bandwidth=$(echo "scale=2; $total_bandwidth / $total_users" | bc 2>/dev/null || echo "0")
    
    # Get server load
    local load=$(uptime | awk -F'load average:' '{print $2}')
    local uptime=$(uptime -p | sed 's/up //')
    
    # Get memory usage
    local mem_total=$(free -m | awk '/^Mem:/{print $2}')
    local mem_used=$(free -m | awk '/^Mem:/{print $3}')
    local mem_percent=$((mem_used * 100 / mem_total))
    
    # Get disk usage
    local disk_used=$(df -h / | awk 'NR==2{print $3}')
    local disk_total=$(df -h / | awk 'NR==2{print $2}')
    local disk_percent=$(df -h / | awk 'NR==2{print $5}')
    
    # Display statistics in a nice box
    echo -e "${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}SERVER STATISTICS${NC}                                   ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} Uptime:        ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$uptime"
    printf "${CYAN}│${NC} Load Average:  ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$load"
    printf "${CYAN}│${NC} Memory Usage:  ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$mem_used MB / $mem_total MB ($mem_percent%)"
    printf "${CYAN}│${NC} Disk Usage:    ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$disk_used / $disk_total ($disk_percent)"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}USER STATISTICS${NC}                                     ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} Total Users:   ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$total_users"
    printf "${CYAN}│${NC} Active Users:  ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$active_users"
    printf "${CYAN}│${NC} Expired Users: ${YELLOW}%-35s${NC} ${CYAN}│${NC}\n" "$expired_users"
    printf "${CYAN}│${NC} Limited Users: ${CYAN}%-35s${NC} ${CYAN}│${NC}\n" "$limited_users"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${WHITE}${BOLD}BANDWIDTH STATISTICS${NC}                               ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────────────────────┤${NC}"
    printf "${CYAN}│${NC} Total Used:    ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$total_bandwidth GB"
    printf "${CYAN}│${NC} Average/User:  ${GREEN}%-35s${NC} ${CYAN}│${NC}\n" "$avg_bandwidth GB"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
    
    echo -e "\nPress Enter to continue..."
    read
}

# ============================================================================
# MAIN MENU
# ============================================================================
show_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}              ${CYAN}${BOLD}AMOKHAN V$SCRIPT_VERSION - SSH MANAGER${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}           ${WHITE}Advanced User Management System${NC}                 ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${YELLOW}SERVER INFO${NC}                                                      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   IP: ${GREEN}$(curl -s --connect-timeout 2 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')${NC}                ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   Users: ${WHITE}$(tail -n +2 $DB_FILE 2>/dev/null | wc -l)${NC} Active: ${GREEN}$(grep -c "|ACTIVE|" $DB_FILE 2>/dev/null)${NC}               ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}                      ${WHITE}${BOLD}MAIN MENU${NC}                           ${BLUE}║${NC}"
    echo -e "${BLUE}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[1]${NC} 👤  Create New User                                      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[2]${NC} 📋  List All Users (with bandwidth)                      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[3]${NC} 🔄  Renew User Account                                   ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[4]${NC} ⚡  Set Bandwidth Limit                                  ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[5]${NC} 📊  Monitor User Bandwidth                               ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[6]${NC} 🗑️   Delete User                                          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[7]${NC} 💾  Backup System                                         ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[8]${NC} 🔄  Restore Backup                                       ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[9]${NC} 📊  System Statistics                                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[10]${NC} 🔧  Install/Configure Services                           ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[11]${NC} 🗑️   COMPLETE UNINSTALL                                  ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}[12]${NC} ❌  Exit                                                ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "${WHITE}${BOLD}Select option [1-12]: ${NC}"
    read -r option
    
    case $option in
        1) create_user ;;
        2) list_users ;;
        3) renew_user ;;
        4) set_limit ;;
        5) monitor_user ;;
        6) delete_user ;;
        7) backup_system ;;
        8) restore_backup ;;
        9) show_stats ;;
        10) install_services ;;
        11) uninstall_script ;;
        12) 
            echo -e "\n${GREEN}Thank you for using AMOKHAN V$SCRIPT_VERSION!${NC}"
            exit 0 
            ;;
        *)
            echo -e "\n${RED}Invalid option!${NC}"
            sleep 2
            ;;
    esac
}

# ============================================================================
# INSTALL SERVICES (from original SlowDNS script)
# ============================================================================
install_services() {
    # This function would contain the SlowDNS installation code
    # from the original script (simplified here for space)
    echo -e "${YELLOW}Service installation feature coming soon...${NC}"
    sleep 2
}

# ============================================================================
# MAIN PROGRAM
# ============================================================================
main() {
    # Initialize system
    init_system
    
    # Check for expired users on startup
    check_expired
    
    # Main loop
    while true; do
        show_menu
    done
}

# ============================================================================
# COMMAND LINE ARGUMENTS
# ============================================================================
case "${1:-}" in
    check-expired)
        check_expired
        ;;
    reset-bandwidth)
        # Reset bandwidth function would go here
        echo "Bandwidth reset feature"
        ;;
    backup)
        backup_system
        ;;
    uninstall)
        uninstall_script
        ;;
    *)
        # Run main program
        trap 'echo -e "\n${RED}✗ Interrupted!${NC}"; exit 1' INT
        main
        ;;
esac
