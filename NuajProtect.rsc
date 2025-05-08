# NuajProtect Security Suite for Mikrotik
# 
# (c) Nuaj Company Inc.
# v1.0
# Jan 10, 2024
# 
#---------------------------------------------------------------
# Note:
# 
# Pre-configuration Requirement
#-------------------------------
# 1) "WAN" interface list should include all WAN interfaces
# 2) Management access and other system services should be set on
#    their own VRF for a dedicated console port
#
#
# Install Script
#----------------
# 1) Upload script, Files > upload
# 2) Go to router terminal
# 3) type > /import NuajProtect
#
#
# Post Instalation Configuration
#--------------------------------
# 1) Add source IP to "NuajP-Source-WhiteList" to allow all 
#    unfiltered traffic from the source IP.
# 2) Add destination IP to "NuajP-Destination-Whitelist" to allow
#    all unfiltered traffic to the destination IP.
# 3) Add destination IP to "NuajP-DNS-Servers" to allow
#    inbound DNS request to DNS server inside the network 
#
#



#
# Portion of Blacklist scripts and list provide by Joshaven Potter
# http://joshaven.com
# 

# Remove old definitions
#------------------------
/system script remove [find where comment~"^NuajProtect"]
/system scheduler remove [find where comment~"^NuajProtect"]

# Static Blacklist: Dsheild
# --------------------------------------------------------------
# Script which will download the drop list as a text file
/system script add name="Download_dshield" comment="NuajProtect" source={
/tool fetch url="http://blacklist.nuaj.ca/dshield.rsc" mode=http;
:log info "Downloaded dshield.rsc";

}

# Script which will Remove old dshield list and add new one
/system script add name="Replace_dshield" comment="NuajProtect" source={
/ip firewall address-list remove [find where comment="DShield"]
/import file-name=dshield.rsc;
:log info "Removed old dshield records and imported new list";
}

# Schedule the download and application of the dshield list
/system scheduler add comment="NuajProtect - Download dshield list" interval=3d \
  name="DownloadDShieldList" on-event=Download_dshield \
  start-date=jan/01/1970 start-time=21:41:11
/system scheduler add comment="NuajProtect - Apply dshield List" interval=3d \
  name="InstallDShieldList" on-event=Replace_dshield \
  start-date=jan/01/1970 start-time=21:46:11
# --------------------------------------------------------------


# Static Blacklist: Malc0de
# --------------------------------------------------------------
# Script which will download the malc0de list as a text file
/system script add name="Download_malc0de" comment="NuajProtect" source={
/tool fetch url="http://blacklist.nuaj.ca/malc0de.rsc" mode=http;
:log info "Downloaded malc0de.rsc";
}

# Script which will Remove old malc0de list and add new one
/system script add name="Replace_malc0de" comment="NuajProtect" source={
/ip firewall address-list remove [find where comment="malc0de"]
/import file-name=malc0de.rsc;
:log info "Removed old malc0de records and imported new list";
}

# Schedule the download and application of the malc0de list
/system scheduler add comment="NuajProtect - Download malc0de list" interval=3d \
  name="Downloadmalc0deList" on-event=Download_malc0de \
  start-date=jan/01/1970 start-time=21:41:11
/system scheduler add comment="NuajProtect - Apply malc0de List" interval=3d \
  name="Installmalc0deList" on-event=Replace_malc0de \
  start-date=jan/01/1970 start-time=21:46:11
# --------------------------------------------------------------


# Static Blacklist: Spamhaus
# --------------------------------------------------------------
# Script which will download the drop list as a text file
/system script add name="DownloadSpamhaus" comment="NuajProtect" source={
/tool fetch url="http://blacklist.nuaj.ca/spamhaus.rsc" mode=http;
:log info "Downloaded spamhaus.rsc";
}

# Script which will Remove old Spamhaus list and add new one
/system script add name="ReplaceSpamhaus" comment="NuajProtect" source={
/ip firewall address-list remove [find where comment="SpamHaus"]
/import file-name=spamhaus.rsc;
:log info "Removed old Spamhaus records and imported new list";
}

