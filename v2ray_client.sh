#!/usr/bin/env bash

v2ray_client_log='/usr/local/etc/v2ray'
v2ray_command='v2ray'
v2ray_config_dir='/usr/local/etc/v2ray'
v2ray_http_port=1087


#  代理代理设置，使得命令行下可以代理
# 国内网站不代理
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,.souche.com"
# ss, ssr, v2ray: 对curl, w3m有效，对ping无效
fq()
{
    if [ $# -eq 0 ] || [ "$1" = 'start' ]; then
        #  对curl有效，对w3m,ping 无效
        # export http_proxy="socks5h://127.0.0.1:1080"
        # export https_proxy="socks5h://127.0.0.1:1080"
        # export ftp_proxy="socks5h://127.0.0.1:1080"

        # 对curl, w3m有效，对ping无效
        export http_proxy="http://127.0.0.1:$v2ray_http_port"
        export https_proxy="http://127.0.0.1:$v2ray_http_port"
        export ftp_proxy="http://127.0.0.1:$v2ray_http_port"
        echo "终端开始代理"
    elif [ "$1" = 'stop' ]; then
        unset http_proxy
        unset https_proxy
        unset ftp_proxy
        echo "终端结束代理"
    else
        echo 'fq       : 终端开始代理'
        echo 'fq start : 终端开始代理'
        echo 'fq stop  : 终端结束代理'
    fi
}



v2_jch()
{
    ps aux | awk NR!=1 | grep " $v2ray_command " | grep -v grep
}


v2()
{
    if [ $# -eq 0 ] || [ "$1" = 'start' ]; then
        if ! [ -d "$v2ray_config_dir" ]; then
            echo "config dir not found: $v2ray_config_dir" >&2
            return
        fi

        # config文件
        local default_config="$v2ray_config_dir/config.json"
        if [ "$1" = 'start' ]; then
            local new_config="$v2ray_config_dir/$2.json"
            if [ -f "$new_config" ]; then
                if [ -f "$default_config" ]; then
                    rm $default_config
                fi
                ln -s $new_config $default_config
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
                    ln -s $new_config $default_config
                fi
            fi
        fi

        # 检查依赖存在
        if ! [ -f "$default_config" ]; then
            echo "config not found: $default_config" >&2
            return
        fi

        if ! ( command -v $v2ray_command > /dev/null ); then
            echo "command not found: $v2ray_command" >&2
            return
        fi

        touch $v2ray_client_log
        if ! [ -f "$v2ray_client_log" ]; then
            echo "log file not found: $v2ray_client_log" >&2
            return
        fi


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

        # 关闭之前的v2ray
        v2 stop

        # 开启v2ray
        ( (
            $v2ray_command  -config $default_config
        ) & ) > $v2ray_client_log 2>&1
        echo "v2ray 已启动"

        # 系统http，https代理，可使所有浏览器代理
        sudo networksetup -setwebproxy 'Wi-Fi' 127.0.0.1 $v2ray_http_port
        sudo networksetup -setsecurewebproxy 'Wi-Fi' 127.0.0.1 $v2ray_http_port
        echo "系统http, https代理开启，设为'127.0.0.1 $v2ray_http_port'"
        # 终端代理
        fq

    elif [ "$1" = 'stop' ]; then
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

        # 系统http，https结束代理
        sudo networksetup -setwebproxystate 'Wi-Fi' off
        sudo networksetup -setsecurewebproxystate 'Wi-Fi' off
        echo "系统http, https代理关闭"
        # 终端结束代理
        fq stop

    elif [ "$1" = 'jch' ] || [ "$1" = 'ps' ]; then
        ps aux | awk NR==1
        v2_jch

    elif [ "$1" = 'log' ] || [ "$1" = 'status' ]; then
        cat $v2ray_client_log

    elif [ "$1" = 'list' ]; then
        ls -la $v2ray_config_dir

    else
        echo '`v2`                 : 开启当前默认配置'
        echo '`v2 start <配置名>`  : 修改当前默认配置为<配置名>，并重启v2ray'
        echo '`v2 stop`            : 停止v2ray'
        echo '`v2 list`            : 查看所有配置'
        echo '`v2 status|log`      : 查看当前日志'
        echo '`v2 jch|ps`          : 查看当前v2ray进程'
    fi

    # unalias v2_jch
}

# unset -v v2ray_command
# unset -v v2ray_http_port
# unset -v v2ray_config_dir
