
Welcome to FreeBSD!

You are connected to Network Sniffer.

Show all traffic flows, one per line, excluding ARP, SSH and GRE:

	% tcpdump -n -i bridge0 not port 22 and not arp and not proto gre 
	% tshark -n -i bridge0 not port 22 and not arp and not proto gre 

Record all traffic flows to PCAP file, except ARP, SSH and GRE:

	% tcpdump -w /tmp/dump.pcap not port 22 and not arp and not proto gre

Analyze SIP traffic only:

	% tcpdump -i bridge0 -s 1500 -vvv -A udp and port 5060
	% tshark -n -i bridge0 -V -T tabs -Y sip port 5060

Show content of HTTP protocol: 

	% tshark -n -i bridge0 -V -Y http

Show content of IPP (Internet Printing Protocol):

	% tshark -n -i bridge0 -V -Y ipp

Display network load and CPS per flow, excluding tunnels and SSH:

	% trafshow -n -i bridge0 not port 22 and not arp and not proto gre

Intrusion detection:

	% snort -c /usr/local/etc/snort/snort.lua -i bridge0 -A fast

---
This setup of FreeBSD was prepared for you by Ruslan Zalata <rz@fabmicro.ru>

