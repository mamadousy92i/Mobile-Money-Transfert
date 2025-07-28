import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';

class AppRouter {
  static GoRouter getRouter(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool isLoggedIn = authProvider.isAuthenticated;
        final bool isGoingToLogin = state.matchedLocation == '/auth';
        final bool isGoingToSplash = state.matchedLocation == '/';

        // Si l'utilisateur est sur l'écran de démarrage, ne pas rediriger
        if (isGoingToSplash) {
          return null;
        }

        // Si l'utilisateur n'est pas connecté et ne va pas vers la page de connexion,
        // rediriger vers la page de connexion
        if (!isLoggedIn && !isGoingToLogin) {
          return '/auth';
        }

        // Si l'utilisateur est connecté et va vers la page de connexion,
        // rediriger vers la page d'accueil
        if (isLoggedIn && isGoingToLogin) {
          return '/home';
        }

        // Dans tous les autres cas, ne pas rediriger
        return null;
      },
      routes: [
        // Écran de démarrage
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        
        // Écran d'authentification
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        
        // Écran d'accueil
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // Écran de profil
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Erreur: Page ${state.matchedLocation} introuvable'),
        ),
      ),
    );
  }
}
