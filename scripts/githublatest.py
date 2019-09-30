#!/usr/bin/env python3

import json
import urllib.request
import argparse

# set parameters for script
parser = argparse.ArgumentParser(description='Get download url from github releases with filename filter')
parser.add_argument('filter', help='file name filer')
parser.add_argument('url', help='url of github api')
# read command line params
args = parser.parse_args()

# get url content
with urllib.request.urlopen(args.url) as response:
    json_data = response.read()
parsed_json = (json.loads(json_data))

# find assets.browser_download_url that matches filter
for asset in parsed_json['assets']:
    if asset['browser_download_url'].find(args.filter) > 0:
        print(asset['browser_download_url'])
