# Dynamic DNS IPv6 for freedns.afraid.org
change interface name "eth0"

set "KEY"

change :1:0000:0000:0000:0000 to your router IP excluding it's subnet 

regex for /48 ([0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4})
regex for /64 ([0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4}:[0-9a-fA-F]{1,4})
