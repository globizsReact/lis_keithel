import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/go_router_refresh_stream.dart';
import '../providers/auth_provider.dart';
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
        builder: (context, state) => const OrderScreen(),
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
      GoRoute(
        path: '/reward-points',
        builder: (context, state) => const RewardPointsScreen(),
      ),
      GoRoute(
        path: '/update-address',
        builder: (context, state) => const UpdateAddressScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      // GoRoute(
      //   path: '/new-password',
      //   builder: (context, state) {
      //     final Map<String, dynamic> extras =
      //         state.extra as Map<String, dynamic>;
      //     return NewPasswordScreen(
      //       phoneNumber: extras['phoneNumber'] as String,
      //     );
      //   },
      // ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      // Order details as a separate route (not nested)
      GoRoute(
        path: '/order-details/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final Map<String, dynamic> extras =
              state.extra as Map<String, dynamic>;

          return OtpVerificationScreen(
            type: extras['type'] as OtpScreenType,
            phoneNumber: extras['phoneNumber'] as String,
            onVerificationSuccess: (otp, context) {
              if (extras['type'] == OtpScreenType.registration) {
                // Handle registration OTP verification
                print('Registration OTP verified: $otp');
                GoRouter.of(context).go('/');
              } else {
                // Handle password change OTP verification
                print('Password change OTP verified: $otp');
                GoRouter.of(context).go('/', extra: {
                  'phoneNumber': extras['phoneNumber'],
                });
              }
            },
            onResendOtp: () {
              // Call your API to resend OTP
              print('Resending OTP');
            },
          );
        },
      ),
    ],
  );
});
