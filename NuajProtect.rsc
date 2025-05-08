# NuajProtect Security Suite for MikroTik
# 
# (c) Nuaj Company Inc.
# v1.5
# May 8, 2025
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
# Install Script
#----------------
# 1) Upload script, Files > upload
# 2) Go to router terminal
# 3) type > /import NuajProtect
#
# Post Installation Configuration
#--------------------------------
# 1) Add source IP to "NuajP-Source-WhiteList" to allow all 
#    unfiltered traffic from the source IP.
# 2) Add destination IP to "NuajP-Destination-Whitelist" to allow
#    all unfiltered traffic to the destination IP.
# 3) "NuajP-DNS-Servers" is pre-populated with Cloudflare 1.1.1.1
#     for Families DNS servers (malware blocking by default, optional
#     malware and adult content filtering).
#
# Blacklist Sources:
# - DShield, SpamHaus, VOIP, Bruteforce, CINSscore: Parsed by Joshaven Potter
# - UHB: Custom blacklist
#

# Remove old definitions
#------------------------
/system script remove [find where comment~"^NuajProtect"]
/system scheduler remove [find where comment~"^NuajProtect"]
/ip firewall address-list remove [find where list="NuajP-DNS-Servers"]

# Configure Router DNS to Use Cloudflare 1.1.1.1 for Families
#--------------------------------------------------------------
/ip dns set servers=1.1.1.2,1.0.0.2 allow-remote-requests=yes

# Add Cloudflare DNS Servers to NuajP-DNS-Servers
#--------------------------------------------------------------
# Purpose: Allow DNS traffic (TCP/UDP, ports 53, 5353) to these servers from WAN
# Default: Cloudflare 1.1.1.1 for Families (1.1.1.2, 1.0.0.2, blocks malware) enabled
# Optional: Cloudflare 1.1.1.1 for Families (1.1.1.3, 1.0.0.3, blocks malware and adult content) disabled
# How to Choose:
# - Keep only the DNS servers you want in this list
# - To enable malware and adult content blocking, set 'disabled=no' (e.g., /ip firewall address-list set [find address=1.1.1.3] disabled=no)
# - To use only malware blocking, keep defaults
# How to Delete: Remove unwanted entries (e.g., /ip firewall address-list remove [find address=1.1.1.3])
# How to Disable: Set 'disabled=yes' (e.g., /ip firewall address-list set [find address=1.1.1.2] disabled=yes)
/ip firewall address-list add list=NuajP-DNS-Servers address=1.1.1.2 comment="Cloudflare 1.1.1.1 for Families - Blocks malware (IPv4)"
/ip firewall address-list add list=NuajP-DNS-Servers address=1.0.0.2 comment="Cloudflare 1.1.1.1 for Families - Blocks malware (IPv4)"
/ip firewall address-list add list=NuajP-DNS-Servers address=1.1.1.3 disabled=yes comment="Cloudflare 1.1.1.1 for Families - Blocks malware and adult content (IPv4, disabled by default)"
/ip firewall address-list add list=NuajP-DNS-Servers address=1.0.0.3 disabled=yes comment="Cloudflare 1.1.1.1 for Families - Blocks malware and adult content (IPv4, disabled by default)"

# Generic Blacklist Download and Apply Function
#--------------------------------------------------------------
:local downloadBlacklist do={
  :local url $1
  :local file $2
  :local comment $3
  /tool fetch url=$url mode=http dst-path=$file
  :if ([:len [/file find name=$file]]>0) do={
    :log info "NuajProtect - Downloaded $file"
  } else={
    :log error "NuajProtect - Failed to download $url"
  }
}

:local replaceBlacklist do={
  :local file $1
  :local comment $2
  /ip firewall address-list remove [find where comment=$comment]
  :if ([:len [/file find name=$file]]>0) do={
    /import file-name=$file
    :log info "NuajProtect - Removed old $comment records and imported new list"
  } else={
    :log error "NuajProtect - No $file to import"
  }
}

# Static Blacklist: DShield
#--------------------------------------------------------------
/system script add name="Download_dshield" comment="NuajProtect" source={
/tool fetch url="http://blacklist.nuaj.ca/dshield.rsc" mode=http;
:log info "Downloaded dshield.rsc";
}

/system script add name="Replace_dshield" comment="NuajProtect" source={
/ip firewall address-list remove [find where comment="DShield"]
/import file-name=dshield.rsc;
:log info "Removed old dshield records and imported new list";
}

/system scheduler add comment="NuajProtect - Download DShield list" interval=1d \
  name="DownloadDShieldList" on-event=Download_dshield \
  start-date=jan/01/1970 start-time=21:00:00
/system scheduler add comment="NuajProtect - Apply DShield List" interval=1d \
  name="InstallDShieldList" on-event=Replace_dshield \
  start-date=jan/01/1970 start-time=21:05:00

# Static Blacklist: SpamHaus
#--------------------------------------------------------------
/system script add name="DownloadSpamhaus" comment="NuajProtect" source={
  $downloadBlacklist "http://blacklist.nuaj.ca/spamhaus.rsc" "spamhaus.rsc" "SpamHaus"
}

