# todo_list

GridView per le Card: Ogni card è un contenitore che può avere una lista di to-dos. La griglia mostra un numero dinamico di card, organizzate in righe da 2.

Ogni Card contiene una Lista di To-Dos: Per ogni card, vengono visualizzati i to-dos associati a quella card. Ogni to-do può essere segnato come completato tramite una checkbox.

Aggiunta di Nuove Card e To-Dos: Il floating action button aggiunge una nuova card alla griglia. Ogni card ha un pulsante che permette di aggiungere nuovi to-dos.

Gestione dello Stato: Tutto il comportamento (aggiungere card, cambiare lo stato dei to-dos, ecc.) è gestito tramite un oggetto TodoListNotifier, che aggiorna l'interfaccia utente ogni volta che lo stato cambia.
