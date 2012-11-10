#!/bin/bash
# name: set_vmfw
# purpose: set up iptables for virtualbox guest.
# caveate:
#	only useful while guests are running with tap bridging mode
#	but want to use nat for routing
#	it may open a BIG hole on your firewall, USING WITH CAREFUL!
# author: netman<netman@study-area.org>
# copyright: GPL
# version: 0.0.2
# date: 2007-04-12

PATH=/sbin:/usr/sbin:/bin:/usr/bin

action=$1
shift 1

# get bridge devices from parameters
while getopts "b:r" opt; do
	case $opt in
		b) br_dev=$OPTARG ;;
		r) fw_rst=1 ;;
	esac
done
# or set default to br0
br_dev=${br_dev:=br0}

# determine bridge network
br_net=`ip route | awk '/ dev '$br_dev' /{print $1}' | grep -v default`

# abort if no ip found on bridge
[ "$br_net" ] || {
	echo "$0: Error: no network routing related to $br_dev. Aborting..."
	exit 3
}

#  working on routing between network matrix
net_matrix () {
	for i in $br_net ; do
		for j in $br_net ; do
			[ $i = $j ] && continue
			iptables -t nat $1 POSTROUTING -s $i -d $j  -j ACCEPT
		done
	done
}

# reset iptables
fw_reset() {
	grep -Eiq 'redhat|fedora' /etc/*-release && {
		service iptables restart
		return 0
	}
	grep -Eiq 'suse' /etc/*-release && {
		SuSEfirewall2 stop
		SuSEfirewall2 start
		return 0
	}
	echo "$0: Warning: can't reset firewall."
	return 1
}

# bring up iptables, reset firewall on demand
fw_up() {
	[ "$fw_rst" = 1 ] && fw_reset
	sysctl -w net.ipv4.ip_forward=1
	for i in $br_net; do
		iptables -t nat -I POSTROUTING -s $i -j MASQUERADE
		iptables -I FORWARD -s $i -j ACCEPT
	done
	net_matrix -I
	iptables -I FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
}

# bring down iptables, no rules deletion applied if reset on demand
fw_down() {
	[ "$fw_rst" = 1 ] && { fw_reset ; return 0; }
	iptables -D FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
	net_matrix -D
	for i in $br_net; do
		iptables -t nat -D POSTROUTING -s $i -j MASQUERADE
		iptables -D FORWARD -s $i -j ACCEPT
	done
}

# run...
case "$action" in
	up|on|start)
		fw_up ;;
	down|off|stop)
		fw_down ;;
	*)
		echo "Usage: $0 {<up|down> [-r]}"
		exit 1
		;;
esac
exit 0
