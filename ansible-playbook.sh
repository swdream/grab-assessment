#!/bin/bash
set -ex

ansible-playbook -i environments/$1 $1.yml
