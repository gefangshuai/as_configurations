#!/bin/bash
# name: set_br.sh
# purpose: set up brigde device for running virtualbox
# author: netman<netman@study-area.org>
# copyright: GPL
# version: 0.0.2
# date: 2007-04-12

PATH=/usr/sbin:/sbin:/usr/bin:/bin

which brctl &>/dev/null || {
	echo "$0: Error: command brctl is not found."
	exit 2
}

set_tun_sh=${0%/*}/set_tun.sh
set_tap_sh=${0%/*}/set_tap.sh
set_vbox_conf=${0%/*}/set_vbox.conf
action=$1
shift 1

# source default settings
. $set_vbox_conf

# get bridge, ether, tap devices from parameters
while getopts "b:e:d" opt; do
	case $opt in
		b) br_dev=$OPTARG ;;
		e) eth_dev=$OPTARG ;;
		d) set_dhcp=true ;;
	esac
done
# or set default to br0
br_dev=${br_dev:=br0}

# try first device if eth_dev is not specified
[ "$eth_dev" ] || eth_dev=`ifconfig | awk '/^eth/{print $1}' | head -1` 

# exit if no active eth_dev found
ifconfig | grep -qw "$eth_dev" || {
	echo "$0: Error: ethernet device $eth_dev is not found."
	exit 2
}

# to collect current eth_dev ip(s)
get_eth_ip() {
	eth_lines=`ip addr list dev $eth_dev | awk '/inet /{print $2}'`
	route_lines=`ip route list | grep " dev $eth_dev $"`
	# fall back to dhcp mode if no ip currently found
	[ "`echo $eth_lines | tr -d ' '`" ] || set_dhcp=true
}

# bring up bridge, and add ether interface to it
br_up() {
	echo -e "\nStaring $br_dev configuration..."
	get_eth_ip
	sudo brctl addbr $br_dev
	sudo dhclient -r $eth_dev &>/dev/null
	sudo ifdown $eth_dev || sudo ifconfig $eth_dev down
	sudo ifconfig $eth_dev 0.0.0.0 promisc
	sudo brctl addif $br_dev $eth_dev
	if [ "$set_dhcp" = true ]; then
		sudo dhclient $br_dev
	else
		for i in $eth_lines
		do
			sudo ip addr add "$i" dev $br_dev
		done
		sudo ifconfig $br_dev up
	fi
	# exit if no ip found
	br_ip="$(ifconfig | grep -wA1 $br_dev | awk '/inet /{print $2}' | cut -d: -f2)"
	[ "$br_ip" ] || {
		echo "$0: Error: no active ip bound to $br_dev."
		exit 4
	}
	[ "$route_lines" ] && {
		echo $route_lines | while read line; do
			sudo ip route add ${line//$eth_dev/$br_dev} 
		done
	}
}

# bring down bridge and restore ether with dhcp
br_down() {
	echo -e "\nStopping $br_dev configuration..."
	sudo dhclient -r $br_dev &>/dev/null
	sudo ifconfig $br_dev down
	sudo brctl delif $br_dev $eth_dev
	sudo ifconfig $br_dev down
	sudo brctl delbr $br_dev
	sudo ifconfig $eth_dev down
	sudo ifup $eth_dev || dhclient $eth_dev || exit 5
}

up() {
	br_ip="$(ifconfig | grep -wA1 $br_dev | awk '/inet /{print $2}' | cut -d: -f2)"
	[ "$br_ip" ] || br_up
}

# do not bring down bridge if there are tap devices up
down() {
	ifconfig | grep -wq "$br_dev" && {
		if ifconfig | grep -Ewq "tap[0-9]+"
		then
			echo "$0: WARNING: Tap device found, skipping..."
			echo -e "\tThere should be one or more virtual machine running."
			echo -e "\tTry 'force-down' instead if you really want to stop $br_dev."
			exit 6
		else
			br_down
		fi
	}
}

# or force down bridge with removing all tap devices
force-down() {
	for i in `ifconfig | awk '/^tap[0-9][0-9]*/{print $1}'`
	do
		$set_tap_sh down -t $i
	done
	ifconfig | grep -wq "$br_dev" && br_down
}

# run ...
case "$action" in
	up|on|start)
		up ;;
	down|off|stop)
		down ;;
	force-down|force-stop)
		force-down ;;
	*)
		echo $"Usage: $0 {<up|down|force-down> [-b br] [-e eth] [-d]}"
		exit 1
		;;
esac
exit 0
