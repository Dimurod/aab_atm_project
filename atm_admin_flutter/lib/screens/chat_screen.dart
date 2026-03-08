// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _ctrl.clear();
    await context.read<AppProvider>().sendMessage(text);
    setState(() => _sending = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<AppProvider>();
    final ticket = prov.activeChat;
    final msgs   = ticket != null ? (prov.chats[ticket.id] ?? []) : <ChatMessage>[];

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          prov.closeChat();
          Navigator.pop(context);
        }),
        title: ticket == null
            ? const Text('Чат')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    if (ticket.escalated && ticket.status != 'resolved')
                      const Text('🔴 ', style: TextStyle(fontSize: 14)),
                    Text(ticket.no,
                      style: const TextStyle(color: AppColors.gold, fontSize: 15)),
                    const SizedBox(width: 8),
                    StatusBadge(
                      text:  ticket.statusLabel,
                      color: AppColors.ticketStatusColor(ticket.status),
                    ),
                  ]),
                  Text('👤 ${ticket.user}  ·  🏧 ${ticket.atm}',
                    style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
                ],
              ),
        backgroundColor: ticket?.escalated == true && ticket?.status != 'resolved'
            ? AppColors.red.withOpacity(0.1)
            : AppColors.navyMid,
        actions: [
          if (ticket != null && ticket.status != 'resolved')
            TextButton(
              onPressed: () {
                prov.resolve(ticket.id);
                Navigator.pop(context);
              },
              child: const Text('✓ Решить',
                style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Column(children: [
        // ── Messages ──
        Expanded(
          child: msgs.isEmpty
              ? const Center(
                  child: Text('История чата пуста',
                    style: TextStyle(color: AppColors.textDim)))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) => _MessageBubble(msg: msgs[i]),
                ),
        ),

        // ── Input ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
            color: AppColors.navyMid,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onSubmitted: (_) => _send(),
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Написать клиенту...',
                  hintStyle: const TextStyle(color: AppColors.textDim),
                  filled: true,
                  fillColor: AppColors.navyLt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color:        AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.navy,
                        ))
                    : const Icon(Icons.send_rounded, color: AppColors.navy, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}


class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    if (msg.isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color:        AppColors.gold.withOpacity(0.1),
            border:       Border.all(color: AppColors.gold.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(msg.text,
            style: const TextStyle(
              color: AppColors.gold, fontSize: 11, fontStyle: FontStyle.italic,
            )),
        ),
      );
    }

    final isLeft = msg.isClient;
    final bgColor = msg.isClient
        ? AppColors.navyLt
        : msg.isOperator
            ? AppColors.gold.withOpacity(0.15)
            : AppColors.blue.withOpacity(0.15);
    final borderColor = msg.isClient
        ? AppColors.border
        : msg.isOperator
            ? AppColors.gold.withOpacity(0.4)
            : AppColors.blue.withOpacity(0.4);

    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left:  isLeft ? 0 : 50,
          right: isLeft ? 50 : 0,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:  bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(12),
            topRight:    const Radius.circular(12),
            bottomLeft:  Radius.circular(isLeft ? 2 : 12),
            bottomRight: Radius.circular(isLeft ? 12 : 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.isClient   ? '👤 Клиент'
              : msg.isOperator ? '👨‍💼 Оператор'
              : '🤖 Бот',
              style: const TextStyle(color: AppColors.textDim, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(msg.text,
              style: const TextStyle(color: AppColors.text, fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
