#!/bin/bash
# name: set_tap.sh
# purpose: set up tap device for running virtualbox
# author: netman<netman@study-area.org>
# copyright: GPL
# version: 0.0.2
# date: 2007-04-12

PATH=/usr/sbin:/sbin:/usr/bin:/bin

set_br_sh=${0%/*}/set_br.sh
set_tun_sh=${0%/*}/set_tun.sh
set_vbox_conf=${0%/*}/set_vbox.conf
action=$1
shift 1

# source default settings
. $set_vbox_conf

# get bridge and tap devices from parameters
while getopts "t:b:e:" opt; do
	case $opt in
		t) tap_dev=$OPTARG ;;
		b) br_dev=$OPTARG ;;
		e) eth_dev=$OPTARG ;;
	esac
done
# or set default to device0
tap_dev=${tap_dev:=tap0}
br_dev=${br_dev:=br0}
eth_dev=${eth_dev:=eth0}

# bring up tap device and add it to bridge
# however, if tap device is not yet created by tunctl, then abort
tap_up() {
	echo -e "\nStaring $1 configuration..."
	grep -wq "$1" /proc/net/dev || $set_tun_sh up -t $1 || {
		echo "$0: Error: can not setup $1 at this time."
		echo -e "\tYou may run following command by root first:"
		echo -e "\t\t$set_tun_sh up -t $1"
		exit 3
	}
	sudo ifconfig $1 0.0.0.0 promisc
	sudo brctl addif $br_dev $1
}

# remove tap device from bridge and set it down
tap_down() {
	echo -e "\nStopping $1 configuration..."
	sudo brctl delif $br_dev $1
	sudo ifconfig $1 down
}

# check bridge status before bring up tap device
up() {
	ifconfig | grep -wq "$br_dev" || $set_br_sh up -b $br_dev -e $eth_dev || exit 4
	[ "$tap_dev" ] && tap_up $tap_dev
}

# take down tap device
down() {
	[ "$tap_dev" ] && tap_down $tap_dev
}

# run...
case "$action" in
	up|on|start)
		up ;;
	down|off|stop)
		down ;;
	reset|restart)
		down
		sleep 1
		up
		;;
	*)
		echo $"Usage: $0 {<up|down|reset> [-t tap] [-b br] [-e eth]}"
		exit 1
		;;
esac
exit 0
