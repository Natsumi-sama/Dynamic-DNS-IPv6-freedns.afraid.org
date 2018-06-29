#!/bin/bash
IFS=$'\r\n' GLOBIGNORE='*' command eval "IParray=($(ifconfig eth0 | awk '/inet6 /{print $2}'))"

for i in "${IParray[@]}"
do
        echo $i
        if [ "${i:0:4}" = "fe80" ]
        then
                echo "link-local address"
                break
        fi
        IPTemp=$(echo $i | grep -o -P "([0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4})" | head -n 1)
        if ping -c1 -I eth0 $IPTemp:1:0000:0000:0000:0000 &> /dev/null
        then
                echo "ping successful"
                IP=$IPTemp
        else
                echo "deleted $i"
                sudo ip -6 addr del $i/64 dev eth0
        fi
done

if [ -z "$IP" ]
then
        echo "\$IP is empty, there is no IPv6 address"
        exit
fi

OLDIP="$(cat ipv6.txt)"
if [ "$IP" != "$OLDIP" ]
then
        curl "https://freedns.afraid.org/dynamic/update.php?KEY=&address=$IP:1:0000:0000:0000:0000"
        sudo sed -i 's/'$(echo $OLDIP)'/'$(echo $IP)'/g' /etc/httpd/conf/httpd.conf
        sudo sed -i 's/'$(echo $OLDIP)'/'$(echo $IP)'/g' /var/named/domain
        sudo systemctl restart named
	sudo systemctl restart httpd
        echo $IP > ipv6.txt
else
        echo "IPv6 address is the same, no update required"
fi
