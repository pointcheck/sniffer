#!/usr/local/bin/perl

$config_file = "/etc/wpa_supplicant.conf";

print "\n\n";
print "This simple script will guide you through configuring WiFI using wpa_supplicant.\n";
print "Suggesitions address to Ruslan Zalata <rz\@fabmicro.ru>\n\n";

$id = `id -u`;

if($id != 0) {
	print "Should be run as root, example: sudo $0\n";
	exit;
}

$rc = system("which wpa_cli");

if($rc) {
	print "wpa_cli is mssing, should install is first (y/N) ? ";

	$yes_no = <>;

	if( $yes_no =~ 'y') {
		$rc = system("pkg install -y wpa_supplicant");
		if($rc != 0) {
			print "Failed to install wpa_supplicant. Abort!\n";
			exit;
		}
	}

	print "wpa_supplicant installed successfully!\n";
}

print "\n";


print "Scanning for available WiFi networks...\n";
system("wpa_cli scan");
sleep(3);
system("wpa_cli scan_results");

while(1) {
	print "Please, enter SSID: ";
	$ssid = <>;

	chop $ssid;

	if($ssid =~ /[\s\t]+/) {
		print "Wrong SSID, cannot use spaces: $ssid";
	} else {
		last;
	}
}

print "Configuring for $ssid\n";

while(1) {
	print "Please enter PSK key: ";
	$psk_key = <>;
	chop $psk_key;

	if($psk_key =~ /[\s\t]+/) {
		print "Wrong PSK key, cannot use spaces: $psk_key\n";
	} else {
		last;
	}
}

print "Configuring for PSK key: $psk_key\n";

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
ctrl_interface=/var/run/wpa_supplicant
eapol_version=2
ap_scan=1
fast_reauth=1

network={
       ssid="$ssid"
       scan_ssid=1
       psk="$psk_key"
       priority=1
}

network={
        priority=0
        key_mgmt=NONE
}
END
close(CONFIG_FILE);

print "Config file has been written.\n";

print "Restart WiFi now (y/N) ? ";

$yes_no = <>;

if( $yes_no =~ 'y') {
	system('service netif restart wlan0');
	print "Done\n";
}

print "Configuring WiFi has been completed.\n";


