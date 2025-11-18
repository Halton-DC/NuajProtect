# ======================================================================
# NuajProtect Security Suite for MikroTik
# (c) Nuaj Company Inc.
# v1.6 — RouterOS 7.x 
# Updated: November 18, 2025
# ======================================================================

# ----------------------------------------------------------------------
# PRE-CONFIGURATION REQUIREMENTS
# ----------------------------------------------------------------------
# 1) Your WAN interfaces must be in the "WAN" interface list
# 2) Management/service access should ideally run inside its own VRF
# 3) This script is designed for RouterOS 7.x (7.10+ recommended)
#
# INSTALLATION
# ----------------------------------------------------------------------
# 1) Upload this file to the router (`Files` → upload)
# 2) Then run:
#     /import NuajProtect
#
# POST-INSTALL CONFIG
# ----------------------------------------------------------------------
# - Add trusted source IPs to:
#     NuajP-Source-WhiteList
# - Add trusted destination IPs to:
#     NuajP-Destination-WhiteList
#
# DNS Defaults:
# - Cloudflare 1.1.1.2 / 1.0.0.2 (malware filtering)
# - Optional adult content filtering is available but disabled
#
# Blacklists used:
#  - DShield
#  - SpamHaus DROP
#  - VOIP blacklist
#  - Bruteforce IPs
#  - CINSscore
#  - UHB (custom)
#
# All HTTPS downloads are fully RouterOS 7-compatible.
# ======================================================================


# ----------------------------------------------------------------------
# CLEAN OLD DEFINITIONS
# ----------------------------------------------------------------------
/system script remove [find where comment~"^NuajProtect"]
/system scheduler remove [find where comment~"^NuajProtect"]
/ip firewall address-list remove [find where list="NuajP-DNS-Servers"]


# ----------------------------------------------------------------------
# DNS CONFIGURATION
# ----------------------------------------------------------------------
/ip dns set servers=1.1.1.2,1.0.0.2 allow-remote-requests=yes

/ip firewall address-list add list=NuajP-DNS-Servers address=1.1.1.2 comment="Cloudflare Families (Malware)"
/ip firewall address-list add list=NuajP-DNS-Servers address=1.0.0.2 comment="Cloudflare Families (Malware)"
/ip firewall address-list add list=NuajP-DNS-Servers address=1.1.1.3 disabled=yes comment="Cloudflare Families (Malware+Adult)"
/ip firewall address-list add list=NuajP-DNS-Servers address=1.0.0.3 disabled=yes comment="Cloudflare Families (Malware+Adult)"


# ----------------------------------------------------------------------
# GENERIC FUNCTIONS (ROUTEROS 7 SAFE)
# ----------------------------------------------------------------------
:global downloadBlacklist do={
  :local url $1
  :local file $2
  /tool fetch url=$url dst-path=$file check-certificate=yes
  :if ([:len [/file find name=$file]]>0) do={
      :log info "NuajProtect - Downloaded $file"
  } else={
      :log error "NuajProtect - FAILED to download $url"
  }
}

:global replaceBlacklist do={
  :local file $1
  :local comment $2
  /ip firewall address-list remove [find where comment=$comment]
  :if ([:len [/file find name=$file]]>0) do={
      /import file-name=$file
      :log info "NuajProtect - Imported updated $comment list"
  } else={
      :log error "NuajProtect - No file $file found"
  }
}


# ----------------------------------------------------------------------
# DSHIELD
# ----------------------------------------------------------------------
/system script add name="Download_dshield" comment="NuajProtect" source={
  :global downloadBlacklist
  $downloadBlacklist "https://blacklist.nuaj.ca/dshield.rsc" "dshield.rsc"
}

/system script add name="Replace_dshield" comment="NuajProtect" source={
  :global replaceBlacklist
  $replaceBlacklist "dshield.rsc" "DShield"
}

# Schedule
/system scheduler add name="DownloadDShieldList" comment="NuajProtect - Download DShield" interval=1d start-date=jan/01/1970 start-time=21:00:00 on-event=Download_dshield
/system scheduler add name="InstallDShieldList" comment="NuajProtect - Apply DShield"   interval=1d start-date=jan/01/1970 start-time=21:05:00 on-event=Replace_dshield


# ----------------------------------------------------------------------
# SPAMHAUS
# ----------------------------------------------------------------------
/system script add name="DownloadSpamhaus" comment="NuajProtect" source={
  :global downloadBlacklist
  $downloadBlacklist "https://blacklist.nuaj.ca/spamhaus.rsc" "spamhaus.rsc"
}

