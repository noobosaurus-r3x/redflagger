#!/bin/bash

# Usage: ./redflagger.sh --latest|--days [num] --all [--output [filename]]
# Example: ./reflagger.sh -d 3 -a -o my_file.txt #This will download the report from 3 days ago and all available reports, saving them to my_file.txt
           ./redflagger.sh -a -o my_file.txt #This will download all available reports, saving them to my_file.txt



output_file="output.txt"  # Default output file
while getopts ":lad:o:" opt; do
  case ${opt} in
    l ) # process option latest
      date=$(date -d "1 day ago" +%Y-%m-%d)
      ;;
    a ) # process option all
      all=true
      ;;
    d ) # process option days
      date=$(date -d "$OPTARG day ago" +%Y-%m-%d)
      ;;
    o ) # process option output
      output_file=$OPTARG
      ;;
    \? ) echo "Usage: ./script.sh [-l] [-a] [-d num] [-o filename]"
      exit 1
      ;;
  esac
done

shift $((OPTIND -1))

if [[ -z "$date" && -z "$all" ]]; then
    echo "Usage: ./script.sh [-l] [-a] [-d num] [-o filename]"
    exit 1
fi

main_url=$(curl -s 'https://dl.red.flag.domains/daily/')
if [[ $? -ne 0 ]]; then
    echo "Failed to fetch the main page. Please check your internet connection."
    exit 1
fi

links=$(echo "$main_url" | grep -oP '(?<=href=")[^"]*')

declare -A downloaded_links

for link in $links; do
    if [[ $link =~ ^[0-9]{4} ]]; then
        if [[ $link == *"$date"* || "$all" == "true" ]]; then
            # Skip if this link was previously downloaded
            if [[ ${downloaded_links[$link]} == "true" ]]; then
                continue
            fi

            echo "Downloading: $link"
            curl -s "https://dl.red.flag.domains/daily/$link" >> "$output_file"
            if [[ $? -ne 0 ]]; then
                echo "Failed to download $link. Continuing with the next one."
                continue
            fi
            
            downloaded_links[$link]="true"
        fi
    fi
done

sort "$output_file" -o "$output_file"
