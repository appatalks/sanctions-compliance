#!/bin/bash
# 
# Purpose: sanctions-compliance will review the latests EU/US sanctions lists and build reports 
# for submissions to help EU/US entities be informed and remain compliant.
#
#
# Source Material: 
# SDN.CSV - comma delimited primary SDN names
# https://ofac.treasury.gov/specially-designated-nationals-list-data-formats-data-schemas

# Options
DNS="@1.1.1.1"
COUNTRY_CODE=".ru" # manually update lines [100 - 107] too!!

# Define paths for files
eu_sanctions_url="https://data.europa.eu/euodp/data/api/3/action/package_show?id=consolidated-list-of-persons-groups-and-entities-subject-to-eu-financial-sanctions"
us_sanctions_url="https://www.treasury.gov/ofac/downloads/sdn.csv"
eu_sanctions_file="/tmp/eu_sanctions.csv"
us_sanctions_file="/tmp/us_sanctions.csv"
eu_tlds_file="/tmp/eu_tlds.txt"
us_tlds_file="/tmp/us_tlds.txt"
eu_dns_records_file="/tmp/eu_dns_records.txt"
us_dns_records_file="/tmp/us_dns_records.txt"
ip_ownership_file="/tmp/ip_ownership.txt"
report_template_file="assets/report_template.txt"
filtered_report_file="/tmp/filtered_report.txt"
final_report_file="/tmp/$(date +%Y%m%d-%H%M)_final_report"

# Download EU Sanctions List
echo "Downloading EU Sanctions List..."
curl -s $(curl -s $eu_sanctions_url | jq -r '.result.resources[] | select(.format | endswith("CSV")) | .url'| tail -n1) -o $eu_sanctions_file

# Download US Sanctions List
echo "Downloading US Sanctions List..."
curl -s $us_sanctions_url -o $us_sanctions_file

# Extract EU sanctioned TLDs
# Targeting .RU Entities
echo "Extracting $COUNTRY_CODE TLDs from EU Sanctions List..."
cat $eu_sanctions_file | grep -oP 'WEB\[http://\K[^]]*' | sed -E 's/\/.*//; s/].*//; s/ .*//' | sort -u | grep "$COUNTRY_CODE" > $eu_tlds_file

# Extract US sanctioned TLDs
# Targeting .RU Entities
echo "Extracting $COUNTRY_CODE TLDs from US Sanctions List..."
grep -oP 'https?://\K\S+|www\.\K\S+' $us_sanctions_file | sed 's/[^a-zA-Z0-9.-]//g' | sort -u | grep "$COUNTRY_CODE" | grep -v "home.treasury.gov" > $us_tlds_file

# Function to check DNS records
function check_dns_records {
    local tlds_file=$1
    local dns_records_file=$2
    echo "Checking DNS Records for $tlds_file..."
    while read -r tld; do
	echo "Discovery in progress for $tld records. Stand By..."
	echo "Top Level Domain: $tld" >> $dns_records_file
        echo "A Records:" >> $dns_records_file
        dig $DNS +short $tld A >> $dns_records_file
        # echo "NS Records:" >> $dns_records_file
        # dig $DNS +short $tld NS >> $dns_records_file
        # echo "MX Records:" >> $dns_records_file
        # dig $DNS +short $tld MX >> $dns_records_file
	sleep 1
    done < $tlds_file
}

# Sanity Check
echo "Discovered Sanctioned Records: $(cat $eu_tlds_file $us_tlds_file | wc -l)"
 
# Check DNS records for EU and US sanctioned TLDs
check_dns_records $eu_tlds_file $eu_dns_records_file
check_dns_records $us_tlds_file $us_dns_records_file

