import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:lis_keithel/providers/auth_provider.dart';
import 'package:lis_keithel/utils/config.dart';
import 'package:lis_keithel/utils/responsive_sizing.dart';
import 'package:lis_keithel/utils/theme.dart';
import 'package:lis_keithel/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool isLoading = false;
  List<NotificationModel> notifications = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

// api call
  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = '${Config.baseUrl}/notifications/message';

    try {
      // Access SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Retrieve the token from SharedPreferences
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      // Replace with your actual API endpoint
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notifications =
              data.map((item) => NotificationModel.fromJson(item)).toList();
          notifications.sort((a, b) => b.createdDate.compareTo(a.createdDate));
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load notifications: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: 'Notifications'),
      body: RefreshIndicator(
        onRefresh: fetchNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    // Access the login state using Riverpod
    final authState = ref.read(authProvider);

    if (!authState.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/login.png',
              width: responsive.width(0.2),
            ),
            SizedBox(height: responsive.height(0.02)),
            Text(
              'Please log in to view your notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.textSize(12),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.height(0.02)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.padding(23),
                  vertical: responsive.padding(11),
                ),
              ),
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return NotificationLoading();
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.padding(23),
                  vertical: responsive.padding(11),
                ),
              ),
              onPressed: fetchNotifications,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/notification.png',
              width: 90,
            ),
            const SizedBox(height: 10),
            const Text(
              'No notificatons',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(notification: notification);
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Color.fromRGBO(128, 128, 128, 0.2),
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.photo.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.network(
                    notification.photo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.message.isNotEmpty)
                    Text(
                      capitalizeFirstWord(notification.message),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    const Text(
                      'No message',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Text(
              getRelativeTime(notification.createdDate),
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.orange,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'y' : 'y'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mo' : 'mo'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'd' : 'd'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'h' : 'h'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'm' : 'm'} ago';
    } else {
      return 'Just now';
    }
  }

  String capitalizeFirstWord(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    // Split the string into words
    final words = text.split(' ');

    // Capitalize the first word
    if (words.isNotEmpty) {
      words[0] = words[0][0].toUpperCase() + words[0].substring(1);
    }

    // Join the words back together
    return words.join(' ');
  }
}

class NotificationModel {
  final int id;
  final String message;
  final DateTime createdDate;
  final String photo;

  NotificationModel({
    required this.id,
    required this.message,
    required this.createdDate,
    required this.photo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      createdDate: DateTime.parse(json['created_date']),
      photo: json['photo'] ?? '',
    );
  }
}
