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

### Collegio Uninominale Camera###

mlr --c2t filter -S '$cod=~".+0000000$" && $tipo=="CU"' then put -S '$CR=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\2");$CP=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\3");$CU=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\4")' then cut -f CR,CP,CU then filter -S -x '$CR=="27"' "$folder"/../risorse/camera_geopolitico_italia.csv | tail -n +2 >"$folder"/processing/camera_cu.tsv

while IFS=$'\t' read -r CR CP CU; do

  curl "https://eleapi.interno.gov.it/siel/PX/scrutiniCI/DE/20220925/TE/02/CR/$CR/CP/$CP/CU/$CU" \
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
    jq . >"$folder"/rawdata/camera-italia-uninominale_"$CR-$CP-$CU".json
  jq <"$folder"/rawdata/camera-italia-uninominale_"$CR-$CP-$CU".json '.cand[] | . |= .+ {CR_CP_CU:"'"$CR-$CP-$CU"'"}' | mlr --j2c unsparsify >"$folder"/processing/camera-italia-uninominale_"$CR-$CP-$CU".csv

done <"$folder"/processing/camera_cu.tsv

mlr --csv unsparsify "$folder"/processing/camera-italia-uninominale_*.csv | mlr --csv cat -n then reshape -r ":" -o i,v then filter -S -x '$v==""' then put -S '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","")' then rename pos,r_pos then reshape -s i,v then sort -f CR_CP_CU -n r_pos,l_pos then put -S '$perc=sub($perc,",",".")' then cut -f cogn,nome,d_nasc,CR_CP_CU,l_pos,pos,desc_lis,img_lis,scor,cifra_el,perc_cifra >"$folder"/processing/camera-italia-uninominale_liste.csv

mlr --csv unsparsify then cut -x -r -f "liste" then cut -x -r -f ":" "$folder"/processing/camera-italia-uninominale_*.csv >"$folder"/processing/camera-italia-uninominale.csv

exit 0

### Senato Italia Uninominale ###

mlr --c2t filter -S '$cod=~".+0000000$" && $tipo=="CU"' then put -S '$CR=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\2");$CP=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\3");$CU=sub($cod,"^([0-9]{2})([0-9]{2})([0-9]{3})([0-9]{4}).+$","\4")' then cut -f CR,CP,CU then filter -S -x '$CR=="21" || $CR=="02"' "$folder"/../risorse/senato_geopolitico_italia.csv | tail -n +2 >"$folder"/processing/senato_cu.tsv

while IFS=$'\t' read -r CR CP CU; do

  curl "https://eleapi.interno.gov.it/siel/PX/scrutiniSI/DE/20220925/TE/03/CR/$CR/CP/$CP/CU/$CU" \
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
    jq . >"$folder"/rawdata/senato-italia-uninominale_"$CR-$CP-$CU".json
  jq <"$folder"/rawdata/senato-italia-uninominale_"$CR-$CP-$CU".json '.cand[] | . |= .+ {CR_CP_CU:"'"$CR-$CP-$CU"'"}' | mlr --j2c unsparsify >"$folder"/processing/senato-italia-uninominale_"$CR-$CP-$CU".csv

done <"$folder"/processing/senato_cu.tsv

curl 'https://eleapi.interno.gov.it/siel/PX/scrutiniSI/DE/20220925/TE/03/CR/21/CU/2101' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Origin: https://elezioni.interno.gov.it' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Referer: https://elezioni.interno.gov.it/' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-site' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers' --compressed |
  jq . >"$folder"/rawdata/senato-italia-uninominale_21-NN-2101.json
jq <"$folder"/rawdata/senato-italia-uninominale_21-NN-2101.json '.cand[] | . |= .+ {CR_CP_CU:"'21-NN-2101'"}' | mlr --j2c unsparsify  then cut -x -r -f "_contr">"$folder"/processing/senato-italia-uninominale_21-NN-2101.csv

curl 'https://eleapi.interno.gov.it/siel/PX/scrutiniSI/DE/20220925/TE/03/CR/02/CU/0201' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Origin: https://elezioni.interno.gov.it' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Referer: https://elezioni.interno.gov.it/' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-site' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'TE: trailers' --compressed |
  jq . >"$folder"/rawdata/senato-italia-uninominale_02-NN-0201.json
jq <"$folder"/rawdata/senato-italia-uninominale_02-NN-0201.json '.cand[] | . |= .+ {CR_CP_CU:"'02-NN-0201'"}' | mlr --j2c unsparsify  then cut -x -r -f "_contr">"$folder"/processing/senato-italia-uninominale_02-NN-0201.csv

mlr --csv unsparsify "$folder"/processing/senato-italia-uninominale_*.csv | mlr --csv cat -n then reshape -r ":" -o i,v then filter -S -x '$v==""' then put -S '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","")' then rename pos,r_pos then reshape -s i,v then sort -f CR_CP_CU -n r_pos,l_pos then put -S '$perc=sub($perc,",",".")' then cut -f cogn,nome,d_nasc,CR_CP_CU,l_pos,pos,desc_lis,img_lis,scor,cifra_el,perc_cifra >"$folder"/processing/senato-italia-uninominale_liste.csv

mlr --csv unsparsify then cut -x -r -f "liste" then cut -x -r -f ":" then reorder -f CR_CP_CU "$folder"/processing/senato-italia-uninominale_*.csv >"$folder"/processing/senato-italia-uninominale.csv
