#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

curl --socks5-hostname localhost:9050 -s -kL https://eleapi.interno.gov.it/siel/PX/votantiP/DE/20220925/TE/02/PR/002 -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Origin: https://elezioni.interno.gov.it' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Referer: https://elezioni.interno.gov.it/' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-site' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers' --compressed >"$folder"/test.json
