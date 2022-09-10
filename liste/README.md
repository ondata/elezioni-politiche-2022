<a href="https://ondata.it/"><img src="https://img.shields.io/badge/by-onData-%232e85d1"/></a> <a href="https://www.datibenecomune.it/"><img src="https://img.shields.io/badge/%F0%9F%99%8F-%23datiBeneComune-%23cc3232"/></a>

# Lista candidate e candidati elezioni politiche 2022

## Introduzione

Dal primo settembre 2022 (grazie a Vittorio Nicoletta per l'[avviso](https://twitter.com/vi__enne/status/1565401905622392837)) è stato pubblicato l'[elenco](https://dait.interno.gov.it/elezioni/trasparenza/elezioni-politiche-2022) delle liste delle candidate e dei candidati alle elezioni politiche 2022.

Purtroppo **soltanto come pagina web**, **senza** rendere disponibile in modo visibile **anche l'accesso alla fonte dati in formato leggibile meccanicamente**.

## Cosa abbiamo fatto

Li abbiamo estratti e sono disponibili in forma nativa nella cartella [`rawdata`](./rawdata) (sono dei file `JSON`).

Da questi sono state estratte le anagrafiche di candidate e candidati in formato `CSV`:

- [`CAMERA_ITALIA_20220925_pluri.csv`](./processing/CAMERA_ITALIA_20220925_pluri.csv)
- [`CAMERA_ITALIA_20220925_uni.csv`](./processing/CAMERA_ITALIA_20220925_uni.csv)
- [`CAMERA_ITALIA_20220925_uni_coalizioni.csv`](./processing/CAMERA_ITALIA_20220925_uni_coalizioni.csv)
- [`CAMERA_ESTERO_20220925.csv`](./processing/CAMERA_ESTERO_20220925.csv)
- [`SENATO_ITALIA_20220925_pluri.csv`](./processing/SENATO_ITALIA_20220925_pluri.csv)
- [`SENATO_ITALIA_20220925_uni.csv`](./processing/SENATO_ITALIA_20220925_uni.csv)
- [`SENATO_ITALIA_20220925_uni_coalizioni.csv`](./processing/SENATO_ITALIA_20220925_uni_coalizioni.csv)
- [`SENATO_ESTERO_20220925.csv`](./processing/SENATO_ESTERO_20220925.csv)

---

⚠️**AGGIORNAMENTO**: 24 ore dopo l'annuncio della pubblicazione di questi dati, il Ministero ha inserito nella [sua pagina web](https://dait.interno.gov.it/elezioni/trasparenza/elezioni-politiche-2022) un tasto per il download in formato `CSV`. Ci fa piacere pensare di avere contribuito a stimolare la pubblicazione di questi dati anche in formato leggibile meccanicamente.

---
## Note

### Sesso

Peccato non sia visibile sul sito web del Ministero - come attributo - anche il sesso di candidate e candidati. È un'occasione persa dal punto di vista della cultura del dato. È per fortuna un attributo estraibile dai dati grezzi (grazie [Vittorio](https://github.com/ondata/elezioni-politiche-2022/issues/5) e [Pierpaolo](https://github.com/ondata/elezioni-politiche-2022/issues/6) per l'idea e per il codice).

### Impossibilità di relazione immediata con dati geografici

I codici che individuano i collegi elettorali, non consentono in modo immediato di correlare i dati sulle liste alle [basi geografiche dei collegi elettorali](https://www.istat.it/it/archivio/273443) pubblicate da Istat.

Ad esempio nei dati del Ministero i codici del collegio uninominale della Valle D'Aosta alla Camera sono

```
cod_ente_p2  NA1
desc_ente_p2 ITALIA
cod_ente_p   CI27
desc_ente_p  VALLE D'AOSTA
cod_ente     CU2701
desc_ente    VALLE D'AOSTA - U01
```

mentre nelle basi geografiche di Istat

```
OBJECTID 11
CU20_COD 20001
CU20_DEN Valle d'aosta/Vallée d'Aoste - U01
CU20_C1  U01
```
Il Ministero degli Interni o Istat dovrebbero pubblicare una "stele di Rosetta", per poter facilmente associare le anagrafiche di sopra ai dati geografici.<br>
O almeno fare in modo che i campi `desc_ente` (Ministero) e `CU20_DEN` (Istat) abbiano contenuti coerenti per ogni collegio.
