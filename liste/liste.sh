#!/bin/bash

set -x
set -e
set -u
set -o pipefail

### requisiti ###
# Miller 5
# jq
### requisiti ###

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

URL_base="https://dait.interno.gov.it"

if [ -f "$folder"/tmp-lista.md ]; then
    rm "$folder"/tmp-lista.md
fi

# scarica liste
curl -kLs 'https://dait.interno.gov.it/elezioni/trasparenza/elezioni-politiche-2022'  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' \
  --compressed | sed -e '/carica/,/)/!d' | perl  -p -e 's/\n//g' | sed 's/carica/\ncarica/g' | grep -Po '/docu.+?",.+?",' | sed -r 's/ +//g;s|","|/|;s/",//' | grep -vP '.+POLI.+?/POLI.+'| while read -r line; do
    nome=$(echo "$line" | sed -r 's|/.+/||')
    curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' "$URL_base"/"$line".json >"$folder"/rawdata/"$nome".json
    <"$folder"/rawdata/"$nome".json jq -c '.candidati[]' | mlr --j2c unsparsify then cut -x -r -f ":" then cut -x -f cod_fisc then put '${dt_nasc}=regextract_or_else(${dt_nasc},"[0-9]{4}","")' >"$folder"/processing/"$nome".csv
    echo "[\`$nome.csv\`](./processing/$nome.csv)" >>"$folder"/tmp-lista.md
  done