# Schedule the download and application of the spamhaus list
/system scheduler add comment="NuajProtect - Download Spamhaus list" interval=3d \
  name="DownloadSpamhausList" on-event=DownloadSpamhaus \
  start-date=jan/01/1970 start-time=21:31:11
/system scheduler add comment="NuajProtect - Apply Spamhaus List" interval=3d \
  name="InstallSpamhausList" on-event=ReplaceSpamhaus \
  start-date=jan/01/1970 start-time=21:36:11
# --------------------------------------------------------------


# Static Blacklist: VOIP Blacklist
# --------------------------------------------------------------
# Script which will download the drop list as a text file
/system script add name="DownloadVOIPbl" comment="NuajProtect" source={
/tool fetch url="http://blacklist.nuaj.ca/voip-bl.rsc" mode=http;
:log info "Downloaded voip-bl.rsc";
}

# Script which will Remove old VOIP blacklist list and add new one
/system script add name="ReplaceVOIPbl" comment="NuajProtect" source={
/ip firewall address-list remove [find where comment="VOIPbl"]
/import file-name=voip-bl.rsc;
:log info "NuajProtect - Removed old VOIP BL records and imported new list";
}

# Schedule the download and application of the VOIP BL list
/system scheduler add comment="NuajProtect - Download VOIP BL list" interval=3d \
  name="DownloadVOIPblList" on-event=DownloadVOIPbl \
  start-date=jan/01/1970 start-time=21:31:11
/system scheduler add comment="NuajProtect - Apply VOIP BL List" interval=3d \
  name="InstallVOIPblList" on-event=ReplaceVOIPbl \
  start-date=jan/01/1970 start-time=21:36:11
# --------------------------------------------------------------


# Static Blacklist: Bruteforce Blacklist
# --------------------------------------------------------------
# Script which will download the drop list as a text file
/system script add name="DownloadBruteforce" comment="NuajProtect" source={
/tool fetch url="http://blacklist.nuaj.ca/bruteforce.rsc" mode=http;
:log info "Downloaded bruteforce.rsc";
}

# Script which will Remove old VOIP Bruteforce list and add new one
/system script add name="ReplaceBruteforce" comment="NuajProtect" source={
/ip firewall address-list remove [find where comment="Bruteforce"]
/import file-name=bruteforce.rsc;
:log info "Removed old Brute records and imported new list";
}

# Schedule the download and application of the Bruteforce list
/system scheduler add comment="NuajProtect - Download Bruteforce list" interval=3d \
  name="DownloadBruteforceList" on-event=DownloadBruteforce \
  start-date=jan/01/1970 start-time=21:31:11
/system scheduler add comment="NuajProtect - Apply Bruteforce List" interval=3d \
  name="InstallBruteforceList" on-event=ReplaceBruteforce \
  start-date=jan/01/1970 start-time=21:36:11
# --------------------------------------------------------------


# Static Blacklist: Cinsscore Blacklist
# --------------------------------------------------------------
# Script which will download the drop list as a text file
/system script add name="DownloadCinsscore" comment="NuajProtect" source={
/tool fetch url="http://blacklist.nuaj.ca/CINSscore.rsc" mode=http;
:log info "Downloaded CINSscore.rsc";
}

# Script which will Remove old VOIP Cinsscore list and add new one
/system script add name="ReplaceCinsscore" comment="NuajProtect" source={
/ip firewall address-list remove [find where comment="Cinsscore"]
/import file-name=CINSscore.rsc;
:log info "Removed old Brute records and imported new list";
}

# Schedule the download and application of the Cinsscore list
/system scheduler add comment="NuajProtect - Download Cinsscore list" interval=3d \
  name="DownloadCinsscoreList" on-event=DownloadCinsscore \
  start-date=jan/01/1970 start-time=21:31:11
