// lib/screens/tickets_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'chat_screen.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});
  @override State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  String _filter = 'all';

  static const _filters = [
    ('all',         'Все'       ),
    ('escalated',   'Эскалации' ),
    ('open',        'Открытые'  ),
    ('in_progress', 'В работе'  ),
    ('resolved',    'Решено'    ),
  ];

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final all  = prov.tickets;

    final filtered = _filter == 'all'
        ? all
        : all.where((t) => t.status == _filter).toList();

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: prov.loadTickets,
      child: Column(children: [
        // ── KPI row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            StatCard(label: 'Эскалации', value: '${prov.escalatedCount}', accent: AppColors.red,    sub: 'требуют внимания'),
            const SizedBox(width: 8),
            StatCard(label: 'Открытые',  value: '${prov.openCount}',      accent: AppColors.blue,   sub: 'ожидают ответа'),
            const SizedBox(width: 8),
            StatCard(
              label: 'Решено',
              value: '${all.where((t) => t.status == "resolved").length}',
              accent: AppColors.green, sub: 'сегодня',
            ),
          ]),
        ),

        // ── Filter chips ──
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _filters.map((f) {
              final isActive = _filter == f.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(f.$2,
                    style: TextStyle(
                      color: isActive ? AppColors.navy : AppColors.textDim,
                      fontWeight: FontWeight.w600, fontSize: 12,
                    )),
                  selected: isActive,
                  selectedColor:   AppColors.gold,
                  backgroundColor: AppColors.navyMid,
                  side: BorderSide(color: isActive ? AppColors.gold : AppColors.border),
                  onSelected: (_) => setState(() => _filter = f.$1),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // ── Ticket list ──
        Expanded(
          child: prov.loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : filtered.isEmpty
              ? Center(
                  child: Text('Нет заявок',
                    style: TextStyle(color: AppColors.textDim, fontSize: 14)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _TicketCard(ticket: filtered[i]),
                ),
        ),
      ]),
    );
  }
}


class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final prov       = context.read<AppProvider>();
    final isEscalated = ticket.escalated && ticket.status != 'resolved';
    final statusColor = AppColors.ticketStatusColor(ticket.status);

    return GestureDetector(
      onTap: () {
        prov.openChat(ticket);
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color:        isEscalated ? AppColors.red.withOpacity(0.07) : AppColors.navyMid,
          border:       Border.all(
            color: isEscalated ? AppColors.red.withOpacity(0.5) : AppColors.border,
            width: isEscalated ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              if (isEscalated) ...[
                const Text('🔴', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(ticket.no,
                style: const TextStyle(
                  color: AppColors.gold, fontWeight: FontWeight.w700,
                  fontSize: 13, fontFamily: 'monospace',
                )),
              const SizedBox(width: 8),
              StatusBadge(text: ticket.statusLabel, color: statusColor),
              const Spacer(),
              Text(ticket.time.length > 5 ? ticket.time.substring(11, 16) : ticket.time,
                style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
            ]),

            const SizedBox(height: 6),
            Text(ticket.categoryLabel,
              style: const TextStyle(color: AppColors.text, fontSize: 13)),

            const SizedBox(height: 4),
            Text('👤 ${ticket.user}  ·  🏧 ${ticket.atm}'
              + (ticket.amount != null ? '  ·  💰 ${ticket.amount!.toStringAsFixed(0)} сум' : ''),
              style: const TextStyle(color: AppColors.textDim, fontSize: 11)),

            const SizedBox(height: 10),

            // Action buttons
            Row(children: [
              if (ticket.status != 'resolved') ...[
                _ActionBtn(
                  label: '✓ Решить',
                  color: AppColors.green,
                  onTap: () => prov.resolve(ticket.id),
                ),
                const SizedBox(width: 8),
              ],
              _ActionBtn(
                label: '💬 Чат',
                color: AppColors.gold,
                onTap: () {
                  prov.openChat(ticket);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ChatScreen(),
                  ));
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}


class _ActionBtn extends StatelessWidget {
  final String label;
  final Color  color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.12),
          border:       Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
