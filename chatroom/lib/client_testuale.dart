import 'dart:io';
import 'dart:convert';

void main() async {
  // Chiedi il nome utente
  stdout.write('Inserisci il tuo nome: ');
  var nome = stdin.readLineSync();

  // Connettiti al server
  var socket = await Socket.connect('192.168.1.187', 4040);
  print('Connesso al server!');

  // Invia il nome al server
  socket.write('$nome\n');

  // Leggi i messaggi dal server
  socket.listen(
    (data) {
      var messaggio = utf8.decode(data);
      print(messaggio);
    },
  );

  // Leggi l'input dall'utente e invialo al server
  stdin.listen((data) {
    var testo = utf8.decode(data).trim();
    if (testo.isNotEmpty) {
      socket.write('$testo\n');
    }
  });
}
