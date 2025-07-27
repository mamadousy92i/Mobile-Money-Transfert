import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'services/app_initializer.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';

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
  late final GoRouter _router;
  final _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _authProvider.init();
    _setupRouter();
  }

  void _setupRouter() {
    _router = GoRouter(
      initialLocation: '/auth',
      redirect: (context, state) {
        final isAuthenticated = _authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/auth';

        // Si l'utilisateur n'est pas authentifié et n'est pas sur la route d'authentification,
        // rediriger vers l'authentification
        if (!isAuthenticated && !isAuthRoute) {
          return '/auth';
        }

        // Si l'utilisateur est authentifié et est sur la route d'authentification,
        // rediriger vers l'accueil
        if (isAuthenticated && isAuthRoute) {
          return '/';
        }

        // Sinon, ne pas rediriger
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
      ],
      refreshListenable: _authProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
      ],
      child: MaterialApp.router(
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
        routerConfig: _router,
      ),
    );
  }
}