# Perform WHOIS lookups and filter relevant information
# This will replace {{filtered_report_file}} in report template.
echo "Performing WHOIS lookups..."
echo "" > $ip_ownership_file
for ip in $(cat $eu_dns_records_file $us_dns_records_file | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort | uniq); do
    echo "Discovery in progress for $ip WHOIS record. Stand By..."	
    echo "\`\`\`" >> $ip_ownership_file    
    echo "**Owner information suspected of sanction violations:** " >> $ip_ownership_file
    # Defined DNS Fields to pull. May want to grab contact information.
    # whois $ip | grep -iE 'inetnum|OrgName|org-name|Country|address|phone|remarks|abuse-email|abuse contact for' | sed -E 's/.*abuse contact for .* is '\''([^'\'']+)'\''/\1/i' |sort -u >> $ip_ownership_file
    whois $ip | grep -iE 'inetnum|OrgName|org-name|Country|address|phone|remarks|OrgAbuseEmail|abuse-email|abuse contact for' | awk '
    /abuse contact for/ { 
        match($0, /'\''([^'\'']+@[^'\'']+)'\''/, arr); 
        if (length(arr[1]) > 0) print "email: " arr[1];
        next; 
    }
    /Abuse contact for/ {
        match($0, /'\''([^'\'']+@[^'\'']+)'\''/, arr);
        if (length(arr[1]) > 0) print "email: " arr[1];
        next;
    }
    /abuse@|@abuse/ {
        match($0, /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/, m);
        if (length(m[0]) > 0) print "email: " m[0];
        next;
    }
    /remarks/ {
        if ($0 ~ /e-?mail/) {
            match($0, /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/, m);
            if (length(m[0]) > 0) print "email: " m[0];
        }
    }
    { print }' | sort -u >> $ip_ownership_file

    echo "~" >> $ip_ownership_file
    # Violation Details
    echo "**Suspected Details of Sanction Violation:**" >> $ip_ownership_file
    echo "The suspected sanction violation stems from the entity's ownership, operation and control of the IP range used for infrastructure, which constitutes material support non-compliant with EU or US sanctions and applicable laws." >> $ip_ownership_file	
    echo "~" >> $ip_ownership_file
    # Cross-Refernce public data of supporting evidence
    echo "**Supporting Evidence:** " >> $ip_ownership_file
    echo "EU Sanctioned $(grep -B2 $ip $eu_dns_records_file | grep "Top Level Domain" | sort | uniq)" >> $ip_ownership_file
    echo "US Sanctioned $(grep -B2 $ip $us_dns_records_file | grep "Top Level Domain" | sort | uniq)" >> $ip_ownership_file
    echo "Resolving IP: $ip" >> $ip_ownership_file

    echo "\`\`\`" >> $ip_ownership_file
    sleep 1
done

# Filter for $COUNTRY_CODE domains using non-RU country
echo "Filtering $COUNTRY_CODE records..."

awk 'BEGIN{RS="```"; FS="\n"}
    /Domain:.*\.ru/ { # Check for presence of TLD line with a .ru domain
        count_ru = 0; other_country = 0; print_block = 1
        for (i = 1; i <= NF; i++) {
            if (tolower($i) ~ /country: +ru/) count_ru++ # Case-insensitive match RU country code
            if (tolower($i) ~ /country: +[a-z]{2}/ && tolower($i) !~ /country: +ru/) other_country = 1
        }
        if (count_ru > 0 && !other_country) print_block = 0
        if (print_block) print $0 "\n"
    }' $ip_ownership_file > $filtered_report_file

# Generate reports
echo "Generating final report..."

block_number=1
awk -v template="$report_template_file" -v output_base="$final_report_file" '
    BEGIN { block=""; RS=""; ORS="\n\n" }
    {
        block=$0; # Save the whole block
        gsub(/\n$/, "", block); # Trim trailing new line

        # Define the output file path
        output_file=output_base "_" block_number "_sanction_violation.md";

        # Read and process the template file
        while ((getline line < template) > 0) {
            if (line ~ /\{\{filtered_report_file\}\}/) {
                # Replace the placeholder with the actual data block
                gsub(/\{\{filtered_report_file\}\}/, block, line);
            }
            print line >> output_file;
        }
        close(template);

        # Increment the block number
        block_number++;
    }' "$filtered_report_file"

# Send report
echo "Sending report..."
# mail -s "Suspected Sanction Violation Report" -A $final_report_file relex-sanctions@ec.europa.eu

# Schedule follow-up
# echo "Scheduling follow-up reminder..."
# echo "bash send_reminder.sh" | at now + 30 days

echo "Process completed successfully."
echo ""

echo "Full Discovery located at: $ip_ownership_file"
echo "EU/US Discovery located at: $filtered_report_file"
echo ""
echo "Submission Ready Reports located at: "
echo "$(ls -1 $final_report_file*violation.md)"
echo ""

# Ask user if they would like to review reports
# If user selects yes, use vim editor; :n = next page
echo "Would you like to review the reports? (yes/no)"
read -r review_answer

if [[ "$review_answer" == "yes" ]]; then
    vim $final_report_file*
fi
echo ""

# Ask user if they would like to submit reports by Email
# If user selects yes, send seperate emails for each report to relex-sanctions@ec.europa.eu
echo "Would you like to email the reports? (yes/no)"
read -r email_answer

if [[ "$email_answer" == "yes" ]]; then
    for report in $final_report_file*_sanction_violation.md; do
        # Initialize the recipients list with a primary recipient
        recipients="relex-sanctions@ec.europa.eu"

        # Extract emails from the specific report, exclude country_code emails, append to recipients
        emails=$(grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$report" | grep -v "$COUNTRY_CODE" | sort -u)
        for email in $emails; do
            # Add only unique and relevant emails to the recipients list
            recipients="$recipients,$email"
        done

        # Send the specific report to the extracted and filtered emails
        echo "Sending $report to $recipients..."
        echo "# mail -s "Suspected Sanction Violation Report" -A "$report" -- $recipients"
        mail -s "Suspected Sanction Violation Report" -A "$report" -- $recipients
	echo ""
    done
    echo "Emails sent successfully."
fi

