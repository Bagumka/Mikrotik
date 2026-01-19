#!tikbook

#.markdown
#  # SSTP Client to Server with Let's Encrypt Certificate
#.

#.markdown
#  ## Configure Let's Encrypt certificates
#.

/certificate settings set crl-download=yes crl-store=system crl-use=no
/tool fetch url=https://letsencrypt.org/certs/2024/r10.pem
/certificate import file-name=r10.pem
/tool fetch url=https://letsencrypt.org/certs/2024/r11.pem
/certificate import file-name=r11.pem

#.markdown
#  ## Outgoing SSTP Connection setup
#.

:local LocalNodeName "LocalNodeName"
:local RemoteNodeName "RemoteNodeName"
:local SstpServer "routerid.sn.mynetname.net"
:local SstpUser "5jBfx2eChFxA3vx1"
:local SstpPassword "sfgfdgfdgsdfgsdf"

/interface sstp-client
    add add-sni=yes authentication=mschap2 ciphers=aes256-sha,aes256-gcm-sha384 disabled=no mrru=1500 \
     pfs=yes profile=default-encryption tls-version=only-1.2 verify-server-certificate=yes \
     name=("$LocalNodeName-$RemoteNodeName-out-sstp") \
     comment=("xplr.vpn: $LocalNodeName-$RemoteNodeName SSTP") \
     connect-to=$SstpServer \
     user=$SstpUser \
     password=$SstpPassword

