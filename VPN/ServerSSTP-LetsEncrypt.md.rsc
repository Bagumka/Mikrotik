#!tikbook

#.markdown
#  # SSTP Server with Let's Encrypt Certificate
#  
#  ⚠️ NOTE: [ServerCommon.md.rsc](https://github.com/Bagumka/Mikrotik/blob/main/VPN/ServerCommon.md.rsc) should be run first !!!
#.

#.markdown
#  ## Restrict access to web GUI
#  
#  To protect from hacking, administration allowed only from LAN subnets. **Strongly recommended.**
#  *You can add remote managment IP's here if you wish.*
#.

/ip service
set www address=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16

#.markdown
#  ## Firewall rules
#  - allow TCP 80 for Let's Encrypt requests,
#  - allow TCP 443 for SSTP Connections
#.

{
    :local beforeId [/ip firewall filter find comment="defconf: accept established,related,untracked"]
    :if ([:len $beforeId]=0) do={ :set beforeId 0 }
    /ip firewall filter
    add action=accept chain=input comment="xplr.security: accept Let's Encrypt in HTTP on WAN interfaces" place-before=$beforeId\
        in-interface-list=WAN protocol=tcp dst-port=80
    add action=accept chain=input comment="xplr.vpn: accept SSTP on WAN interfaces" place-before=$beforeId\
        in-interface-list=WAN protocol=tcp dst-port=443 place-before=$beforeId
}

#.markdown
#  ## Configure Let's Encrypt certificates
#  
#  ### Install Let's Encrypt CA
#.

/certificate settings set crl-download=yes crl-store=system crl-use=no
/tool fetch url=https://letsencrypt.org/certs/2024/r10.pem
/certificate import file-name=r10.pem passphrase=""
/tool fetch url=https://letsencrypt.org/certs/2024/r11.pem
/certificate import file-name=r11.pem passphrase=""

#.markdown
#  ### Requesting server certificate
#  
#  If you have additional names, like 'vpn.static.host.com', use it as sacondary names, devided by comma:
#  
#  `
#  /certificate enable-ssl-certificate dns-name=([/ip cloud get dns-name]. ",vpn.static.host.com,1.vpn.static.host.com,2.vpn.static.host.com")
#  `
#  
#  or use by default, only Mikrotik DDNS:
#.

/certificate enable-ssl-certificate dns-name=[/ip cloud get dns-name]

#.markdown
#  ### Rename certificate to 'understandable' name
#.

/certificate/set name=("Letsencrypt-".[/ip cloud get dns-name]) [/certificate find where (common-name=[/ip cloud get dns-name] && private-key=yes && key-usage~"tls-server" && issuer ~"Let's Encrypt") ]

#.markdown
#  ## Enable SSTP server
#.

/interface sstp-server server 
    set authentication=mschap2 default-profile=default-VPN enabled=yes pfs=required tls-version=only-1.2\
    certificate=("Letsencrypt-".[/ip cloud get dns-name])

#.markdown
#  ## Stale SSTP connection workaround
#  
#  Mikrotik have small bug in SSTP. Some times disconnected connections not destroyed. This workaround monitor this kind of connections and removing them
#.

/system scheduler
add comment="xplr.vpn: Stale SSTP connection killer" \
    name=check-sstp-noencinterval=10m on-event="/system script run kill-unencrypted-sstp"\
    policy=read,write,test start-date=2025-01-01 start-time=0:00:00
/system script
add comment="xplr.vpn: Stale SSTP connection killer" dont-require-permissions=no policy=read,write,test\
    name=kill-unencrypted-sstp source=":foreach i in=[/ppp active find where service=\"sstp\" and encoding=\"\"] do={\
    \n  :log warning (\"Killing SSTP session without encryption: \" . [/ppp active get \$i name]);\
    \n  /ppp active remove \$i;\
    \n}"

#.markdown
#  ### (OPTIONAL) Configure api-ssl to use this sertificate
#.

/ip service set api-ssl certificate=("Letsencrypt-".[/ip cloud get dns-name])

