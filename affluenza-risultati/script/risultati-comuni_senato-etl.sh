#!/bin/bash

set -x


folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

### comuni ###

if [ -f "$folder"/tmp/senato-italia-comune_anagrafica.jsonl ]; then
    rm "$folder"/tmp/senato-italia-comune_anagrafica.jsonl
fi

if [ -f "$folder"/tmp/senato-italia-comune_anagrafica.csv ]; then
    rm "$folder"/tmp/senato-italia-comune_anagrafica.csv
fi

find "$folder"/rawdata -maxdepth 1 -iname "senato-italia-comune_*" | tr '\n' '\0' | while IFS= read -r -d '' line; do
  echo "$line"
  filename=$(basename "$line" .json)
  codice=$(echo "$filename" | grep -oP '[0-9].+[0-9]')
  <"$line" jq -c '.int | . |= .+ {codice:"'"$codice"'"}' >>"$folder"/tmp/senato-italia-comune_anagrafica.jsonl
done

mlr --j2c unsparsify then reorder -f codice then remove-empty-columns "$folder"/tmp/senato-italia-comune_anagrafica.jsonl >"$folder"/tmp/senato-italia-comune_anagrafica.csv

exit 0

if [ -f "$folder"/tmp/senato-italia-comune.jsonl ]; then
    rm "$folder"/tmp/senato-italia-comune.jsonl
fi

if [ -f "$folder"/tmp/senato-italia-comune.csv ]; then
    rm "$folder"/tmp/senato-italia-comune.csv
fi

find "$folder"/rawdata -maxdepth 1 -iname "senato-italia-comune_*" | tr '\n' '\0' | while IFS= read -r -d '' line; do
  echo "$line"
  filename=$(basename "$line" .json)
  codice=$(echo "$filename" | grep -oP '[0-9].+[0-9]')
  <"$line" jq '.cand[]' | mlr --json unsparsify then reshape -r ":" -o i,v then filter -S -x '$v==""' then put -S '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","");$codice="'"$codice"'"' then rename pos,r_pos then reshape -s i,v >>"$folder"/tmp/senato-italia-comune.jsonl
done

mlr --j2c unsparsify then reorder -f codice then cut -x -f img_lis then put '$perc=sub($perc,",",".")' "$folder"/tmp/senato-italia-comune.jsonl >"$folder"/tmp/senato-italia-comune.csv
