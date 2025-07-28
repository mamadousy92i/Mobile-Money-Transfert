import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_initializer.dart';
import 'providers/auth_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services
  await AppInitializer.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _authProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.getRouter(context);
          
          return MaterialApp.router(
            title: 'MoneyTransfer',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2563EB),
                primary: const Color(0xFF2563EB),
                secondary: const Color(0xFF10B981),
              ),
              useMaterial3: true,
              fontFamily: 'Poppins',
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}