/system script add name="ReplaceSpamhaus" comment="NuajProtect" source={
  :global replaceBlacklist
  $replaceBlacklist "spamhaus.rsc" "SpamHaus"
}

# Schedule
/system scheduler add name="DownloadSpamhausList" comment="NuajProtect - Download SpamHaus" interval=1d start-date=jan/01/1970 start-time=21:10:00 on-event=DownloadSpamhaus
/system scheduler add name="InstallSpamhausList" comment="NuajProtect - Apply SpamHaus" interval=1d start-date=jan/01/1970 start-time=21:15:00 on-event=ReplaceSpamhaus


# ----------------------------------------------------------------------
# VOIP BLACKLIST
# ----------------------------------------------------------------------
/system script add name="DownloadVOIPbl" comment="NuajProtect" source={
  :global downloadBlacklist
  $downloadBlacklist "https://blacklist.nuaj.ca/voip-bl.rsc" "voip-bl.rsc"
}

/system script add name="ReplaceVOIPbl" comment="NuajProtect" source={
  :global replaceBlacklist
  $replaceBlacklist "voip-bl.rsc" "VOIPbl"
}

# Schedule
/system scheduler add name="DownloadVOIPblList" comment="NuajProtect - Download VOIP" interval=1d start-date=jan/01/1970 start-time=21:20:00 on-event=DownloadVOIPbl
/system scheduler add name="InstallVOIPblList" comment="NuajProtect - Apply VOIP"   interval=1d start-date=jan/01/1970 start-time=21:25:00 on-event=ReplaceVOIPbl


# ----------------------------------------------------------------------
# BRUTEFORCE
# ----------------------------------------------------------------------
/system script add name="DownloadBruteforce" comment="NuajProtect" source={
  :global downloadBlacklist
  $downloadBlacklist "https://blacklist.nuaj.ca/bruteforce.rsc" "bruteforce.rsc"
}

/system script add name="ReplaceBruteforce" comment="NuajProtect" source={
  :global replaceBlacklist
  $replaceBlacklist "bruteforce.rsc" "Bruteforce"
}

# Schedule
/system scheduler add name="DownloadBruteforceList" comment="NuajProtect - Download Bruteforce" interval=1d start-date=jan/01/1970 start-time=21:30:00 on-event=DownloadBruteforce
/system scheduler add name="InstallBruteforceList" comment="NuajProtect - Apply Bruteforce"   interval=1d start-date=jan/01/1970 start-time=21:35:00 on-event=ReplaceBruteforce


# ----------------------------------------------------------------------
# CINSscore
# ----------------------------------------------------------------------
/system script add name="DownloadCinsscore" comment="NuajProtect" source={
  :global downloadBlacklist
  $downloadBlacklist "https://blacklist.nuaj.ca/cinscore.rsc" "cinscore.rsc"
}

/system script add name="ReplaceCinsscore" comment="NuajProtect" source={
  :global replaceBlacklist
  $replaceBlacklist "cinscore.rsc" "Cinsscore"
}

# Schedule
/system scheduler add name="DownloadCinsscoreList" comment="NuajProtect - Download CINSscore" interval=1d start-date=jan/01/1970 start-time=21:40:00 on-event=DownloadCinsscore
/system scheduler add name="InstallCinsscoreList" comment="NuajProtect - Apply CINSscore" interval=1d start-date=jan/01/1970 start-time=21:45:00 on-event=ReplaceCinsscore


# ----------------------------------------------------------------------
# UHB — Custom Blacklist
# ----------------------------------------------------------------------
/system script add name="DownloadUHB" comment="NuajProtect" source={
  :global downloadBlacklist
  $downloadBlacklist "https://blacklist.nuaj.ca/uhb.rsc" "uhb.rsc"
}

/system script add name="ReplaceUHB" comment="NuajProtect" source={
  :global replaceBlacklist
  $replaceBlacklist "uhb.rsc" "UHB"
}

# Schedule
/system scheduler add name="DownloadUHBList" comment="NuajProtect - Download UHB" interval=1d start-date=jan/01/1970 start-time=21:50:00 on-event=DownloadUHB
/system scheduler add name="InstallUHBList" comment="NuajProtect - Apply UHB" interval=1d start-date=jan/01/1970 start-time=21:55:00 on-event=ReplaceUHB


# ----------------------------------------------------------------------
# PRIVATE IP RANGES
# ----------------------------------------------------------------------
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


