#!/bin/bash

WFANTUND_BIN=/usr/local/sbin/wfantund

# Script starts wfantund using the links made from the sym link script

# first argument serial port to border router

sudo $WFANTUND_BIN -o Config:NCP:SocketPath ${1:-/dev/wisun-br0}
