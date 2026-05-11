# Brawl Tracker
 
**Sviluppatore:** Kazi Annafi Wasi 
**Classe:** 5IC
 
## Descrizione
 
Applicazione mobile per visualizzare le statistiche dei giocatori di Brawl Stars.
L'utente si registra con il suo tag di gioco e una password, poi può vedere le sue statistiche, cercare altri giocatori e salvarli nei preferiti.
 
---
 
## Tecnologie usate
 
- **Backend:** PHP + MySQL
- **Frontend:** Flutter
- **API esterna:** Brawl Stars API ufficiale
- **Database locale:** SQLite (cache offline)
---
 
## Come funziona
 
Il server PHP riceve le richieste dall'app Flutter e le gestisce:
- registrazione e login degli utenti
- salvataggio e gestione dei preferiti
- comunicazione con le API ufficiali di Brawl Stars
L'app Flutter mostra le statistiche del giocatore loggato, permette di cercare altri giocatori tramite tag e salvarli nei preferiti.
I dati vengono salvati in un database SQLite locale, così l'app funziona anche senza connessione al server mostrando i dati salvati in precedenza.
 
---

## Diario di progetto
 
### Step 1 - Database e configurazione
Creato il database MySQL con le tabelle users e favorites.
Configurata la connessione in db.php.
 
### Step 2 - Registrazione e login
Creati gli endpoint register.php e login.php.
Le password vengono salvate in modo sicuro con bcrypt (algoritmo per cifrare le password).
 
### Step 3 - Preferiti
Creati gli endpoint per aggiungere, leggere e rimuovere i preferiti.
 
### Step 4 - Integrazione API Brawl Stars
Creato get_player.php che fa da intermediario tra l'app e le API ufficiali di Brawl Stars, per non esporre il token API nell'app.
 
### Step 5 - App Flutter
Create le schermate di login, stats, cerca e preferiti.
Implementato il login automatico tramite SQLite.
 
### Step 6 - Cache offline
I dati del giocatore e i preferiti vengono salvati in SQLite.
Se il server non è raggiungibile l'app mostra i dati salvati in precedenza.
