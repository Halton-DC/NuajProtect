# NuajProtect Security Suite for MikroTik

**Version**: 1.5  
**Last Updated**: May 8, 2025  
**License**: MIT  
**Author**: Nuaj Company Inc.

## Overview

NuajProtect is a comprehensive security suite for MikroTik routers, designed to enhance network protection through dynamic and static blacklists, DDoS mitigation, and secure DNS configuration. It leverages multiple blacklist sources, a honeypot-based dynamic blacklist system, and safe DNS servers to block malicious traffic while allowing legitimate connections.

### Key Features
- **Static Blacklists**: Integrates DShield, SpamHaus, VOIP, Bruteforce, CINSscore, and UHB blacklists to block known malicious IPs.
- **Dynamic Blacklists**: Uses a honeypot to block IPs attempting unauthorized access (3 strikes within 10 minutes, blocked for 5-6 days).
- **DDoS Protection**: Detects and mitigates DDoS attacks by limiting connections and blacklisting attackers.
- **Secure DNS**: Configures `safedns.allover.co.za` (88.198.70.38, 88.198.70.39) as primary DNS, with optional Cloudflare 1.1.1.1 for Families for malware and content filtering.
- **IPv4/IPv6 Support**: Includes private IP blocking and IPv6 dynamic blacklists.
- **Daily Updates**: Automatically updates blacklists daily with staggered scheduling to minimize router load.
- **Error Handling**: Logs download/import failures for reliable operation.

## Prerequisites
- MikroTik router running RouterOS (tested on v6.x and v7.x).
- WAN interfaces added to the "WAN" interface list.
- Management access and system services configured on a dedicated VRF (recommended for security).
- Internet access for downloading blacklists and DNS resolution.

## Installation
1. **Download the Script**:
   - Clone this repository or download `NuajProtect.rsc`:
     ```bash
     git clone https://github.com/<your-username>/NuajProtect.git
     ```
2. **Upload to Router**:
   - Log into your MikroTik router via WinBox or WebFig.
   - Navigate to `Files` > `Upload` and select `NuajProtect.rsc`.
3. **Import the Script**:
   - Open the router terminal and run:
     ```bash
     /import NuajProtect.rsc
     ```
   - The script will configure blacklists, DNS, firewall rules, and schedules.

## Post-Installation Configuration
1. **Whitelist Trusted IPs**:
   - Add trusted source IPs to `NuajP-Source-WhiteList`:
     ```bash
     /ip firewall address-list add list=NuajP-Source-WhiteList address=192.168.1.100 comment="Trusted PC"
     ```
   - Add trusted destination IPs to `NuajP-Destination-Whitelist`:
     ```bash
     /ip firewall address-list add list=NuajP-Destination-Whitelist address=8.8.8.8 comment="Google DNS"
     ```
2. **DNS Configuration**:
   - The script sets `safedns.allover.co.za` (88.198.70.38, 88.198.70.39) as the router’s DNS servers by default.
   - Optional Cloudflare 1.1.1.1 for Families DNS servers are included in `NuajP-DNS-Servers` (disabled by default):
     - `1.1.1.2`, `1.0.0.2`: Blocks malware.
     - `1.1.1.3`, `1.0.0.3`: Blocks malware and adult content.
   - To enable Cloudflare DNS:
     ```bash
     /ip firewall address-list set [find address=1.1.1.2] disabled=no
     /ip firewall address-list set [find address=1.0.0.2] disabled=no
     /ip dns set servers=1.1.1.2,1.0.0.2
     ```
   - To disable a DNS server:
     ```bash
     /ip firewall address-list set [find address=88.198.70.38] disabled=yes
     ```
   - To remove a DNS server:
     ```bash
     /ip firewall address-list remove [find address=1.1.1.3]
     ```
3. **Verify Setup**:
   - Check DNS settings:
     ```bash
     /ip dns print
     ```
     Expected: `servers: 88.198.70.38,88.198.70.39`
   - Check address list:
     ```bash
     /ip firewall address-list print where list=NuajP-DNS-Servers
     ```
   - Confirm blacklist files:
     ```bash
     /file print
     ```
   - View logs:
     ```bash
     /log print where topics~"(info|error)"
     ```

