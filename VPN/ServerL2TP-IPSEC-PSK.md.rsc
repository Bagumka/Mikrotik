#!tikbook

#.markdown
#  # L2TP/IPsec Server
#  
#  ⚠️ NOTE: [ServerCommon.md.rsc](https://raw.githubusercontent.com/Bagumka/Mikrotik/refs/heads/main/VPN/ServerCommon.md.rsc) should be run first !!!
#.

#.markdown
#  ## Enable L2TP/IPsec server
#  
#  For maximum compatibility, ipsec-secret should be:
#  - ASCII letters (a-Z)
#  - Numbers (0-9)
#  - **No Symbols (/\$%...)**
#  - Key Length **less** than 16 characters.
#.

{
    :local L2TPIpsecSecret "MyPSK16ASCIIChar"

    /interface l2tp-server server
    set default-profile=default-VPN enabled=yes authentication=mschap2 use-ipsec=yes\
    ipsec-secret=$L2TPIpsecSecret
}

#.markdown
#  ## Firewall rules
#  
#  - allow IPsec-ESP
#  - allow IPsec-AH
#  - allow UDP 500 for IPsec IKE/ISAKMP
#  - allow UDP 4500 for IPsec NAT traversal
#  - allow UDP 1701 for L2TP
#.

{
    :local beforeId [/ip firewall filter find comment="defconf: accept established,related,untracked"]
    :if ([:len $beforeId]=0) do={ :set beforeId 0 }
    /ip firewall filter
    add action=accept chain=input in-interface-list=WAN protocol=ipsec-esp place-before=$beforeId\
        comment="xplr.vpn: accept in IPsec-ESP on WAN interfaces"
    add action=accept chain=input in-interface-list=WAN protocol=ipsec-ah place-before=$beforeId\
        comment="xplr.vpn: accept in IPsec-AH on WAN interfaces"
    add action=accept chain=input dst-port=500 in-interface-list=WAN protocol=udp place-before=$beforeId\
        comment="xplr.vpn: accept in IPsec IKE/ISAKMP on WAN interfaces"
    add action=accept chain=input dst-port=4500 in-interface-list=WAN protocol=udp place-before=$beforeId\
        comment="xplr.vpn: accept in IPsec NAT traversal on WAN interfaces"
    add action=accept chain=input dst-port=1701 in-interface-list=WAN protocol=udp place-before=$beforeId\
        comment="xplr.vpn: accept in L2TP on WAN interfaces"
}

#.markdown
#  ## L2TP/IPSec Performance
#  
#  Depending on hardware, select correct protocols for hardware encryption acceleration.
#  See [Hardware acceleration section](https://help.mikrotik.com/docs/spaces/ROS/pages/11993097/IPsec#IPsec-Hardwareacceleration) in manual
#.

#.markdown
#  CHR x86 (AES-NI):
#.

/ip ipsec proposal set [ find default=yes ] auth-algorithms=sha512,sha256,sha1 enc-algorithms="aes-256-cbc,aes-256-ctr,aes-256-gcm,aes-192-cbc,aes-192-ctr,aes-192-gcm,aes-128-cbc,aes-128-ctr,aes-128-gcm"

#.markdown
#  RB3011UiAS-RM:
#.

/ip ipsec proposal set [ find default=yes ] auth-algorithms=sha256,sha1 enc-algorithms="aes-256-cbc,aes-256-ctr,aes-128-cbc,aes-128-ctr,3des,des"

