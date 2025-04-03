import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/config.dart';
import '../models/models.dart';
import '../services/reward_service.dart';

final rewardServiceProvider = Provider<RewardService>((ref) {
  return RewardService(baseUrl: Config.baseUrl);
});

final rewardProvider = FutureProvider<RewardModel>((ref) async {
  final rewardService = ref.watch(rewardServiceProvider);
  return await rewardService.fetchRewards();
});
