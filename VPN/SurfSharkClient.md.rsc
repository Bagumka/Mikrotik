#!tikbook

#.markdown
#  # based on Surfshark Wireguard setup instructions https://github.com/RouteSeeker/Mikrotik/blob/main/journal/06.Wireguard%2BSurfshark.md
#  
#  VPN > Ручная настройка > Маршрутизатор > WireGuard > Учетные данные > У меня нет пары ключей
#  Имя: Вводим понятное название.
#  Например: «My router to US NYC»
#  Дальше > Сгенерировать новую пару ключей
#  Копируем
#  ключи
#  VPN > Ручная настройка > Маршрутизатор > WireGuard > Маршрутизатор > WireGuard > Местоположение
#  Пролистать, выбрать из списка желаемую локацию, например, США, Нью-Йорк
#  Копируем
#  Адрес сервера: us-nyc.prod.surfshark.com
#  PUBLIC KEY:
#  
#.

/interface wireguard
add comment="xplr.vpn: WG to Surfshark" listen-port=51820 mtu=1380 name=wgcltsurfshark private-key=\
    "PRIVATE KEY PROVIDED BY SURFSHARK"

/ip firewall mangle
add action=change-mss chain=forward comment="xplr.vpn: WG to Surfshark" new-mss=clamp-to-pmtu protocol=tcp \
    tcp-flags=syn

/interface list
add comment="xplr.vpn: WG to Surfshark" name=PublicVPN
/interface list member
dd comment="xplr.vpn: WG to Surfshark" interface=wgcltsurfshark list=PublicVPN

/ip address
add address=10.14.0.2/16 comment="xplr.vpn: WG to Surfshark IP" interface=wgcltsurfshark network=10.14.0.0

/ip firewall nat
add action=masquerade chain=srcnat comment="xplr.vpn: NAT via WG to Surfshark" ipsec-policy=out,none \
    out-interface-list=PublicVPN

/ip firewall mangle
add action=change-ttl chain=forward comment="xplr.vpn: Hide icmp traceroute nodes via WG to Surfshark" new-ttl=\
    set:64 out-interface-list=PublicVPN

/routing table
add comment="xplr.vpn: WG to Surfshark" disabled=no fib name=Surfshark

/ip route
add comment="xplr.vpn: Default via WG to Surfshark IP" disabled=no distance=1 dst-address=0.0.0.0/0 gateway=\
    wgcltsurfshark routing-table=Surfshark scope=30 suppress-hw-offload=no target-scope=10

/routing rule
add action=lookup-only-in-table comment="xplr.vpn: route lan client via WG to Surfshark" disabled=no \
    src-address=192.168.88.100/32 table=Surfshark
add action=lookup-only-in-table comment="xplr.vpn: route lan client via WG to Surfshark" disabled=no \
    src-address=192.168.88.101/32 table=Surfshark

add action=lookup-only-in-table comment="xplr.vpn: allow lan-to-lan traffic" disabled=no \
    src-address=192.168.88.100/32 dst-address=192.168.88.0/24 table=main
add action=lookup-only-in-table comment="xplr.vpn: allow lan-to-lan traffic" disabled=no \
    src-address=192.168.88.101/32 dst-address=192.168.88.0/24 table=main

/ip firewall filter
add action=reject chain=forward comment="xplr.vpn: reject forward DNS Requests" dst-port=53 log=yes place-before=\
    0 protocol=tcp reject-with=icmp-network-unreachable

#/tool fetch url="https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem"
#/certificate import file-name=DigiCertGlobalRootCA.crt.pem
/ip dns
set allow-remote-requests=yes
set servers=1.1.1.1,1.0.0.1
set use-doh-server=https://cloudflare-dns.com/dns-query verify-doh-cert=yes

#/tool fetch url="https://secure.globalsign.com/cacert/root-r3.crt" dst-path=GlobalSignRootR3.crt
#/certificate import file-name=GlobalSignRootR3.crt
#/ip dns
#set allow-remote-requests=yes
#set servers=8.8.8.8,8.8.4.4
#set use-doh-server=https://dns.google/dns-query verify-doh-cert=yes

/interface wireguard peers
add allowed-address=0.0.0.0/0 client-dns=162.252.172.57,149.154.159.92 comment="xplr.vpn: WG to Surfshark" \
    endpoint-address=SERVERNAME.prod.surfshark.com endpoint-port=51820 interface=wgcltsurfshark name=SurfShark \
    persistent-keepalive=30s public-key="PUBLIC KEY PROVIDED BY SURFSHARK"

