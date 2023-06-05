# redflagger
Bash script inspired by NewRedflag, a python script written by lil-doudou
https://github.com/lil-doudou/NewRedflag

The point to that script is to make a wordlist based on the latest domains found on https://red.flag.domains/

# Usage: ```./redflagger.sh --latest|--days [num] --all [--output [filename]]{{{ 

# Example: ```./reflagger.sh -d 3 -a -o my_file.txt``` 
#This will download the report from 3 days ago and all available reports, saving them to my_file.txt

# Example2:```./redflagger.sh -a -o my_file.txt``` 
#This will download all available reports, saving them to my_file.txt
