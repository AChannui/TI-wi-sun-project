#!/bin/bash

echo "set interface:up true" | sudo wfanctl
echo "set stack:up true" | sudo wfanctl

echo "ifconfig up" | spinel-cli.py -u /dev/wisun-rn0
echo "wisunstack start" | spinel-cli.py -u /dev/wisun-rn0

wait
