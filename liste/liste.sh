#!/bin/bash

set -x
set -e
set -u
set -o pipefail

### requisiti ###
# Miller 5 https://github.com/johnkerl/miller/releases/tag/v5.10.2
# jq
# gawk
### requisiti ###

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

URL_base="https://dait.interno.gov.it"

if [ -f "$folder"/tmp-lista.md ]; then
  rm "$folder"/tmp-lista.md
fi

if [ -f "$folder"/fonti_dati.txt ]; then
  rm "$folder"/fonti_dati.txt
fi

# cancella tutti i file csv nella cartella processing
find "$folder"/processing/ -maxdepth 1 -name "*.csv" -type f -delete

# scarica liste e creane copia in formato CSV
curl -kLs 'https://dait.interno.gov.it/elezioni/trasparenza/elezioni-politiche-2022' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' \
  --compressed | sed -e '/carica/,/)/!d' | perl -p -e 's/\n//g' | sed 's/carica/\ncarica/g' | grep -Po '/docu.+?",.+?",' | sed -r 's/ +//g;s|","|/|;s/",//' | grep -vP '.+POLI.+?/POLI.+' | while read -r line; do
  nome=$(echo "$line" | sed -r 's|/.+/||')
  curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' "$URL_base""$line".json >"$folder"/rawdata/"$nome".json
  echo "$URL_base""$line".json >>"$folder"/fonti_dati.txt
  jq <"$folder"/rawdata/"$nome".json -c '.candidati[]' | mlr --j2c unsparsify then cut -x -r -f ":" then put '${dt_nasc}=regextract_or_else(${dt_nasc},"[0-9]{4}","")' >"$folder"/processing/"$nome".csv
  echo "[\`$nome.csv\`](./processing/$nome.csv)" >>"$folder"/tmp-lista.md

  # estrai sesso
  CF_FIELD=$(head -n 1 -q "$folder"/processing/"$nome".csv | gawk -F, '{print NF}')
  gawk -F, -v cf_field=$CF_FIELD '{print $cf_field}' "$folder"/processing/"$nome".csv | colrm 1 9 | colrm 3 | gawk '(NR==1) {print "sesso";next} $1<32 {print "M"} $1>31 {print "F"}' | paste -d',' "$folder"/processing/"$nome".csv - >"$folder"/processing/"$nome".csv.tmp
  mv "$folder"/processing/"$nome".csv.tmp "$folder"/processing/"$nome".csv
  mlr -I --csv cut -x -f cod_fisc then sort -f cod_ente -n n_ord,cod_lista,cod_cand "$folder"/processing/"$nome".csv
done

# estrai coalizioni
find "$folder"/rawdata -iname "*uni*" -maxdepth 1 -type f | while read line; do
  nome=$(basename "$line" .json)
  jq <"$line" -c '.candidati[]' | mlr --j2c unsparsify then \
  cut -r -f "(cod_cand|e_coal)" then \
  reshape -r ":" -o i,v then \
  put '$lista=regextract_or_else($i,"[0-9]+","");$i=sub($i,".+:","")' then \
  filter -x '$v==""' then \
  reshape -s i,v then \
  sort -n cod_cand,lista,num_lista,cod_lista then \
  unsparsify>"$folder"/processing/"$nome"_coalizioni.csv
done
