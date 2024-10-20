#!/bin/bash 

# Starts kea docker. Will assume kea docker is already built

# first argument is docker image 

docker run --rm --net=host ${1:-alex-kea}
