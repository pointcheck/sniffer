#!/usr/local/bin/perl

$mpd5_etc = "/usr/local/etc/mpd5";
$mpd5_conf = "mpd.conf";

$config_file = $mpd5_etc . "/" . $mpd5_conf;

print "\n\n";
print "This simple script will guide you through configuring mpd5 for PPTP or L2TP.\n";
print "Suggesitions address to Ruslan Zalata <rz\@fabmicro.ru>\n\n";

$id = `id -u`;

if($id != 0) {
	print "Should be run as root, example: sudo $0\n";
	exit;
}

$rc = system("pkg check mpd5");

if($rc) {
	print "mpd5 is mssing, should install is first (y/N) ? ";

	$yes_no = <>;

	if( $yes_no =~ 'y') {
		$rc = system("pkg install -y mpd5");
		if($rc != 0) {
			print "Failed to install mpd5. Abort!\n";
			exit;
		}
	}

	print "mpd5 installed successfully!\n";
}

print "\n";

while(1) {
	print "Please, enter VPN connection type (1 - PPTP, 2 -L2TP, Ctrl-C to exit): ";
	$vpn_type = <>;

	if($vpn_type !~ '1' && $vpn_type !~ '2') {
		print "Wrong VPN type: $vpn_type";
	} else {
		$vpn_type = "PPTP" if($vpn_type =~ '1'); 
		$vpn_type = "L2TP" if($vpn_type =~ '2'); 
		last;
	}
}

print "Configuring for $vpn_type\n";

while(1) {
	print "Please enter server IP: ";
	$server_ip = <>;
	chop $server_ip;

	if($server_ip !~ '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$') {
		print "Wrong IP address, should be like 1.2.3.4\n";
	} else {
		last;
	}
}

print "Configuring for server IP: $server_ip\n";

while(1) {
	print "Please enter username: ";
	$username = <>;
	chop $username;

	if($username =~ '\s|\t|@|:') {
		print "Wrong username, cannot have spaces, tabs or @ sign!\n";
	} else {
		last;
	}
}

print "Configuring for username: $username\n";

while(1) {
	print "Please enter password: ";
	$password = <>;
	chop $password;

	if($password =~ '\s|\t') {
		print "Wrong username, cannot have spaces or tabs!\n";
	} else {
		last;
	}
}

print "Configuring for password: $password\n";

if(! -d $mpd5_etc) {
	print "Creating mpd5 config directory: $mpd5_etc\n";
	mkdir $mpd5_etc;
}

if(-f $config_file) {
	print "Config config file '$config_file' already exists, overwrite (y/N) ? ";
	$yes_no = <>;

	if( $yes_no !~ 'y') {
		print "Aborted!\n";
		exit;
	}

	print "Old config file will be overwritten!\n";
}


open(CONFIG_FILE, ">".$config_file);

print CONFIG_FILE<<END;
startup:
	log +ALL +EVENTS -FRAME -ECHO

default:
        load $vpn_type 

L2TP:
        create bundle static B1

        set iface up-script $mpd5_etc/ifup.sh
        set iface down-script $mpd5_etc/ifdown.sh

        set iface enable tcpmssfix
        set ipcp yes vjcomp

        set ccp yes mppc
        set mppc yes e128
        set mppc yes stateless

        create link static L1 l2tp
        set link action bundle B1
        set link max-redial 0
        set link mtu 1460
        set link keep-alive 0 0#20 75
        set link accept chap-msv2

        set l2tp peer $server_ip
        set auth authname "$username"
        set auth password "$password"

        open

PPTP:

        create bundle static B1
        set bundle enable compression
        set ccp yes mppc
        set mppc no e40
        set mppc yes e128
        set mppc yes stateless

        set iface up-script $mpd5_etc/ifup.sh
        set iface down-script $mpd5_etc/ifdown.sh
        
        create link static L1 pptp
        set link action bundle B1
        set link max-redial 0
        set link mtu 1460
        set link keep-alive 20 75
        set pptp disable windowing

        set pptp peer $server_ip
        set auth authname "$username"
        set auth password "$password"

        open
END
close(CONFIG_FILE);

print "Config file has been written.\n";


open(IFUP, ">".$mpd5_etc."/ifup.sh");

print IFUP<<END;
#!/bin/sh
echo \$* > /tmp/.mpd5.\$1
wanip=`/sbin/route -n get default | sed -rn 's/gateway: (.*)/\\1/p'` 
echo \$wanip > /tmp/.defaultgateway
localip=\$3
remoteip=\$4
serverip=\$8
echo localip=\$3 remoteip=\$4 serverip=\$8 >> /tmp/.mpd5.\$1
/sbin/route delete \$serverip
/sbin/route add \$serverip \$wanip
/sbin/route delete default
/sbin/route add default \$remoteip
END
close(IFUP);

system("chmod +x ".$mpd5_etc."/ifup.sh");

print "ifiup.sh script has been written.\n";

open(IFDOWN, ">".$mpd5_etc."/ifdown.sh");

print IFDOWN<<END;
#!/bin/sh
wanip=`cat /tmp/.defaultgateway`
/sbin/route delete \$4
/sbin/route delete default
/sbin/route add default \$wanip
rm /tmp/.defaultgateway
END
close(IFDOWN);

system("chmod +x ".$mpd5_etc."/ifdown.sh");

print "ifdown.sh script has been written.\n";

print "Update /etc/rc.conf to auto-run mpd5 (y/N) ? ";

$yes_no = <>;

if( $yes_no =~ 'y') {
	print "Updating /etc/rc.conf using sysrc\n";
	system('sysrc mpd_enable="YES"');
	system('sysrc mpd_flags="-b"');
	print "Done\n";
}

print "Start mpd5 now (y/N) ? ";

$yes_no = <>;

if( $yes_no =~ 'y') {
	system('service mpd5 restart');
	print "Done\n";
}

print "Configuring mpd5 has been complete.\n";


