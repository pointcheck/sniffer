#!/usr/local/bin/perl

print "\n\n";
print "This simple script will guide you through configuring Ethernet Bridging interface.\n";
print "Suggesitions address to Ruslan Zalata <rz\@fabmicro.ru>\n\n";

$id = `id -u`;

if($id != 0) {
	print "Should be run as root, example: sudo $0\n";
	exit;
}


$ifaces = `ifconfig -l`;

printf "Following network interfaces are currently available:\n\n$ifaces\n\n";

if($ifaces =~ /bridge/) {

	print "Enthernet Bridging (bridge0) seems already configured, proceed with re-configuring (y/N) ? ";

	$yes_no = <>;
	
	if($yes_no !~ 'y') {
		print "Aborted!\n";
		exit;
	}
}

print "\n";

@IFACES = ();

while(1) {
	print "Provide interface name to add to the Bridge (like, `em0'), finish adding with Enter: ";
	$iface = <>;

	chop $iface;

	if($iface =~ /^[a-z]+[0-9]+$/) {
		if($ifaces =~ /$iface/) {
			push @IFACES, $iface;
			print "Interface `$iface' added, currently in the list are: ".join(' ', @IFACES)."\n";
		} else {
			print "Interface `$iface' is not available on this system!\n";
		}
	} elsif ($iface eq '') {
		last;
	} else {
		print "Wrong interface name, should have chars and digits only: $iface\n";
	}
}

print "Configuring Ethernet Bridge (bridge0) for these members: ".join(' ', @IFACES)."\n";
print "Is this correct (y/N) ? ";

$yes_no = <>;
	
if($yes_no !~ 'y') {
	print "Aborted!\n";
	exit;
}

$rc = 0;

foreach $iface (@IFACES) {
	$list .= "addm $iface ";
	$rc += system("sysrc ifconfig_$iface='up'");
}

$rc += system("sysrc cloned_interfaces='bridge0'");
$rc += system("sysrc ifconfig_bridge0='$list SYNCDHCP'");

if($rc > 0) {
	print "One or more errors occured during editing /etc/rc.conf with `sysrc'. Please check it manually!\n";
	print "Aborted!\n";
	exit;
} else {
	print "Bridge interface `bridge0' has been configured. Restart network (y/N) ? ";
}


$yes_no = <>;
	
print "Configuring Ethernet Bridge has been completed.\n";

if($yes_no !~ 'y') {
	print "You should run manually: sudo service netif restart\n";
	exit;
}

system("service netif restart");

print "Configuring Ethernet Bridge has been completed.\n";

