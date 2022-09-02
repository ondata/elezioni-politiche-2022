<a href="https://www.datibenecomune.it/"><img src="https://img.shields.io/badge/%F0%9F%99%8F-%23datiBeneComune-%23cc3232"/></a>

# Lista candidate e candidati elezioni politiche 2022

## Introduzione

Dal primo settembre 2022 (grazia a Vittorio Nicoletta per l'[avviso](https://twitter.com/vi__enne/status/1565401905622392837)) è stato pubblicato l'[elenco](https://dait.interno.gov.it/elezioni/trasparenza/elezioni-politiche-2022) delle liste delle candidate e dei candidati alle elezioni politiche 2022.

Purtroppo **soltanto come pagina web**, **senza** rendere disponibile in modo visibile **anche l'accesso alla fonte dati in formato leggibile meccanicamente**.

## Cosa abbiamo fatto

Li abbiamo estratti e sono disponibili in forma nativa nella cartella [`rawdata`](./rawdata) (sono dei file `JSON`).

Da questi sono state estratte le anagrafiche di candidate e candidati in formato `CSV`:

- [`CAMERA_ITALIA_20220925_pluri.csv`](./processing/CAMERA_ITALIA_20220925_pluri.csv)
- [`CAMERA_ITALIA_20220925_uni.csv`](./processing/CAMERA_ITALIA_20220925_uni.csv)
- [`CAMERA_ESTERO_20220925.csv`](./processing/CAMERA_ESTERO_20220925.csv)
- [`SENATO_ITALIA_20220925_pluri.csv`](./processing/SENATO_ITALIA_20220925_pluri.csv)
- [`SENATO_ITALIA_20220925_uni.csv`](./processing/SENATO_ITALIA_20220925_uni.csv)
- [`SENATO_ESTERO_20220925.csv`](./processing/SENATO_ESTERO_20220925.csv)

## Note

Peccato non sia visibile sul sito web - come attributo - il sesso. È un'occasione persa dal punto di vista della cultura del dato. È per fortuna un'attributo estraibile dai dati (grazie [Vittorio](https://github.com/ondata/elezioni-politiche-2022/issues/5) e [Pierpaolo](https://github.com/ondata/elezioni-politiche-2022/issues/6)).
