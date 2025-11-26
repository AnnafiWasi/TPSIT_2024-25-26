# chatroom

Sviluppatore: Kazi Annafi Wasi

## Ragionamento

Ho fatto un server che sta in ascolto e aspetta che i client si connettano. Quando un client si collega, la prima cosa che manda è il suo nome utente. Dopo il server sa chi è e può mandare i suoi messaggi a tutti gli altri.

Per tenere traccia di chi è connesso ho usato una lista con tutti i socket e una mappa che collega ogni socket al nome dell'utente. Così quando arriva un messaggio so da chi viene.

Quando un utente scrive qualcosa, il messaggio arriva al server e il server lo rimanda a tutti tranne a chi l'ha mandato. In questo modo tutti vedono tutti i messaggi.



