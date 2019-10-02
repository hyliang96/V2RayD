# 自制mac的v2ray终端管理器

## 功能

在终端管理v2ray-core，保持后台运行，切换不同的配置，自动开启实现终端、浏览器的v2ray代理

在开、关v2ray-core前，它会做以下事情

- 在mac的`系统偏好设置-网络-高级-代理`中设置，开启、关闭`http`及`https`的代理，从而让浏览器能走、不走代理
- 设置或删除 `http(s)_proxy`，从而让终端能走、不走代理
- 在v2ray-core启动前，关闭其他代理客户端（shadowsocksX-NG-R、V2RayU）以避免它们占用本方的v2ray-core需要的端口

## 安装v2ray-core

安装v2ray-core

```bash
brew install v2ray-core
```

配置文件在

```bash
/usr/local/etc/v2ray
```

## 终端管理器使用方法

将以下添加到`~/.bash_profile`之类的登录即加载文件中

```bash
. ./v2ray_client.sh
```

而后终端下，执行如下命令来管理v2ray-core进程

```bash
v2  [参数]
```

参数：

`v2`                 : 开启当前默认配置
`v2 start <配置名>`  : 修改当前默认配置为<配置名>，并重启v2ray
`v2 stop`            : 停止v2ray
`v2 list`            : 查看所有配置
`v2 status|log`      : 查看当前日志
`v2 jch|ps`          : 查看当前v2ray进程

## ToDo

### 实现开机自启

尝试了一下方法，但还无法实现开机自启

撰写一个bash脚本，位于`/path/to/LoginHook/script`，其中有一行为

```bash
/绝对路径到本项目/v2ray_deamon.sh
```

添加自启项

```bash
sudo defaults write com.apple.loginwindow LoginHook /path/to/LoginHook/script
```

撤销自启项

```bash
sudo defaults delete com.apple.loginwindow LoginHook
```

对应的文件位于`/var/root/Library/Preferences/com.apple.loginwindow.plist`

注：整个OSX只有一个loginhook（更多参见[apple官方文档](https://developer.apple.com/library/archive/technotes/tn2228/_index.html)- "Login Hook"）

更多参见：

https://support.apple.com/en-us/HT2420

https://blog.csdn.net/github_35041937/article/details/52709098

https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CustomLogin.html 