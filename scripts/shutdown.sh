#!/bin/bash

sudo pkill wfantund

echo "reset" | spinel-cli.py -u /dev/wisun-br0
echo "reset" | spinel-cli.py -u /dev/wisun-rn0
