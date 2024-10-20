#!/bin/bash

# one stop shop for starting wfantund, router node, border router, and kea. Must run this in tmux to work
# assumes user is running this window first panes ie pane 0

while ! tmux list-panes -t .3; do 
    tmux split-window -c $PWD
done

tmux select-layout tiled
tmux select-pane -t '.0'

for pane in 1 2 3; do 
    tmux send-keys -t ".$pane" C-c
done

tmux send-keys -t '.1' ./10-wfantund_start.sh
[[ -z "$NOCR" ]] && tmux send-keys -t '.1' C-m
sleep 5
tmux send-keys -t '.2' ./20-wfantund_configure.sh
[[ -z "$NOCR" ]] && tmux send-keys -t '.2' C-m
sleep 5
tmux send-keys -t '.3' ./30-start_kea.sh
[[ -z "$NOCR" ]] && tmux send-keys -t '.3' C-m
