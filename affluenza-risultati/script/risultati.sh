#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

find "$folder"/rawdata -maxdepth 1 -iname "*.json" -type f -delete
find "$folder"/rawdata -maxdepth 1 -iname "*.csv" -type f -delete
find "$folder"/processing -maxdepth 1 -iname "*.csv" -type f -delete

### Camera Italia ###

curl 'https://eleapi.interno.gov.it/siel/PX/scrutiniCI/DE/20220925/TE/02' \
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
  -H 'Cache-Control: no-cache' -H 'TE: trailers' --compressed |
  jq . >"$folder"/rawdata/camera-italia.json

jq <"$folder"/rawdata/camera-italia.json '.cand[]' | mlr --j2c unsparsify >"$folder"/processing/camera-italia.csv
jq <"$folder"/rawdata/camera-italia.json '.int' | mlr --j2c unsparsify >"$folder"/processing/camera-italia_info.csv

mlr -I --csv reshape -r ":" -o i,v then filter -S -x '$v==""' then put '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","")' then rename pos,r_pos then reshape -s i,v then sort -n r_pos,l_pos then put -S '$perc=sub($perc,",",".")' "$folder"/processing/camera-italia.csv

mv "$folder"/processing/camera-italia.csv "$folder"/../dati/risultati/camera-italia.csv
mv "$folder"/processing/camera-italia_info.csv "$folder"/../dati/risultati/camera-italia_info.csv

### Senato Italia ###

curl 'https://eleapi.interno.gov.it/siel/PX/scrutiniSI/DE/20220925/TE/03' \
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
  jq . >"$folder"/rawdata/senato-italia.json

jq <"$folder"/rawdata/senato-italia.json '.cand[]' | mlr --j2c unsparsify >"$folder"/processing/senato-italia.csv
jq <"$folder"/rawdata/senato-italia.json '.int' | mlr --j2c unsparsify >"$folder"/processing/senato-italia_info.csv

mlr -I --csv reshape -r ":" -o i,v then filter -S -x '$v==""' then put '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","")' then rename pos,r_pos then reshape -s i,v then sort -n r_pos,l_pos then put -S '$perc=sub($perc,",",".")' "$folder"/processing/senato-italia.csv

mv "$folder"/processing/senato-italia.csv "$folder"/../dati/risultati/senato-italia.csv
mv "$folder"/processing/senato-italia_info.csv "$folder"/../dati/risultati/senato-italia_info.csv

### Circoscrizione Camera Italia ###

mlr --c2t filter -S '$tipo=="CR"' then put -S '$CR=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\2");$CP=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\3");$CU=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\4")' then cut -f CR,CP,CU then filter -S -x '$CR=="27"' "$folder"/../risorse/camera_geopolitico_italia.csv | tail -n +2 >"$folder"/processing/camera_circoscrizioni.tsv

while IFS=$'\t' read -r CR CP CU; do

  curl "https://eleapi.interno.gov.it/siel/PX/scrutiniCI/DE/20220925/TE/02/CR/$CR" \
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
    jq . >"$folder"/rawdata/camera-italia-circoscrizione_"$CR".json
  jq <"$folder"/rawdata/camera-italia-circoscrizione_"$CR".json '.cand[] | . |= .+ {CR:"'"$CR"'"}' | mlr --j2c unsparsify >"$folder"/processing/camera-italia-circoscrizione_"$CR".csv

done <"$folder"/processing/camera_circoscrizioni.tsv

mlr --csv unsparsify "$folder"/processing/camera-italia-circoscrizione_*.csv >"$folder"/processing/camera-italia-circoscrizione.csv
mlr -I --csv reorder -f CR "$folder"/processing/camera-italia-circoscrizione.csv

mlr -I --csv cat then reshape -r ":" -o i,v then filter -S -x '$v==""' then put '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","")' then rename pos,r_pos then reshape -s i,v then sort -n CR,r_pos,l_pos then put -S '$perc=sub($perc,",",".")' "$folder"/processing/camera-italia-circoscrizione.csv

mv "$folder"/processing/camera-italia-circoscrizione.csv "$folder"/../dati/risultati/camera-italia-circoscrizione.csv

### Circoscrizione Senato Italia ###

mlr --c2t filter -S '$tipo=="CR"' then put -S '$CR=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\2")' then cut -f CR then filter -S -x '$CR=="21" || $CR=="02"' "$folder"/../risorse/senato_geopolitico_italia.csv | tail -n +2 >"$folder"/processing/senato_circoscrizioni.tsv

