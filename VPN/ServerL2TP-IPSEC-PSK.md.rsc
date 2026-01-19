#!tikbook

#.markdown
#  # L2TP/IPsec
#  ## Разрешаем работу L2TP/IPsec сервера
#.

/interface l2tp-server server set default-profile=default-VPN enabled=yes authentication=mschap2 use-ipsec=yes ipsec-secret="MyIpSecPasswordNotMoreThan64Chars"

#.markdown
#  ## Правила firewall для работы L2TP/IPSec сервера
#.

/ip firewall filter add action=accept chain=input in-interface-list=WAN protocol=ipsec-esp comment="xplr.vpn: accept in IPsec-ESP on WAN interfaces" place-before=[find comment="defconf: accept established,related,untracked"]
/ip firewall filter add action=accept chain=input in-interface-list=WAN protocol=ipsec-ah comment="xplr.vpn: accept in IPsec-AH on WAN interfaces" place-before=[find comment="defconf: accept established,related,untracked"]
/ip firewall filter add action=accept chain=input dst-port=500 in-interface-list=WAN protocol=udp comment="xplr.vpn: accept in IPsec IKE/ISAKMP on WAN interfaces" place-before=[find comment="defconf: accept established,related,untracked"]
/ip firewall filter add action=accept chain=input dst-port=4500 in-interface-list=WAN protocol=udp comment="xplr.vpn: accept in IPsec NAT traversal on WAN interfaces" place-before=[find comment="defconf: accept established,related,untracked"]
/ip firewall filter add action=accept chain=input dst-port=1701 in-interface-list=WAN protocol=udp comment="xplr.vpn: accept in L2TP on WAN interfaces" place-before=[find comment="defconf: accept established,related,untracked"]

#.markdown
#  ## Производительность L2TP/IPSec
#  В зависимости от оборудования, выбирайте правильные протоколы для использования аппаратного ускорения шифрования: Manual:IP/IPsec - MikroTik Wiki
#.

#.markdown
#  Для CHR x86 (AES-NI):
#.

/ip ipsec proposal set [ find default=yes ] auth-algorithms=sha512,sha256,sha1 enc-algorithms="aes-256-cbc,aes-256-ctr,aes-256-gcm,aes-192-cbc,aes-192-ctr,aes-192-gcm,aes-128-cbc,aes-128-ctr,aes-128-gcm"

#.markdown
#  Для RB3011UiAS-RM:
#.

/ip ipsec proposal set [ find default=yes ] auth-algorithms=sha256,sha1 enc-algorithms="aes-256-cbc,aes-256-ctr,aes-128-cbc,aes-128-ctr,3des,des"

