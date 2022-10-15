#!/bin/bash

set -x
#set -e
#set -u
#set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

# find "$folder"/rawdata -maxdepth 1 -iname "*.json" -type f -delete
# find "$folder"/rawdata -maxdepth 1 -iname "*.csv" -type f -delete
# find "$folder"/processing -maxdepth 1 -iname "*.csv" -type f -delete

### comuni ###

mlr --c2t filter -S '$tipo=="CM"' then put -S '$CP=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\3");$CU=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\4");$PR=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4})([0-9]{3})([0-9]{4}).*$","\5");$CM=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4})([0-9]{3})([0-9]{4}).*$","\6")' then cut -f cod,CP,CU,PR,CM "$folder"/../risorse/camera_geopolitico_italia.csv | tail -n +2 >"$folder"/processing/comuni.tsv

while IFS=$'\t' read -r cod CP CU PR CM; do

  if [ ! -f "$folder"/rawdata/camera-italia-comune_"$CU-$PR-$CM".json ]; then

    echo "$CM"
    curl "https://eleapi.interno.gov.it/siel/PX/scrutiniCI/DE/20220925/TE/02/CP/$CP/CU/$CU/PR/$PR/CM/$CM" \
      -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0' \
      -H 'Accept: application/json, text/javascript, */*; q=0.01' \
      -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' \
      -H 'Accept-Encoding: gzip, deflate, br' \
      -H 'Content-Type: application/json' \
      -H 'Origin: https://elezioni.interno.gov.it' \
      -H 'DNT: 1' \
      -H 'Connection: keep-alive' \
      -H 'Referer: https://elezioni.interno.gov.it/' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Site: same-site' \
      -H 'Pragma: no-cache' \
      -H 'Cache-Control: no-cache' \
      -H 'TE: trailers' --compressed |
      jq . >"$folder"/rawdata/camera-italia-comune_"$CU-$PR-$CM".json

  else

    echo "$CU-$PR-$CM esiste già"

  fi

done \
  <"$folder"/processing/comuni.tsv

exit 0
