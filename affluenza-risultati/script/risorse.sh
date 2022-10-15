#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder/tmp"
mkdir -p "$folder/rawdata"
mkdir -p "$folder/processing"

# suddivisioni geografiche
territorio="https://elezioni.interno.gov.it/tornate/20220925/enti/camerasenato_territoriale_italia.json"

if [ ! -f "$folder"/../risorse/territorio.json ]; then
  curl "$territorio" \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0' \
    -H 'Accept: application/json, text/javascript, */*; q=0.01' \
    -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'X-Requested-With: XMLHttpRequest' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Referer: https://elezioni.interno.gov.it/camera/votanti/20220925/votantiCI' \
    -H 'Sec-Fetch-Dest: empty' \
    -H 'Sec-Fetch-Mode: cors' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' \
    -H 'TE: trailers' --compressed | jq . >"$folder"/../risorse/territorio.json
fi

# converti in CSV
jq <"$folder"/../risorse/territorio.json '.enti[]' | mlr --j2c unsparsify >"$folder"/../risorse/territorio.csv

# anagrafica comuni

if [ ! -f "$folder"/../risorse/anagraficaComuni.csv ]; then

  URLcodiciComuni="https://dait.interno.gov.it/territorio-e-autonomie-locali/sut/elenco_codici_comuni_csv.php"

  curl -Lks "$URLcodiciComuni" \
    -H 'Connection: keep-alive' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
    -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' \
    -H 'Cookie: has_js=1' \
    --compressed --insecure >"$folder"/../risorse/anagraficaComuni.csv

  mlr -I --icsvlite -N --ocsv --ifs ";" clean-whitespace "$folder"/../risorse/anagraficaComuni.csv
  mlr -I --csv put -S '${CODICE ISTAT}=gsub(${CODICE ISTAT},"(\"|=)","")' "$folder"/../risorse/anagraficaComuni.csv

  mlr -I --csv put -S '$codINT=sub(${CODICE ELETTORALE},"^(.{1})(.+)$","\2")' "$folder"/../risorse/anagraficaComuni.csv
fi

camera="https://elezioni.interno.gov.it/tornate/20220925/enti/camera_geopolitico_italia.json"

if [ ! -f "$folder"/../risorse/camera_geopolitico_italia.json ]; then
  curl "$camera" \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0' \
    -H 'Accept: application/json, text/javascript, */*; q=0.01' \
    -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'X-Requested-With: XMLHttpRequest' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Referer: https://elezioni.interno.gov.it/camera/votanti/20220925/votantiCI' \
    -H 'Sec-Fetch-Dest: empty' \
    -H 'Sec-Fetch-Mode: cors' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' \
    -H 'TE: trailers' --compressed | jq . >"$folder"/../risorse/camera_geopolitico_italia.json
fi

# converti in CSV
jq <"$folder"/../risorse/camera_geopolitico_italia.json '.enti[]' | mlr --j2c unsparsify >"$folder"/../risorse/camera_geopolitico_italia.csv

senato="https://elezioni.interno.gov.it/tornate/20220925/enti/senato_geopolitico_italia.json"

if [ ! -f "$folder"/../risorse/senato_geopolitico_italia.json ]; then
  curl "$senato" \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0' \
    -H 'Accept: application/json, text/javascript, */*; q=0.01' \
    -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'X-Requested-With: XMLHttpRequest' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Referer: https://elezioni.interno.gov.it/camera/votanti/20220925/votantiCI' \
    -H 'Sec-Fetch-Dest: empty' \
    -H 'Sec-Fetch-Mode: cors' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' \
    -H 'TE: trailers' --compressed | jq . >"$folder"/../risorse/senato_geopolitico_italia.json
fi

# converti in CSV
jq <"$folder"/../risorse/senato_geopolitico_italia.json '.enti[]' | mlr --j2c unsparsify >"$folder"/../risorse/senato_geopolitico_italia.csv


# aggiungi a dati comunali camera, il codice ISTAT

mlr --csv put '$join=fmtnum($cod_prov,"%03d").fmtnum($cod_com,"%04d")' "$folder"/../dati/risultati/camera-italia-comune_anagrafica.csv >"$folder"/tmp/tmp.csv

mlr --csv put -S '$join=regextract($codINT,"[0-9]{7}$")' then cut -f join,"CODICE ISTAT" "$folder"/../risorse/anagraficaComuni.csv >"$folder"/tmp/tmp2.csv

mlr --csv join --ul -j join -f "$folder"/tmp/tmp.csv then unsparsify then cut -x -f join "$folder"/tmp/tmp2.csv >"$folder"/../dati/risultati/camera-italia-comune_anagrafica.csv
