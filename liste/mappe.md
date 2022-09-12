## Come sono state costruite le mappe

Per potere costruire [queste mappe](README.md#le-%EF%B8%8F-mappe-per-sapere-per-chi-puoi-votare), era necessario poter fare il `JOIN` tra le [basi geografiche dei collegi elettorali](https://www.istat.it/it/archivio/273443) pubblicate da **Istat**, e i [dati sulle liste](processing) che abbiamo estratto dal sito del Ministero dell'Interno.

Abbiamo reso disponibili dei file CSV per poter fare questo `JOIN` nella cartella [`geo`](processing/geo/):

- [`liste_Camera_Plurinominale_MinisteroInterno-ISTAT.csv`](processing/geo/liste_Camera_Plurinominale_MinisteroInterno-ISTAT.csv)
- [`liste_Camera_Uninominale_MinisteroInterno-ISTAT.csv`](processing/geo/liste_Camera_Uninominale_MinisteroInterno-ISTAT.csv)
- [`liste_Senato_Plurinominale_MinisteroInterno-ISTAT.csv`](processing/geo/liste_Senato_Plurinominale_MinisteroInterno-ISTAT.csv)
- [`liste_Senato_Uninominale_MinisteroInterno-ISTAT.csv`](processing/geo/liste_Senato_Uninominale_MinisteroInterno-ISTAT.csv)

Hanno tutti una struttura come quella sottostante in cui `desc_ente` e `cod_ente`, sono dei campi presenti tra i dati delle liste pubblicati sul sito del Ministero dell'Interno, mentre `CU20_COD` è il campo corrispondente nei file geografici Istat.


| CU20_COD | desc_ente | cod_ente |
| --- | --- | --- |
| 10101 | PIEMONTE 1 - U01 | CU0111 |
| 10102 | PIEMONTE 1 - U02 | CU0112 |
| 10103 | PIEMONTE 1 - U03 | CU0113 |
| 10104 | PIEMONTE 1 - U04 | CU0121 |
| 10105 | PIEMONTE 1 - U05 | CU0122 |
