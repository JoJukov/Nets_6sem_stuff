#!/bin/bash

read -s -p "$(printf "Choose option:\n1)Set IP, mask, gateway, DNS through DHCP-server\n2)set IP, mask, gateway, DNS by yourself\n3)Show info\nOr press any other button to exit\n")" -n1 opt

int='/etc/sysconfig/network-scripts/ifcfg-enp0s3'

function colored_text {
	echo -e "\e[33m$1\e[m"
}

function reset_stats {
	sed '/IPADDR=.*/d' -i "${int}"
	sed '/NETMASK=.*/d' -i "${int}"
	sed '/GATEWAY=.*/d' -i "${int}"
	sed '/DNS*/d' -i "${int}"
}

function set_by_computer {
	sed 's/BOOTPROTO=.*/BOOTPROTO="dhcp"/' -i "${int}"
	reset_stats
	service network restart
	 
}

function set_by_yourself {
	read -p "Enter Ip address: " ip
	read -p "Enter mask: " mask
	read -p "Enter gateway: " gateway
	read -p "Enter DNS server:" dns
	sed 's/BOOTPROTO=.*/BOOTPROTO="static"/' -i "${int}"
	reset_stats
	echo "IPADDR=${ip}" >> "${int}"
	echo "NETMASK=${mask}" >> "${int}"
	echo "GATEWAY=${gateway}" >> "${int}"
	echo "DNS1=${dns}" >> ${int}
	service network restart
}

function print_info() {
	colored_text "Network card:"
	ifconfig -s
	colored_text "Link (ping 1 time):"
	ping 1.1.1.1 -W 1 -c 1
	colored_text "Speed, duplex:"
	ethtool enp0s3 | grep 'Speed\|Duplex'	
}

case "$opt" in
	1)echo;
	set_by_computer
	exit 0 
		;;
	2)echo;
	set_by_yourself
	exit 0
		;;
	3)echo;
	print_info
	exit 0

		;;
	*) echo; echo -e "Terminated..."
	exit 0
		;;
esac
