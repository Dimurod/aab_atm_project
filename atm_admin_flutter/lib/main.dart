// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'providers/app_provider.dart';
import 'screens/tickets_screen.dart';
import 'screens/map_screen.dart';
import 'screens/map_screen.dart' show StatsScreen;
import 'screens/monitoring_screen.dart';

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
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

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
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
