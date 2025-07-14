#!/bin/sh
rm /mnt/root/.viminfo
rm /mnt/root/.history
rm /mnt/root/.sh_history
rm /mnt/root/.lesshst
rm /mnt/home/sniffer/.viminfo
rm /mnt/home/sniffer/.history
rm /mnt/home/sniffer/.sh_history
rm /mnt/home/sniffer/.lesshst

sed -e 's/authname *".*"/authname "username"/' -e 's/password *".*"/password "password"/' -e 's/peer *[0-9.]*/peer 1.2.3.4/' -i .old /mnt/usr/local/etc/mpd5/mpd.conf
rm /mnt/usr/local/etc/mpd5/mpd.conf.old 

sed -e 's/ssid=".*"/ssid="SOME_NETWORK"/' -e 's/psk=".*"/psk="password"/' -i .old /mnt/etc/wpa_supplicant.conf
rm /mnt/etc/wpa_supplicant.conf.old

