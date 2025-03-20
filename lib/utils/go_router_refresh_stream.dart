import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel_v1/providers/auth_provider.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  final Ref _ref;
  final StateNotifierProvider<AuthNotifier, AuthState> _provider;
  late final ProviderSubscription<AuthState> _subscription;

  GoRouterRefreshStream(this._ref, this._provider) {
    _subscription = _ref.listen(_provider, (_, __) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
