# BPF rule for listening to SIP response packets using DPI

Listen for SIP response packets using DPI mechanism. There are two quite simple subrules:```udp[8:4] = 0x5349502f``` and  ```udp[12:4] = 0x322e3020```, each compare two 4 bytes values from UDP payload to given constants. Constants **0x5349502f** and **0x322e3020** define a string of text "SIP/2.0 " including space character. If UDP packet has this string at the top of its payload it matches the rule. Rules ```udp[8:4]``` means "take 4 bytes offset beginning of UDP packet and represent is as 32-bit value".

Note, constants are in network (big endian) byte order.

## Example using `tcpdump'

Command:

```
tcpdump -n -i bridge0 -s 1500 -X -vv 'udp[8:4] = 0x5349502f && udp[12:4] = 0x322e3020'
```

Captured packet:

```
tcpdump: listening on bridge0, link-type EN10MB (Ethernet), snapshot length 1500 bytes
00:26:23.478943 IP (tos 0x68, ttl 254, id 375, offset 0, flags [none], proto UDP (17), length 412)
    72.243.211.106.53520 > 192.168.168.139.5060: [udp sum ok] SIP, length: 384
        SIP/2.0 100 Trying
        Via: SIP/2.0/UDP 192.168.168.139:5060;branch=z9hG4bK-gdklpgig931861861291050861291.b;rport
        0x0000:  4568 019c 0177 0000 fe11 92e1 4df2 6f6a  Eh...w......M.oj
        0x0010:  c0a8 a88b d110 13c4 0188 5447 5349 502f  ..........TGSIP/
        0x0020:  322e 3020 3130 3020 5472 7969 6e67 0d0a  2.0.100.Trying..
        0x0030:  5669 613a 2053 4950 2f32 2e30 2f55 4450  Via:.SIP/2.0/UDP
        0x0040:  2031 3932 2e31 3638 2e31 3638 2e31 3339  .192.168.168.139
        0x0050:  3a35 3036 303b 6272 616e 6368 3d7a 3968  :5060;branch=z9h
        0x0060:  4734 624b 2d67 646b 6c70 6769 6739 3331  G4bK-gdklpgig931
        0x0070:  3836 3138 3631 3239 3130 3530 3836 3132  8618612910508612
        0x0080:  3931 2e62 3b72 706f 7274 0d0a 4672 6f6d  91.b;rport..From
        0x0090:  3a20 22d0 94d0 bed0 bcd0 bed1 84d0 bed0  :.".............
        0x00a0:  bd22 203c 7369 703a 3230 3140 6661 626d  .".<sip:201@exam
        0x00b0:  6963 726f 2e72 753e 3b74 6167 3d46 726f  ples.xx>;tag=Fro
        0x00c0:  6d54 6167 2d67 646b 6c70 6769 6739 3331  mTag-gdklpgig931
        0x00d0:  3836 3138 3631 3239 3130 3530 3836 3132  8618612910508612
        0x00e0:  3931 2e62 0d0a 546f 3a20 3c73 6970 3a32  91.b..To:.<sip:2
        0x00f0:  3031 4066 6162 6d69 6372 6f2e 7275 3e0d  01@examples.xx>.
        0x0100:  0a44 6174 653a 2054 6875 2c20 3130 204a  .Date:.Thu,.10.J
        0x0110:  756c 2032 3032 3520 3136 3a33 323a 3235  ul.2025.16:32:25
        0x0120:  2047 4d54 0d0a 4361 6c6c 2d49 443a 2067  .GMT..Call-ID:.g
        0x0130:  646b 6c70 6769 6739 3331 3836 3138 3631  dklpgig931861861
        0x0140:  3239 3130 3530 3836 3132 3931 2e62 0d0a  291050861291.b..
        0x0150:  5365 7276 6572 3a20 4369 7363 6f2d 5349  Server:.Cisco-SI
        0x0160:  5047 6174 6577 6179 2f49 4f53 2d31 322e  PGateway/IOS-12.
        0x0170:  780d 0a43 5365 713a 2032 3833 2052 4547  x..CSeq:.283.REG
        0x0180:  4953 5445 520d 0a43 6f6e 7465 6e74 2d4c  ISTER..Content-L
        0x0190:  656e 6774 683a 2030 0d0a 0d0a            ength:.0....

```

## Example using `tshark'

Command:


```
tshark -n -i bridge0 -s 1500 -V 'udp[8:4] = 0x5349502f && udp[12:4] = 0x322e3020'
```

