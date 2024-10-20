#!/bin/bash

# Starts up border router and router node using wfanctl and spinel. wfanctl will have a segmentation fault for each command.

# first argument serial port to router node 


echo "set interface:up true" | sudo wfanctl
echo "set stack:up true" | sudo wfanctl

echo "ifconfig up" | spinel-cli.py -u ${1:-/dev/wisun-rn0}
echo "wisunstack start" | spinel-cli.py -u /${1:-/dev/wisun-rn0}
