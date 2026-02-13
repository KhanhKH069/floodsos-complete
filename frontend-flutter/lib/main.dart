// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/sos_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/location_provider.dart';
import 'providers/voice_provider.dart';
import 'services/socket_service.dart';
import 'services/firebase_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await FirebaseService.initialize();
    } catch (_) {}
  }
  try {
    SocketService().connect();
  } catch (_) {}

  runApp(const FloodSOSApp());
}

class FloodSOSApp extends StatelessWidget {
  const FloodSOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SOSProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1E2129),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          textTheme:
              const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white10,
            labelStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIconColor: Colors.white70,
          ),
        ),
        themeMode: ThemeMode.dark,
        // 🟢 THAY ĐỔI QUAN TRỌNG: Vào thẳng màn hình gửi SOS luôn
        home: const HomeScreen(),
      ),
    );
  }
}
// Đã xóa class RoleSelectionScreen vì không dùng nữa
