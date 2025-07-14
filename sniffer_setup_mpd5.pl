#!/usr/local/bin/perl

$mpd5_etc = "/usr/local/etc/mpd5";
$mpd5_conf = "mpd.conf";

$config_file = $mpd5_etc . "/" . $mpd5_conf;

print "\n\n";
print "This simple script will guide you through configuring mpd5 for PPTP, L2TP or PPPEO.\n";
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
	print "Please, enter VPN connection type (1 - PPTP, 2 -L2TP, 3 - PPPOE, A - ALL, or Ctrl-C to exit): ";
	$vpn_type = <>;

	if($vpn_type !~ '1' && $vpn_type !~ '2' && $vpn_type !~ '3' && $vpn_type !~ 'A') {
		print "Wrong VPN type: $vpn_type";
	} else {
		$vpn_type = "PPTP" if($vpn_type =~ '1'); 
		$vpn_type = "L2TP" if($vpn_type =~ '2'); 
		$vpn_type = "PPPOE" if($vpn_type =~ '3'); 
		$vpn_type = "ALL" if($vpn_type =~ 'A'); 
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
END

if($vpn_type eq 'ALL') {
print CONFIG_FILE<<END;
        load PPPOE
        load L2TP 
        load PPTP 
END
} else {
print CONFIG_FILE<<END;
        load $vpn_type 
END
}
print CONFIG_FILE<<END;

PPPOE:
        create bundle static B0

        set iface up-script /usr/local/etc/mpd5/ifup.sh
        set iface down-script /usr/local/etc/mpd5/ifdown.sh

        create link static L0 pppoe
        set link action bundle B0
        set link max-redial 0

        set link mtu 1492
        set link keep-alive 10 60

        set auth authname "$username"
        set auth password "$password"

        set pppoe iface bridge0
        set pppoe service ""

        open

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

        create bundle static B2
        set bundle enable compression
        set ccp yes mppc
        set mppc no e40
        set mppc yes e128
        set mppc yes stateless

        set iface up-script $mpd5_etc/ifup.sh
        set iface down-script $mpd5_etc/ifdown.sh
        
        create link static L2 pptp
        set link action bundle B2
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
wanip=`route -n get default | sed -rn 's/gateway: (.*)/\1/p'` 
echo \$wanip > /tmp/.mpd5.\$1.defaultgateway
localip=`echo \$3 | sed 's/\/.*//g'`
remoteip=\$4
serverip=\$8
fibn=`echo \$1 | sed 's/[a-z]*//g'`
fib=`expr \$fibn + 1`
echo iface=\$1 fib=\$fib localip=\$3 remoteip=\$4 serverip=\$8 >> /tmp/.mpd5.\$1
ifconfig \$1 fib \$fib 
setfib \$fib route delete \$serverip
setfib \$fib route add \$serverip \$wanip
setfib \$fib route delete default
setfib \$fib route add \$localip -iface lo0 
setfib \$fib route add default \$remoteip
sed "s/#ListenAddress 0.0.0.0/ListenAddress \$localip/" /etc/ssh/sshd_config > /tmp/.mpd5.\$1.sshd_config
setfib \$fib /usr/sbin/sshd -4 -f /tmp/.mpd5.\$1.sshd_config &
END
close(IFUP);

system("chmod +x ".$mpd5_etc."/ifup.sh");

print "ifup.sh script has been written.\n";

open(IFDOWN, ">".$mpd5_etc."/ifdown.sh");

print IFDOWN<<END;
#!/bin/sh
wanip=`cat /tmp/.mpd5.\$1.defaultgateway`
fibn=`echo \$1 | sed 's/[a-z]*//g'`
fib=`expr \$fibn + 1`
setfib \$fib route delete \$4
setfib \$fib route delete default
setfib \$fib /route add default \$wanip
ifconfig \$1 fib 0
rm /tmp/.mpd5.\$1.defaultgateway
exit 0
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

system("echo net.fibs=4 >> /etc/sysctl.conf");

print "Start mpd5 now (y/N) ? ";

$yes_no = <>;

if( $yes_no =~ 'y') {
	system('service mpd5 restart');
	print "Done\n";
}

print "Configuring mpd5 has been completed.\n";


