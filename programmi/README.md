# Programmi elezioni politiche 2022

## Introduzione

Il 25 settembre 2022 si svolgeranno le elezioni politiche 2022.

Così come previsto nelle "[Istruzioni per la presentazione e l'ammissione delle candidature](https://dait.interno.gov.it/documenti/pubb_01_politiche_ed.2022.pdf)", è previsto il  "**deposito, presso il Ministero dell'interno, del programma elettorale del partito o gruppo politico**", anche in formato digitale:

> Per il programma elettorale è richiesto, oltre al formato cartaceo, anche quello digitale, in quanto necessario ai fini degli adempimenti previsti dall'articolo 4, comma 1, della legge n. 165 / 2017 e dall'articolo 2 della legge n. 4 / 2004. Pertanto, dovrà essere consegnato anche un CD-ROM contenente i files **in formato accessibile (PDF/A)**.

L'[articolo 4](https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:2017-11-03;165~art4) della legge n. 165 / 2017 ha disposto che, in un'apposita sezione del sito internet del Ministero dell'interno, denominata «[ELEZIONI TRASPARENTI](https://dait.interno.gov.it/elezioni/trasparenza/elezioni-politiche-2022)», entro dieci giorni dalla scadenza del termine per il deposito dei contrassegni, per ciascun partito, movimento e gruppo politico organizzato che ha presentato le liste, **SONO PUBBLICATI,IN MANIERA FACILMENTE ACCESSIBILI** (il tutto maiuscolo è presente nelle istruzioni del Ministero):

- il **contrassegno** depositato;
- lo **statuto** ovvero la dichiarazione di trasparenza;
- il **programma** elettorale con il nome e cognome della persona indicata come capo della forza politica.

 Il suddetto sito internet del Ministero dell'interno nasce per consentire alle persone di accedere agevolmente alle informazioni e ai documenti pubblicati, "*attraverso la ricerca per cognome e nome di ciascun candidato ammesso, per denominazione del partito, del movimento politico o della lista nonché per circoscrizione in occasione delle elezioni europee ed anche per collegio in caso di elezioni politiche*".

## Cosa abbiamo fatto

L'anagrafica dei documenti presentati dai partiti (movimenti o gruppi politici), oltre a essere visibile nel [sito dedicato](https://dait.interno.gov.it/elezioni/trasparenza/elezioni-politiche-2022), è disponibile anche in formato leggibile meccanicamente (`JSON`) presso questo indirizzo:<br>
<https://dait.interno.gov.it/documenti/trasparenza/POLITICHE_20220925/POLITICHE_20220925.json>

Avere una fonte unica è molto comodo, ad esempio, per tutte le persone che vogliono leggere e analizzare i vari programmi, per chi vuole creare degli spazi e dei servizi informativi su questa tornata elettorale.

Noi - per il momento - abbiamo voluto scaricare tutti i programmi disponibili, per leggerne alcune delle caratteristiche intrinseche (il rispetto dell'accessibilità, il formato, il numero di pagine, ecc.),

## Note sui programmi

- **35** i **partiti** (movimenti o gruppi politici) in elenco;
- **31** i **programmi** disponibili. Al 2 settembre 2022 non è presente un programma per:
  - MOVIMENTO ASSOCIATIVO ITALIANI ALL'ESTERO - MAIE
  - MOVIMENTO DELLE LIBERTA'
  - UNIONE SUDAMERICANA EMIGRATI ITALIANI - USEI
  - LEGA PER SALVINI PREMIER - FORZA ITALIA - FRATELLI D'ITALIA
- i **formati file** dei programmi sono così suddivisi:
  - **30** file **PDF**;
  - **1** file **DOC** (non è un formato file citato nel documento di istruzioni);
- Circa il **75% dei programmi in PDF** - 23 su 30 - **non ha il testo leggibile** (contengono soltanto immagini);
- **6 programmi** sono composti da **meno di 3 pagine**. Il 75% rientra in un massimale di 18 pagine;
- due partiti, "PARTITO DEMOCRATICO - ITALIA DEMOCRATICA E PROGRESSISTA" e "ALLEANZA VERDI E SINISTRA", sono presenti in elenco (sia su [sito](https://dait.interno.gov.it/elezioni/trasparenza/elezioni-politiche-2022), che sul [file JSON](https://dait.interno.gov.it/documenti/trasparenza/POLITICHE_20220925/POLITICHE_20220925.json) che fa da fonte) più di una volta (non sappiamo se sia un errore).

Qui il [file di anagrafica](processing/anagrafica.csv) informativa sui programmi (i dettagli al momento sono presenti soltanto su quelli in formato PDF).

## Considerazioni

È un bruttissimo segnale che il **75% dei programmi** consegnati da partiti, movimenti o gruppi politici al Ministero dell'Interno non abbiamo **il testo leggibile**.<br>
Sia dal lato di chi consegna, sia dal lato di chi riceve, che dovrebbe pretendere dei documenti senza alcuna barriera, garantendo l'**accessibilità**, nel rispetto dei [diritti di cittadinanza digitali](https://ondata.github.io/guida-diritti-cittadinanza-digitali/parte-seconda/accessibilita/).

**Alcuni** dei **programmi** pubblicati sul sito del Ministero, **sono già vecchi** e **abbondantemente superati**.<br>Un esempio per tutti quello del partito "LEGA PER SALVINI PREMIER": il file [sul sito del Ministero](https://dait.interno.gov.it/documenti/trasparenza/POLITICHE_20220925/Documenti/9/(9_progr_2_)-lega_per_salvini_premier.programma.pdf) è composto da **circa 15 pagine**, quello pubblicato [sul sito del partito](https://static.legaonline.it/files/Programma_Lega_2022.pdf) da **circa 200**.
Sicuramente questa difformità non è "fuori legge", ma il Ministero dovrebbe richiedere di ricevere nel tempo anche gli aggiornamenti dei documenti, archiviando tutte le versioni. Altrimenti è una trasparenza (per i programmi) non efficace e troppo formale.

Richiedere l'invio dei programmi, consentirebbe al Ministero di creare non soltanto un unico punto d'accesso con l'elenco di tutti programmi, ma uno spazio ad esempio dove **abilitare la ricerca testuale di parole chiave in tutti i testi presentati**, o la possibilità di condividere porzioni di testo correlate alla fonte ministeriale (un embedding alla YouTube, ma di testo).
