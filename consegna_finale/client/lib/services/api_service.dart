import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const base = "http://172.20.10.10/brawl_tracker";

  static String encodeTag(String tag) {
    String t = tag.trim().toUpperCase();
    if (!t.startsWith("#")) t = "#$t";
    return Uri.encodeComponent(t);
  }

  static Future<Map<String, dynamic>> login(String tag, String pass) async {
    try {
      final res = await http.post(
        Uri.parse("$base/auth/login.php"),
        body: jsonEncode({"tag": tag, "password": pass}),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Server non raggiungibile"};
    }
  }

  static Future<Map<String, dynamic>> register(String tag, String pass) async {
    try {
      final res = await http.post(
        Uri.parse("$base/auth/register.php"),
        body: jsonEncode({"tag": tag, "password": pass}),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Server non raggiungibile"};
    }
  }

  static Future<Map<String, dynamic>> getPlayer(String tag) async {
    try {
      final res = await http.get(
        Uri.parse("$base/proxy/get_player.php?player_tag=${encodeTag(tag)}"),
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Server non raggiungibile"};
    }
  }

  static Future<Map<String, dynamic>> addFavorite(String user, String player) async {
    try {
      final res = await http.post(
        Uri.parse("$base/favorites/add_favorite.php"),
        body: jsonEncode({"user_tag": user, "player_tag": player}),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Server non raggiungibile"};
    }
  }

  static Future<Map<String, dynamic>> getFavorites(String user) async {
    try {
      final res = await http.get(
        Uri.parse("$base/favorites/get_favorites.php?user_tag=${encodeTag(user)}"),
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Server non raggiungibile"};
    }
  }

  static Future<Map<String, dynamic>> removeFavorite(String user, String player) async {
    try {
      final res = await http.post(
        Uri.parse("$base/favorites/remove_favorite.php"),
        body: jsonEncode({"user_tag": user, "player_tag": player}),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Server non raggiungibile"};
    }
  }

  static Future<Map<String, dynamic>> updatePassword(String tag, String current, String newPass) async {
    try {
      final res = await http.patch(
        Uri.parse("$base/auth/update_user.php"),
        body: jsonEncode({
          "tag": tag,
          "password": current,
          "new_password": newPass,
        }),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Server non raggiungibile"};
    }
  }
}