import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../db/db_helper.dart';

class SearchScreen extends StatefulWidget {
  final String userTag;
  const SearchScreen({super.key, required this.userTag});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  Map<String, dynamic>? player;
  bool loading = false;
  bool isFav   = false;

  Future<void> search() async {
    setState(() { loading = true; player = null; });
    final result = await ApiService.getPlayer(controller.text.trim());
    if (!mounted) return;
    if (result.containsKey("error") || result.containsKey("reason")) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["error"] ?? "Errore")));
      return;
    }
    final fav = await DBHelper.isFavorite(widget.userTag, result["tag"] ?? "");
    if (!mounted) return;
    setState(() { player = result; isFav = fav; loading = false; });
  }

  Future<void> toggleFavorite() async {
    if (player == null) return;
    if (isFav) {
      await ApiService.removeFavorite(widget.userTag, player!["tag"]);
      await DBHelper.removeFavorite(widget.userTag, player!["tag"]);
      setState(() => isFav = false);
    } else {
      final res = await ApiService.addFavorite(widget.userTag, player!["tag"]);
      if (!mounted) return;
      if (res["success"] == true) {
        await DBHelper.addFavorite(
            widget.userTag, player!["tag"], player!["name"] ?? "");
        setState(() => isFav = true);
      }
    }
  }

  Widget riga(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value?.toString() ?? "-"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Inserisci tag giocatore",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: search, child: const Text("Cerca")),
            ],
          ),
          const SizedBox(height: 20),
          if (loading) const CircularProgressIndicator(),
          if (player != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(player!["name"] ?? "",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          onPressed: toggleFavorite,
                          icon: Icon(
                            isFav ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    Text(player!["tag"] ?? ""),
                    const Divider(),
                    riga("Trofei",  player!["trophies"]),
                    riga("Record",  player!["highestTrophies"]),
                    riga("3v3",     player!["3vs3Victories"]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}