/system script add name="ReplaceSpamhaus" comment="NuajProtect" source={
  $replaceBlacklist "spamhaus.rsc" "SpamHaus"
}

/system scheduler add comment="NuajProtect - Download SpamHaus list" interval=1d \
  name="DownloadSpamhausList" on-event=DownloadSpamhaus \
  start-date=jan/01/1970 start-time=21:10:00
/system scheduler add comment="NuajProtect - Apply SpamHaus List" interval=1d \
  name="InstallSpamhausList" on-event=ReplaceSpamhaus \
  start-date=jan/01/1970 start-time=21:15:00

# Static Blacklist: VOIP Blacklist
#--------------------------------------------------------------
/system script add name="DownloadVOIPbl" comment="NuajProtect" source={
  $downloadBlacklist "http://blacklist.nuaj.ca/voip-bl.rsc" "voip-bl.rsc" "VOIPbl"
}

/system script add name="ReplaceVOIPbl" comment="NuajProtect" source={
  $replaceBlacklist "voip-bl.rsc" "VOIPbl"
}

/system scheduler add comment="NuajProtect - Download VOIP BL list" interval=1d \
  name="DownloadVOIPblList" on-event=DownloadVOIPbl \
  start-date=jan/01/1970 start-time=21:20:00
/system scheduler add comment="NuajProtect - Apply VOIP BL List" interval=1d \
  name="InstallVOIPblList" on-event=ReplaceVOIPbl \
  start-date=jan/01/1970 start-time=21:25:00

# Static Blacklist: Bruteforce Blacklist
#--------------------------------------------------------------
/system script add name="DownloadBruteforce" comment="NuajProtect" source={
  $downloadBlacklist "http://blacklist.nuaj.ca/bruteforce.rsc" "bruteforce.rsc" "Bruteforce"
}

/system script add name="ReplaceBruteforce" comment="NuajProtect" source={
  $replaceBlacklist "bruteforce.rsc" "Bruteforce"
}

/system scheduler add comment="NuajProtect - Download Bruteforce list" interval=1d \
  name="DownloadBruteforceList" on-event=DownloadBruteforce \
  start-date=jan/01/1970 start-time=21:30:00
/system scheduler add comment="NuajProtect - Apply Bruteforce List" interval=1d \
  name="InstallBruteforceList" on-event=ReplaceBruteforce \
  start-date=jan/01/1970 start-time=21:35:00

# Static Blacklist: CINSscore Blacklist
#--------------------------------------------------------------
/system script add name="DownloadCinsscore" comment="NuajProtect" source={
  $downloadBlacklist "http://blacklist.nuaj.ca/CINSscore.rsc" "CINSscore.rsc" "Cinsscore"
}

/system script add name="ReplaceCinsscore" comment="NuajProtect" source={
  $replaceBlacklist "CINSscore.rsc" "Cinsscore"
}

/system scheduler add comment="NuajProtect - Download CINSscore list" interval=1d \
  name="DownloadCinsscoreList" on-event=DownloadCinsscore \
  start-date=jan/01/1970 start-time=21:40:00
/system scheduler add comment="NuajProtect - Apply CINSscore List" interval=1d \
  name="InstallCinsscoreList" on-event=ReplaceCinsscore \
  start-date=jan/01/1970 start-time=21:45:00

# Static Blacklist: UHB Blacklist
#--------------------------------------------------------------
/system script add name="DownloadUHB" comment="NuajProtect" source={
  $downloadBlacklist "http://blacklist.nuaj.ca/uhb.rsc" "uhb.rsc" "UHB"
}

/system script add name="ReplaceUHB" comment="NuajProtect" source={
  $replaceBlacklist "uhb.rsc" "UHB"
}

/system scheduler add comment="NuajProtect - Download UHB list" interval=1d \
  name="DownloadUHBList" on-event=DownloadUHB \
  start-date=jan/01/1970 start-time=21:50:00
/system scheduler add comment="NuajProtect - Apply UHB List" interval=1d \
  name="InstallUHBList" on-event=ReplaceUHB \
  start-date=jan/01/1970 start-time=21:55:00

# Define Private IP List
#--------------------------------------------------------------
/ip firewall address-list remove [find where list="NuajP-PrivateIP"]
/ip firewall address-list add list=NuajP-PrivateIP address=0.0.0.0/8
/ip firewall address-list add list=NuajP-PrivateIP address=10.0.0.0/8
/ip firewall address-list add list=NuajP-PrivateIP address=100.64.0.0/10
/ip firewall address-list add list=NuajP-PrivateIP address=127.0.0.0/8
/ip firewall address-list add list=NuajP-PrivateIP address=169.254.0.0/16
/ip firewall address-list add list=NuajP-PrivateIP address=172.16.0.0/12
/ip firewall address-list add list=NuajP-PrivateIP address=192.0.0.0/24
/ip firewall address-list add list=NuajP-PrivateIP address=192.0.2.0/24
/ip firewall address-list add list=NuajP-PrivateIP address=192.168.0.0/16
/ip firewall address-list add list=NuajP-PrivateIP address=192.88.99.0/24
/ip firewall address-list add list=NuajP-PrivateIP address=198.18.0.0/15
/ip firewall address-list add list=NuajP-PrivateIP address=198.51.100.0/24
/ip firewall address-list add list=NuajP-PrivateIP address=203.0.113.0/24
/ip firewall address-list add list=NuajP-PrivateIP address=224.0.0.0/4
/ip firewall address-list add list=NuajP-PrivateIP address=240.0.0.0/4

