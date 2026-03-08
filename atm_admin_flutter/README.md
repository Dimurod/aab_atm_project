# 📱 ATM Admin — Flutter Mobile App

Мобильное приложение для операторов Asia Alliance Bank.

## Запуск

```bash
flutter pub get
flutter run
```

## Структура

```
lib/
├── main.dart                     # Точка входа, навигация
├── theme.dart                    # Цвета, шрифты, AppColors
│
├── models/
│   └── models.dart               # Ticket, AtmDevice, ChatMessage
│
├── services/
│   ├── api_service.dart          # HTTP → FastAPI бэкенд
│   ├── websocket_service.dart    # Реал-тайм события
│   └── notification_service.dart # Firebase Push + локальные уведомления
│
├── providers/
│   └── app_provider.dart         # Весь стейт (ChangeNotifier)
│
├── widgets/
│   └── widgets.dart              # StatusBadge, StatCard, SectionTitle
│
└── screens/
    ├── tickets_screen.dart       # Список заявок с фильтрами
    ├── chat_screen.dart          # Chat-перехват оператора
    ├── map_screen.dart           # Список банкоматов по статусу
    └── stats_screen.dart         # Аналитика и KPI
```

## Настройка перед запуском

1. В `lib/services/api_service.dart` замени:
   ```dart
   static const String baseUrl = 'http://YOUR_SERVER_IP:8000/api';
   ```

2. В `lib/services/websocket_service.dart`:
   ```dart
   static const String wsUrl = 'ws://YOUR_SERVER_IP:8000/ws/admin';
   ```

3. Добавь `google-services.json` (Android) и `GoogleService-Info.plist` (iOS) из Firebase Console.