/system scheduler add comment="NuajProtect - Apply Cinsscore List" interval=3d \
  name="InstallCinsscoreList" on-event=ReplaceCinsscore \
  start-date=jan/01/1970 start-time=21:36:11
# --------------------------------------------------------------


# Define Private IP List
# --------------------------------------------------------------
# Remove old list
/ip firewall address-list remove [find where list="NuajP-PrivateIP"]

# Add private ip
/ip firewall address-list add list=NuajP-PrivateIP address=0.0.0.0/8;
/ip firewall address-list add list=NuajP-PrivateIP address=10.0.0.0/8;
/ip firewall address-list add list=NuajP-PrivateIP address=100.64.0.0/10;
/ip firewall address-list add list=NuajP-PrivateIP address=127.0.0.0/8;
/ip firewall address-list add list=NuajP-PrivateIP address=169.254.0.0/16;
/ip firewall address-list add list=NuajP-PrivateIP address=172.16.0.0/12;
/ip firewall address-list add list=NuajP-PrivateIP address=192.0.0.0/24;
/ip firewall address-list add list=NuajP-PrivateIP address=192.0.2.0/24;
/ip firewall address-list add list=NuajP-PrivateIP address=192.168.0.0/16;
/ip firewall address-list add list=NuajP-PrivateIP address=192.88.99.0/24;
/ip firewall address-list add list=NuajP-PrivateIP address=198.18.0.0/15;
/ip firewall address-list add list=NuajP-PrivateIP address=198.51.100.0/24;
/ip firewall address-list add list=NuajP-PrivateIP address=203.0.113.0/24;
/ip firewall address-list add list=NuajP-PrivateIP address=224.0.0.0/4;
/ip firewall address-list add list=NuajP-PrivateIP address=240.0.0.0/4;
# --------------------------------------------------------------



# Define the Dynamic Blacklists (TCP)
#----------------------------------------------------------------

# Remove old definition
/ip firewall filter remove [find where comment~"^NuajProtect"]
/ip firewall raw remove [find where comment~"^NuajProtect"]

# Accept established connection
/ip firewall filter add chain=input action=accept connection-state=established,related,untracked log=no log-prefix="" comment="NuajProtect - Accept established connection";

# Drop Invalid
/ip firewall filter add chain=input action=drop connection-state=invalid log=no log-prefix="" comment="NuajProtect - Drop invalid";

# Accept Pings
/ip firewall filter add chain=input action=accept protocol=icmp log=no log-prefix="" comment="NuajProtect - Accept pings";

# Accept in ipsec policy
/ip firewall filter add chain=forward action=accept log=no log-prefix="" ipsec-policy=in,ipsec comment="NuajProtect - Accept IPsec";

# Accept out ipsec policy
/ip firewall filter add chain=forward action=accept ipsec-policy=out,ipsec comment="NuajProtect - Accept IPsec";

# Accept established,related, untracked
/ip firewall filter add chain=forward action=accept connection-state=established,related,untracked log=no log-prefix="" comment="NuajProtect - Accept established";

# Drop invalid connection
/ip firewall filter add chain=forward action=drop connection-state=invalid log=no log-prefix="" comment="NuajProtect - Drop invalid";

# Dynamic Blacklist using honey pot
# Any source IP unable to established connection on the restricted ports within 3 tries will be blocked for 5 days.

# Dynamic Blacklist Re-listed - Block for 6 days
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic-Blacklist address-list=NuajP-Dynamic-Blacklist \
address-list-timeout=6d in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Blacklisted Reset>" comment="NuajProtect - Re-Blacklisted for 6 days"

# Dynamic Blacklist Creation - Final - blocked for 5 days
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic-Strike3 address-list=NuajP-Dynamic-Blacklist \
address-list-timeout=5d in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Blacklisted>" comment="NuajProtect - Blacklisted for 5 days";

# Dynamic Blacklist Creation - 3rd attenpt - 10-minute countdown removal
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic-Strike2 address-list=NuajP-Dynamic-Strike3 \
address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Strike 3>" comment="NuajProtect - Srike 3"

