#!/bin/bash

rm keys/key*

if [ -d "pemcluster" ]; then
  rm -rf pemcluster
fi

if [ -d "pgcluster" ]; then
  rm -rf pgcluster
fi

vagrant destroy --force