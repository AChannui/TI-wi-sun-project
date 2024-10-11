#!/bin/bash


echo "BR:"
echo "routerstate" | spinel-cli.py -u /dev/wisun-br0
echo "" 
echo "RN:" 
echo "routerstate" | spinel-cli.py -u /dev/wisun-rn0
