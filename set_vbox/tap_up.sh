#!/bin/bash

PATH=/sbin:/usr/sbin:/bin:/usr/bin

${0%/*}/set_tap.sh up -t $2
