// lib/models/models.dart

class Ticket {
  final int id;
  final String no;
  final String category;
  String status;
  bool escalated;
  final String atm;
  final String user;
  final String time;
  final double? amount;
  final String lang;
  final int? telegramId;
  final String? phone;
  final String? source;

  Ticket({
    required this.id,
    required this.no,
    required this.category,
    required this.status,
    required this.escalated,
    required this.atm,
    required this.user,
    required this.time,
    this.amount,
    this.lang = 'ru',
    this.telegramId,
    this.phone,
    this.source,
  });

  factory Ticket.fromJson(Map<String, dynamic> j) => Ticket(
        id: j['id'],
        no: j['ticket_no'] ?? j['no'] ?? '',
        category: j['category'] ?? 'other',
        status: j['status'] ?? 'open',
        escalated: j['escalated'] ?? false,
        atm: j['atm_id'] ?? j['atm'] ?? '—',
        user: j['first_name'] ?? j['user'] ?? '—',
        time: j['created_at'] ?? j['time'] ?? '',
        amount: j['amount'] != null
            ? double.tryParse(j['amount'].toString())
            : null,
        lang: j['lang'] ?? 'ru',
        telegramId: j['telegram_id'],
        phone: j['phone'],
        source: j['source'],
      );

  String get categoryLabel =>
      {
        'card_held': '💳 Карта удержана',
        'card_stuck': '💳 Карта застряла',
        'no_cash': '💵 Невыдача наличных',
        'cash_not_dispensed': '💵 Невыдача наличных',
        'operator_needed': '📞 Нужен оператор',
        'info': '📍 Информация',
        'other': '❓ Другое',
      }[category] ??
      category;

  String get statusLabel =>
      {
        'open': 'Открыта',
        'in_progress': 'В работе',
        'resolved': 'Решена',
        'escalated': 'Эскалация',
      }[status] ??
      status;

  String get sourceLabel => source == 'pwa' ? '🌐 PWA' : '✈️ Telegram';
  bool get hasTelegramId => telegramId != null && telegramId! > 0;
  bool get hasPhone => phone != null && phone!.isNotEmpty;
}

// lib/models/atm_device.dart

class AtmDevice {
  final String id;
  final String address;
  final String status;
  final double latitude;
  final double longitude;
  final String deviceType;
  final String? branchName;

  AtmDevice({
    required this.id,
    required this.address,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.deviceType = 'Unknown',
    this.branchName,
  });

  factory AtmDevice.fromJson(Map<String, dynamic> j) => AtmDevice(
        id: j['atm_id'] ?? j['id'] ?? '',
        address: j['address'] ?? '',
        status: j['status'] ?? 'Unknown',
        latitude: double.tryParse(j['latitude'].toString()) ?? 0,
        longitude: double.tryParse(j['longitude'].toString()) ?? 0,
        deviceType: j['device_type'] ?? 'Unknown',
        branchName: j['branch_name'],
      );
}

// lib/models/chat_message.dart

class ChatMessage {
  final String from;
  final String text;
  final DateTime time;

  ChatMessage({
    required this.from,
    required this.text,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        from: j['from'] ?? 'bot',
        text: j['text'] ?? '',
        time: DateTime.tryParse(j['time'] ?? '') ?? DateTime.now(),
      );

  bool get isClient => from == 'client';
  bool get isOperator => from == 'operator';
  bool get isSystem => from == 'system';
}
