#!/bin/bash

#
# setup.sh 
#
# Desc: sets up a complete Arch Linux system for JJQuin
#

function eof {
    printf "\nError: ${1}\n"
    printf "\nExiting Arch Setup Script.\n"
    exit 1
}

source ./arch.conf

source ./scripts/01-zpoolsetup.sh
source ./scripts/02-installarch.sh


