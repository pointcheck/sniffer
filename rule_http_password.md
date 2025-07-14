# Sniff login/password on by-passing HTTP traffic using `tshark' 

Here below is a sequence of commands illustrating how to decode login/password from HTTP traffic with Basic auth.

Note, that nowaways most web traffic is encrypted and Basic auth is not frequencty used, so this example has little practical values, except educational. 

## Writing all HTTP traffic a PCAP file 

Here we provide rules to limit to HTTP (port 80) traffic for a given host IP.


```
tshark -i bridge0 -w dump-192.168.168.139.pcap port 80 and host 192.168.168.139
```

## Learning streams that got captured and their IDs 

```
tshark -n -r dump-192.168.168.139.pcap -2 -R "http.request or http.response" -T fields -e tcp.stream
```

## Decode stream 0

```
tshark -n -r dump-192.168.168.139.pcap -z follow,tcp,ascii,0
```

A full text of HTTP request and response will be shown, from which we learn about URL redirection.


## Decode stream 1 and filter out Authorization: header containing sensitive data 

```
tshark -n -r dump-192.168.168.139.pcap -z follow,tcp,ascii,1 | grep Authorization:
```

We get the follwing result:

```
Authorization: Basic YWRtaW46cGFzc3dvcmQ=
```

## Run Base64 decoding:

```
sniffer@sniffer:~ % echo YWRtaW46cGFzc3dvcmQ= | base64 -d
admin:password
```

Here it goes, login: **admin**, password: **password**

