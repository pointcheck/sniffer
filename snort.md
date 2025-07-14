# Using `snort3' for detecting TCP port-scan

There are many way to perform TCP port-scan, some are quite sophisticated and cannot be easily detected. Firts, let's take a look on a simplest and most common way.

## Using snort3 to detect TCP-SYN port-scan with a simple one-line rule

The follow rule ```alert tcp any any -> any any (flags:S; dsize:0; msg:"Possible NMAP TCP port scan"; sid: 1231213;)'``` detects packets with TCP-SYN flag set and with zero sized payload which what is commonly used when scanning TCP ports. So, we can detect this with ```snort``` like this:


# Command:

```
snort -i bridge0 -A fast --rule 'alert tcp any any -> any any (flags:S; dsize:0; msg:"Possible NMAP TCP port scan"; sid: 1231213;)'
```


## Using built-in plugin 'port_scan'

Snort has a built-in plugin call `port_scan' to detect complex port-scan attacks. To enable it, we have to edit default configuration file ```/usr/local/etc/snort/snort.lua```:

```
sudo ee /usr/local/etc/snort/snort.lua
```

Find a string definining ```port_scan``` variable and set it to (you will have to remove comments "-- "):

```
port_scan = default_hi_port_scan
```

Next, find definition if ```ips``` variable and set it to something like:

```
ips =
{
    -- use this to enable decoder and inspector alerts
    enable_builtin_rules = true,
}
```

You will need to uncomment ```enable_builtin_rules = true```.

Save file and exit.

Now you can run snort3 with the following command like params:

```
snort -c /usr/local/etc/snort/snort.lua -i bridge0 -A fast
```

### Test for detecting TCP port scan

Command:

```
rz@butterfly:~ % sudo nmap -v 192.168.168.139 
Starting Nmap 7.94 ( https://nmap.org ) at 2025-07-12 18:12 +05 
Initiating Ping Scan at 18:12 
Scanning 192.168.168.139 [4 ports] 
Completed Ping Scan at 18:12, 0.00s elapsed (1 total hosts) 
Initiating Parallel DNS resolution of 1 host. at 18:12 
Completed Parallel DNS resolution of 1 host. at 18:12, 0.00s elapsed 
Initiating SYN Stealth Scan at 18:12 
Scanning 192.168.168.139 [1000 ports] 
Discovered open port 80/tcp on 192.168.168.139 
Discovered open port 22/tcp on 192.168.168.139 
Completed SYN Stealth Scan at 18:12, 1.81s elapsed (1000 total ports) 
Nmap scan report for 192.168.168.139 
Host is up (0.015s latency). 
Not shown: 998 closed tcp ports (reset) 
PORT   STATE SERVICE 
22/tcp open  ssh 
80/tcp open  http 

Read data files from: /usr/local/share/nmap 
Nmap done: 1 IP address (1 host up) scanned in 1.83 seconds 
           Raw packets sent: 1015 (44.636KB) | Rcvd: 1001 (40.036KB) 
```

Snort will report:

```
07/12-21:06:02.701981 [**] [122:1:1] "(port_scan) TCP portscan" [**] [Priority: 3] {TCP} 192.168.168.139:5950 -> 192.168.176.155:61333 
07/12-21:06:02.702141 [**] [122:1:1] "(port_scan) TCP portscan" [**] [Priority: 3] {TCP} 192.168.176.155:61333 -> 192.168.168.139:617 
07/12-21:06:02.702208 [**] [122:1:1] "(port_scan) TCP portscan" [**] [Priority: 3] {TCP} 192.168.168.139:617 -> 192.168.176.155:61333 
07/12-21:06:02.702372 [**] [122:1:1] "(port_scan) TCP portscan" [**] [Priority: 3] {TCP} 192.168.176.155:61333 -> 192.168.168.139:9009 
07/12-21:06:02.702434 [**] [122:1:1] "(port_scan) TCP portscan" [**] [Priority: 3] {TCP} 192.168.168.139:9009 -> 192.168.176.155:61333 
07/12-21:06:02.703011 [**] [122:1:1] "(port_scan) TCP portscan" [**] [Priority: 3] {TCP} 192.168.176.155:61333 -> 192.168.168.139:9503 
07/12-21:06:02.703072 [**] [122:1:1] "(port_scan) TCP portscan" [**] [Priority: 3] {TCP} 192.168.168.139:9503 -> 192.168.176.155:61333 
07/12-21:06:02.703462 [**] [122:1:1] "(port_scan) TCP portscan" [**] [Priority: 3] {TCP} 192.168.176.155:61333 -> 192.168.168.139:3371 
```


### Test for detecting UDP port scan

Command:

```
rz@butterfly:~ % sudo nmap -v -sU 192.168.168.139 

Starting Nmap 7.94 ( https://nmap.org ) at 2025-07-12 18:10 +05 
Initiating Ping Scan at 18:10 
Scanning 192.168.168.139 [4 ports] 
Completed Ping Scan at 18:10, 0.00s elapsed (1 total hosts) 
Initiating Parallel DNS resolution of 1 host. at 18:10 
Completed Parallel DNS resolution of 1 host. at 18:10, 0.00s elapsed 
Initiating UDP Scan at 18:10 
Scanning 192.168.168.139 [1000 ports] 
Increasing send delay for 192.168.168.139 from 0 to 50 due to max_successful_tryno increase to 4 
```

Snort will report:

```
07/12-21:04:38.489675 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {UDP} 192.168.176.155:47076 -> 192.168.168.139:34578 
07/12-21:04:38.489820 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {UDP} 192.168.176.155:47076 -> 192.168.168.139:17207 
07/12-21:04:38.490334 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {ICMP} 192.168.168.139 -> 192.168.176.155 
07/12-21:04:38.496755 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {UDP} 192.168.176.155:47076 -> 192.168.168.139:18821 
07/12-21:04:39.660300 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {UDP} 192.168.176.155:47078 -> 192.168.168.139:18821 
07/12-21:04:39.660512 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {UDP} 192.168.176.155:47078 -> 192.168.168.139:17207 
07/12-21:04:39.660890 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {ICMP} 192.168.168.139 -> 192.168.176.155 
07/12-21:04:39.714057 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {UDP} 192.168.176.155:47074 -> 192.168.168.139:49193 
07/12-21:04:40.795739 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {UDP} 192.168.176.155:47076 -> 192.168.168.139:49193 
07/12-21:04:40.796073 [**] [122:17:1] "(port_scan) UDP portscan" [**] [Priority: 3] {ICMP} 192.168.168.139 -> 192.168.176.155 
```


### Test for detecting IP scan

Command:

```
rz@butterfly:~ % sudo nmap -v -sO 192.168.168.139 
Starting Nmap 7.94 ( https://nmap.org ) at 2025-07-12 18:09 +05 
Initiating Ping Scan at 18:09 
Scanning 192.168.168.139 [4 ports] 
Completed Ping Scan at 18:09, 0.00s elapsed (1 total hosts) 
Initiating Parallel DNS resolution of 1 host. at 18:09 
Completed Parallel DNS resolution of 1 host. at 18:09, 0.00s elapsed 
Initiating IPProto Scan at 18:09 
Scanning 192.168.168.139 [256 ports] 
```

Snort will report:

```
07/12-21:03:56.396242 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {ICMP} 192.168.168.139 -> 192.168.176.155 
07/12-21:03:56.737086 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:57.064270 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:57.385228 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:57.385881 [**] [116:253:1] "(icmp4) ICMP original IP payload < 64 bits" [**] [Priority: 3] {ICMP} 192.168.168.139 -> 192.168.176.155 
07/12-21:03:57.385881 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {ICMP} 192.168.168.139 -> 192.168.176.155 
07/12-21:03:57.726043 [**] [116:449:1] "(decode) unassigned/reserved IP protocol" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:57.726043 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:58.067370 [**] [116:449:1] "(decode) unassigned/reserved IP protocol" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:58.067370 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:58.396691 [**] [116:449:1] "(decode) unassigned/reserved IP protocol" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:58.396691 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
07/12-21:03:58.396916 [**] [116:253:1] "(icmp4) ICMP original IP payload < 64 bits" [**] [Priority: 3] {ICMP} 192.168.168.139 -> 192.168.176.155 
07/12-21:03:58.396916 [**] [122:9:1] "(port_scan) IP protocol scan" [**] [Priority: 3] {ICMP} 192.168.168.139 -> 192.168.176.155 
07/12-21:03:59.038868 [**] [116:449:1] "(decode) unassigned/reserved IP protocol" [**] [Priority: 3] {IP} 192.168.176.155 -> 192.168.168.139 
```



## Enabling community rules in `snort3' 


There is a publicly updated database of rules for snort3 to detect knows networt attacks. You will have to download there rules anuallt from https://www.snort.org/downloads

Usually file name is ```snort3-community-rules.tar.gz```. Unpack it to ```/usr/local/etc/snort/rules``` directory:

```
sniffer@sniffer:~ % sudo tar -zxf snort3-community-rules.tar.gz -C /usr/local/etc/snort/rules/
```


Then edit configuration file to add path to these rules. Call ```ee``` again and the folling to ```ips``` varibale:

ips =
{
    -- use this to enable decoder and inspector alerts
    enable_builtin_rules = true,

    -- use include for rules files; be sure to set your path
    -- note that rules files can include other rules files
    -- (see also related path vars at the top of snort_defaults.lua)

    variables = default_variables,
    rules = [[   
    include $RULE_PATH/snort3-community-rules/snort3-community.rules
    include $RULE_PATH/local.rules
    -- alert ( gid:122; sid:1; msg:"tcp port scan"; )
    ]]
}
```

Run snort3 as before:

```
snort -c /usr/local/etc/snort/snort.lua -i bridge0 -A fast
```

Check with ```nmap``` and see what get.