# Dynamic Blacklist Creation - 2nd attenpt - 10-minute countdown removal
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic-Strike1 address-list=NuajP-Dynamic-Strike2 \
address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Strike 2>" comment="NuajProtect - Srike 2"

# Dynamic Blacklist Creation - 1st attempt - 10-minute countdown removal
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=!NuajP-Dynamic-Strike1 address-list=NuajP-Dynamic-Strike1 \
address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Strike 1>" comment="NuajProtect - Srike 1"
#----------------------------------------------------------------


# IPv6 - Define the Dynamic Blacklists (TCP)
#----------------------------------------------------------------

# Remove old definition
/ipv6 firewall filter remove [find where comment~"^NuajProtect"]
/ipv6 firewall raw remove [find where comment~"^NuajProtect"]

# Accept established connection
/ipv6 firewall filter add chain=input action=accept connection-state=established,related,untracked log=no log-prefix="" comment="NuajProtect - Accept established connection";

# Drop Invalid
/ipv6 firewall filter add chain=input action=drop connection-state=invalid log=no log-prefix="" comment="NuajProtect - Drop invalid";

# Accept Pings
/ipv6 firewall filter add chain=input action=accept protocol=icmp log=no log-prefix="" comment="NuajProtect - Accept pings";

# Accept in ipv6sec policy
/ipv6 firewall filter add chain=forward action=accept log=no log-prefix="" ipsec-policy=in,ipsec comment="NuajProtect - Accept IPsec";

# Accept out ipsec policy
/ipv6 firewall filter add chain=forward action=accept ipsec-policy=out,ipsec comment="NuajProtect - Accept IPsec";

# Accept established,related, untracked
/ipv6 firewall filter add chain=forward action=accept connection-state=established,related,untracked log=no log-prefix="" comment="NuajProtect - Accept established";

# Drop invalid connection
/ipv6 firewall filter add chain=forward action=drop connection-state=invalid log=no log-prefix="" comment="NuajProtect - Drop invalid";

# Dynamic Blacklist using honey pot
# Any source ipv6unable to established connection on the restricted ports within 3 tries will be blocked for 5 days.

# Dynamic Blacklist Re-listed - Block for 6 days
/ipv6 firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic6-Blacklist address-list=NuajP-Dynamic6-Blacklist \
address-list-timeout=6d in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Blacklisted Reset>" comment="NuajProtect - Re-Blacklisted for 6 days"

# Dynamic Blacklist Creation - Final - blocked for 5 days
/ipv6 firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic6-Strike3 address-list=NuajP-Dynamic6-Blacklist \
address-list-timeout=5d in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Blacklisted>" comment="NuajProtect - Blacklisted for 5 days";

# Dynamic Blacklist Creation - 3rd attenpt - 10-minute countdown removal
/ipv6 firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic6-Strike2 address-list=NuajP-Dynamic6-Strike3 \
address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Strike 3>" comment="NuajProtect - Srike 3"

# Dynamic Blacklist Creation - 2nd attenpt - 10-minute countdown removal
/ipv6 firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic6-Strike1 address-list=NuajP-Dynamic6-Strike2 \
address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Strike 2>" comment="NuajProtect - Srike 2"

# Dynamic Blacklist Creation - 1st attempt - 10-minute countdown removal
/ipv6 firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=!NuajP-Dynamic6-Strike1 address-list=NuajP-Dynamic6-Strike1 \
address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no log-prefix="NuajP - Strike 1>" comment="NuajProtect - Srike 1"
#----------------------------------------------------------------



# Define Simple DDoS Protection
#----------------------------------------------------------------
/ip firewall filter add chain=detect-ddos action=return dst-limit=32,32,src-and-dst-addresses/10s log=no log-prefix="" comment="NuajProtect - DDoS"
/ip firewall filter add chain=detect-ddos action=add-dst-to-address-list address-list=ddos-targets address-list-timeout=10m log=no log-prefix="" comment="NuajProtect - DDoS"
/ip firewall filter add chain=detect-ddos action=add-src-to-address-list address-list=ddos-attackers address-list-timeout=10m log=no log-prefix="" comment="NuajProtect - DDoS"


