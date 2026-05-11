import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userTag;
  const ChangePasswordScreen({super.key, required this.userTag});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final current = TextEditingController();
  final newPass  = TextEditingController();
  String msg = "";

  Future<void> aggiorna() async {
    if (current.text.isEmpty || newPass.text.isEmpty) {
      setState(() => msg = "Compila tutti i campi");
      return;
    }
    final res = await ApiService.updatePassword(
        widget.userTag, current.text.trim(), newPass.text.trim());
    if (!mounted) return;
    setState(() {
      msg = res["success"] == true ? "Password aggiornata!" : res["error"] ?? "Errore";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambia password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password attuale",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nuova password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: aggiorna,
                child: const Text("Aggiorna password"),
              ),
            ),
            const SizedBox(height: 12),
            Text(msg),
          ],
        ),
      ),
    );
  }
}