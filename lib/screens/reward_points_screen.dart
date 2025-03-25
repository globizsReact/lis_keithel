import 'package:flutter/material.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class RewardPointsScreen extends StatefulWidget {
  const RewardPointsScreen({super.key});

  @override
  State<RewardPointsScreen> createState() => _RewardPointsScreenState();
}

class _RewardPointsScreenState extends State<RewardPointsScreen> {
  final List<String> _tabOptions = ['Active', 'Used', 'Expired'];
  int _currentTabIndex = 0;

  // Sample reward point data
  final List<Map<String, dynamic>> _activePoints = [
    {
      'order': '#8594',
      'points': 25,
      'expiry': DateTime(2025, 3, 26),
    },
    {
      'order': '#8595',
      'points': 50,
      'expiry': DateTime(2025, 4, 15),
    },
    {
      'order': '#8596',
      'points': 75,
      'expiry': DateTime(2025, 5, 10),
    }
  ];

  final List<Map<String, dynamic>> _usedPoints = [];
  final List<Map<String, dynamic>> _expiredPoints = [];
  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'My Reward Points'),
      body: Column(
        children: [
          // Tab Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.padding(23),
            ),
            child: Row(
              children: _tabOptions.map((tab) {
                int index = _tabOptions.indexOf(tab);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: responsive.padding(12)),
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
                              : AppTheme.grey,
                          fontWeight: FontWeight.bold,
                        ),
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
              padding: EdgeInsets.symmetric(
                  vertical: responsive.padding(16),
                  horizontal: responsive.padding(23)),
              child: _buildPointsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsList() {
    List<Map<String, dynamic>> currentPoints;
    switch (_currentTabIndex) {
      case 0:
        currentPoints = _activePoints;
        break;
      case 1:
        currentPoints = _usedPoints;
        break;
      case 2:
        currentPoints = _expiredPoints;
        break;
      default:
        currentPoints = [];
    }

    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    // Empty State
    if (currentPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/noReward.png',
              width: responsive.width(0.25),
              gaplessPlayback: true,
            ),
            SizedBox(height: responsive.height(0.02)),
            Text(
              'No ${_tabOptions[_currentTabIndex]} Points',
              style: TextStyle(
                fontSize: responsive.textSize(14),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.height(0.05)),
          ],
        ),
      );
    }

    // Points List
    return ListView.builder(
      itemCount: currentPoints.length,
      itemBuilder: (context, index) {
        var point = currentPoints[index];
        return Container(
          margin: EdgeInsets.only(bottom: responsive.padding(12)),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(
              'Order ${point['order']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: responsive.textSize(16),
              ),
            ),
            subtitle: Text(
              'Expiry: ${point['expiry'].day}th ${_getMonthName(point['expiry'].month)} ${point['expiry'].year}',
              style: TextStyle(
                fontSize: responsive.textSize(13),
                fontWeight: FontWeight.w600,
                color: AppTheme.grey,
              ),
            ),
            trailing: Text(
              '${point['points']} pts',
              style: TextStyle(
                color: AppTheme.orange,
                fontSize: responsive.textSize(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
