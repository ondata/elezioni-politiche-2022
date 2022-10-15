#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp
mkdir -p "$folder"/../dati/Eligendo/processing/
mkdir -p "$folder"/../dati/Eligendo/rawdata/

# imposta encoding in UTF-8 e cambia separatore da ";" a ","
find "$folder"/../dati/Eligendo/rawdata/ -maxdepth 1 -iname "*Scrutini_*_Italia*.csv" -type f -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  #chardetect "$line"
  name=$(basename "$line" .csv)
  iconv -f iso8859-1 -t UTF-8 "$line" >"$folder"/../dati/Eligendo/processing/"$name".csv
  mlr -I --csv --ifs ";" clean-whitespace "$folder"/../dati/Eligendo/processing/"$name".csv
done

# estrai comuni con nome univoco
mlr --csv filter '$tipo=="CM"' then count-similar -g desc then filter '$count==1' then cut -f cod,desc "$folder"/../risorse/territorio.csv >"$folder"/tmp/territorio.csv

# estrai comuni con nome non univoco
mlr --csv filter '$tipo=="CM"' then count-similar -g desc then filter '$count>1' then cut -f cod,desc "$folder"/../risorse/territorio.csv >"$folder"/tmp/territorio-multi.csv

# estrai dati scrutini camera, per comuni con nome univoco
mlr --csv join --np --ur -j desc -l desc -r COMUNE -f "$folder"/tmp/territorio-multi.csv then unsparsify "$folder"/../dati/Eligendo/processing/Politiche2022_Scrutini_Camera_Italia.csv >"$folder"/tmp/Politiche2022_Scrutini_Camera_Italia.csv

# estrai dati scrutini senato, per comuni con nome univoco
mlr --csv join --np --ur -j desc -l desc -r COMUNE -f "$folder"/tmp/territorio-multi.csv then unsparsify "$folder"/../dati/Eligendo/processing/Politiche2022_Scrutini_Senato_Italia.csv >"$folder"/tmp/Politiche2022_Scrutini_Senato_Italia.csv

# estrai coppia codice ministero interno e codice istat comune
mlr --csv cut -f "CODICE ISTAT",codINT "$folder"/../risorse/anagraficaComuni.csv >"$folder"/tmp/anagraficaComuni.csv

# aggiungi id ministero interno ai comuni con nome univoco dei dati camera
mlr --csv join  -j COMUNE -r desc -l COMUNE -f "$folder"/tmp/Politiche2022_Scrutini_Camera_Italia.csv then unsparsify "$folder"/tmp/territorio.csv >"$folder"/tmp/tmp.csv


# aggiungi codice Istat ai comuni con nome univoco dei dati camera
mlr --csv join  -j cod -r codINT -l cod -f "$folder"/tmp/tmp.csv then unsparsify "$folder"/tmp/anagraficaComuni.csv >"$folder"/../dati/Eligendo/processing/Politiche2022_Scrutini_Camera_Italia.csv

# aggiungi id ministero interno ai comuni con nome univoco dei dati senato
mlr --csv join  -j COMUNE -r desc -l COMUNE -f "$folder"/tmp/Politiche2022_Scrutini_Senato_Italia.csv then unsparsify "$folder"/tmp/territorio.csv >"$folder"/tmp/tmp.csv


# aggiungi codice Istat ai comuni con nome univoco dei dati senato
mlr --csv join  -j cod -r codINT -l cod -f "$folder"/tmp/tmp.csv then unsparsify "$folder"/tmp/anagraficaComuni.csv >"$folder"/../dati/Eligendo/processing/Politiche2022_Scrutini_Senato_Italia.csv

# aggiungi dati comuni con nome non univoco

# imposta encoding in UTF-8 e cambia separatore da ";" a ","
find "$folder"/../dati/Eligendo/rawdata/ -maxdepth 1 -iname "*Scrutini_*_Italia*.csv" -type f -print0 | while IFS= read -r -d '' line; do
  echo "$line"
  #chardetect "$line"
  name=$(basename "$line" .csv)
  iconv -f iso8859-1 -t UTF-8 "$line" >"$folder"/../dati/Eligendo/processing/tmp-"$name".csv
  mlr -I --csv --ifs ";" clean-whitespace "$folder"/../dati/Eligendo/processing/tmp-"$name".csv
done

mlr --csv join  -j COMUNE,PROVINCIA -l COMUNE,PROVINCIA -r desc,PROVINCIA -f "$folder"/../dati/Eligendo/processing/tmp-Politiche2022_Scrutini_Camera_Italia.csv then unsparsify "$folder"/tmp/territorio-multi-province.csv >"$folder"/tmp/Politiche2022_Scrutini_Camera_Italia-multi.csv

mlr --csv join  -j COMUNE,PROVINCIA -l COMUNE,PROVINCIA -r desc,PROVINCIA -f "$folder"/../dati/Eligendo/processing/tmp-Politiche2022_Scrutini_Senato_Italia.csv then unsparsify "$folder"/tmp/territorio-multi-province.csv >"$folder"/tmp/Politiche2022_Scrutini_Senato_Italia-multi.csv

mlr --csv unsparsify then sort -f CIRCOSCRIZIONE,PROVINCIA,"CODICE ISTAT" "$folder"/../dati/Eligendo/processing/Politiche2022_Scrutini_Camera_Italia.csv "$folder"/tmp/Politiche2022_Scrutini_Camera_Italia-multi.csv >"$folder"/tmp/tmp.csv

mv "$folder"/tmp/tmp.csv "$folder"/../dati/Eligendo/processing/Politiche2022_Scrutini_Camera_Italia.csv

mlr --csv unsparsify then sort -f CIRCOSCRIZIONE,PROVINCIA,"CODICE ISTAT" "$folder"/../dati/Eligendo/processing/Politiche2022_Scrutini_Senato_Italia.csv "$folder"/tmp/Politiche2022_Scrutini_Senato_Italia-multi.csv >"$folder"/tmp/tmp.csv

mv "$folder"/tmp/tmp.csv "$folder"/../dati/Eligendo/processing/Politiche2022_Scrutini_Senato_Italia.csv
