#!/bin/bash

# stops the wfantund
# assumes user is running this window first panes ie pane 0

./shutdown.sh

tmux send-keys -t '.3' C-c
