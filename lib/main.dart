import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel_v1/screens/screens.dart';
import 'package:lis_keithel_v1/utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
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
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
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
