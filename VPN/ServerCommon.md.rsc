#!tikbook

#.markdown
#  # Common VPN Server setup
#  
#  ## Enable Mikrotik Cloud (DDNS)
#.

/ip cloud set ddns-enabled=yes update-time=yes

#.markdown
#  ## Address planning
#  
#  Here we using 192.0.2.0/24 (TEST-NET-1) address range to avoid network conflicts. 192.0.2.254 as router address, and 192.0.2.1-192.0.2.253 for client connections address pool
#  
#  ❗️ To use your preferred addresses here, they must be set as :global before running this script.
#  
#  For example:
#  <PRE>
#  :global xplrVpnRouterIP 192.168.89.1
#  :global xplrVpnPoolRange 192.168.89.2-192.168.89.254
#  :global xplrVpnWINSIP 192.168.88.10
#  </PRE>
#.

:global xplrVpnRouterIP
:if ([:len $xplrVpnRouterIP] = 0) do={ :set xplrVpnRouterIP 192.0.2.254 }
:global xplrVpnPoolRange
:if ([:len $xplrVpnPoolRange] = 0) do={ :set xplrVpnPoolRange 192.0.2.1-192.0.2.253 }

#.markdown
#  ## Bridge loopback
#  
#  To ensure that all working correctly, creating local bridge with router IP and add it to LAN interface list.
#.

/interface bridge add name=bridge-vpnloopback comment="xplr.vpn: loopback"
    /ip address add address=$xplrVpnRouterIP/32 interface=bridge-vpnloopback comment="xplr.vpn: loopback"
    /interface list member add interface=bridge-vpnloopback list=LAN comment="xplr.vpn: loopback"

#.markdown
#  ## IP Pool
#  
#  Create address pool for VPN clients. Clients will acuire addresses from 192.0.2.1 to 192.0.2.253
#.

/ip pool add name="VPN" ranges=$xplrVpnPoolRange comment="xplr.vpn: IP Pool for clients"

#.markdown
#  ## PPTP, L2TP, SSTP connections profile
#  Create profile for VPN Connections. Use addresses from Address planning section.
#.

:global xplrVpnWINSIP

/ppp profile
    add name="default-VPN" use-encryption=required use-compression=yes change-tcp-mss=yes use-upnp=yes only-one=yes\
        local-address=$xplrVpnRouterIP\
        remote-address=VPN\
        wins-server=$xplrVpnWINSIP\
        dns-server=$xplrVpnRouterIP\
        comment="xplr.vpn: Single session vpn profile"

#.markdown
#  ⚠️ WARNING!!! When you add the parameter dns-server=x.x.x.x to the profile, you **MUST** allow port 53 on all PPP interfaces!
#  Otherwise, L2TP connections from mobile iOS/Android devices will stop working correctly!!!
#  Packet loss and lags are observed.
#.

{
    :local beforeId [/ip firewall filter find comment="defconf: accept established,related,untracked"]
    :if ([:len $beforeId]=0) do={ :set beforeId 0 }
    /ip firewall filter
    add comment="xplr.vpn: accept in DNS on !WAN interfaces"\
        action=accept\
        chain=input\
        protocol=udp\
        dst-port=53\
        in-interface-list=!WAN\
        place-before=$beforeId
}

#.markdown
#  ## Creating PPTP, L2TP, SSTP connections user
#  
#  Stable lenghts:
#  - username: 32
#  - password: 16
#  
#  Using 198.51.100.0/24	TEST-NET-2 /24 for remote network
#  203.0.113.0/24	TEST-NET-3 /30 subnet for link
#.

:global genPtPLogin do={
    :local len [:rndnum from=20 to=32]
    :return [:rndstr length=$len]
}

:global genP2PPass do={
    :local len [:rndnum from=13 to=16]
    :return [:rndstr length=$len]
}

:global ClientCommentString "John Doe, +380000000000, Device XYZ"

#.markdown
#  ### Simple Dynamic client
#  
#  Login and password are auto-generated
#  
#  `
#  /ppp secret
#  add name="[$genP2PLogin]" password="[$genP2PPass]" profile=default-VPN disabled=no\
#  comment="xplr.vpn: $ClientCommentString"
#  `
#  
#  ### Dynamic Site-To-Site with subnet routing
#  
#  `
#  /ppp secret
#  add name="[$genP2PLogin]" password="[$genP2PPass]" profile=default-VPN disabled=no\
#  routes=198.51.100.0/24\
#  comment="xplr.vpn: $ClientCommentString x Subnet 198.51.100.0/24"
#  `
#  
#  ### Static Site-To-Site with subnet routing
#  
#  
#  `
#  /ppp secret
#  add name="[$genP2PLogin]" password="[$genP2PPass]" profile=default-VPN disabled=no\
#  routes=198.51.100.0/24\
#  local-address=203.0.113.2\
#  remote-address=203.0.113.1\
#  comment="xplr.vpn: $ClientCommentString x Subnet 198.51.100.0/24 via /30 Link"
#  `
#.

