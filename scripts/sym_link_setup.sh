#!/bin/bash

BR_SERIAL=L45002VL
BR_PORT=

RN_SERIAL=L45002UP
RN_PORT=

for port in /dev/ttyACM*; do 
    if udevadm info $port | grep -q ID_SERIAL_SHORT=$BR_SERIAL; then
        BR_PORT=$port
        break
    fi 
done


for port in /dev/ttyACM*; do 
    if udevadm info $port | grep -q ID_SERIAL_SHORT=$RN_SERIAL; then
        RN_PORT=$port
        break
    fi 
done

sudo ln -s $BR_PORT /dev/wisun-br0
sudo ln -s $RN_PORT /dev/wisun-rn0
