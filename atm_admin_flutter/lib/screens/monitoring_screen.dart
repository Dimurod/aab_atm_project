// lib/screens/monitoring_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../widgets/widgets.dart';

// ── MODEL ─────────────────────────────────────────────────────────
class AtmMonitorStatus {
  final String atmId;
  final String address;
  final int cashLevel;
  final int paperLevel;
  final bool isOnline;
  final bool cardJam;
  final String lastPing;
  final int openTickets;

  AtmMonitorStatus({
    required this.atmId,
    required this.address,
    required this.cashLevel,
    required this.paperLevel,
    required this.isOnline,
    required this.cardJam,
    required this.lastPing,
    required this.openTickets,
  });

  factory AtmMonitorStatus.fromJson(Map<String, dynamic> j) => AtmMonitorStatus(
        atmId: j['atm_id'] ?? '',
        address: j['address'] ?? '',
        cashLevel: j['cash_level'] ?? 0,
        paperLevel: j['paper_level'] ?? 0,
        isOnline: j['is_online'] ?? false,
        cardJam: j['card_jam'] ?? false,
        lastPing: j['last_ping'] ?? '',
        openTickets: j['open_tickets'] ?? 0,
      );

  String get statusText {
    if (!isOnline) return 'Офлайн';
    if (cardJam) return 'Карта!';
    if (cashLevel < 15) return 'Мало налич.';
    if (paperLevel < 10) return 'Нет ленты';
    return 'Онлайн';
  }

  Color get statusColor {
    if (!isOnline) return AppColors.red;
    if (cardJam) return AppColors.red;
    if (cashLevel < 15) return AppColors.yellow;
    if (paperLevel < 10) return AppColors.yellow;
    return AppColors.green;
  }

  bool get hasAlert =>
      !isOnline || cardJam || cashLevel < 15 || paperLevel < 10;
}

// ── SCREEN ────────────────────────────────────────────────────────
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});
  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  static const _apiUrl =
      'https://smart-atm-backend.onrender.com/api/monitoring/atms';

  List<AtmMonitorStatus> _atms = [];
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    // Обновляем каждые 60 секунд
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = _atms.isEmpty);
    try {
      final res = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['atms'] as List)
            .map((j) => AtmMonitorStatus.fromJson(j))
            .toList();
        if (mounted) {
          setState(() {
            _atms = list;
            _loading = false;
            _error = null;
          });
        }
      }
    } catch (e) {
      // Если есть старые данные — не показываем ошибку
      if (mounted) {
        setState(() {
          _loading = false;
          if (_atms.isEmpty) _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('⚠️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('Ошибка загрузки',
              style: TextStyle(color: AppColors.textDim, fontSize: 14)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text('Повторить',
                style: TextStyle(color: AppColors.navy)),
          ),
        ]),
      );
    }

    final alerts = _atms.where((a) => a.hasAlert).length;
    final online = _atms.where((a) => a.isOnline).length;
    final lowCash = _atms.where((a) => a.cashLevel < 20).length;
    final lowPaper = _atms.where((a) => a.paperLevel < 15).length;

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── KPI ──────────────────────────────────────────────────
          Row(children: [
            _KpiCard(
              value: '$online',
              label: 'Онлайн',
              sub: 'из ${_atms.length}',
              color: AppColors.green,
            ),
            const SizedBox(width: 8),
            _KpiCard(
              value: '$alerts',
              label: 'Тревог',
              sub: 'требуют внимания',
              color: alerts > 0 ? AppColors.red : AppColors.green,
            ),
            const SizedBox(width: 8),
            _KpiCard(
              value: '$lowCash',
              label: 'Мало наличных',
              sub: '< 20%',
              color: lowCash > 0 ? AppColors.yellow : AppColors.green,
            ),
          ]),

          const SizedBox(height: 8),

          Row(children: [
            _KpiCard(
              value: '$lowPaper',
              label: 'Мало ленты',
              sub: '< 15%',
              color: lowPaper > 0 ? AppColors.yellow : AppColors.green,
            ),
            const SizedBox(width: 8),
            _KpiCard(
              value: '${_atms.where((a) => a.cardJam).length}',
              label: 'Card Jam',
              sub: 'карта застряла',
              color:
                  _atms.any((a) => a.cardJam) ? AppColors.red : AppColors.green,
            ),
            const SizedBox(width: 8),
            _KpiCard(
              value: '${_atms.fold(0, (s, a) => s + a.openTickets)}',
              label: 'Заявок',
              sub: 'открытых',
              color: AppColors.blue,
            ),
          ]),

          const SizedBox(height: 20),

          // ── ALERTS BANNER ─────────────────────────────────────────
          if (alerts > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                border: Border.all(color: AppColors.red.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Text('🚨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$alerts банкомат(а) требует внимания!',
                    style: const TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          // ── ATM LIST ──────────────────────────────────────────────
          SectionTitle('Банкоматы (${_atms.length})'),
          ..._atms.map((atm) => _AtmMonitorCard(atm: atm)),
        ],
      ),
    );
  }
}

