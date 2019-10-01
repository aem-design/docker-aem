#!/usr/bin/env python3

import requests
import time
import argparse
import sys
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry


# retry request
def requests_retry_session(
        retries=3,
        backoff_factor=0.3,
        status_forcelist=(403, 500, 502, 504),
        session=None,
):
    session = session or requests.Session()
    retry = Retry(
        total=retries,
        read=retries,
        connect=retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session

def main():

    # set parameters for script
    parser = argparse.ArgumentParser(description='Get download url from github releases with filename filter')
    parser.add_argument('filter', help='file name filer')
    parser.add_argument('url', help='url of github api')
    # read command line params
    args = parser.parse_args()

    # get url content with retry
    t0 = time.time()
    try:
        response = requests_retry_session().get(args.url)
    except Exception as x:
        print('Download failed', x.__class__.__name__, file=sys.stderr)
        print(response, file=sys.stderr)
        return
    else:
        print('Download succeeded', response.status_code, file=sys.stderr)
    finally:
        t1 = time.time()
        print('Took', t1 - t0, 'seconds', file=sys.stderr)

    parsed_json = response.json()

    if 'assets' not in parsed_json:
        print('Error occurred getting: ' + args.url)
        print(parsed_json)
        return

    # find assets.browser_download_url that matches filter
    for asset in parsed_json['assets']:
        if asset['browser_download_url'].find(args.filter) > 0:
            print(asset['browser_download_url'])

    return

if __name__ == '__main__':
    main()