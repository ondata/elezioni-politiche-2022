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

mlr --c2t filter -S '$tipo=="CM"' then put -S '$CP=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\3");$CU=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\4");$PR=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4})([0-9]{3})([0-9]{4}).*$","\5");$CM=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4})([0-9]{3})([0-9]{4}).*$","\6")' then cut -f cod,CP,CU,PR,CM "$folder"/../risorse/senato_geopolitico_italia.csv | tail -n +2 >"$folder"/processing/comuni-senato.tsv

while IFS=$'\t' read -r cod CP CU PR CM; do

  if [ ! -f "$folder"/rawdata/senato-italia-comune_"$CP-$CU-$PR-$CM".json ]; then

    echo "$CM"
    curl -ksL "https://eleapi.interno.gov.it/siel/PX/scrutiniSI/DE/20220925/TE/03/CP/$CP/CU/$CU/PR/$PR/CM/$CM" \
      -H 'authority: eleapi.interno.gov.it' \
      -H 'accept: application/json, text/javascript, */*; q=0.01' \
      -H 'accept-language: en-US,en;q=0.9,it;q=0.8' \
      -H 'content-type: application/json' \
      -H 'origin: https://elezioni.interno.gov.it' \
      -H 'referer: https://elezioni.interno.gov.it/' \
      -H 'sec-ch-ua: "Google Chrome";v="105", "Not)A;Brand";v="8", "Chromium";v="105"' \
      -H 'sec-ch-ua-mobile: ?0' \
      -H 'sec-ch-ua-platform: "Windows"' \
      -H 'sec-fetch-dest: empty' \
      -H 'sec-fetch-mode: cors' \
      -H 'sec-fetch-site: same-site' \
      -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36' \
      --compressed |
      jq . >"$folder"/rawdata/senato-italia-comune_"$CP-$CU-$PR-$CM".json

  else

    echo "$CU-$PR-$CM esiste già"

  fi

done <"$folder"/processing/comuni-senato.tsv

exit 0