// ── KPI CARD ──────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String value, label, sub;
  final Color color;
  const _KpiCard({
    required this.value,
    required this.label,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.navyMid,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            Text(sub,
                style: const TextStyle(color: AppColors.textDim, fontSize: 9),
                textAlign: TextAlign.center),
          ]),
        ),
      );
}

// ── ATM MONITOR CARD ──────────────────────────────────────────────
class _AtmMonitorCard extends StatelessWidget {
  final AtmMonitorStatus atm;
  const _AtmMonitorCard({required this.atm});

  Color _cashColor(int pct) {
    if (pct > 50) return AppColors.green;
    if (pct > 20) return AppColors.yellow;
    return AppColors.red;
  }

  Color _paperColor(int pct) {
    if (pct > 30) return AppColors.green;
    if (pct > 10) return AppColors.yellow;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final hasAlert = atm.hasAlert;
    final borderColor =
        hasAlert ? atm.statusColor.withOpacity(0.5) : AppColors.border;

    String pingTime = '';
    if (atm.lastPing.length >= 16) {
      pingTime = atm.lastPing.substring(11, 16);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasAlert ? atm.statusColor.withOpacity(0.05) : AppColors.navyMid,
        border: Border.all(color: borderColor, width: hasAlert ? 1.5 : 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: atm.statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: atm.statusColor.withOpacity(0.5), blurRadius: 6)
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(atm.atmId,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFamily: 'monospace',
              )),
          const SizedBox(width: 8),
          StatusBadge(text: atm.statusText, color: atm.statusColor),
          const Spacer(),
          if (atm.openTickets > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.15),
                border: Border.all(color: AppColors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text('${atm.openTickets} заявок',
                  style: TextStyle(
                      color: Colors.blue[300],
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 6),
          Text('↻ $pingTime',
              style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
        ]),

        const SizedBox(height: 6),
        Text(atm.address,
            style: const TextStyle(color: AppColors.text, fontSize: 11)),

        const SizedBox(height: 12),

        // Cash bar
        _LevelBar(
          icon: '💰',
          label: 'Наличные',
          value: atm.cashLevel,
          color: _cashColor(atm.cashLevel),
          warning: atm.cashLevel < 20,
          warningText: 'Нужна инкассация!',
        ),

        const SizedBox(height: 8),

        // Paper bar
        _LevelBar(
          icon: '🧾',
          label: 'Чековая лента',
          value: atm.paperLevel,
          color: _paperColor(atm.paperLevel),
          warning: atm.paperLevel < 15,
          warningText: 'Замените ленту!',
        ),

        // Card jam alert
        if (atm.cardJam) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              border: Border.all(color: AppColors.red.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(children: [
              Text('🔴', style: TextStyle(fontSize: 12)),
              SizedBox(width: 6),
              Text('Карта застряла! Требуется техник',
                  style: TextStyle(
                      color: AppColors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ],

        // Offline alert
        if (!atm.isOnline) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              border: Border.all(color: AppColors.red.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(children: [
              Text('📵', style: TextStyle(fontSize: 12)),
              SizedBox(width: 6),
              Text('Банкомат не отвечает! Проверьте связь',
                  style: TextStyle(
                      color: AppColors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ── LEVEL BAR ─────────────────────────────────────────────────────
class _LevelBar extends StatelessWidget {
  final String icon, label;
  final int value;
  final Color color;
  final bool warning;
  final String warningText;

  const _LevelBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.warning,
    required this.warningText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
        const Spacer(),
        Text('$value%',
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        if (warning) ...[
          const SizedBox(width: 6),
          Text(warningText,
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: value / 100,
          minHeight: 6,
          backgroundColor: AppColors.navyLt,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }
}
