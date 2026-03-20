// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'providers/app_provider.dart';
import 'screens/tickets_screen.dart';
import 'screens/map_screen.dart';
import 'screens/map_screen.dart' show StatsScreen;
import 'screens/monitoring_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'AAB ATM Admin',
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/login': (_) => const LoginScreen(),
        },
      ),
    );
  }
}

// ── Проверяем авторизацию при запуске ────────────────────────────
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final loggedIn = await ApiService.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A1628),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFC8A951)),
      ),
    );
  }
}

// ── Главный экран ─────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _screens = const [
    TicketsScreen(),
    MonitoringScreen(),
    MapScreen(),
    StatsScreen(),
  ];

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final badgeCount = prov.escalatedCount + prov.openCount;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC8A951), Color(0xFFE8C96A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('A',
                  style: TextStyle(
                    color: Color(0xFF0A1628),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  )),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Asia Alliance Bank'),
        ]),
        actions: [
          // Live индикатор
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF2ECC8B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Live',
                  style: TextStyle(color: Color(0xFF7A8BA8), fontSize: 12)),
            ]),
          ),
          // Кнопка выхода
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Выйти',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF132040),
                  title: const Text('Выход',
                      style: TextStyle(color: Colors.white)),
                  content: const Text('Вы уверены что хотите выйти?',
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена',
                          style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text('Выйти',
                          style: TextStyle(color: Color(0xFFC8A951))),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: badgeCount > 0,
              label: Text('$badgeCount'),
              child: const Icon(Icons.list_alt_rounded),
            ),
            label: 'Заявки',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Мониторинг',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Карта',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Статистика',
          ),
        ],
      ),
    );
  }
}
