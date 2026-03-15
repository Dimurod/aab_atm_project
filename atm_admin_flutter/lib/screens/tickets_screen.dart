// lib/screens/tickets_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'chat_screen.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});
  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  String _filter = 'all';
  String _sourceFilter = 'all'; // all | pwa | telegram

  static const _filters = [
    ('all', 'Все'),
    ('escalated', 'Эскалации'),
    ('open', 'Открытые'),
    ('in_progress', 'В работе'),
    ('resolved', 'Решено'),
  ];

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final all = prov.tickets;

    var filtered = _filter == 'all'
        ? all
        : _filter == 'escalated'
            ? all.where((t) => t.escalated && t.status != 'resolved').toList()
            : all.where((t) => t.status == _filter).toList();

    if (_sourceFilter != 'all') {
      filtered = filtered.where((t) => t.source == _sourceFilter).toList();
    }

    final pwaCount = all.where((t) => t.source == 'pwa').length;
    final telegramCount = all.where((t) => t.source != 'pwa').length;

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: prov.loadTickets,
      child: Column(children: [
        // ── KPI row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            StatCard(
              label: 'Эскалации',
              value: '${prov.escalatedCount}',
              accent: AppColors.red,
              sub: 'требуют внимания',
            ),
            const SizedBox(width: 8),
            StatCard(
              label: 'Открытые',
              value: '${prov.openCount}',
              accent: AppColors.blue,
              sub: 'ожидают ответа',
            ),
            const SizedBox(width: 8),
            StatCard(
              label: 'Решено',
              value: '${all.where((t) => t.status == "resolved").length}',
              accent: AppColors.green,
              sub: 'сегодня',
            ),
          ]),
        ),

        // ── Source filter (PWA vs Telegram) ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(children: [
            _SourceChip(
              label: '🌐 PWA ($pwaCount)',
              active: _sourceFilter == 'pwa',
              onTap: () => setState(
                  () => _sourceFilter = _sourceFilter == 'pwa' ? 'all' : 'pwa'),
            ),
            const SizedBox(width: 8),
            _SourceChip(
              label: '✈️ Telegram ($telegramCount)',
              active: _sourceFilter == 'telegram',
              onTap: () => setState(() => _sourceFilter =
                  _sourceFilter == 'telegram' ? 'all' : 'telegram'),
            ),
          ]),
        ),

        // ── Status filter chips ──
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
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      )),
                  selected: isActive,
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.navyMid,
                  side: BorderSide(
                    color: isActive ? AppColors.gold : AppColors.border,
                  ),
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
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.gold))
              : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('✅', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text('Нет заявок',
                              style: TextStyle(
                                  color: AppColors.textDim, fontSize: 14)),
                        ],
                      ),
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

class _SourceChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SourceChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.gold.withOpacity(0.15) : AppColors.navyMid,
          border: Border.all(
            color: active ? AppColors.gold : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? AppColors.gold : AppColors.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();
    final isEscalated = ticket.escalated && ticket.status != 'resolved';
    final statusColor = AppColors.ticketStatusColor(ticket.status);

    return GestureDetector(
      onTap: () {
        prov.openChat(ticket);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatScreen()));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color:
              isEscalated ? AppColors.red.withOpacity(0.07) : AppColors.navyMid,
          border: Border.all(
            color:
                isEscalated ? AppColors.red.withOpacity(0.5) : AppColors.border,
            width: isEscalated ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Row(children: [
              if (isEscalated) ...[
                const Text('🔴', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(ticket.no,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  )),
              const SizedBox(width: 8),
              StatusBadge(text: ticket.statusLabel, color: statusColor),
              const Spacer(),
              // Source badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ticket.source == 'pwa'
                      ? Colors.blue.withOpacity(0.15)
                      : Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(ticket.sourceLabel,
                    style: TextStyle(
                      color: ticket.source == 'pwa'
                          ? Colors.blue[300]
                          : Colors.green[300],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const SizedBox(width: 8),
              Text(
                  ticket.time.length > 15
                      ? ticket.time.substring(11, 16)
                      : ticket.time,
                  style:
                      const TextStyle(color: AppColors.textDim, fontSize: 11)),
            ]),

            const SizedBox(height: 8),

            // ── Category ──
            Text(ticket.categoryLabel,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),

            const SizedBox(height: 6),

            // ── Info row ──
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                // ATM
                _InfoChip(
                  icon: '🏧',
                  label: ticket.atm,
                ),
                // User (Telegram)
                if (ticket.hasTelegramId)
                  _InfoChip(
                    icon: '👤',
                    label: ticket.user,
                  ),
                // Phone (PWA)
                if (ticket.hasPhone)
                  GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: ticket.phone!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Номер скопирован'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Color(0xFF003087),
                        ),
                      );
                    },
                    child: _InfoChip(
                      icon: '📱',
                      label: ticket.phone!,
                      color: AppColors.gold,
                    ),
                  ),
                // Amount
                if (ticket.amount != null)
                  _InfoChip(
                    icon: '💰',
                    label: '${ticket.amount!.toStringAsFixed(0)} сум',
                    color: Colors.orange[300],
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Action buttons ──
            Row(children: [
              if (ticket.status != 'resolved') ...[
                _ActionBtn(
                  label: '✓ Решить',
                  color: AppColors.green,
                  onTap: () => prov.resolve(ticket.id),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: '⚡ В работу',
                  color: AppColors.blue,
                  onTap: () => prov.setInProgress(ticket.id),
                ),
                const SizedBox(width: 8),
              ],
              _ActionBtn(
                label: '💬 Чат',
                color: AppColors.gold,
                onTap: () {
                  prov.openChat(ticket);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()));
                },
              ),
              // Phone call button
              if (ticket.hasPhone) ...[
                const SizedBox(width: 8),
                _ActionBtn(
                  label: '📞 Звонок',
                  color: Colors.green,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: ticket.phone!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📋 ${ticket.phone} — скопировано'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: const Color(0xFF003087),
                      ),
                    );
                  },
                ),
              ],
            ]),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color? color;
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
              color: color ?? AppColors.textDim,
              fontSize: 11,
              fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
            )),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }
}
