#!tikbook

#.markdown
#  # PPTP Server
#  
#  ⚠️ NOTE: [ServerCommon.md.rsc](https://github.com/Bagumka/Mikrotik/blob/main/VPN/ServerCommon.md.rsc) should be run first !!!
#  
#  🚨 **WARNING!!!** PPTP connections are considered unsafe, it is suggested to use a more modern VPN protocol instead
#.

#.markdown
#  ## Enable PPTP server
#.

/interface pptp-server server 
set default-profile=default-VPN enabled=yes authentication=mschap2

#.markdown
#  ## Firewall rules
#  - allow TCP 1723 for PPTP Connections
#.

{
    :local beforeId [/ip firewall filter find comment="defconf: accept established,related,untracked"]
    :if ([:len $beforeId]=0) do={ :set beforeId 0 }
    /ip firewall filter
    add action=accept chain=input comment="xplr.vpn: accept PPTP on WAN interfaces" place-before=$beforeId\
        in-interface-list=WAN protocol=tcp dst-port=1723 place-before=$beforeId
}

