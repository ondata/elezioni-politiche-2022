<a href="https://ondata.it/"><img src="https://img.shields.io/badge/by-onData-%232e85d1"/></a> <a href="https://www.datibenecomune.it/"><img src="https://img.shields.io/badge/%F0%9F%99%8F-%23datiBeneComune-%23cc3232"/></a>

- [Lista candidate e candidati elezioni politiche 2022](#lista-candidate-e-candidati-elezioni-politiche-2022)
  - [Introduzione](#introduzione)
  - [Cosa abbiamo fatto](#cosa-abbiamo-fatto)
  - [Le 🗺️ mappe per sapere per chi puoi votare?](#le-️-mappe-per-sapere-per-chi-puoi-votare)
    - [Con quali dati sono state costruite](#con-quali-dati-sono-state-costruite)
    - [Credits](#credits)
    - [Se vuoi usare queste mappe](#se-vuoi-usare-queste-mappe)
  - [Note](#note)
    - [Sesso](#sesso)
    - [Impossibilità di relazione immediata con dati geografici](#impossibilità-di-relazione-immediata-con-dati-geografici)
  - [Se vuoi usare questi dati](#se-vuoi-usare-questi-dati)

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

## Le 🗺️ mappe per sapere per chi puoi votare?

Abbiamo creato le **mappe** che al _**click**_ sui poligoni dei collegi elettorali, restituiscono l'**elenco di candidate e candidati di quel collegio**.

Queste **le 4 mappe disponibili** (⚠️ solo da *desktop*, non da mobile):

- **Collegi uninominali**
  - [🗺️ Camera dei Deputati](https://gjrichter.github.io/ixmaps/ui/dispatch.htm?ui=view&basemap=ll&legend=1&project=https://raw.githubusercontent.com/gjrichter/viz/master/Elezioni/Politiche/2022/ixmaps_project_CAMERA_CollegiUNINOMINALI_2020_candidati_poligoni_coalizioni.json)
  - [🗺️ Senato della Repubblica](https://gjrichter.github.io/ixmaps/ui/dispatch.htm?ui=view&basemap=ll&legend=1&project=https://raw.githubusercontent.com/gjrichter/viz/master/Elezioni/Politiche/2022/ixmaps_project_SENATO_CollegiUNINOMINALI_2020_candidati_poligoni_coalizioni.json)
- **Collegi plurinominali**
  - [🗺️ Camera dei Deputati](https://gjrichter.github.io/ixmaps/ui/dispatch.htm?ui=view&basemap=ll&legend=1&project=https://raw.githubusercontent.com/gjrichter/viz/master/Elezioni/Politiche/2022/ixmaps_project_CAMERA_CollegiPLURINOMINALI_2020_candidati_poligoni.json)
  - [🗺️ Senato della Repubblica](https://gjrichter.github.io/ixmaps/ui/dispatch.htm?ui=view&basemap=ll&legend=1&project=https://raw.githubusercontent.com/gjrichter/viz/master/Elezioni/Politiche/2022/ixmaps_project_SENATO_CollegiPLURINOMINALI_2020_candidati_poligoni.json)


Un volta aperta una delle mappe potrai (vedi immagine a seguire):

1. fare *click* sul colleggio di tuo interesse;
2. avere restituito le informazioni su quel collegio.

E poi nella nuvola informativa:

1. Il **nome** del **collegio**
2. l'**elenco** di **candidate** e **candidati**, con la **distinzione** cromatica per **sesso**;
3. il **nome** di candidata/o - su cui potrai fare click per fare una ricerca su quel nome - e i **relativi partiti** (movimenti o gruppi politici);
4. il **numero totale** di candidate e candidati;
5. l'**età media** di di candidate e candidati.


![](imgs/mappa-liste.png)

### Con quali dati sono state costruite

Quelli che abbiamo estratto dal sito del **Ministero dell'Interno**, insieme [le basi geografiche dei collegi elettorali](https://www.istat.it/it/archivio/273443) pubblicate da **Istat**.

### Credits

Queste mappe sono state costruite dal "nostro" [Guenter Richter](https://twitter.com/grichter), con il suo iXMaps.

### Se vuoi usare queste mappe

Se vuoi inserirle in una tua pubblicazione, se vuoi *linkarle* o *embeddarle*, per favore aggiungi la nota (con il *link*) "un progetto di [onData](https://github.com/ondata/elezioni-politiche-2022)". Grazie


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


## Se vuoi usare questi dati

Se vuoi usarli, per favore aggiungi la nota (con il *link*) "da un progetto di [onData](https://github.com/ondata/elezioni-politiche-2022)". Grazie
