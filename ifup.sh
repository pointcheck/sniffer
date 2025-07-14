#!/bin/sh
echo $* > /tmp/.mpd5.$1
wanip=`route -n get default | sed -rn 's/gateway: (.*)/\1/p'` 
echo $wanip > /tmp/.mpd5.$1.defaultgateway
localip=`echo $3 | sed 's/\/.*//g'`
remoteip=$4
serverip=$8
fibn=`echo $1 | sed 's/[a-z]*//g'`
fib=`expr $fibn + 1`
echo iface=$1 fib=$fib localip=$3 remoteip=$4 serverip=$8 >> /tmp/.mpd5.$1
ifconfig $1 fib $fib 
setfib $fib route delete $serverip
setfib $fib route add $serverip $wanip
setfib $fib route delete default
setfib $fib route add $localip -iface lo0 
setfib $fib route add default $remoteip
sed "s/#ListenAddress 0.0.0.0/ListenAddress $localip/" /etc/ssh/sshd_config > /tmp/.mpd5.$1.sshd_config
setfib $fib /usr/sbin/sshd -4 -f /tmp/.mpd5.$1.sshd_config &
