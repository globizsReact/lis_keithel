import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

// router
final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Access the login state using Riverpod
    final authState = ProviderScope.containerOf(context).read(authProvider);

    // Check if the current route is a protected route
    final isProtectedRoute =
        ['/order', '/account'].contains(state.matchedLocation);

    // If the user is not logged in and tries to access a protected route, redirect to login
    if (!authState.isLoggedIn && isProtectedRoute) {
      return '/login';
    }

    // No redirection needed
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/order',
      builder: (context, state) => const OrderSCreen(),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const MultiRegisterScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LIS Keithel',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.themeData,
    );
  }
}
