# BPF rule for listening to SSH connections using DPI

Listen for SSH connections using DPI mechanism. First, find out IP header size, that is ```(ip[12:1] & 0xf0) >> 2```. Then use it as offset to peek deeper inside to find fist four bytes of payload. Compare firt 4 bytes of payload with string **SSH_**, that is what **0x5353482d** HEX constant represents. Note, constants are in network (big endian) byte order.

## Example using `tcpdump'

Command:

```
tcpdump -n -i bridge0 -s 1500 -X -vv 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x5353482d'
```

Captured packet:

```
sniffer@sniffer:~ % tcpdump -n -i bridge0 -s 1500 -X -vv 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x5353482d'
tcpdump: listening on bridge0, link-type EN10MB (Ethernet), snapshot length 1500 bytes
00:25:10.212128 IP (tos 0x48, ttl 63, id 0, offset 0, flags [DF], proto TCP (6), length 90)
    192.168.176.155.37196 > 192.168.168.139.22: Flags [P.], cksum 0x63d4 (correct), seq 3500301681:3500301719, ack 2008447800, win 257, options [nop,nop,TS val 2915515975 ecr 962763132], length 38: SSH: SSH-2.0-OpenSSH_9.9 FreeBSD-20250219
        0x0000:  4548 005a 0000 4000 3f06 60de c0a8 b09b  EH.Z..@.?.`.....
        0x0010:  c0a8 a88b 914c 0016 d0a2 5d71 77b6 7b38  .....L....]qw.{8
        0x0020:  8018 0101 63d4 0000 0101 080a adc7 3e47  ....c.........>G
        0x0030:  3962 997c 5353 482d 322e 302d 4f70 656e  9b.|SSH-2.0-Open
        0x0040:  5353 485f 392e 3920 4672 6565 4253 442d  SSH_9.9.FreeBSD-
        0x0050:  3230 3235 3032 3139 0d0a                 20250219..
00:25:10.289781 IP (tos 0x0, ttl 64, id 7554, offset 0, flags [DF], proto TCP (6), length 91)
    192.168.168.139.22 > 192.168.176.155.37196: Flags [P.], cksum 0x91b5 (correct), seq 1:40, ack 38, win 509, options [nop,nop,TS val 962763215 ecr 2915515975], length 39: SSH: SSH-2.0-OpenSSH_7.4p1 Debian-10+deb9u3
        0x0000:  4500 005b 1d82 4000 4006 42a3 c0a8 a88b  E..[..@.@.B.....
        0x0010:  c0a8 b09b 0016 914c 77b6 7b38 d0a2 5d97  .......Lw.{8..].
        0x0020:  8018 01fd 91b5 0000 0101 080a 3962 99cf  ............9b..
        0x0030:  adc7 3e47 5353 482d 322e 302d 4f70 656e  ..>GSSH-2.0-Open
        0x0040:  5353 485f 372e 3470 3120 4465 6269 616e  SSH_7.4p1.Debian
        0x0050:  2d31 302b 6465 6239 7533 0a              -10+deb9u3.
```

## Example using `tshark' 

Command:

```
tshark -n -i bridge0 -s 1500 -V 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x5353482d'
```

Captured packet:

```
Capturing on 'bridge0'
Frame 1: 104 bytes on wire (832 bits), 104 bytes captured (832 bits) on interface bridge0, id 0
    Section number: 1
    Interface id: 0 (bridge0)
        Interface name: bridge0
    Encapsulation type: Ethernet (1)
    Arrival Time: Jul 11, 2025 00:36:25.038883854 +05
    UTC Arrival Time: Jul 10, 2025 19:36:25.038883854 UTC
    Epoch Arrival Time: 1752176185.038883854
    [Time shift for this packet: 0.000000000 seconds]
    [Time delta from previous captured frame: 0.000000000 seconds]
    [Time delta from previous displayed frame: 0.000000000 seconds]
    [Time since reference or first frame: 0.000000000 seconds]
    Frame Number: 1
    Frame Length: 104 bytes (832 bits)
    Capture Length: 104 bytes (832 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ethertype:ip:tcp:ssh]
Ethernet II, Src: e8:39:35:b1:10:ee, Dst: fe:4a:eb:ea:b4:61
    Destination: fe:4a:eb:ea:b4:61
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
    Source: e8:39:35:b1:10:ee
        .... ..0. .... .... .... .... = LG bit: Globally unique address (factory default)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
    Type: IPv4 (0x0800)
    [Stream index: 0]
Internet Protocol Version 4, Src: 192.168.176.155, Dst: 192.168.168.139
    0100 .... = Version: 4
    .... 0101 = Header Length: 20 bytes (5)
    Differentiated Services Field: 0x48 (DSCP: AF21, ECN: Not-ECT)
        0100 10.. = Differentiated Services Codepoint: Assured Forwarding 21 (18)
        .... ..00 = Explicit Congestion Notification: Not ECN-Capable Transport (0)
    Total Length: 90
    Identification: 0x0000 (0)
    010. .... = Flags: 0x2, Don't fragment
        0... .... = Reserved bit: Not set
        .1.. .... = Don't fragment: Set
        ..0. .... = More fragments: Not set
    ...0 0000 0000 0000 = Fragment Offset: 0
    Time to Live: 63
    Protocol: TCP (6)
    Header Checksum: 0x60de [validation disabled]
    [Header checksum status: Unverified]
    Source Address: 192.168.176.155
    Destination Address: 192.168.168.139
    [Stream index: 0]
Transmission Control Protocol, Src Port: 45404, Dst Port: 22, Seq: 1, Ack: 1, Len: 38
    Source Port: 45404
    Destination Port: 22
    [Stream index: 0]
    [Stream Packet Number: 1]
    [Conversation completeness: Incomplete (0)]
        ..0. .... = RST: Absent
        ...0 .... = FIN: Absent
        .... 0... = Data: Absent
        .... .0.. = ACK: Absent
        .... ..0. = SYN-ACK: Absent
        .... ...0 = SYN: Absent
        [Completeness Flags: [ Null ]]
    [TCP Segment Len: 38]
    Sequence Number: 1    (relative sequence number)
    Sequence Number (raw): 2043450806
    [Next Sequence Number: 39    (relative sequence number)]
    Acknowledgment Number: 1    (relative ack number)
    Acknowledgment number (raw): 2021031524
    1000 .... = Header Length: 32 bytes (8)
    Flags: 0x018 (PSH, ACK)
        000. .... .... = Reserved: Not set
        ...0 .... .... = Accurate ECN: Not set
        .... 0... .... = Congestion Window Reduced: Not set
        .... .0.. .... = ECN-Echo: Not set
        .... ..0. .... = Urgent: Not set
        .... ...1 .... = Acknowledgment: Set
        .... .... 1... = Push: Set
        .... .... .0.. = Reset: Not set
        .... .... ..0. = Syn: Not set
        .... .... ...0 = Fin: Not set
        [TCP Flags: ·······AP···]
    Window: 257
    [Calculated window size: 257]
    [Window size scaling factor: -1 (unknown)]
    Checksum: 0x8b83 [unverified]
    [Checksum Status: Unverified]
    Urgent Pointer: 0
    Options: (12 bytes), No-Operation (NOP), No-Operation (NOP), Timestamps
        TCP Option - No-Operation (NOP)
            Kind: No-Operation (1)
        TCP Option - No-Operation (NOP)
            Kind: No-Operation (1)
        TCP Option - Timestamps: TSval 2682966770, TSecr 963437961
            Kind: Time Stamp Option (8)
            Length: 10
            Timestamp value: 2682966770
            Timestamp echo reply: 963437961
    [Timestamps]
        [Time since first frame in this TCP stream: 0.000000000 seconds]
        [Time since previous frame in this TCP stream: 0.000000000 seconds]
    [SEQ/ACK analysis]
        [Bytes in flight: 38]
        [Bytes sent since last PSH flag: 38]
    TCP payload (38 bytes)
SSH Protocol
    Protocol: SSH-2.0-OpenSSH_9.9 FreeBSD-20250219
    [Direction: client-to-server]
```

