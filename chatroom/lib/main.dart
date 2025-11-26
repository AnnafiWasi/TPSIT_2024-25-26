import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatroom',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Socket? socket;
  List<String> messaggi = [];
  TextEditingController controller = TextEditingController();
  String nomeUtente = '';
  bool connesso = false;

  @override
  Widget build(BuildContext context) {
    // Se non sei ancora connesso, mostra la schermata di login
    if (!connesso) {
      return Scaffold(
        appBar: AppBar(title: Text('Chatroom')),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nome utente'),
                onChanged: (value) {
                  nomeUtente = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: connetti,
                child: Text('Connetti'),
              ),
            ],
          ),
        ),
      );
    }

    // Altrimenti mostra la chat
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - $nomeUtente'),
      ),
      body: Column(
        children: [
          // Lista dei messaggi
          Expanded(
            child: ListView.builder(
              itemCount: messaggi.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(messaggi[index]),
                );
              },
            ),
          ),
          // Campo per scrivere
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Scrivi un messaggio...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: invia,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void connetti() async {
    print('Tentativo di connessione...');
    try {
      // CAMBIA QUESTO IP CON QUELLO DEL TUO SERVER
      socket = await Socket.connect('192.168.1.187', 4040);
      print('Connesso!');

      // Invia il nome utente
      socket!.write('$nomeUtente\n');

      setState(() {
        connesso = true;
        messaggi.add('Connesso al server!');
      });

      // Ascolta i messaggi dal server
      socket!.listen(
        (data) {
          var messaggio = utf8.decode(data).trim();
          print('Ricevuto: $messaggio');
          setState(() {
            messaggi.add(messaggio);
          });
        },
        onError: (error) {
          print('Errore socket: $error');
        },
      );
    } catch (e) {
      print('Errore connessione: $e');
      setState(() {
        messaggi.add('ERRORE: Non riesco a connettermi al server');
      });
    }
  }

  void invia() {
    var testo = controller.text;
    if (testo.isNotEmpty && socket != null) {
      socket!.write('$testo\n');
      controller.clear();
    }
  }
}
