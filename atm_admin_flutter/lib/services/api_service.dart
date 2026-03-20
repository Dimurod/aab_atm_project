// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://smart-atm-backend.onrender.com/api';

  // ── AUTH TOKEN ────────────────────────────────────────────────────

  static String? _token;

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('token_saved_at', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('token_saved_at');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final savedAt = prefs.getInt('token_saved_at') ?? 0;
    if (token == null) return false;
    // Автовыход через 8 часов
    final elapsed = DateTime.now().millisecondsSinceEpoch - savedAt;
    if (elapsed > 8 * 60 * 60 * 1000) {
      await clearToken();
      return false;
    }
    return true;
  }

  // Заголовки с токеном
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── LOGIN ─────────────────────────────────────────────────────────

  static Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'] as String?;
        if (token != null) {
          await saveToken(token);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> logout() async {
    await clearToken();
  }

  // ── Tickets ───────────────────────────────────────────────────────

  static Future<List<Ticket>> getTickets({String? status}) async {
    final uri = Uri.parse('$baseUrl/tickets')
        .replace(queryParameters: status != null ? {'status': status} : null);
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 401) throw Exception('Unauthorized');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['tickets'] as List).map((j) => Ticket.fromJson(j)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<void> resolveTicket(int id) async {
    await http.patch(
      Uri.parse('$baseUrl/tickets/$id/status'),
      headers: await _headers(),
      body: jsonEncode({'status': 'resolved'}),
    );
  }

  static Future<void> setInProgress(int id) async {
    await http.patch(
      Uri.parse('$baseUrl/tickets/$id/status'),
      headers: await _headers(),
      body: jsonEncode({'status': 'in_progress'}),
    );
  }

  // ── ATMs ──────────────────────────────────────────────────────────

  static Future<List<AtmDevice>> getAtms() async {
    final res = await http.get(
      Uri.parse('$baseUrl/atms'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['atms'] as List).map((j) => AtmDevice.fromJson(j)).toList();
    }
    throw Exception('Failed to load ATMs');
  }

  // ── Monitoring ────────────────────────────────────────────────────

  static Future<List<dynamic>> getMonitoring() async {
    final res = await http.get(
      Uri.parse('$baseUrl/monitoring/atms'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['atms'] as List;
    }
    throw Exception('Failed to load monitoring');
  }

  // ── Operator chat ─────────────────────────────────────────────────

  static Future<void> sendMessage({
    required int telegramId,
    required String text,
    String lang = 'ru',
  }) async {
    await http.post(
      Uri.parse('$baseUrl/operator/send'),
      headers: await _headers(),
      body: jsonEncode({
        'telegram_id': telegramId,
        'text': text,
        'lang': lang,
      }),
    );
  }
}
