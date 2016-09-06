#!/bin/bash

SCRIPT_NAME=$0
TASK=$1
STATE=$2

RED=$'\e[1;31m'
BLUE=$'\e[1;34m'
NOCOLOR=$'\e[0m'
YELLOW=$'\e[1;33m'
GREEN=$'\e[1;32m'

if [ "x${TASK}" = "xmysqldump" ]; then
    mysqldump -u test  -pgte53jewe -h 127.0.0.1  --triggers=false panda > $HOME/shell.sql
    if [ $? -eq 0 ]; then
        echo "${BLUE}Database dump successfully saved to yours home directory ($HOME/shell.sql)${NOCOLOR}";
    else
        echo "${RED}Something went wrong. Please read error above.${NOCOLOR}"
    fi
elif [ "x${TASK}" = "xfirewall" ]; then
    if [ "$EUID" -ne 0 ]; then
        echo "${RED}ROOT access needed${NOCOLOR}";
        exit
    fi
    if [ "x${STATE}" = "x--on" ]; then
        ufw disable
        if [ $? -eq 0 ]; then
            echo "${BLUE}Firewall enabled${NOCOLOR}"
        else
            echo "${RED}Something went wrong. Please read error above.${NOCOLOR}"
        fi
    elif [ "x${STATE}" = "x--off" ]; then
        ufw enable
        if [ $? -eq 0 ]; then
            echo "${BLUE}Firewall is disabled${NOCOLOR}";
        else
            echo "${RED}Something went wrong. Please read error above.${NOCOLOR}"
        fi
    else
        echo "${RED}Invalid parameter for firewall switcher. Available parameters is --on/--off${NOCOLOR}";
    fi
elif [ "x${TASK}" = "x--h" ]; then
    echo "${GREEN}This Bash script gives possibility to run commands from test task for${NOCOLOR} ${YELLOW}GlobalLogic${NOCOLOR}";
    echo "${GREEN}Available parameters is mysqldump and firewall --on/--off (needs SUDO access). Have a nice day :)${NOCOLOR}";
else
    echo "Type $0 --h to read instruction.";
fi