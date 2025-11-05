# Chrono

**Autore:** Kazi Annafi Wasi
Questo progetto è un semplice cronometro realizzato in Flutter. Il cronometro mostra minuti, secondi e decimi di secondo.

## Funzionamento
* Un **ticker** emette un evento ogni 100ms.
* Ogni 10 tick viene incrementato il numero dei secondi.
* L'interfaccia aggiorna il tempo tramite uno **StreamBuilder**.

## Controlli
Sono presenti due pulsanti in basso a destra:

* **START / STOP / RESET**: avvia, ferma o azzera il cronometro.
* **PAUSE / RESUME**: mette in pausa o riprende il conteggio (solo quando il cronometro è in START).

## Scelte principali
* Uso di `StreamController` per separare i tick dai secondi.
* `Timer.periodic` per generare intervalli regolari.