Captured packet:

```
Capturing on 'bridge0'
Frame 1: 426 bytes on wire (3408 bits), 426 bytes captured (3408 bits) on interface bridge0, id 0
    Section number: 1
    Interface id: 0 (bridge0)
        Interface name: bridge0
    Encapsulation type: Ethernet (1)
    Arrival Time: Jul 11, 2025 00:54:19.286236877 +05
    UTC Arrival Time: Jul 10, 2025 19:54:19.286236877 UTC
    Epoch Arrival Time: 1752177259.286236877
    [Time shift for this packet: 0.000000000 seconds]
    [Time delta from previous captured frame: 0.000000000 seconds]
    [Time delta from previous displayed frame: 0.000000000 seconds]
    [Time since reference or first frame: 0.000000000 seconds]
    Frame Number: 1
    Frame Length: 426 bytes (3408 bits)
    Capture Length: 426 bytes (3408 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: eth:ethertype:ip:udp:sip]
Ethernet II, Src: e8:39:35:b1:10:ee, Dst: fe:4a:eb:ea:b4:61
    Destination: fe:4a:eb:ea:b4:61
        .... ..1. .... .... .... .... = LG bit: Locally administered address (this is NOT the factory default)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
    Source: e8:39:35:b1:10:ee
        .... ..0. .... .... .... .... = LG bit: Globally unique address (factory default)
        .... ...0 .... .... .... .... = IG bit: Individual address (unicast)
    Type: IPv4 (0x0800)
    [Stream index: 0]
Internet Protocol Version 4, Src: 72.243.211.106, Dst: 192.168.168.139
    0100 .... = Version: 4
    .... 0101 = Header Length: 20 bytes (5)
    Differentiated Services Field: 0x68 (DSCP: AF31, ECN: Not-ECT)
        0110 10.. = Differentiated Services Codepoint: Assured Forwarding 31 (26)
        .... ..00 = Explicit Congestion Notification: Not ECN-Capable Transport (0)
    Total Length: 412
    Identification: 0x01a9 (425)
    000. .... = Flags: 0x0
        0... .... = Reserved bit: Not set
        .0.. .... = Don't fragment: Not set
        ..0. .... = More fragments: Not set
    ...0 0000 0000 0000 = Fragment Offset: 0
    Time to Live: 254
    Protocol: UDP (17)
    Header Checksum: 0x92af [validation disabled]
    [Header checksum status: Unverified]
    Source Address: 72.243.211.106
    Destination Address: 192.168.168.139
    [Stream index: 0]
User Datagram Protocol, Src Port: 53520, Dst Port: 5060
    Source Port: 53520
    Destination Port: 5060
    Length: 392
    Checksum: 0x5e47 [unverified]
    [Checksum Status: Unverified]
    [Stream index: 0]
    [Stream Packet Number: 1]
    [Timestamps]
        [Time since first frame: 0.000000000 seconds]
        [Time since previous frame: 0.000000000 seconds]
    UDP payload (384 bytes)
Session Initiation Protocol (100)
    Status-Line: SIP/2.0 100 Trying
        Status-Code: 100
        [Resent Packet: False]
    Message Header
        Via: SIP/2.0/UDP 192.168.168.139:5060;branch=z9hG4bK-gdklpgig931861861291050861291.b;rport
            Transport: UDP
            Sent-by Address: 192.168.168.139
            Sent-by port: 5060
            Branch: z9hG4bK-gdklpgig931861861291050861291.b
            RPort: rport
        From: "Домофон" <sip:201@samples.xx>;tag=FromTag-gdklpgig931861861291050861291.b
            SIP from display info: "Домофон"
            SIP from address: sip:201@samples.xx
                SIP from address User Part: 201
                SIP from address Host Part: samples.xx
            SIP from tag: FromTag-gdklpgig931861861291050861291.b
        To: <sip:201@samples.xx>
            SIP to address: sip:201@samples.xx
                SIP to address User Part: 201
                SIP to address Host Part: samples.xx
        Date: Thu, 10 Jul 2025 17:00:21 GMT
        Call-ID: gdklpgig931861861291050861291.b
        [Generated Call-ID: gdklpgig931861861291050861291.b]
        Server: Cisco-SIPGateway/IOS-12.x
        CSeq: 308 REGISTER
            Sequence Number: 308
            Method: REGISTER
        Content-Length: 0
```
