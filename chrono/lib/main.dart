import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronometro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Cronometro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Stream per il ticker (emette ogni 100ms)
  StreamController<int> tickerController = StreamController<int>();

  // Stream per i secondi
  StreamController<int> secondiController = StreamController<int>();

  // Timer che genera i tick
  Timer? timer;

  // Contatori
  int secondi = 0;
  int decimi = 0;

  // Stati
  String stato = 'RESET'; // può essere: RESET, START, STOP
  String pausaStato = 'RESUME'; // può essere: RESUME, PAUSE

  @override
  void initState() {
    super.initState();

    // PIPE: collego il ticker stream allo stream dei secondi
    tickerController.stream.listen((tick) {
      decimi = decimi + 1;

      if (decimi >= 10) {
        decimi = 0;
        secondi = secondi + 1;
      }

      // Emetto il nuovo valore nello stream dei secondi
      secondiController.add(secondi);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    tickerController.close();
    secondiController.close();
    super.dispose();
  }

  // Funzione che avvia il timer
  void avvia() {
    timer = Timer.periodic(Duration(milliseconds: 100), (t) {
      tickerController.add(0); // emetto un tick
    });
  }

  // Funzione che ferma il timer
  void ferma() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  // Bottone 1: START -> STOP -> RESET -> START ...
  void clickBottone1() {
    setState(() {
      if (stato == 'RESET') {
        stato = 'START';
        avvia();
      } else if (stato == 'START') {
        stato = 'STOP';
        ferma();
      } else if (stato == 'STOP') {
        stato = 'RESET';
        ferma();
        secondi = 0;
        decimi = 0;
        pausaStato = 'RESUME';
        secondiController.add(secondi);
      }
    });
  }

  // Bottone 2: PAUSE <-> RESUME
  void clickBottone2() {
    if (stato != 'START') {
      return; // funziona solo se è in START
    }

    setState(() {
      if (pausaStato == 'RESUME') {
        pausaStato = 'PAUSE';
        ferma();
      } else {
        pausaStato = 'RESUME';
        avvia();
      }
    });
  }

  // Formatta il tempo in MM:SS.D
  String formattaTempo() {
    int minuti = secondi ~/ 60;
    int sec = secondi % 60;

    String m = minuti.toString();
    String s = sec.toString();

    if (minuti < 10) m = '0' + m;
    if (sec < 10) s = '0' + s;

    return m + ':' + s + '.' + decimi.toString();
  }

  // Icona per bottone 1
  IconData iconaBottone1() {
    if (stato == 'RESET') return Icons.play_arrow;
    if (stato == 'START') return Icons.stop;
    return Icons.refresh;
  }

  // Icona per bottone 2
  IconData iconaBottone2() {
    if (pausaStato == 'RESUME') return Icons.pause;
    return Icons.play_arrow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CRONOMETRO',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            SizedBox(height: 40),

            // Ascolto lo stream dei secondi
            StreamBuilder<int>(
              stream: secondiController.stream,
              initialData: 0,
              builder: (context, snapshot) {
                return Text(
                  formattaTempo(),
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                );
              },
            ),

            SizedBox(height: 20),
            Text(
              'Stato: ' + stato,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // BOTTONE 2: PAUSE/RESUME
          FloatingActionButton(
            heroTag: 'pause',
            onPressed: clickBottone2,
            child: Icon(iconaBottone2()),
            backgroundColor: Colors.orange,
          ),
          SizedBox(width: 16),

          // BOTTONE 1: START/STOP/RESET
          FloatingActionButton(
            heroTag: 'start',
            onPressed: clickBottone1,
            child: Icon(iconaBottone1()),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