# Define the Dynamic Blacklists (UDP)
#----------------------------------------------------------------
# Accepts all traffic from and to NuajP-Source-WhiteList 
/ip firewall raw add chain=prerouting action=accept log=no log-prefix="" src-address-list=NuajP-Source-WhiteList comment="NuajProtect - Accept from Whitelist"
/ip firewall raw add chain=prerouting action=accept log=no log-prefix="" dst-address-list=NuajP-Destination-WhiteList comment="NuajProtect - Accept to Whitelist"


# Block DDoS Attack
#-------------------
/ip firewall raw add chain=prerouting action=drop log=no log-prefix="" src-address-list=ddos-attackers dst-address-list=ddos-targets comment="NuajProtect - DDoS"

# Block DNS Request on WAN unless Destination IP is listed in NuajP-DNS-Servers list
#------------------------------------------------------------------------------------
/ip firewall raw add chain=prerouting action=drop in-interface-list=WAN dst-port=53 log=no log-prefix="NuajP - DNS Request>" protocol=udp dst-address-list=!NuajP-DNS-Servers comment="NuajProtect - Block DNS from WAN"
/ip firewall raw add chain=prerouting action=drop in-interface-list=WAN dst-port=53 log=no log-prefix="NuajP - DNS Request>" protocol=tcp dst-address-list=!NuajP-DNS-Servers comment="NuajProtect - Block DNS from WAN"

# Block to and from Dynamic Blacklist
#-------------------------------------
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="**NuajP - Blocked DBL>" src-address-list=NuajP-Dynamic-Blacklist comment="NuajProtect - Block Ingress from Blacklisted IP"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="**NuajP - Blocked DBL<" dst-address-list=NuajP-Dynamic-Blacklist comment="NuajProtect - Block Egress to Blacklisted IP"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="**NuajP - Blocked BL>" src-address-list=blacklist comment="NuajProtect - Block Ingress from Blacklisted IP"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="**NuajP - Blocked BL<" dst-address-list=blacklist comment="NuajProtect - Block Egress to Blacklisted IP"

# UDP Honey trap definition
#---------------------------
/ip firewall raw add chain=prerouting action=add-src-to-address-list in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no \
log-prefix="NuajP - Blacklisted>" protocol=udp src-address-list=NuajP-Dynamic-Blacklist address-list=NuajP-Dynamic-Blacklist address-list-timeout=6d comment="NuajProtect - Blacklisted for 6 days Resetted"

/ip firewall raw add chain=prerouting action=add-src-to-address-list in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no \
log-prefix="NuajP - Blacklisted>" protocol=udp src-address-list=NuajP-Dynamic-Strike3 address-list=NuajP-Dynamic-Blacklist address-list-timeout=5d comment="NuajProtect - Blacklisted for 5 days"

/ip firewall raw add chain=prerouting action=add-src-to-address-list in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no \
log-prefix="NuajP - Strike 3>" protocol=udp src-address-list=NuajP-Dynamic-Strike2 address-list=NuajP-Dynamic-Strike3 address-list-timeout=10m comment="NuajProtect - Strike 3"

/ip firewall raw add chain=prerouting action=add-src-to-address-list in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no \
log-prefix="NuajP - Strike 2>" protocol=udp src-address-list=NuajP-Dynamic-Strike1 address-list=NuajP-Dynamic-Strike2 address-list-timeout=10m comment="NuajProtect - Strike 2"

/ip firewall raw add chain=prerouting action=add-src-to-address-list in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log=no \
log-prefix="NuajP - Strike 1>" protocol=udp src-address-list=!NuajP-Dynamic-Strike1 address-list=NuajP-Dynamic-Strike1 address-list-timeout=10m comment="NuajProtect - Strike 1"
