#!/bin/bash

set -x
set -e
set -u
set -o pipefail

### requisiti ###
# Miller 5 https://github.com/johnkerl/miller/releases/tag/v5.10.2
# jq
# exiftool
# pdftotext
### requisiti ###

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/programmi
mkdir -p "$folder"/programmi/no-ministero

# Viva indecis-it
fonte="https://raw.githubusercontent.com/indecis-it/data/main/data/sources.csv"

# scarica indice dei documenti
curl -kL "$fonte" >"$folder"/rawdata/indecis-it.csv

# find "$folder"/programmi/no-ministero -iname "*.pdf" -delete

# scarica soltanto i programmi, che non hanno come fonte il ministero
mlr --c2j filter '$type=="programma" && $url!=~"dait" && $url=~"pdf" && $slug=~"^progr.+" ' then head -g list_id -n 5 "$folder"/rawdata/indecis-it.csv | while read line; do
  slug=$(echo $line | jq -r '.slug')
  id=$(echo $line | jq -r '.id')
  title=$(echo $line | jq -r '.title')
  url=$(echo $line | jq -r '.url')
  list=$(echo $line | jq -r '.list')
  list_id=$(echo $line | jq -r '.list_id')
  mkdir -p "$folder"/programmi/no-ministero/"$list_id"/
  if [ ! -f "$folder"/programmi/no-ministero/"$list_id"/"$slug".pdf ]; then
    curl -H -kL 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36' "$url" >"$folder"/programmi/no-ministero/"$list_id"/"$slug".pdf
  fi
done

# cancella, se esiste, file con i metadati sui PDF
if [ -f "$folder"/programmi/no-ministero/info-meta.jsonl ]; then
  rm "$folder"/programmi/no-ministero/info-meta.jsonl
fi

find "$folder"/programmi/no-ministero -iname "*.pdf" | while read line; do
  righe=$(pdftotext "$line" - | wc -l)
  exiftool -n -csv "$line" | mlr --c2j put '$righe='"$righe"';$SourceFile=sub($SourceFile,".+/","")' then cut -x -f ExifToolVersion,Directory,FileModifyDate,FileAccessDate,FileInodeChangeDate >>"$folder"/programmi/no-ministero/info-meta.jsonl
done

mlr --j2c cut -f FileName,FileSize,FileType,FileTypeExtension,MIMEType,PDFVersion,Linearized,CreateDate,Creator,ModifyDate,XMPToolkit,CreatorTool,MetadataDate,Producer,Format,PageCount,righe,Conformance,Title,Author then unsparsify "$folder"/programmi/no-ministero/info-meta.jsonl >"$folder"/programmi/no-ministero/info-meta.csv
