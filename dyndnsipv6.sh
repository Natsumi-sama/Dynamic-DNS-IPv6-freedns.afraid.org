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
	if ping -c1 -I eth0 $i &> /dev/null
	then
		echo "ping successful"
		IP=$(echo $i | cut -c -14)
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

#find the colon
IP=$(echo $IP | cut -c -14)
if [ "${IP: -1}" = ":" ]
then
	IP="$(echo $IP | cut -c -13)"
else
	if [ "$(echo ${IP: -2} | cut -c 1)" = ":" ]
	then
		IP="$(echo $IP | cut -c -12)"
	fi
fi
OLDIP="$(cat ipv6.txt)"

if [ "$IP" != "$OLDIP" ]
then
	curl "https://freedns.afraid.org/dynamic/update.php?KEY=&address=$IP::1"
	sudo sed -i 's/'$(echo $OLDIP)'/'$(echo $IP)'/g' /etc/httpd/conf/httpd.conf
	sudo systemctl restart httpd
	echo $IP > ipv6.txt
else
	echo "IPv6 address is the same, no update required"
fi
