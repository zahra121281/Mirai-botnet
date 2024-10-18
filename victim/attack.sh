#!/bin/bash

SERVER="172.18.218.92"
DJANGO_SERVER_URL="http://$SERVER/api"  
PING_COUNT=2
SECRET_KEY="/usr/lib/systemd/network.key" 
IV_FILE="/usr/lib/systemd/iv.txt"         
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo")
TCPDUMP_DURATION=180 
TCPDUMP_FILE="/tmp/network_traffic.pcap"

# Check connection to the server
check_connection() {
    if ping -c $PING_COUNT $SERVER &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Encrypt data using AES symmetric encryption
encrypt_data() {
    local key_hex=$(cat "$SECRET_KEY" | tr -d '\n')  # Read the key and strip newlines
    local iv_hex=$(cat "$IV_FILE" | tr -d '\n')      # Read the IV and strip newlines

    echo -n "$1" | openssl enc -aes-256-cbc -K "$key_hex" -iv "$iv_hex" -base64
}


# Send system data securely to Django server
send_system_data() {
    HOSTNAME=$(hostname)
    OS_INFO=$(cat /etc/os-release)
    KERNEL_VERSION=$(uname -r)
    ARCHITECTURE=$(uname -m)
    USERS=$(who)
    IP_ADDRESSES=$(ip a | grep -oP 'inet \K[\d.]+(?=/)' | grep -v '^127')
    CPU_INFO=$(lscpu | head -n 14)
    MEMORY_INFO=$(free -h)
    DISK_USAGE=$(df -h)
    USB_DEVICES=$(lsusb)

    DATA="hostname=$HOSTNAME&os_info=$OS_INFO&kernel=$KERNEL_VERSION&architecture=$ARCHITECTURE&users=$USERS&ip_addresses=$IP_ADDRESSES&cpu_info=$CPU_INFO&memory_info=$MEMORY_INFO&disk_usage=$DISK_USAGE&usb_devices=$USB_DEVICES"

    ENCRYPTED_DATA=$(encrypt_data "$DATA")
    curl -X POST -H "Content-Type: application/json" --data-ascii "{\"data\":\"$ENCRYPTED_DATA\"}" "$DJANGO_SERVER_URL/system-data/"
}

capture_network_traffic() {
    interface=$1
    capture_file="/tmp/captured_traffic_$(date +%Y%m%d_%H%M%S).pcap"
    sudo tcpdump -i $interface -w $capture_file -G $TCPDUMP_DURATION -W 1 -nn  > /dev/null 2>&1
    sleep $TCPDUMP_DURATION
    process_packet_data $capture_file $interface
}

process_packet_data() {
    pcap_file=$1
    interface=$2

    tcpdump -nn -r $pcap_file | while read -r line; do

        timestamp=$(echo "$line" | awk '{print $1, $2}' | awk -F' ' '{print $1}')
        ip_src_port=$(echo "$line" | awk '{print $3}')
        ip_src=$(echo "$ip_src_port" | cut -d'.' -f1-4)
        port_src=$(echo "$ip_src_port" | rev | cut -d'.' -f1 | rev)
        ip_dst_port=$(echo "$line" | awk '{print $5}' | cut -d':' -f1)
        ip_dst=$(echo "$ip_dst_port" | cut -d'.' -f1-4)
        port_dst=$(echo "$ip_dst_port" | rev | cut -d'.' -f1 | rev)
        pid_sender=$(ss -pant | grep "$ip_src:$port_src" | awk '{print $6}' | cut -d',' -f2| awk -F'=' '{print $2}')
        DATA="interface=$interface&ip_source=$ip_src&ip_destination=$ip_dst&port_source=$port_src&port_destination=$port_dst&pid_sender=$pid_sender&time_sent=$timestamp"
        ENCRYPTED_DATA=$(encrypt_data "$DATA")

        echo " next record : $ENCRYPTED_DATA" 
        curl -X POST -H "Content-Type: application/json" --data-ascii "{\"data\":\"$ENCRYPTED_DATA\"}" "$DJANGO_SERVER_URL/network-traffic/"
    done
}

# Main loop: Send system data and network traffic periodically
while true; do
    active_interface=$(ip route | grep default | awk '{print $5}')
    if check_connection; then
        send_system_data
        
        capture_network_traffic $active_interface
        
    fi
    sleep 180  # Wait 3 minutes before the next cycle
done
