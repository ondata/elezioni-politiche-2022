#!/bin/bash

set -x
set -e
set -u
set -o pipefail

### requisiti ###
# Miller 5
# jq
# exiftool
# pdftotext
### requisiti ###

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/programmi

# scarica indice dei documenti
curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' "https://dait.interno.gov.it/documenti/trasparenza/POLITICHE_20220925/POLITICHE_20220925.json" | jq . >"$folder"/rawdata/POLITICHE_20220925.json

# estrai programmi, ovvero il tipo di doc==2
jq <"$folder"/rawdata/POLITICHE_20220925.json '.contrass' |
  mlr --j2c unsparsify then filter '${e_file:0:tp_doc}==2' then cut -f n_ord,"e_file:0:tp_doc","e_file:0:desc_tp","e_file:0:f_doc" then uniq -a then label n_ord,tp_doc,desc_tp,f_doc >"$folder"/processing/POLITICHE_20220925_programmi.csv

base_URL="https://dait.interno.gov.it/documenti/trasparenza/POLITICHE_20220925/Documenti"

# cancella, se esiste, file con i metadati sui PDF
if [ -f "$folder"/processing/info-meta.jsonl ]; then
  rm "$folder"/processing/info-meta.jsonl
fi

# scarica i PDF ed estraine i metadati
mlr <processing/POLITICHE_20220925_programmi.csv --c2j cut -f n_ord,f_doc | while read line; do
  numero=$(echo $line | jq -r '.n_ord')
  file=$(echo $line | jq -r '.f_doc')
  filename=$(basename -- "$file")
  extension="${filename##*.}"
  filename="${filename%.*}"
  if [ ! -f "$folder"/programmi/"$file" ]; then
    curl -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' "$base_URL/$numero/$file" >"$folder"/programmi/$file
  fi
  if [ $extension == "pdf" ]; then
    righe=$(pdftotext "$folder"/programmi/$file - | wc -l)
    exiftool -n -csv "$folder"/programmi/$file | mlr --c2j put '$n_ord='"$numero"';$righe='"$righe"';$SourceFile=sub($SourceFile,".+/","")' then cut -x -f ExifToolVersion,Directory,FileModifyDate,FileAccessDate,FileInodeChangeDate then reorder -f n_ord >>"$folder"/processing/info-meta.jsonl
  fi
done

# converti il file dei metadati dei PDF da JSON Lines a CSV
mlr --j2c unsparsify "$folder"/processing/info-meta.jsonl >"$folder"/processing/info-meta.csv

# estrai un versione meno ricca del file CSV dei metadati dei PDF
mlr --csv cut -f n_ord,FileName,FileSize,FileType,FileTypeExtension,MIMEType,PDFVersion,Linearized,CreateDate,Creator,ModifyDate,XMPToolkit,CreatorTool,MetadataDate,Producer,Format,PageCount,righe,Conformance,Title,Author "$folder"/processing/info-meta.csv >"$folder"/processing/info-meta-lite.csv

# crea un file di anagrafica completo di nomi dei partiti e metadati dei programmi in PDF
jq <"$folder"/rawdata/POLITICHE_20220925.json '.contrass' | mlr --j2c unsparsify then filter '${e_file:0:tp_doc}==2' then cut -x -r -f ":" then cut -f n_ord,nome_c,cogn_c,partito then uniq -a  >"$folder"/processing/anagrafica.csv

mlr --csv join --ul -j n_ord -f "$folder"/processing/anagrafica.csv then unsparsify then remove-empty-columns "$folder"/processing/info-meta-lite.csv >"$folder"/processing/tmp.csv

mv "$folder"/processing/tmp.csv "$folder"/processing/anagrafica.csv

# report

<$folder/rawdata/POLITICHE_20220925.json jq '.contrass' | mlr --j2c unsparsify then cut -f n_ord,partito then uniq -a >"$folder"/processing/tmp.csv

mlr --csv join --ul -j n_ord,partito -f "$folder"/processing/tmp.csv then unsparsify then remove-empty-columns then filter '$nome_c==""' then cut -f n_ord,partito "$folder"/processing/anagrafica.csv >"$folder"/processing/partiti-no-programma.csv