while IFS=$'\t' read -r CR; do

  curl "https://eleapi.interno.gov.it/siel/PX/scrutiniSI/DE/20220925/TE/03/CR/$CR" \
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
    jq . >"$folder"/rawdata/senato-italia-circoscrizione_"$CR".json
  jq <"$folder"/rawdata/senato-italia-circoscrizione_"$CR".json '.cand[] | . |= .+ {CR:"'"$CR"'"}' | mlr --j2c unsparsify >"$folder"/processing/senato-italia-circoscrizione_"$CR".csv

done <"$folder"/processing/senato_circoscrizioni.tsv

mlr --csv unsparsify "$folder"/processing/senato-italia-circoscrizione_*.csv >"$folder"/processing/senato-italia-circoscrizione.csv
mlr -I --csv reorder -f CR "$folder"/processing/senato-italia-circoscrizione.csv

mlr -I --csv cat then reshape -r ":" -o i,v then filter -S -x '$v==""' then put '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","")' then rename pos,r_pos then reshape -s i,v then sort -n CR,r_pos,l_pos then put -S '$perc=sub($perc,",",".")' "$folder"/processing/senato-italia-circoscrizione.csv

mv "$folder"/processing/senato-italia-circoscrizione.csv "$folder"/../dati/risultati/senato-italia-circoscrizione.csv

### Collegio plurinominale Camera ###

mlr --c2t filter -S '$cod=~".+0000000$" && $tipo=="CP"' then put -S '$CR=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\2");$CP=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\3");$CU=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\4")' then cut -f CR,CP,CU "$folder"/../risorse/camera_geopolitico_italia.csv | tail -n +2 >"$folder"/processing/camera_cp.tsv

while IFS=$'\t' read -r CR CP CU; do

  curl "https://eleapi.interno.gov.it/siel/PX/scrutiniCI/DE/20220925/TE/02/CR/$CR/CP/$CP" \
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
    jq . >"$folder"/rawdata/camera-italia-plurinominale_"$CR-$CP".json
  jq <"$folder"/rawdata/camera-italia-plurinominale_"$CR-$CP".json '.cand[] | . |= .+ {CR_CP:"'"$CR-$CP"'"}' | mlr --j2c unsparsify >"$folder"/processing/camera-italia-plurinominale_"$CR-$CP".csv

done <"$folder"/processing/camera_cp.tsv

mlr --csv unsparsify "$folder"/processing/camera-italia-plurinominale_*.csv >"$folder"/processing/camera-italia-plurinominale.csv
mlr -I --csv reorder -f CR_CP "$folder"/processing/camera-italia-plurinominale.csv

mlr -I --csv cat then reshape -r ":" -o i,v then filter -S -x '$v==""' then put -S '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","")' then rename pos,r_pos then reshape -s i,v then sort -f CR_CP -n r_pos,l_pos then put -S '$perc=sub($perc,",",".")' "$folder"/processing/camera-italia-plurinominale.csv

mv "$folder"/processing/camera-italia-plurinominale.csv "$folder"/../dati/risultati/camera-italia-plurinominale.csv


### Collegio plurinominale Senato ###

mlr --c2t filter -S '$cod=~".+0000000$" && $tipo=="CP"' then put -S '$CR=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\2");$CP=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\3");$CU=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\4")' then cut -f CR,CP,CU "$folder"/../risorse/senato_geopolitico_italia.csv | tail -n +2 >"$folder"/processing/senato_cp.tsv

while IFS=$'\t' read -r CR CP CU; do

  curl "https://eleapi.interno.gov.it/siel/PX/scrutiniSI/DE/20220925/TE/03/CR/$CR/CP/$CP" \
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
    jq . >"$folder"/rawdata/senato-italia-plurinominale_"$CR-$CP".json
  jq <"$folder"/rawdata/senato-italia-plurinominale_"$CR-$CP".json '.cand[] | . |= .+ {CR_CP:"'"$CR-$CP"'"}' | mlr --j2c unsparsify >"$folder"/processing/senato-italia-plurinominale_"$CR-$CP".csv

done <"$folder"/processing/senato_cp.tsv

mlr --csv unsparsify "$folder"/processing/senato-italia-plurinominale_*.csv >"$folder"/processing/senato-italia-plurinominale.csv
mlr -I --csv reorder -f CR_CP "$folder"/processing/senato-italia-plurinominale.csv

mlr -I --csv cat then reshape -r ":" -o i,v then filter -S -x '$v==""' then put -S '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","")' then rename pos,r_pos then reshape -s i,v then sort -f CR_CP -n r_pos,l_pos then put -S '$perc=sub($perc,",",".")' "$folder"/processing/senato-italia-plurinominale.csv

mv "$folder"/processing/senato-italia-plurinominale.csv "$folder"/../dati/risultati/senato-italia-plurinominale.csv

exit 0
