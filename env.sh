#!/bin/bash
export G='\033[1;32m'
export R='\033[1;31m'
export N='\033[0m'

export credentials=$(cat /vagrant/.edbtoken)
export LC_ALL=en_US.UTF-8

export PG1IP=192.168.0.211
export PG2IP=192.168.0.212
export BARMANIP=192.168.0.213
export PEMSERVERIP=192.168.0.214