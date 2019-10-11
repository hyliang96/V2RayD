#!/usr/bin/env bash

# set -o errexit
# set -e
# trap 'exit' ERR
# echo "Running v2.sh  with pid $$"

# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

. $here/v2ray_client.sh

v2 $@

# release this variable in the end of file
unset -v here

# set +e
