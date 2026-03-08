// lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static const String wsUrl = 'ws://192.168.1.109:8000/ws/admin';

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get events => _controller.stream;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen(
        (data) {
          final event = jsonDecode(data as String) as Map<String, dynamic>;
          _controller.add(event);
        },
        onError: (e) {
          print('WS error: $e');
          _reconnect();
        },
        onDone: () {
          print('WS closed — reconnecting...');
          _reconnect();
        },
      );
    } catch (e) {
      print('WS connect error: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 3), connect);
  }

  void dispose() {
    _channel?.sink.close();
    _controller.close();
  }
}
