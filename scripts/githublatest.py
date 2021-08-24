#!/usr/bin/env python3

import requests
import argparse
import re

# set parameters for script
parser = argparse.ArgumentParser(description='Get download url from github releases with filename filter')
parser.add_argument('filter', help='file name filter regex')
parser.add_argument('url', help='url of github api')
# read command line params
args = parser.parse_args()

# get url content
response = requests.get(args.url)
parsed_json = response.json()

# find assets.browser_download_url that matches filter
pattern = re.compile(args.filter)
for asset in parsed_json['assets']:
    if pattern.match(asset['browser_download_url']):
      print(asset['browser_download_url'])
