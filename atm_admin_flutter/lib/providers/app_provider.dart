// lib/providers/app_provider.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final WebSocketService _ws = WebSocketService();

  List<Ticket>    tickets    = [];
  List<AtmDevice> atms       = [];
  Ticket?         activeChat;
  Map<int, List<ChatMessage>> chats = {};
  bool   loading    = false;
  String? error;

  AppProvider() {
    _initWebSocket();
    loadTickets();
    loadAtms();
  }

  // ── Load data ──────────────────────────────────────────────────

  Future<void> loadTickets() async {
    loading = true;
    notifyListeners();
    try {
      tickets = await ApiService.getTickets();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadAtms() async {
    try {
      atms = await ApiService.getAtms();
      notifyListeners();
    } catch (_) {}
  }

  // ── Ticket actions ─────────────────────────────────────────────

  Future<void> resolve(int id) async {
    await ApiService.resolveTicket(id);
    final i = tickets.indexWhere((t) => t.id == id);
    if (i != -1) {
      tickets[i].status    = 'resolved';
      tickets[i].escalated = false;
      notifyListeners();
    }
    if (activeChat?.id == id) activeChat = null;
  }

  Future<void> setInProgress(int id) async {
    await ApiService.setInProgress(id);
    final i = tickets.indexWhere((t) => t.id == id);
    if (i != -1) {
      tickets[i].status = 'in_progress';
      notifyListeners();
    }
  }

  // ── Chat ────────────────────────────────────────────────────────

  void openChat(Ticket ticket) {
    activeChat = ticket;
    chats.putIfAbsent(ticket.id, () => []);
    notifyListeners();
  }

  void closeChat() {
    activeChat = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (activeChat == null) return;
    final ticket = activeChat!;

    final msg = ChatMessage(from: 'operator', text: text, time: DateTime.now());
    chats[ticket.id] = [...(chats[ticket.id] ?? []), msg];

    // Update status
    final i = tickets.indexWhere((t) => t.id == ticket.id);
    if (i != -1) tickets[i].status = 'in_progress';

    notifyListeners();

    if (ticket.telegramId != null) {
      await ApiService.sendMessage(
        telegramId: ticket.telegramId!,
        text: text,
        lang: ticket.lang,
      );
    }
  }

  // ── WebSocket ──────────────────────────────────────────────────

  void _initWebSocket() {
    _ws.connect();
    _ws.events.listen((event) {
      switch (event['event']) {
        case 'new_ticket':
          final t = Ticket(
            id:        event['ticket_id'],
            no:        event['ticket_no'] ?? '',
            category:  event['category'] ?? 'other',
            status:    'open',
            escalated: false,
            atm:       event['atm_id'] ?? '—',
            user:      event['first_name'] ?? '—',
            time:      DateTime.now().toIso8601String(),
            amount:    event['amount'] != null ? double.tryParse(event['amount'].toString()) : null,
            telegramId:event['telegram_id'],
          );
          tickets = [t, ...tickets];
          NotificationService.showNewTicket(t.no);
          notifyListeners();
          break;

        case 'escalation':
          final id = event['ticket_id'];
          final i  = tickets.indexWhere((t) => t.id == id);
          if (i != -1) {
            tickets[i].status    = 'escalated';
            tickets[i].escalated = true;
            NotificationService.showEscalationAlert(
              tickets[i].no, tickets[i].user,
            );
            notifyListeners();
          }
          break;

        case 'operator_request':
          final t = Ticket(
            id:        event['ticket_id'],
            no:        event['ticket_no'] ?? '',
            category:  'other',
            status:    'open',
            escalated: false,
            atm:       event['atm_id'] ?? '—',
            user:      event['first_name'] ?? '—',
            time:      DateTime.now().toIso8601String(),
            telegramId:event['telegram_id'],
          );
          tickets = [t, ...tickets];
          notifyListeners();
          break;
      }
    });
  }

  // ── Computed ────────────────────────────────────────────────────

  int get escalatedCount =>
      tickets.where((t) => t.escalated && t.status != 'resolved').length;
  int get openCount =>
      tickets.where((t) => t.status == 'open').length;

  @override
  void dispose() {
    _ws.dispose();
    super.dispose();
  }
}
