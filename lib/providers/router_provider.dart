import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel_v1/utils/go_router_refresh_stream.dart';
import 'package:lis_keithel_v1/providers/auth_provider.dart';
// Import your screen files here
import '../screens/screens.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref, authProvider),
    redirect: (context, state) {
      // Access the login state using Riverpod
      final authState = ref.read(authProvider);

      // Debug print to verify state changes
      print('GoRouter redirect: isLoggedIn = ${authState.isLoggedIn}');

      // Check if the current route is a protected route
      final isProtectedRoute =
          ['/order', '/account'].contains(state.matchedLocation);

      // If the user is not logged in and tries to access a protected route, redirect to login
      if (!authState.isLoggedIn && isProtectedRoute) {
        return '/login';
      }

      // If user is logged in and on login screen, redirect to home
      if (authState.isLoggedIn && state.matchedLocation == '/login') {
        return '/';
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
});
