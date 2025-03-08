import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage the selected index
final selectedIndexProvider = StateProvider<int>((ref) => 0);
