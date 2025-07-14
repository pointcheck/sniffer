#!/bin/sh
wanip=`cat /tmp/.mpd5.$1.defaultgateway`
fibn=`echo $1 | sed 's/[a-z]*//g'`
fib=`expr $fibn + 1`
setfib $fib route delete $4
setfib $fib route delete default
setfib $fib /route add default $wanip
ifconfig $1 fib 0
rm /tmp/.mpd5.$1.defaultgateway
exit 0
