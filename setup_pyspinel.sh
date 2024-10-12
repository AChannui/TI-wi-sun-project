#!/bin/bash

# came from simplelink dir
# use to download pyspinel

repoDir="pyspinel_repo"
mkdir -p $repoDir
cd $repoDir
git clone https://github.com/TexasInstruments/ti-wisunfan-pyspinel
cd pyspinel_repo
cd ti-wisunfan-pyspinel
git checkout TI_WiSUN_STACK_01_00_06
pip install -r requirements.txt
