#!/bin/bash
export N=$(tput sgr0)
export R=$(tput setaf 1)
export G=$(tput setaf 2)

export credentials=$(cat /vagrant/.edbtoken)
export LC_ALL=en_US.UTF-8

export PG1IP=192.168.0.211
export PG2IP=192.168.0.212
export BARMANIP=192.168.0.213
export PEMSERVERIP=192.168.0.214