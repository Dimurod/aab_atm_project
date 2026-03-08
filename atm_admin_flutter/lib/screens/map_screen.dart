// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final atms = context.watch<AppProvider>().atms;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionTitle('Устройства (${atms.length})'),
        ...atms.map((atm) => _AtmCard(atm: atm)),
        if (atms.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text('Загрузка...', style: TextStyle(color: AppColors.textDim)),
            ),
          ),
      ],
    );
  }
}

class _AtmCard extends StatelessWidget {
  final AtmDevice atm;
  const _AtmCard({required this.atm});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(atm.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.navyMid,
        border:       Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(atm.id, style: const TextStyle(
                color: AppColors.gold, fontWeight: FontWeight.w700,
                fontSize: 13, fontFamily: 'monospace',
              )),
              const SizedBox(width: 8),
              StatusBadge(text: atm.status, color: color),
            ]),
            const SizedBox(height: 4),
            Text(atm.address,
              style: const TextStyle(color: AppColors.text, fontSize: 12)),
            if (atm.branchName != null) ...[
              const SizedBox(height: 2),
              Text(atm.branchName!,
                style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
            ],
            const SizedBox(height: 2),
            Text(atm.deviceType,
              style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          ],
        )),
      ]),
    );
  }
}


// ─────────────────────────────────────────────────────────
// lib/screens/stats_screen.dart

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov    = context.watch<AppProvider>();
    final tickets = prov.tickets;
    final atms    = prov.atms;

    final total     = tickets.length;
    final resolved  = tickets.where((t) => t.status == 'resolved').length;
    final selfServe = total > 0 ? (resolved / total * 100).round() : 66;

    final byCategory = {
      'card_held': tickets.where((t) => t.category == 'card_held').length,
      'no_cash':   tickets.where((t) => t.category == 'no_cash').length,
      'other':     tickets.where((t) => t.category == 'other').length,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // KPI
        Row(children: [
          StatCard(label: 'Всего',      value: '$total',        accent: AppColors.blue),
          const SizedBox(width: 8),
          StatCard(label: 'Решено ботом', value: '$selfServe%', accent: AppColors.green),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          StatCard(label: 'Эскалации',  value: '${prov.escalatedCount}', accent: AppColors.red),
          const SizedBox(width: 8),
          StatCard(label: 'Ср. время',  value: '4.2 мин',       accent: AppColors.gold),
        ]),

        const SizedBox(height: 20),
        SectionTitle('По категориям'),
        _CategoryBar(label: '💳 Карта удержана', count: byCategory['card_held']!, total: total, color: AppColors.blue),
        const SizedBox(height: 8),
        _CategoryBar(label: '💵 Невыдача',        count: byCategory['no_cash']!,   total: total, color: AppColors.gold),
        const SizedBox(height: 8),
        _CategoryBar(label: '📞 Оператор',        count: byCategory['other']!,     total: total, color: AppColors.yellow),

        const SizedBox(height: 20),
        SectionTitle('Статус сети банкоматов'),
        Row(children: [
          _AtmStat(label: 'Online',      count: atms.where((a) => a.status == 'Online').length,      color: AppColors.green),
          const SizedBox(width: 8),
          _AtmStat(label: 'Maintenance', count: atms.where((a) => a.status == 'Maintenance').length, color: AppColors.yellow),
          const SizedBox(width: 8),
          _AtmStat(label: 'Offline',     count: atms.where((a) => a.status == 'Offline').length,     color: AppColors.red),
        ]),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _CategoryBar({required this.label, required this.count, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.navyMid, border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13)),
          Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 5,
            backgroundColor: AppColors.navyLt,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(pct * 100).round()}% от всех обращений',
          style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
      ]),
    );
  }
}

class _AtmStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _AtmStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color:  color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Text('$count', style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
      ]),
    ),
  );
}
