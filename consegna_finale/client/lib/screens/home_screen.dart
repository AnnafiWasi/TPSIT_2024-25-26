import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'stats_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userTag;
  const HomeScreen({super.key, required this.userTag});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  Future<void> logout() async {
    await DBHelper.clearUser(widget.userTag);
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      StatsScreen(userTag: widget.userTag),
      SearchScreen(userTag: widget.userTag),
      FavoritesScreen(userTag: widget.userTag),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Brawl Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                    ChangePasswordScreen(userTag: widget.userTag))),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cerca"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Preferiti"),
        ],
      ),
    );
  }
}