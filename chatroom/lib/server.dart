import 'dart:io';
import 'dart:convert';

// Lista di tutti i client connessi
List<Socket> clienti = [];
Map<Socket, String> nomiUtenti = {};

void main() async {
  // Crea il server sulla porta 4040
  var server = await ServerSocket.bind('192.168.1.187', 4040);
  print('Server avviato sulla porta 4040');

  // Ascolta le connessioni
  await for (var client in server) {
    print('Nuovo client connesso!');
    clienti.add(client);
    gestisciClient(client);
  }
}

void gestisciClient(Socket client) {
  // Quando arriva un messaggio dal client
  client.listen(
    (data) {
      var messaggio = utf8.decode(data).trim();

      // Se non ha ancora un nome, questo è il suo nome
      if (!nomiUtenti.containsKey(client)) {
        nomiUtenti[client] = messaggio;
        print('Utente registrato: $messaggio');
        inviaATutti('$messaggio è entrato nella chat!', client);
      } else {
        // Altrimenti è un messaggio normale
        var nome = nomiUtenti[client];
        print('$nome: $messaggio');
        inviaATutti('$nome: $messaggio', null);
      }
    },
    onDone: () {
      // Quando il client si disconnette
      var nome = nomiUtenti[client] ?? 'Sconosciuto';
      print('$nome si è disconnesso');
      clienti.remove(client);
      nomiUtenti.remove(client);
      inviaATutti('$nome ha lasciato la chat', null);
    },
  );
}

void inviaATutti(String messaggio, Socket? mittente) {
  // Manda il messaggio a tutti i client
  for (var client in clienti) {
    if (client != mittente) {
      client.write('$messaggio\n');
    }
  }
}
