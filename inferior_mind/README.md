# inferior_mind

**Autore:** Annafi Wasi Kazi

## Descrizione
Inferior Mind è una versione semplificata del gioco Mastermind realizzata in Flutter.  
Il giocatore deve indovinare una sequenza di 4 colori cliccando sui bottoni circolari.  
Cliccando sui bottoni il colore cambia ciclicamente tra giallo, verde, blu e rosso, inizialmente sono tutti grigi.  
Una volta impostata la sequenza desiderata, il giocatore preme il pulsante di verifica (FloatingActionButton) per confrontare la sua scelta con la sequenza segreta generata casualmente dall'app.  

Dopo la verifica:
- Appare sullo schermo un messaggio “Hai vinto!” (verde) o “Hai perso!” (rosso).  
- I bottoni tornano grigi.  
- Viene generata automaticamente una nuova sequenza casuale da indovinare.  

---

## Spiegazione del codice

### 1. Struttura dei bottoni
- La lista `counters` memorizza il **colore attuale di ciascun bottone** tramite un numero da 0 a 4.  
- La lista `colors` contiene 5 colori: grigio, giallo, verde, blu e rosso.  
  - **Nota:** il colore grigio è usato come stato iniziale e non fa parte del gioco vero e proprio, quindi durante il gioco si usano solo 4 colori (giallo, verde, blu, rosso).  
- La funzione `changeColor(int index)` viene chiamata quando si clicca un bottone:
  - Se il bottone è arrivato al colore rosso (4), ritorna a giallo (1).  
  - Altrimenti, passa al colore successivo.  
- I bottoni hanno un **SizedBox(height: 16)** tra loro per dare spazio e migliorare la leggibilità.  

### 2. Sequenza segreta
- `randomArray` memorizza la **sequenza segreta** generata casualmente all’inizio (`initState()`) e ogni volta che si verifica una giocata.  
- La sequenza è composta da numeri da 1 a 4, corrispondenti ai colori **giallo, verde, blu e rosso**.  
  - Il valore 0 (grigio) non viene mai generato nella sequenza segreta, perché rappresenta lo stato iniziale dei bottoni.

### 3. Verifica della giocata
- La funzione `controllGame()` confronta `counters` con `randomArray`:  
  - Se tutti i valori coincidono → vittoria.  
  - Altrimenti → sconfitta.  
- Dopo la verifica:
  - Aggiorna il messaggio sullo schermo (`messaggio`).  
  - Resetta i bottoni a grigi (`counters = [0, 0, 0, 0]`).  
  - Genera una nuova sequenza casuale (`randomArray`) per la prossima partita.  
---
