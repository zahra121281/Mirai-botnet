#!/bin/bash

# Output CSV file
output_file="open_ports.csv"

echo "analysing network for live hosts"
# Step 1: List all network interfaces except loopback
interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo")

# Step 2: Prepare the CSV file
echo "Host,Port,State" > "$output_file"  # Add header to CSV file

# Step 3: Get the subnet for each interface
for interface in $interfaces; do
    echo "Scanning interface: $interface"

    # Get the IP and subnet for the interface
    cidr=$(ip -o -4 addr show dev "$interface" | awk '{print $4}')
    if [ -z "$cidr" ]; then
        echo "No IPv4 address assigned to $interface, skipping..."
        continue
    fi
    
    # Extract the network part from the CIDR notation (e.g., 192.168.18.0/24)
    subnet=$(ipcalc -n "$cidr" | grep Network | awk '{print $2}')
    echo "subnet is ....   $subnet " 
    if [ -z "$subnet" ]; then
        echo "Failed to get subnet for $interface"
        continue
    fi

    echo "Subnet: $subnet"

    # Step 4: Scan the network for hosts that are up
    echo "Scanning the network for hosts..."
    up_hosts=$(nmap -sn "$subnet" | grep "Nmap scan report for" | awk '{print $5}')
    echo "up hosts $up_hosts"

    # Step 5: For each host found, scan ports from 1 to 500
    for host in $up_hosts; do
        echo "Scanning ports for host: $host"
        open_ports=$(nmap -p- "$host" | grep -E "^[0-9]+/tcp   open")

        # Step 6: Save the results in CSV format
        while IFS= read -r line; do
            port=$(echo "$line" | awk '{print $1}')
            state=$(echo "$line" | awk '{print $2}')
            echo "$host,$port,$state" >> "$output_file"
        done <<< "$open_ports"
    done
done

echo "Scan complete. Open ports saved to $output_file."

