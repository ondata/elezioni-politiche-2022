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


find "$folder"/processing -maxdepth 1 -iname "*coalizioni*"  -type f | while read line; do
  nome=$(basename "$line" .csv)
  mlr --csv cut -f cod_cand,desc_lista then nest --nested-fs "; " --implode --values --across-records -f desc_lista "$line" >"$folder"/processing/"$nome"_nested.csv
done
