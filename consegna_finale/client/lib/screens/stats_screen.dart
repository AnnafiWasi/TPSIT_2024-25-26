import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../db/db_helper.dart';

class StatsScreen extends StatefulWidget {
  final String userTag;
  const StatsScreen({super.key, required this.userTag});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? player;
  bool loading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    loadPlayer();
  }

  Future<void> loadPlayer() async {
    setState(() { loading = true; error = ""; });

    final result = await ApiService.getPlayer(widget.userTag);

    if (!mounted) return;

    if (result.containsKey("error") || result.containsKey("reason")) {
      final cached = await DBHelper.getPlayer(widget.userTag);
      if (!mounted) return;
      if (cached != null) {
        setState(() { player = cached; loading = false; });
      } else {
        setState(() { error = "Server non raggiungibile"; loading = false; });
      }
    } else {
      await DBHelper.savePlayer(widget.userTag, result);
      setState(() { player = result; loading = false; });
    }
  }

  Widget riga(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: loadPlayer, child: const Text("Riprova")),
          ],
        ),
      );
    }

    final club     = player?["club"] as Map<String, dynamic>?;
    final brawlers = player?["brawlers"] as List<dynamic>? ?? [];
    final migliore = brawlers.isNotEmpty
        ? brawlers.reduce((a, b) =>
    (a["trophies"] ?? 0) >= (b["trophies"] ?? 0) ? a : b)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(player?["name"] ?? "",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(player?["tag"] ?? "",
                  style: const TextStyle(color: Colors.grey)),
              if (club != null)
                Text("Club: ${club["name"]}",
                    style: const TextStyle(color: Colors.indigo)),
              const Divider(height: 24),
              riga("Trofei",        player?["trophies"]),
              riga("Record trofei", player?["highestTrophies"]),
              riga("Livello",       player?["expLevel"]),
              riga("Punti exp",     player?["expPoints"]),
              riga("Vittorie 3v3",  player?["3vs3Victories"]),
              riga("Vittorie Solo", player?["soloVictories"]),
              riga("Vittorie Duo",  player?["duoVictories"]),
              riga("Brawlers",      brawlers.length),
              if (migliore != null)
                riga("Miglior brawler",
                    "${migliore["name"]} (${migliore["trophies"]} 🏆)"),
            ],
          ),
        ),
      ),
    );
  }
}