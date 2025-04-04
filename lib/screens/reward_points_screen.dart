import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel/utils/responsive_sizing.dart';
import 'package:lis_keithel/utils/theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class RewardsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardAsyncValue = ref.watch(rewardProvider);

    return Scaffold(
      appBar: SimpleAppBar(title: 'Reward Points'),
      body: rewardAsyncValue.when(
        loading: () => RewardsLoading(),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (rewardModel) {
          return _TabbedRewardsView(
            active: rewardModel.active,
            used: rewardModel.used,
            transferred: rewardModel.transferred,
            expired: rewardModel.expired,
          );
        },
      ),
    );
  }
}

class _TabbedRewardsView extends StatefulWidget {
  final List<RewardItem> active;

  final List<RewardItem> used;
  final List<RewardItem> transferred;
  final List<RewardItem> expired;

  const _TabbedRewardsView({
    required this.active,
    required this.used,
    required this.transferred,
    required this.expired,
  });

  @override
  State<_TabbedRewardsView> createState() => _TabbedRewardsViewState();
}

class _TabbedRewardsViewState extends State<_TabbedRewardsView> {
  final List<String> _tabOptions = ['Active', 'Used', 'Transferred', 'Expired'];
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: _tabOptions.map((tab) {
              int index = _tabOptions.indexOf(tab);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = index;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _currentTabIndex == index
                        ? AppTheme.orange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _currentTabIndex == index
                          ? Colors.white
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Points List or Empty State
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildRewardsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsList() {
    List<RewardItem> currentRewards;
    switch (_currentTabIndex) {
      case 0:
        currentRewards = widget.active;
        break;
      case 1:
        currentRewards = widget.used;
        break;
      case 2:
        currentRewards = widget.transferred;
        break;
      case 3:
        currentRewards = widget.expired;
        break;
      default:
        currentRewards = [];
    }

    // Empty State
    if (currentRewards.isEmpty) {
      // Initialize responsive sizing
      ResponsiveSizing().init(context);
      final responsive = ResponsiveSizing();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/noReward.png',
              width: responsive.width(0.2),
            ),
            SizedBox(height: responsive.height(0.02)),
            Text(
              'No ${_tabOptions[_currentTabIndex]} Rewards',
              style: TextStyle(
                fontSize: responsive.textSize(12),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.height(0.025)),
          ],
        ),
      );
    }

    // Rewards List
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: currentRewards.length,
      itemBuilder: (context, index) {
        var reward = currentRewards[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12, left: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(
              '#${reward.salesOrderId}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Expires: ${reward.expireDate}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            trailing: Text(
              '${reward.point} Pts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.orange,
              ),
            ),
          ),
        );
      },
    );
  }
}
