# 2026-01-26 22:48:55 by RouterOS 7.21.1
# software id = Z6CN-1BES
#
# model = cAPGi-5HaxD2HaxD&EG12-EA
# serial number = HHG0AAF400V
/interface bridge
add admin-mac=F4:1E:57:9B:41:CB auto-mac=no comment=defconf name=bridge
/interface wifi
set [ find default-name=wifi1 ] channel.skip-dfs-channels=10min-cac configuration.country=Ukraine .mode=ap .ssid="2.1 MW SPP" disabled=no security.authentication-types=\
    wpa2-psk,wpa3-psk .ft=yes .ft-over-ds=yes .passphrase=Guris1985
set [ find default-name=wifi2 ] channel.skip-dfs-channels=10min-cac configuration.country=Ukraine .mode=ap .ssid="2.1 MW SPP" disabled=no security.authentication-types=\
    wpa2-psk,wpa3-psk .ft=yes .ft-over-ds=yes .passphrase=Guris1985
add configuration.ssid="2.1 MW SPP_Guest" disabled=no mac-address=F6:1E:57:9B:41:CD master-interface=wifi1 name=wifi3 security.passphrase=Center2025
add configuration.ssid="2.1 MW SPP_Guest" disabled=no mac-address=F6:1E:57:9B:41:CE master-interface=wifi2 name=wifi4 security.passphrase=Center2025
/interface lte
set [ find default-name=lte1 ] allow-roaming=no band="" pin=3812
/interface ethernet switch
set 0 cpu-flow-control=yes
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/ip pool
add name=dhcp ranges=192.168.68.100-192.168.68.200
/ip dhcp-server
add address-pool=dhcp interface=bridge name=defconf
/queue type
add fq-codel-ecn=no kind=fq-codel name=fq-codel-ethernet-default
/queue interface
set ether1 queue=fq-codel-ethernet-default
set ether2 queue=fq-codel-ethernet-default
/disk settings
set auto-media-interface=bridge auto-media-sharing=yes auto-smb-sharing=yes
/interface bridge filter
add action=drop chain=forward in-interface=wifi3
add action=drop chain=forward out-interface=wifi3
add action=drop chain=forward in-interface=wifi4
add action=drop chain=forward out-interface=wifi4
/interface bridge port
add bridge=bridge comment=defconf interface=ether2
add bridge=bridge comment=defconf interface=wifi1
add bridge=bridge comment=defconf interface=wifi2
add bridge=bridge interface=wifi3
add bridge=bridge interface=wifi4
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=lte1 list=WAN
/ip address
add address=192.168.68.1/24 comment=defconf interface=bridge network=192.168.68.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add default-route-tables=main interface=ether1
/ip dhcp-server network
add address=192.168.68.0/24 comment=defconf dns-server=192.168.68.1 gateway=192.168.68.1 netmask=24
/ip dns
set allow-remote-requests=yes
/ip dns static
add address=192.168.68.1 comment=defconf name=router.lan type=A
/ip firewall address-list
add address=vpn.explorer.od.ua list=Administration
/ip firewall filter
add action=accept chain=input src-address-list=Administration
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" ipsec-policy=out,none out-interface-list=WAN
/ip upnp
set enabled=yes
/ip upnp interfaces
add interface=bridge type=internal
add interface=lte1 type=external
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" dst-port=33434-33534 protocol=udp
add action=accept chain=input comment="defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=ipsec-esp
add action=accept chain=input comment="defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=ipsec-esp
add action=accept chain=forward comment="defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
/ipv6 nd
set [ find default=yes ] advertise-dns=yes
/system clock
set time-zone-name=Europe/Kiev
/system identity
set name=2.1_MW_SPP
/system routerboard mode-button
set enabled=yes on-event=dark-mode
/system script
add comment=defconf dont-require-permissions=no name=dark-mode owner=*sys policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="\r\
    \n   :if ([system leds settings get all-leds-off] = \"never\") do={\r\
    \n     /system leds settings set all-leds-off=immediate \r\
    \n   } else={\r\
    \n     /system leds settings set all-leds-off=never \r\
    \n   }\r\
    \n "
/system watchdog
set ping-timeout=5m watch-address=1.1.1.1
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool romon
set enabled=yes secrets="4z%0\$N60W.q;"