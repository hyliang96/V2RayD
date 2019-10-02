#!/usr/bin/env bash

# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
# here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

# Under ~/Library/LaunchAgents is auto-launching process for 'ShadowsocksX-NG-R8' and 'V2RayU'.
# ShadowsocksX-NG-R8's sslocal and proxy will launch and take place of localhost:1080 and localhost:1087,
# so V2RayU's v2ray-core and this scipt's v2ray-core can't start up at this time.
# This script open  'ShadowsocksX-NG-R8.app' and exit it, in order to exit ShadowsocksX-NG-R8's sslocal,
# Once ShadowsocksX-NG-R8's sslocal exits, V2RayU's v2ray-core will strat up within 3 second,
# so this script needs to open V2RayU.app and exit it, in order to exit V2RayU's v2ray-core.
# After that, localhost:1080 and localhost:1087 is available, and this scipt's v2ray-core can strat up.




# . $here/v2ray_client.sh
. /Users/mac/Desktop/v2ray/v2ray_client.sh
v2

# release this variable in the end of file
unset -v here