# =====================================================================
# STRIKE SYSTEM (TCP) — DEFAULT PORTS
# =====================================================================
/ip firewall filter add chain=input action=add-src-to-address-list address-list=NuajP-Dynamic-Blacklist address-list-timeout=6d \
    protocol=tcp src-address-list=NuajP-Dynamic-Blacklist \
    dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 \
    in-interface-list=WAN log-prefix="NuajP - Reset>" comment="NuajProtect - Reset Blacklist Timer (TCP)"

# Strike 3
/ip firewall filter add chain=input action=add-src-to-address-list address-list=NuajP-Dynamic-Blacklist address-list-timeout=5d \
    protocol=tcp src-address-list=NuajP-Dynamic-Strike3 \
    dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 \
    in-interface-list=WAN log-prefix="NuajP - Blacklist>" comment="NuajProtect - Strike 3 → Blacklist (TCP)"

# Strike 2
/ip firewall filter add chain=input action=add-src-to-address-list address-list=NuajP-Dynamic-Strike3 address-list-timeout=10m \
    protocol=tcp src-address-list=NuajP-Dynamic-Strike2 \
    dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 \
    in-interface-list=WAN log-prefix="NuajP - Strike3>" comment="NuajProtect - Strike 2 (TCP)"

# Strike 1
/ip firewall filter add chain=input action=add-src-to-address-list address-list=NuajP-Dynamic-Strike2 address-list-timeout=10m \
    protocol=tcp src-address-list=NuajP-Dynamic-Strike1 \
    dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 \
    in-interface-list=WAN log-prefix="NuajP - Strike2>" comment="NuajProtect - Strike 1 (TCP)"

# First Strike
/ip firewall filter add chain=input action=add-src-to-address-list address-list=NuajP-Dynamic-Strike1 address-list-timeout=10m \
    protocol=tcp src-address-list=!NuajP-Dynamic-Strike1 \
    dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 \
    in-interface-list=WAN log-prefix="NuajP - Strike1>" comment="NuajProtect - First Strike (TCP)"


# =====================================================================
# OPTIONAL STRIKE EXTENSIONS — USER HONEYPOT PORTS (TCP)
# ---------------------------------------------------------------------
# HOW TO USE:
# 1. Add your custom honeypot ports to dst-port (e.g. 2222, 5000, 8081)
# 2. Set disabled=no
#
# These rules are deliberately empty (minimal) to avoid Line Length Limits.
# =====================================================================

# Reset Blacklist Timer — OPTIONAL EXTRA PORTS
/ip firewall filter add disabled=yes chain=input action=add-src-to-address-list \
    address-list=NuajP-Dynamic-Blacklist address-list-timeout=6d \
    protocol=tcp src-address-list=NuajP-Dynamic-Blacklist \
    dst-port= \
    in-interface-list=WAN log-prefix="NuajP - Reset Ext>" \
    comment="NuajProtect (Optional) - Add honeypot ports for Reset stage"


# Strike 3 — OPTIONAL EXTRA PORTS
/ip firewall filter add disabled=yes chain=input action=add-src-to-address-list \
    address-list=NuajP-Dynamic-Blacklist address-list-timeout=5d \
    protocol=tcp src-address-list=NuajP-Dynamic-Strike3 \
    dst-port= \
    in-interface-list=WAN log-prefix="NuajP - Strike3 Ext>" \
    comment="NuajProtect (Optional) - Add honeypot ports for Strike 3"


# Strike 2 — OPTIONAL EXTRA PORTS
/ip firewall filter add disabled=yes chain=input action=add-src-to-address-list \
    address-list=NuajP-Dynamic-Strike3 address-list-timeout=10m \
    protocol=tcp src-address-list=NuajP-Dynamic-Strike2 \
    dst-port= \
    in-interface-list=WAN log-prefix="NuajP - Strike2 Ext>" \
    comment="NuajProtect (Optional) - Add honeypot ports for Strike 2"


# Strike 1 — OPTIONAL EXTRA PORTS
/ip firewall filter add disabled=yes chain=input action=add-src-to-address-list \
    address-list=NuajP-Dynamic-Strike2 address-list-timeout=10m \
    protocol=tcp src-address-list=NuajP-Dynamic-Strike1 \
    dst-port= \
    in-interface-list=WAN log-prefix="NuajP - Strike1 Ext>" \
    comment="NuajProtect (Optional) - Add honeypot ports for Strike 1"


