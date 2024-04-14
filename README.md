# Sanction Compliance Discovery Tool and Notification

## Overview

The _**Sanctions Compliance Discovery Tool**_ is designed to assist security researchers and compliance officers in monitoring and analyzing entities that may be subject to ```EU``` and ```US``` sanctions. This tool automates the retrieval and analysis of sanctions lists to identify and report on entities potentially violating these sanctions. By streamlining the process of sanctions compliance, this tool helps ensure that organizations under ```EU``` and ```US``` jurisdiction can efficiently adhere to [regulatory requirements](https://ofac.treasury.gov/) and mitigate the risks of [legal penalties](https://www.consilium.europa.eu/en/press/press-releases/2024/04/12/council-gives-final-approval-to-introduce-criminal-offences-and-penalties-for-eu-sanctions-violation/).

## Features

- **Automated Downloads**: Downloads the latest ```EU``` and ```US``` sanctions lists directly from official sources.
- **Data Extraction**: Extracts ```domain names``` and performs ```DNS lookups``` to gather associated ```IP addresses```.
- **WHOIS Lookups**: Retrieves ```ownership``` and ```contact information``` for ```IP addresses```, highlighting potential sanctions violations.
- **Report Generation**: Creates detailed reports based on the extracted and analyzed data, formatted for compliance submissions.
- **Interactive Emailing**: Allows users to email reports directly from the script, targeting relevant parties.

## Installation

To use the _**Sanctions Compliance Discovery Tool**_, you need a bash environment with `curl`, `jq`, `grep`, `awk`, `sed`, and `mail` (or a similar mail utility) installed. Follow these steps to set up the script:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/appatalks/sanctions-compliance.git
   cd sanctions-compliance
   ```

2. **Set Executable Permissions**:
   ```bash
   chmod +x compliance_discovery.sh
   ```

3. **Configure Mail Utility**:
   - Ensure that your system's mail utility is configured correctly to send emails. This might involve setting up `sendmail` or `postfix`.

## Usage

Run the script directly from the command line:

```bash
./compliance_discovery.sh
```

You are prompted and encouraged to review, **verify** and modify the generated reports as needed and optionally email these reports to specified recipients.

### Configuring the Script

Edit the following variables within the script to suit your needs:

- `COUNTRY_CODE`: Optionally change this to the country code ```TLD``` you wish to filter (.ru, .by, .ir, .cn, etc.).
- `DNS`: Set this to your preferred ```DNS resolver``` if not using the default.

## Contributing

Contributions to the Sanctions Compliance Discovery Tool are welcome. Please fork the repository, make your changes, and submit a pull request.

## License

This project is licensed under the ```GNU General Public License v3.0``` - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any problems or have suggestions, please open an issue in the repository.
