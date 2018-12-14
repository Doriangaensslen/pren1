# This script makes WLAN Hotspot on the WLAN0 and makes there DHCP offerings.
# ETH0 still uses DHCP to get a IP if you plug it in when you connect it to your DHCP Server at home

# Please be carefull with the IP's and Hotspot names, you want to alter them to your needs

#Disable DHCP on WLAN0
sudo bash -c 'echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf'

sudo bash -c 'cat >> /etc/network/interfaces.d/wlan0 << EOF
# WLAN-Interface
allow-hotplug wlan0
iface wlan0 inet static
address 192.168.2.1
netmask 255.255.255.0
EOF'

sudo bash -c 'cat >> /etc/network/interfaces.d/lo << EOF
# Localhost
auto lo
iface lo inet loopback
EOF'

sudo bash -c 'cat >> /etc/network/interfaces.d/eth0 << EOF
# Ethernet
auto eth0
iface eth0 inet dhcp
EOF'

#Install DHCP and DNS Service
sudo apt-get install -y dnsmasq
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf_alt
sudo bash -c 'cat >> /etc/dnsmasq.conf << EOF
# DHCP-Server aktiv für WLAN-Interface
interface=wlan0

# DHCP-Server nicht aktiv für bestehendes Netzwerk
no-dhcp-interface=eth0

# IPv4-Adressbereich und Lease-Time
dhcp-range=192.168.2.100,192.168.2.150,24h

# DNS
dhcp-option=option:dns-server,192.168.2.1
EOF'


sudo apt-get install -y hostapd
sudo bash -c 'cat >> /etc/hostapd/hostapd.conf << EOF
# WLAN-Router-Betrieb

# Schnittstelle und Treiber
interface=wlan0

# WLAN-Konfiguration
ssid=pren11
channel=1
hw_mode=g
ieee80211n=1
ieee80211d=1
country_code=DE
wmm_enabled=1

# WLAN-Verschlüsselung
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=supergeheimertest
EOF'

sudo chmod 600 /etc/hostapd/hostapd.conf

#Tell the daemon where the config sits
sudo bash -c 'echo "RUN_DAEMON=yes" >> /etc/default/hostapd'
sudo bash -c 'echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd'

#start it and activate it on boot
sudo systemctl start hostapd
sudo systemctl enable hostapd