## Blacklist Sources
The suite uses the following blacklists, updated daily:
- **DShield**: `http://blacklist.nuaj.ca/dshield.rsc` (custom source).
- **SpamHaus**: `http://blacklist.nuaj.ca/spamhaus.rsc` (blocks spam and malicious IPs).
- **VOIP**: `http://blacklist.nuaj.ca/voip-bl.rsc` (blocks VOIP abuse).
- **Bruteforce**: `http://blacklist.nuaj.ca/bruteforce.rsc` (blocks brute-force attackers).
- **CINSscore**: `http://blacklist.nuaj.ca/CINSscore.rsc` (blocks high-risk IPs).
- **UHB**: `http://blacklist.nuaj.ca/uhb.rsc` (custom blacklist for specific threats).

Each blacklist is downloaded and applied at staggered times (21:00–21:55) to minimize router load.

## DNS Configuration
- **Primary DNS**:
  - `safedns.allover.co.za` (88.198.70.38, 2a01:4f8:140:5021::38)
  - `safedns2.allover.co.za` (88.198.70.39, 2a01:4f8:140:5021::39)
  - Secure DNS servers, enabled by default, used by the router.
- **Optional DNS** (disabled by default):
  - Cloudflare 1.1.1.1 for Families:
    - `1.1.1.2`, `1.0.0.2`: Blocks malware.
    - `1.1.1.3`, `1.0.0.3`: Blocks malware and adult content.
  - Users can enable or delete these entries in `NuajP-DNS-Servers` (see Post-Installation Configuration).
- **Firewall Rules**:
  - Allows DNS traffic (TCP/UDP, ports 53, 5353) to enabled `NuajP-DNS-Servers` entries.
  - Blocks unauthorized DNS requests from WAN.

## Dynamic Blacklists
- **Honeypot System**:
  - Monitors TCP/UDP traffic on restricted ports (7, 9, 13, 17, 19, 22, 23, 139, 162, 389, 445, 1433, 3306, 8291).
  - IPs attempting unauthorized access get:
    - **Strike 1**: 10-minute timeout.
    - **Strike 2**: 10-minute timeout.
    - **Strike 3**: Blocked for 5 days.
    - **Re-listing**: Blocked for 6 days if further attempts occur.
- **IPv4/IPv6 Support**: Separate lists for IPv4 (`NuajP-Dynamic-*`) and IPv6 (`NuajP-Dynamic6-*`).

## DDoS Protection
- Detects excessive connections (32 per 10 seconds, source/destination-based).
- Adds attackers and targets to `ddos-attackers` and `ddos-targets` lists (10-minute timeout).
- Drops traffic between attackers and targets.

## Troubleshooting
- **DNS Resolution Fails**:
  - Verify DNS settings: `/ip dns print`.
  - Test connectivity: `/ping 88.198.70.38`.
  - Check address list: `/ip firewall address-list print where list=NuajP-DNS-Servers`.
- **Blacklist Download Fails**:
  - Check logs: `/log print where topics~"(info|error)"`.
  - Test URL: `/tool fetch url="http://blacklist.nuaj.ca/uhb.rsc" mode=http dst-path=test.rsc`.
- **Dynamic Blacklist Issues**:
  - Verify rules: `/ip firewall filter print where comment~NuajProtect`.
  - Check blocked IPs: `/ip firewall address-list print where list=NuajP-Dynamic-Blacklist`.
- **General Issues**:
  - Ensure WAN interface list is configured: `/interface list member print where list=WAN`.
  - Check logs for errors: `/log print`.

## Contributing
We welcome contributions! To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/YourFeature`).
3. Commit changes (`git commit -m "Add YourFeature"`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

Please include detailed descriptions of changes and test results.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

**Release Notice**:  
NuajProtect is provided "as is" with no warranty or liability of any kind, express or implied. Nuaj Company Inc. and its contributors are not responsible for any damages, losses, or issues arising from the use of this software. **Test thoroughly in a non-production environment before deployment** to ensure compatibility and stability with your network configuration.

## Contact
For support or inquiries:
- **Email**: support@nuaj.ca
- **GitHub Issues**: [Open an issue](https://github.com/<your-username>/NuajProtect/issues)

---

⭐ **Star this repository** if you find NuajProtect useful!  
Contributions and feedback are greatly appreciated.
