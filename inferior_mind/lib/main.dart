import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name
      title: 'Flutter Hello World',
      // Application theme data, you can set the colors for the application as
      // you want
      theme: ThemeData(
        // useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      // A widget which will be started on application startup
      home: MyHomePage(title: 'Inferior Mind'),
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
  List<int> counters = [0, 0, 0, 0];
  List<MaterialColor> colors = [
    Colors.grey,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.red
  ];
  late List<int> randomArray;
  String messaggio = "";
  @override
  void initState() {
    super.initState();
    var random = Random();
    randomArray = List.generate(4, (_) => random.nextInt(4) + 1);
    print(randomArray);
  }

  void changeColor(int index) {
    setState(() {
      if (counters[index] == 4) {
        counters[index] = 1;
      } else {
        counters[index]++;
      }
    });
  }

  void controllGame() {
    print("Random array: $randomArray");
    print("Scelte utente: $counters");
    bool haVinto = true;
    for (int i = 0; i < randomArray.length; i++) {
      if (counters[i] != randomArray[i]) {
        haVinto = false;
        break;
      }
    }
    setState(() {
      messaggio = haVinto ? "Hai vinto! 🎉" : "Hai perso 😢";
      counters = [0, 0, 0, 0];
      var random = Random();
      randomArray = List.generate(4, (_) => random.nextInt(4) + 1);
      print("Nuova sequenza da indovinare: $randomArray");
    });

    print(messaggio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.blueGrey,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => changeColor(0),
              child: Text(''),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: colors[counters[0]],
                padding: EdgeInsets.all(24),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => changeColor(1),
              child: Text(''),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: colors[counters[1]],
                padding: EdgeInsets.all(24),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => changeColor(2),
              child: Text(''),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: colors[counters[2]],
                padding: EdgeInsets.all(24),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => changeColor(3),
              child: Text(''),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: colors[counters[3]],
                padding: EdgeInsets.all(24),
              ),
            ),
            SizedBox(height: 16),
            Text(
              messaggio,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: messaggio.contains("vinto") ? Colors.green : Colors.red,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controllGame(),
        child: Icon(Icons.check),
        tooltip: "Verifica giocata",
      ),
    );
  }
}
