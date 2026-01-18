#!tikbook

#.markdown
#  # Common Configuration
#.

# 2026-01-18 20:00:00 by RouterOS 7.21
# software id = ESSW-K0MJ
#
# model = wAPG-5HaxD2HaxD
# serial number =

/interface bridge
add auto-mac=yes comment=xplr.defconf name=bridge

/interface bridge port
add bridge=bridge comment="xplr.wifi.sta: defconf" interface=ether1
add bridge=bridge comment="xplr.wifi.sta: defconf" interface=ether2

/interface list
add comment=xplr.defconf name=LAN

/interface list member
add comment=xplr.defconf interface=bridge list=LAN

/ip neighbor discovery-settings
set discover-interface-list=LAN

/ip dhcp-client
add comment="xplr.wifi.sta: defconf" interface=bridge

/ip dns
set allow-remote-requests=yes
/system clock
set time-zone-name=Europe/Berlin
/system identity
set name=STATION-PSEUDOBRIDGE
/system routerboard settings
set auto-upgrade=yes

/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool romon
set enabled=yes secrets=YoUr_RoMoN_SeCrEt_HeRe

#.markdown
#  # Wi-Fi Setup
#  
#  Set Authentication type and parameters, SSID, and network to connect. Add both, 2,4 and 5 Ghz interfaces to bridge. One wifi interface in bridge should be disabled and managed by script.
#.

/interface wifi security
add authentication-types=wpa3-psk comment="xplr.wifi.sta: defconf" disabled=\
    no ft=yes ft-over-ds=yes management-protection=required name=\
    SP-EXPLORERBR passphrase=380949467003 sae-pwe=hash-to-element
/interface wifi configuration
add comment="xplr.wifi.sta: defconf" country=Germany disabled=no \
    installation=indoor mode=station-pseudobridge name=station_EXPLORERBR \
    security=SP-EXPLORERBR ssid=EXPLORERBR
/interface wifi
set [ find default-name=wifi1 ] comment="xplr.wifi.sta: 2.4Ghz" \
    configuration=station_EXPLORERBR configuration.mode=station-pseudobridge \
    disabled=no
set [ find default-name=wifi2 ] comment="xplr.wifi.sta: 5Ghz" configuration=\
    station_EXPLORERBR configuration.mode=station-pseudobridge disabled=no

/interface bridge port
add bridge=bridge comment="xplr.wifi.sta: defconf" disabled=yes interface=wifi1
add bridge=bridge comment="xplr.wifi.sta: defconf" interface=wifi2

#.markdown
#  # Wifi managment script.
#  
#  Script monitors connection state of wifi links.
#  
#  When this AP connecting to uplink, even if it configured to connect to 2,4 and 5 Ghz simultaneously, by default, Mikrotik cannot switch between 2,4 and 5Ghz automatically. 2 interfaces working together conflicts.
#  If both, 2,4 and 5 Ghz interfaces connected, only 5Ghz enabled in bridge.
#  if 5 Ghz interface disconnected for some reason, for example, DFS, 5 Ghz interface will be set disabled, and 2,4 will set enablen in bridge.
#  
#  Script will run check every 5 seconds.
#.

/system script
add comment="xplr.wifi.sta: wifi bridge failover" dont-require-permissions=no \
    name=wifi-bridge-failover owner=Bagumka policy=read,write,test source=":gl\
    obal wf5g\
    \n:global wf24\
    \n:global wfactive\
    \n\
    \n:local r1 [/interface/wifi/registration-table print as-value where inter\
    face=\"wifi1\"]\
    \n:local r2 [/interface/wifi/registration-table print as-value where inter\
    face=\"wifi2\"]\
    \n\
    \n:local b1 \"\"\
    \n:local b2 \"\"\
    \n\
    \n:if ([:len \$r1] > 0) do={ :set b1 ([:pick \$r1 0]->\"band\") }\
    \n:if ([:len \$r2] > 0) do={ :set b2 ([:pick \$r2 0]->\"band\") }\
    \n\
    \n# detect 5G / 2.4G\
    \n:if (\$b1~\"^5ghz\") do={ :set wf5g \"wifi1\"; :set wf24 \"wifi2\" }\
    \n:if (\$b2~\"^5ghz\") do={ :set wf5g \"wifi2\"; :set wf24 \"wifi1\" }\
    \n:if (\$b1~\"^2ghz\") do={ :set wf24 \"wifi1\"; :set wf5g \"wifi2\" }\
    \n:if (\$b2~\"^2ghz\") do={ :set wf24 \"wifi2\"; :set wf5g \"wifi1\" }\
    \n\
    \n# not detected - exit\
    \n:if ((\$wf5g=\"\") or (\$wf24=\"\")) do={ :return }\
    \n\
    \n# 5 GHz priority\
    \n:local c5 [/interface/wifi/registration-table print count-only where int\
    erface=\$wf5g]\
    \n:local target \"\"\
    \n:local other \"\"\
    \n\
    \n:if (\$c5 > 0) do={\
    \n    :set target \$wf5g\
    \n    :set other \$wf24\
    \n} else={\
    \n    :set target \$wf24\
    \n    :set other \$wf5g\
    \n}\
    \n\
    \n# current bridge ports status\
    \n:local tId [/interface/bridge/port find interface=\$target]\
    \n:local oId [/interface/bridge/port find interface=\$other]\
    \n\
    \n:local tDis [/interface/bridge/port get \$tId disabled]\
    \n:local oDis [/interface/bridge/port get \$oId disabled]\
    \n\
    \n# switch only if we need it \
    \n:if ((\$tDis=yes) or (\$oDis=no)) do={\
    \n    /interface/bridge/port set \$tId disabled=no\
    \n    /interface/bridge/port set \$oId disabled=yes\
    \n\
    \n    :set wfactive \$target\
    \n    :log info (\"wifi-failover: switched to \" . \$target . \" (5G=\" . \
    \$wf5g . \", 2G=\" . \$wf24 . \")\")\
    \n}"
/system scheduler
add comment="xplr.wifi.sta: wifi bridge failover" interval=5s name=schedule1 \
    on-event="/system/script/run wifi-bridge-failover" policy=read,write,test \
    start-date=2026-01-01 start-time=0:0:0

