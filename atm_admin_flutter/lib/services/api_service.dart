// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.109:8000/api';

  // ── Tickets ──────────────────────────────────────────────────────

  static Future<List<Ticket>> getTickets({String? status}) async {
    final uri = Uri.parse('$baseUrl/tickets')
        .replace(queryParameters: status != null ? {'status': status} : null);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['tickets'] as List).map((j) => Ticket.fromJson(j)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<void> resolveTicket(int id) async {
    await http.patch(
      Uri.parse('$baseUrl/tickets/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': 'resolved'}),
    );
  }

  static Future<void> setInProgress(int id) async {
    await http.patch(
      Uri.parse('$baseUrl/tickets/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': 'in_progress'}),
    );
  }

  // ── ATMs ─────────────────────────────────────────────────────────

  static Future<List<AtmDevice>> getAtms() async {
    final res = await http.get(Uri.parse('$baseUrl/atms'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['atms'] as List).map((j) => AtmDevice.fromJson(j)).toList();
    }
    throw Exception('Failed to load ATMs');
  }

  // ── Operator chat ─────────────────────────────────────────────────

  static Future<void> sendMessage({
    required int telegramId,
    required String text,
    String lang = 'ru',
  }) async {
    await http.post(
      Uri.parse('$baseUrl/operator/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'telegram_id': telegramId,
        'text': text,
        'lang': lang,
      }),
    );
  }
}