# Define Dynamic Blacklists (TCP)
#----------------------------------------------------------------
/ip firewall filter remove [find where comment~"^NuajProtect"]
/ip firewall raw remove [find where comment~"^NuajProtect"]

/ip firewall filter add chain=input action=accept connection-state=established,related,untracked comment="NuajProtect - Accept established connection"
/ip firewall filter add chain=input action=drop connection-state=invalid comment="NuajProtect - Drop invalid"
/ip firewall filter add chain=input action=accept protocol=icmp comment="NuajProtect - Accept pings"
/ip firewall filter add chain=forward action=accept ipsec-policy=in,ipsec comment="NuajProtect - Accept IPsec in"
/ip firewall filter add chain=forward action=accept ipsec-policy=out,ipsec comment="NuajProtect - Accept IPsec out"
/ip firewall filter add chain=forward action=accept connection-state=established,related,untracked comment="NuajProtect - Accept established"
/ip firewall filter add chain=forward action=drop connection-state=invalid comment="NuajProtect - Drop invalid"

/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic-Blacklist address-list=NuajP-Dynamic-Blacklist \
  address-list-timeout=6d in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log-prefix="NuajP - Blacklisted Reset>" comment="NuajProtect - Re-Blacklisted for 6 days"
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic-Strike3 address-list=NuajP-Dynamic-Blacklist \
  address-list-timeout=5d in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log-prefix="NuajP - Blacklisted>" comment="NuajProtect - Blacklisted for 5 days"
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic-Strike2 address-list=NuajP-Dynamic-Strike3 \
  address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log-prefix="NuajP - Strike 3>" comment="NuajProtect - Strike 3"
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=NuajP-Dynamic-Strike1 address-list=NuajP-Dynamic-Strike2 \
  address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log-prefix="NuajP - Strike 2>" comment="NuajProtect - Strike 2"
/ip firewall filter add chain=input action=add-src-to-address-list protocol=tcp src-address-list=!NuajP-Dynamic-Strike1 address-list=NuajP-Dynamic-Strike1 \
  address-list-timeout=10m in-interface-list=WAN dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 log-prefix="NuajP - Strike 1>" comment="NuajProtect - Strike 1"

# Define Basic DDoS Protection
#----------------------------------------------------------------
/ip firewall filter add chain=detect-ddos action=return dst-limit=32,32,src-and-dst-addresses/10s comment="NuajProtect - Basic DDoS"
/ip firewall filter add chain=detect-ddos action=add-dst-to-address-list address-list=ddos-targets address-list-timeout=10m comment="NuajProtect - Basic DDoS"
/ip firewall filter add chain=detect-ddos action=add-src-to-address-list address-list=ddos-attackers address-list-timeout=10m comment="NuajProtect - Basic DDoS"

# Define Dynamic Blacklists (UDP)
#----------------------------------------------------------------
/ip firewall raw add chain=prerouting action=accept src-address-list=NuajP-Source-WhiteList comment="NuajProtect - Accept from Whitelist"
/ip firewall raw add chain=prerouting action=accept dst-address-list=NuajP-Destination-WhiteList comment="NuajProtect - Accept to Whitelist"

/ip firewall raw add chain=prerouting action=drop src-address-list=ddos-attackers dst-address-list=ddos-targets comment="NuajProtect - Block Basic DDoS"

/ip firewall raw add chain=prerouting action=drop in-interface-list=WAN dst-port=53,5353 protocol=udp dst-address-list=!NuajP-DNS-Servers log-prefix="NuajP - DNS Request>" comment="NuajProtect - Block DNS from WAN"
/ip firewall raw add chain=prerouting action=drop in-interface-list=WAN dst-port=53,5353 protocol=tcp dst-address-list=!NuajP-DNS-Servers log-prefix="NuajP - DNS Request>" comment="NuajProtect - Block DNS from WAN"

/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="**NuajP - Blocked DBL>" src-address-list=NuajP-Dynamic-Blacklist comment="NuajProtect - Block Ingress from Blacklisted IP"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="**NuajP - Blocked DBL<" dst-address-list=NuajP-Dynamic-Blacklist comment="NuajProtect - Block Egress to Blacklisted IP"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="**NuajP - Blocked BL>" src-address-list=blacklist comment="NuajProtect - Block Ingress from Blacklisted IP"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="**NuajP - Blocked BL<" dst-address-list=blacklist comment="NuajProtect - Block Egress to Blacklisted IP"

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
