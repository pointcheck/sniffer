# A set of scripts to configure Network Traffic Analyzer based on FreeBSD

Simple yet powerful network debugging tool (sniffer) can be created using mini-PC with
two Ethernet network interfaces and FreeBSD installed and configured for bridging
packets between these interfaces, thus allowing snooping on network traffic passing the bridge.

## Almost ready bootable FreeBSD image

-rw-r--r--   1 rz rz 979791320 Jul 14 15:51 Sniffer-FreeBSD-14.3-bootable.img.xz

### Step-by-step instructions

0. Insert USB flash drive into your working PC, you will need at least 5GB of disk space capacity

1. Unpack and write image data to USB stick

on FreeBSD:
```
sudo sh -c "xz -d -c Sniffer-FreeBSD-14.3-bootable.img.xz | dd of=/dev/da0 bs=1m conv=sync status=progress"
```

on Linux:
```
sudo sh -c "xz -d -c Sniffer-FreeBSD-14.3-bootable.img.xz | dd of=/dev/sdb bs=1m conv=sync status=progress"
```

2. Insert this USB stick into your sniffer mini-PC machine (it can be any other x86 based PC with two Ethernet ports) and boot it.

Do not forget to set boot sequence in BIOS to boot from USB.

3. Once booted, log in using username **sniffer** and password **reffins**

Note, root password is **1234**, do not forget to change it! 

4. Setup WiFi for remote access

```
sudo ./sniffer_setup_wifi.pl
```

5. Setup Ethernet Bridging

Connect two Ethernet ports in-between of the DUT and network. Setup `bridge0' network interface using script:

```
sudo ./sniffer_setup_bridge.pl
```

6. Optionally setup **mpd5** for PPTP, LP2TP and PPPoE tunneling to let remote access to sniffer from the Internet

```
sudo ./sniffer_setup_mpd5.pl
```

7. Reboot

```
sudo reboot
```

8. Log in again and use the sniffer

There are **tcpdump**, **tshark**, **trafshow** and **snort** tools at your disposal.

9. Some brief docs are also available

Cheatsheet with offten used commands:

```
more cheatsheet.md
```

10.  Install cheatsheet.md as MOTD (welcome message)

```
sudo cp cheatsheet.md /etc/motd.template
sudo service motd restart
```

11. Traffic sniffing, monitoring and intrusion detection examples:

```
more rule_sip.md
more rule_ssh.md
more rule_http_password.md
more snort.md
```

## Deploying your own bootable FreeBSD image

After some use, you will most likely want to deploy your own bootable image with all the configurations and scripts you created and adjusted to your needs. To ease with this task, there are two scripts provided:

1. To create FreeBSD bootable USB stick from existing system

Log in into your sniffer machine, insert new USB stick and run:
```
sudo ./make_bootable_usb.sh
```

2. To create an image file

To make an image file off of the newly created bootable USB stick, run:
```
sudo ./make_image.sh
```
 
Good luck in debugging networks!

---
Ruslan Zalata <rz@fabmicro.ru>

