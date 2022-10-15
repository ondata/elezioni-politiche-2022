#!/bin/bash

set -x


folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp
mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

### comuni ###

if [ -f "$folder"/tmp/camera-italia-comune_anagrafica.jsonl ]; then
    rm "$folder"/tmp/camera-italia-comune_anagrafica.jsonl
fi

if [ -f "$folder"/tmp/camera-italia-comune_anagrafica.csv ]; then
    rm "$folder"/tmp/camera-italia-comune_anagrafica.csv
fi

find "$folder"/rawdata -maxdepth 1 -iname "*-comune_*" | tr '\n' '\0' | while IFS= read -r -d '' line; do
  echo "$line"
  filename=$(basename "$line" .json)
  codice=$(echo "$filename" | grep -oP '[0-9].+[0-9]')
  <"$line" jq -c '.int | . |= .+ {codice:"'"$codice"'"}' >>"$folder"/tmp/camera-italia-comune_anagrafica.jsonl
done

mlr --j2c unsparsify then reorder -f codice then remove-empty-columns "$folder"/tmp/camera-italia-comune_anagrafica.jsonl >"$folder"/tmp/camera-italia-comune_anagrafica.csv

exit 0

if [ -f "$folder"/tmp/camera-italia-comune.jsonl ]; then
    rm "$folder"/tmp/camera-italia-comune.jsonl
fi

if [ -f "$folder"/tmp/camera-italia-comune.csv ]; then
    rm "$folder"/tmp/camera-italia-comune.csv
fi

find "$folder"/rawdata -maxdepth 1 -iname "camera-italia-comune_*" | tr '\n' '\0' | while IFS= read -r -d '' line; do
  echo "$line"
  filename=$(basename "$line" .json)
  codice=$(echo "$filename" | grep -oP '[0-9].+[0-9]')
  <"$line" jq '.cand[]' | mlr --json unsparsify then rename perc,perc_cand then reshape -r ":" -o i,v then filter -S -x '$v==""' then put -S '$l_pos=regextract($i,"[0-9]+");$i=sub($i,".+:","");$codice="'"$codice"'"' then rename pos,r_pos then reshape -s i,v >>"$folder"/tmp/camera-italia-comune.jsonl
done

mlr --j2c unsparsify then reorder -f codice then cut -x -f img_lis then put -S '$perc=sub($perc,",",".");$perc_cand=sub($perc_cand,",",".")' then reorder -f codice,cogn,nome,a_nome,r_pos,voti,perc,eletto,voti_solo_can,l_pos,pos,desc_lis,perc_cand then sort -f codice "$folder"/tmp/camera-italia-comune.jsonl >"$folder"/tmp/camera-italia-comune.csv
