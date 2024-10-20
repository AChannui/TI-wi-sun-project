#!/bin/bash

# Script starts wfantund using the links made from the sym link script

# first argument serial port to border router

sudo wfantund -o Config:NCP:SocketPath ${1:-/dev/wisun-br0}