# First Strike — OPTIONAL EXTRA PORTS
/ip firewall filter add disabled=yes chain=input action=add-src-to-address-list \
    address-list=NuajP-Dynamic-Strike1 address-list-timeout=10m \
    protocol=tcp src-address-list=!NuajP-Dynamic-Strike1 \
    dst-port= \
    in-interface-list=WAN log-prefix="NuajP - First Ext>" \
    comment="NuajProtect (Optional) - Add honeypot ports for Initial Strike (TCP)"


# ----------------------------------------------------------------------
# BASIC DDOS PROTECTION
# ----------------------------------------------------------------------
/ip firewall filter add chain=detect-ddos action=return dst-limit=32,32,src-and-dst-addresses/10s comment="NuajProtect - DDoS"
/ip firewall filter add chain=detect-ddos action=add-dst-to-address-list address-list=ddos-targets address-list-timeout=10m comment="NuajProtect - Targeted"
/ip firewall filter add chain=detect-ddos action=add-src-to-address-list address-list=ddos-attackers address-list-timeout=10m comment="NuajProtect - Attacker"


# ----------------------------------------------------------------------
# FIREWALL — UDP DYNAMIC BLACKLIST LOGIC
# ----------------------------------------------------------------------
/ip firewall raw add chain=prerouting action=accept src-address-list=NuajP-Source-WhiteList comment="NuajProtect - Whitelist Source"
/ip firewall raw add chain=prerouting action=accept dst-address-list=NuajP-Destination-WhiteList comment="NuajProtect - Whitelist Destination"

/ip firewall raw add chain=prerouting action=drop src-address-list=ddos-attackers dst-address-list=ddos-targets comment="NuajProtect - Block DDoS"

# Block DNS from WAN except approved servers
/ip firewall raw add chain=prerouting action=drop in-interface-list=WAN protocol=udp dst-port=53,5353 dst-address-list=!NuajP-DNS-Servers log-prefix="NuajP-DNS>" comment="NuajProtect - Block DNS"
/ip firewall raw add chain=prerouting action=drop in-interface-list=WAN protocol=tcp dst-port=53,5353 dst-address-list=!NuajP-DNS-Servers log-prefix="NuajP-DNS>" comment="NuajProtect - Block DNS"

# Log & block blacklists
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="NuajP-BL>" src-address-list=NuajP-Dynamic-Blacklist comment="Ingress Blacklist"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="NuajP-BL<" dst-address-list=NuajP-Dynamic-Blacklist comment="Egress Blacklist"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="NuajP-BL>" src-address-list=blacklist comment="Ingress (Static BL)"
/ip firewall raw add chain=prerouting action=drop log=yes log-prefix="NuajP-BL<" dst-address-list=blacklist comment="Egress (Static BL)"

# Strike system (UDP) mirrors TCP
/ip firewall raw add chain=prerouting action=add-src-to-address-list protocol=udp in-interface-list=WAN \
    address-list=NuajP-Dynamic-Blacklist address-list-timeout=6d \
    src-address-list=NuajP-Dynamic-Blacklist dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 comment="BL Reset (UDP)"

# Strike 3
/ip firewall raw add chain=prerouting action=add-src-to-address-list protocol=udp in-interface-list=WAN \
    address-list=NuajP-Dynamic-Blacklist address-list-timeout=5d \
    src-address-list=NuajP-Dynamic-Strike3 dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 comment="Strike 3 → BL (UDP)"

# Strike 2
/ip firewall raw add chain=prerouting action=add-src-to-address-list protocol=udp in-interface-list=WAN \
    address-list=NuajP-Dynamic-Strike3 address-list-timeout=10m \
    src-address-list=NuajP-Dynamic-Strike2 dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 comment="Strike 2 (UDP)"

# Strike 1
/ip firewall raw add chain=prerouting action=add-src-to-address-list protocol=udp in-interface-list=WAN \
    address-list=NuajP-Dynamic-Strike2 address-list-timeout=10m \
    src-address-list=NuajP-Dynamic-Strike1 dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 comment="Strike 1 (UDP)"

# Initial Strike
/ip firewall raw add chain=prerouting action=add-src-to-address-list protocol=udp in-interface-list=WAN \
    address-list=NuajP-Dynamic-Strike1 address-list-timeout=10m \
    src-address-list=!NuajP-Dynamic-Strike1 dst-port=7,9,13,17,19,22,23,139,162,389,445,1433,3306,8291 comment="First Strike (UDP)"
