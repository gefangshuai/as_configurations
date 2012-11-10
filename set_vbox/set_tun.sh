#!/bin/bash
# name: set_tun.sh
# purpose: 
#	preparation for running virtualbox
#	using tunctl to create tap device
#	otherwise virtualbox will not able to set up tap devices on fly
# caveate:
#	- uml-utitlies must be installed
#	- it is recommended to run the script on boot
# author: netman<netman@study-area.org>
# copyright: GPL
# version: 0.0.3
# date: 2007-04-23

PATH=/usr/sbin:/sbin:/usr/bin:/bin

usage() {
	echo $"Usage: $0 {<up|down> [-u user] [-g group] [-d dir] [-t tap]}"
	exit 1
}

which tunctl &>/dev/null || {
	echo "$0: Error: command tunctl is not found."
	exit 2
}

[ "$1" ] || usage

tun_dev=/dev/net/tun
set_vbox_conf=${0%/*}/set_vbox.conf
action=$1
shift 1

# source default settings
. $set_vbox_conf

# get user and tap count or tap device in prameters
while getopts "u:g:d:t:" opt; do
    case $opt in
	u) vbox_user=$OPTARG ;;
	g) vbox_group=$OPTARG ;;
	d) vbox_conf_dir=$OPTARG ;;
	t) tap_dev=$OPTARG ;;
    esac
done

# set group default to vboxusers if not specified
[ "$vbox_group" ] || vbox_group=vboxusers
# exit if vbox group doesn't exist
grep -q "^$vbox_group:" /etc/group || {
	echo "$0: Error: can not find group $vbox_group."
	exit 4
}

# set uid who to run virtualbox
set_user() {
	# get uid according to the owner of vbox config dir
	vbox_user=`ls -ld $vbox_conf_dir | awk '{print $3}'`
	[ "$vbox_user" ] && return 0

	# or set to current user other than root
	[ `id -u` = 0 ] || {
		vbox_user=`id -un`
		return 0
	}

	# or have uid from MIN_UID
	min_uid=`awk '/^UID_MIN/{print $2}' /etc/login.defs`
	vbox_user=`awk -F: '$3=='$min_uid'{print $1}' /etc/passwd`

	# otherwise set default to root
	[ "$vbox_user" ] || {
		echo "$0: Warning: set vbox user to root."
		vbox_user=root
		return 1
	}
}

# run set_user if no user argument given
[ "$vbox_user" ] || set_user

# exit if vbox user dosn't exist
grep -q "^$vbox_user:" /etc/passwd || {
	echo "$0: Error: Can not find user $vbox_user."
	exit 5
}

# make sure the user is a member of vbox group
groups $vbox_user | grep -qw "$vbox_group" || {
	grep -qw "^$vbox_gropu:" /etc/group || sudo groupadd $vbox_group
	# redhat style or suse style
	sudo gpasswd -a $vbox_user $vbox_group 2>/dev/null || \
	sudo groupmod -A $vbox_user $vbox_group 2>/dev/null || {
		echo "$0: Error: can not add '$vbox_user' to group '$vbox_group'."
		exit 6
	}
}

# exit if vbox config directory dosn't exist
[ -d "$vbox_conf_dir" ] || {
	echo "$0: Warning: vbox config dir $vbox_conf_dir dosn't exist, trying others..."
	vbox_conf_dir=~$vbox_user/.VirtualBox/Machines
}
[ -d "$vbox_conf_dir" ] || {
	echo "$0: Error: vbox config dir $vbox_conf_dir dosn't exist."
	exit 7
}

# set tun device permission
sudo chgrp $vbox_group $tun_dev && sudo chmod 0660 $tun_dev || {
	echo "$0: Error: can not set permission to device '$tun_dev'."
	exit 8
}

# create tap devices with setting up owner
tun_up() {
	echo -e "\nCreating tap devices..."
	# configure device if name specified
	[ "$tap_dev" ] && {
		sudo tunctl -t $tap_dev -u $vbox_user || {
			echo "$0: Error: can not set up '$tun_dev' to user '$vbox_user'."
			exit 9
		}
		return 0
	}
	# otherwise configure all those found in Virtualbox Machines dir
	for i in `sed -n 's/.*name="\(tap[0-9]\+\)".*/\1/p' $vbox_conf_dir/*/*.xml`
	do
		sudo tunctl -t $i -u $vbox_user || {
			echo "$0: Error: can not set up '$i' to user '$vbox_user'."
			exit 9
		}
	done
	sudo chmod 0660 $tun_dev
}

# remove specified tap device or all those found in /proc/dev/net
tun_down() {
	echo -e "\nRemoving tap devices..."
	[ "$tap_dev" ] && {
		sudo tunctl -d $tap_dev || exit 10
		return 0
	}
	for i in `awk '/tap/{print $1}' /proc/net/dev | tr -d :`; do
		sudo tunctl -d $i || err_cnt=1
	done
	[ "$err_cnt" = 1 ] && exit 10
}

# run...
case "$action" in
	up|on|start|create)
		tun_up ;;
	down|off|stop|remove)
		tun_down ;;
	*)
		usage
		;;
esac
exit 0
