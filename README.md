# RedFlagger

RedFlagger is a bash script designed to download and aggregate reports from 'https://dl.red.flag.domains/daily/' based on user-specified conditions.

It is inspierd by NewRedflag, a python script written by lil-doudou

https://github.com/lil-doudou/NewRedflag

## Usage

```./redflagger.sh [--latest|--days num] [--all] [--output filename]```



### Options

- `--latest` or `-l`: Downloads the report from 1 day ago.
- `--days num` or `-d num`: Downloads the report from 'num' days ago.
- `--all` or `-a`: Downloads all available reports.
- `--output filename` or `-o filename`: Specifies the output file to store the downloaded reports. Defaults to 'output.txt' if no filename is provided.

### Examples

Download the report from 3 days ago and all available reports, saving them to 'my_file.txt':

```./redflagger.sh -d 3 -a -o my_file.txt```

Download all available reports, saving them to 'my_file.txt':

```./redflagger.sh -a -o my_file.txt```


