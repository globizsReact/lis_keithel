import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class RewardPointsScreen extends StatefulWidget {
  const RewardPointsScreen({super.key});

  @override
  State<RewardPointsScreen> createState() => _RewardPointsScreenState();
}

class _RewardPointsScreenState extends State<RewardPointsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: 'My Reward Points'),
    );
  }
}
