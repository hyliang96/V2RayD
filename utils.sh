
v2_jch()
{
    ps aux | awk NR!=1 | grep " $v2ray_command " | grep -v grep
}


set_config()
{
    # echo "Running set_config  with pid $$" >&2
    if ! [ -d "$v2ray_config_dir" ]; then
        echo "config dir not found: $v2ray_config_dir" >&2
        return
    fi

    # config文件
    local default_config="$v2ray_config_dir/config.json"
    local new_filename="$1"

    if ! [ "$new_filename" = '' ]; then
        local new_config="$v2ray_config_dir/$new_filename.json"
        if [ -f "$new_config" ]; then
            if [ -f "$default_config" ]; then
                rm $default_config
            fi
            ln -s $(basename $new_config) $default_config
        else
            echo "config not found: $new_config" >&2
            return
        fi
    else
        # 检查config.json存在
        if ! [ -f "$default_config" ]; then
            local configs=($v2ray_config_dir/*.json)
            local new_config="${configs[1]}"
            if [ -f "$new_config" ]; then
                ln -s $(basename $new_config) $default_config
                echo "default config is set as $new_config"
            else
                echo "no *.json under $v2ray_config_dir" >&2
                return
            fi
        fi
    fi

    # 检查依赖存在
    if ! [ -f "$default_config" ]; then
        echo "default config not found: $default_config" >&2
        return
    fi

    echo "$default_config"
}

command_check()
{
    if ! ( command -v $v2ray_command > /dev/null ); then
        echo "command not found: $v2ray_command" >&2
        return
    fi
    echo '1'
}

log_check()
{
    touch $v2ray_client_log
    if ! [ -f "$v2ray_client_log" ]; then
        echo "log file not found: $v2ray_client_log" >&2
        return
    fi
    echo '1'
}

stop_other_proxy()
{
    # 关闭其他代理程序
    # Under ~/Library/LaunchAgents is auto-launching process for 'ShadowsocksX-NG-R8' and 'V2RayU'.
    # ShadowsocksX-NG-R8's sslocal and proxy will launch and take place of localhost:1080 and localhost:1087,
    # so V2RayU's v2ray-core and this scipt's v2ray-core can't start up at this time.
    # This script open  'ShadowsocksX-NG-R8.app' and exit it, in order to exit ShadowsocksX-NG-R8's sslocal,
    # Once ShadowsocksX-NG-R8's sslocal exits, V2RayU's v2ray-core will strat up within 3 second,
    # so this script needs to open V2RayU.app and exit it, in order to exit V2RayU's v2ray-core.
    # After that, localhost:1080 and localhost:1087 is available, and this scipt's v2ray-core can strat up.

    if ! [ "`ps aux | grep -F 'ShadowsocksX-NG' | grep -v grep`" = '' ]; then
        local _user=`ps aux | grep -F 'ShadowsocksX-NG' | grep -v grep | awk 'NR==1{print}' | awk '{print $1}'`
        sudo su - $_user -c 'open -a  "ShadowsocksX-NG-R8"'
        sudo su - $_user -c 'osascript -e "tell application \"ShadowsocksX-NG-R8\" to quit"'
        sleep 3
    fi


    if ( ! [ "`ps aux | grep -F './v2ray-core/v2ray' | grep -v grep`" = '' ] ) || \
        ( ! [ "`ps aux | grep -F 'V2rayU' | grep -v grep`" = '' ] ); then
        local _user=`ps aux | grep -F 'V2rayU' | grep -v grep | awk 'NR==1{print}' | awk '{print $1}'`
        if [ "$_user" = '' ]; then
            local _user=`ps aux | grep -F './v2ray-core/v2ray' | grep -v grep | awk 'NR==1{print}' | awk '{print $1}'`
        fi
        sudo su - $_user -c 'open -a "V2RayU"'
        sudo su - $_user -c 'osascript -e "tell application \"V2RayU\" to quit"'
    fi
}

v2_stop()
{
    if ! [ "`v2_jch`" = '' ]; then
        sudo killall $v2ray_command
        if [ "`v2_jch`" = '' ]; then
            echo "已关闭v2ray"
        else
            echo "未关闭v2ray"
            v2_jch
        fi
    else
        echo "no process named: $v2ray_command"
    fi
}
