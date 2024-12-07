#!/usr/bin/env bash
set -euo pipefail

# Usage: ./redflagger.sh --latest|--days [num] --all [--output [filename]]
# Example: ./redflagger.sh -d 3 -a -o my_file.txt
# This example fetches the report from 3 days ago and all available reports, then writes them to my_file.txt.
# Another example: ./redflagger.sh -a -o my_file.txt
# This example fetches all available reports and writes them to my_file.txt.

output_file="output.txt"

date_request=""
all="false"

while getopts ":lad:o:" opt; do
    case "${opt}" in
        l)
            # The date is set to one day ago in YYYY-MM-DD format.
            date_request="$(date -d "1 day ago" +%Y-%m-%d 2>/dev/null || true)"
            if [ -z "${date_request}" ]; then
                echo "Error computing the date for option -l."
                exit 1
            fi
            ;;
        a)
            # Set all=true to fetch all available reports.
            all="true"
            ;;
        d)
            # Set the date to a specified number of days ago, if the argument is a positive integer.
            if [[ "${OPTARG}" =~ ^[0-9]+$ ]]; then
                date_request="$(date -d "${OPTARG} day ago" +%Y-%m-%d 2>/dev/null || true)"
                if [ -z "${date_request}" ]; then
                    echo "Error computing the date for option -d ${OPTARG}."
                    exit 1
                fi
            else
                echo "The argument for -d must be an integer."
                exit 1
            fi
            ;;
        o)
            # Change the output file to the specified filename, if not empty.
            output_file="${OPTARG}"
            if [ -z "${output_file}" ]; then
                echo "The output filename cannot be empty."
                exit 1
            fi
            ;;
        \?)
            echo "Usage: ./redflagger.sh [-l] [-a] [-d num] [-o filename]"
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

if [ -z "${date_request}" ] && [ "${all}" != "true" ]; then
    echo "Usage: ./redflagger.sh [-l] [-a] [-d num] [-o filename]"
    exit 1
fi

# Fetch the main page content and store it in main_url.
main_url="$(curl -s 'https://dl.red.flag.domains/daily/' || true)"
if [ -z "${main_url}" ]; then
    echo "Unable to fetch the main page. Check your network connection."
    exit 1
fi

# Extract all links that match YYYY-MM-DD format.
links="$(echo "${main_url}" | grep -Eo 'href="[0-9]{4}-[0-9]{2}-[0-9]{2}[^"]*"' || true)"
if [ -z "${links}" ]; then
    echo "No matching links found."
    exit 0
fi

declare -A downloaded_links

# Process each link found on the page.
while IFS= read -r raw_link; do
    # Remove the prefix href=" and the trailing quote.
    clean_link="$(echo "${raw_link}" | sed -E 's/^href="([^"]+)".*$/\1/')"
    if [[ "${clean_link}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        # If all=true or if the link matches the requested date, attempt to download it.
        if [ "${all}" = "true" ] || [[ "${clean_link}" == *"${date_request}"* ]]; then
            if [ "${downloaded_links[${clean_link}]+isset}" != "isset" ]; then
                echo "Downloading: ${clean_link}"
                if ! curl -s "https://dl.red.flag.domains/daily/${clean_link}" >> "${output_file}" 2>/dev/null; then
                    echo "Failed to download ${clean_link}. Continuing with the next one."
                    continue
                fi
                downloaded_links["${clean_link}"]="true"
            fi
        fi
    fi
done <<< "${links}"

# Sort the output file to maintain an ordered dataset.
sort "${output_file}" -o "${output_file}"
