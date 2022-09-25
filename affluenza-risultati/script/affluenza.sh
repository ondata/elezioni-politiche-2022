#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

mlr --csv -N cut -f 1 "$folder"/../risorse/territorio.csv | grep -E '^.*0000$' | grep -v -E '.*000000$' >"$folder"/processing/codici-province.csv

jq <"$folder"/../risorse/territorio.json '.enti' | mlr --j2t unsparsify then filter -S '$tipo=="PR"' then cut -o -f cod,desc then put -S '$PR=sub($cod,"^([0-9]{2})([0-9]{3})(.+)","\2");$altro=sub($cod,"^([0-9]{2})([0-9]{3})(.+)","\1\2")' | tail -n +2 >"$folder"/rawdata/province.tsv

test="no"

if [ "$test" = "sì" ]; then
  head <"$folder"/rawdata/province.tsv -n 3 >"$folder"/tmp.tsv
  mv "$folder"/tmp.tsv "$folder"/rawdata/province.tsv
fi

find "$folder"/rawdata -maxdepth 1 -iname "*.json" -type f -delete
find "$folder"/processing -maxdepth 1 -iname "*.csv" -type f -delete

while IFS=$'\t' read -r cod desc PR altro; do

  curl "https://eleapi.interno.gov.it/siel/PX/votantiP/DE/20220925/TE/02/PR/$PR" \
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
    jq . >"$folder"/rawdata/"$altro".json
  jq <"$folder"/rawdata/"$altro".json '.enti.enti_f[] | . |= .+ {provincia:"'"$cod"'"}' | mlr --j2c unsparsify >"$folder"/processing/"$altro".csv
done <"$folder"/rawdata/province.tsv

# fai il merge dei CSV in un unico TSV
mlr --c2t unsparsify "$folder"/processing/*.csv >"$folder"/processing/affluenzaComuni.tsv

# estrai dal TSV i campi utili
mlr -I --tsv cut -o -f "desc","cod","provincia","ele_t","com_vot:0:dt_com","com_vot:0:perc","com_vot:0:vot_t","com_vot:1:dt_com","com_vot:1:perc","com_vot:1:vot_t","com_vot:2:dt_com","com_vot:2:perc","com_vot:2:vot_t","com_vot:3:dt_com","com_vot:3:perc","com_vot:3:vot_t" "$folder"/processing/affluenzaComuni.tsv

# rinomina i campi del TSV
mlr -I --tsv rename "desc","comune","cod","cod_istat","ele_t","elettori","com_vot:0:dt_com","datah12","com_vot:0:perc","%h12","com_vot:0:vot_t","voti_h12","com_vot:1:dt_com","datah19","com_vot:1:perc","%h19","com_vot:1:vot_t","voti_h19","com_vot:2:dt_com","datah23","com_vot:2:perc","%h23","com_vot:2:vot_t","voti_h23","com_vot:3:dt_com","datah15","com_vot:3:perc","%h15","com_vot:3:vot_t","voti_h15" "$folder"/processing/affluenzaComuni.tsv

# aggiungi codice comune
mlr -I --tsv put '$codINT=fmtnum($cod_istat,"%04d")' then put -S '$codINT=sub($provincia,"0000$","").$codINT' "$folder"/processing/affluenzaComuni.tsv

# prepara file per JOIN tra dati elezioni e anagrafica elettorale
mlr --c2t cut -f "CODICE ISTAT",codINT "$folder"/../risorse/anagraficaComuni.csv >"$folder"/processing/tmp.tsv

# fai il JOIN
mlr --tsv join --ul -j codINT -f "$folder"/processing/affluenzaComuni.tsv then unsparsify then cut -x -f "cod_istat",codINT "$folder"/processing/tmp.tsv >"$folder"/processing/tmp2.tsv

mv "$folder"/processing/tmp2.tsv "$folder"/processing/affluenzaComuni.tsv

mlr -I --tsv reorder -f "CODICE ISTAT" "$folder"/processing/affluenzaComuni.tsv

sed -i -r 's/,/\./g' "$folder"/processing/affluenzaComuni.tsv

find "$folder"/processing -maxdepth 1 -iname "*.csv" -type f -delete

mlr --t2c cat "$folder"/processing/affluenzaComuni.tsv >"$folder"/processing/affluenzaComuni.csv

mv "$folder"/processing/affluenzaComuni.csv "$folder"/../dati/affluenza/affluenzaComuni.csv
