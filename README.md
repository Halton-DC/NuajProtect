# NuajProtect Security Suite for MikroTik

**Version**: 1.5  
**Last Updated**: May 8, 2025  
**License**: MIT  
**Author**: Nuaj Company Inc.

## Overview

NuajProtect is a comprehensive security suite for MikroTik routers, designed to enhance network protection through dynamic and static blacklists, DDoS mitigation, and secure DNS configuration. It leverages multiple blacklist sources, a honeypot-based dynamic blacklist system, and Cloudflare’s secure DNS to block malicious traffic while allowing legitimate connections.

### Key Features
- **Static Blacklists**: Integrates DShield, SpamHaus, VOIP, Bruteforce, CINSscore, and Ultimate.Host.Black (UHB) blacklists to block known malicious IPs.
- **Dynamic Blacklists**: Uses a honeypot to block IPs attempting unauthorized access (3 strikes within 10 minutes, blocked for 5-6 days).
- **Basic DDoS Protection**: Detects and mitigates DDoS attacks by limiting connections and blacklisting attackers.
- **Secure DNS**: Configures Cloudflare 1.1.1.1 for Families (`1.1.1.2`, `1.0.0.2`, blocks malware) as primary DNS, with optional malware and adult content filtering (`1.1.1.3`, `1.0.0.3`, disabled by default).
- **Private IP Blocking**: Blocks non-routable IP ranges to enhance security.
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
   - The script sets Cloudflare 1.1.1.1 for Families (`1.1.1.2`, `1.0.0.2`, blocks malware) as the router’s DNS servers by default.
   - Optional Cloudflare DNS servers for malware and adult content blocking are included in `NuajP-DNS-Servers` (disabled by default):
     - `1.1.1.3`, `1.0.0.3`: Blocks malware and adult content.
   - To enable the malware and adult content DNS:
     ```bash
     /ip firewall address-list set [find address=1.1.1.3] disabled=no
     /ip firewall address-list set [find address=1.0.0.3] disabled=no
     /ip dns set servers=1.1.1.3,1.0.0.3
     ```
   - To disable a DNS server:
     ```bash
     /ip firewall address-list set [find address=1.1.1.2] disabled=yes
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
     Expected: `servers: 1.1.1.2,1.0.0.2`
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
- **DShield**: `http://blacklist.nuaj.ca/dshield.rsc` (custom source, parsed by Joshaven Potter).
- **SpamHaus**: `http://blacklist.nuaj.ca/spamhaus.rsc` (blocks spam and malicious IPs, parsed by Joshaven Potter).
- **VOIP**: `http://blacklist.nuaj.ca/voip-bl.rsc` (blocks VOIP abuse, maintained by Joshaven Potter).
- **Bruteforce**: `http://blacklist.nuaj.ca/bruteforce.rsc` (blocks brute-force attackers, maintained by Joshaven Potter).
- **CINSscore**: `http://blacklist.nuaj.ca/CINSscore.rsc` (blocks high-risk IPs, maintained by Joshaven Potter).
- **Ultimate.Host.Black (UHB)**: `http://blacklist.nuaj.ca/uhb.rsc` (custom blacklist for specific threats).  
  **Caution**: The Ultimate.Host.Black (UHB) list contains over 147,000 IPs, which may cause performance issues or memory constraints on some MikroTik models. Test thoroughly on your hardware, and consider disabling this blacklist if issues arise.

Each blacklist is downloaded and applied at staggered times (21:00–21:55) to minimize router load.

## Acknowledgments
We extend our heartfelt thanks to the following individuals and organizations for their contributions to NuajProtect:
- **Joshaven Potter**: Special thanks for inspiring this project and maintaining the DShield, SpamHaus, VOIP, Bruteforce, and CINSscore blacklists in MikroTik-compatible format. Their work at [https://joshaven.com](https://joshaven.com) has been instrumental in making NuajProtect possible.
- **DShield** (SANS Internet Storm Center): For their original recommended block list, identifying malicious IP ranges.
- **SpamHaus**: For their original DROP list, protecting against spam and malicious activities.
- **VOIP Blacklist Contributors**: For their efforts in combating VOIP abuse and fraud.
- **Bruteforce Blocklist Contributors**: For tracking IPs involved in brute-force attacks.
- **CINSscore Contributors**: For their high-quality, high-risk IP blocklist.
- **UHB Contributors**: For their custom Ultimate.Host.Black (UHB) blacklist addressing specific threats.

Their efforts are invaluable to network security, and NuajProtect relies on their contributions.

## DNS Configuration
- **Primary DNS**:
  - Cloudflare 1.1.1.1 for Families (`1.1.1.2`, `1.0.0.2`): Blocks malware, enabled by default, used by the router.
- **Optional DNS** (disabled by default):
  - Cloudflare 1.1.1.1 for Families (`1.1.1.3`, `1.0.0.3`): Blocks malware and adult content.
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
- **Address Lists**: Uses `NuajP-Dynamic-*` lists for tracking blocked IPs.

## Basic DDoS Protection
- Detects excessive connections (32 per 10 seconds, source/destination-based).
- Adds attackers and targets to `ddos-attackers` and `ddos-targets` lists (10-minute timeout).
- Drops traffic between attackers and targets.

## Troubleshooting
- **DNS Resolution Fails**:
  - Verify DNS settings: `/ip dns print`.
  - Test connectivity: `/ping 1.1.1.2`.
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
Contributions are welcome but must be approved by the repository maintainer (@<your-github-username>) via pull requests. To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/YourFeature`).
3. Commit changes (`git commit -m "Add YourFeature"`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request with a detailed description of changes and test results.
6. The maintainer will review and approve the pull request before merging.

**Note**: Direct pushes to the `main` branch are disabled. All changes require a pull request and maintainer approval to ensure quality and compatibility.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

**Release Notice**:  
NuajProtect is provided "as is" with no warranty or liability of any kind, express or implied. Nuaj Company Inc. and its contributors are not responsible for any damages, losses, or issues arising from the use of this software. **Test thoroughly in a non-production environment before deployment** to ensure compatibility and stability with your network configuration.

## Contact
For support or inquiries:
- **Email**: support@nuaj.com
- **GitHub Issues**: [Open an issue](https://github.com/<your-username>/NuajProtect/issues)

Powered by Halton Data Center - http://haltondc.com

---

⭐ **Star this repository** if you find NuajProtect useful!  
Contributions and feedback are greatly appreciated.
