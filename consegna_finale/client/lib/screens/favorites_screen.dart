import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../db/db_helper.dart';
import 'stats_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final String userTag;
  const FavoritesScreen({super.key, required this.userTag});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() => loading = true);

    final result = await ApiService.getFavorites(widget.userTag);

    if (!mounted) return;

    if (result.containsKey("error")) {
      final cached = await DBHelper.getFavorites(widget.userTag);
      setState(() {
        favorites = List<Map<String, dynamic>>.from(cached);
        loading = false;
      });
      return;
    }

    final serverList = List<Map<String, dynamic>>.from(result["favorites"] ?? []);
    final List<Map<String, dynamic>> lista = [];

    for (final fav in serverList) {
      final playerTag = fav["player_tag"] as String;
      final cached    = await DBHelper.getFavoriteByTag(widget.userTag, playerTag);
      final nome      = cached?["player_name"] as String?;

      if (nome != null && nome.isNotEmpty) {
        lista.add({"player_tag": playerTag, "player_name": nome});
      } else {
        final dati = await ApiService.getPlayer(playerTag);
        final n    = dati["name"] as String? ?? playerTag;
        await DBHelper.addFavorite(widget.userTag, playerTag, n);
        lista.add({"player_tag": playerTag, "player_name": n});
      }
    }

    if (!mounted) return;
    setState(() { favorites = lista; loading = false; });
  }

  Future<void> remove(String playerTag) async {
    await ApiService.removeFavorite(widget.userTag, playerTag);
    await DBHelper.removeFavorite(widget.userTag, playerTag);
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (favorites.isEmpty) {
      return const Center(child: Text("Nessun preferito aggiunto"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav  = favorites[index];
        final nome = fav["player_name"] ?? fav["player_tag"];

        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(nome),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(nome)),
                  body: StatsScreen(userTag: fav["player_tag"]),
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => remove(fav["player_tag"]),
            ),
          ),
        );
      },
    );
  }
}