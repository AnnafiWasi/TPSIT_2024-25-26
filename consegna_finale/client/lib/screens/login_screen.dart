import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../db/db_helper.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final tag  = TextEditingController();
  final pass = TextEditingController();
  String msg = "";

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final savedTag = await DBHelper.getUser();
    if (!mounted) return;
    if (savedTag != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => HomeScreen(userTag: savedTag)));
    }
  }

  Future<void> login() async {
    final res = await ApiService.login(tag.text.trim(), pass.text.trim());
    if (!mounted) return;
    if (res["success"] == true) {
      await DBHelper.saveUser(res["tag"]);
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => HomeScreen(userTag: res["tag"])));
    } else {
      setState(() => msg = res["error"] ?? "Login fallito");
    }
  }

  Future<void> register() async {
    final res = await ApiService.register(tag.text.trim(), pass.text.trim());
    if (!mounted) return;
    if (res["success"] == true) {
      setState(() => msg = "Registrato! Ora fai il login.");
    } else {
      setState(() => msg = res["error"] ?? "Errore registrazione");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Brawl Tracker",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: tag,
              decoration: const InputDecoration(
                labelText: "Tag giocatore",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: register,
                child: const Text("Registrati"),
              ),
            ),
            const SizedBox(height: 12),
            Text(msg, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}