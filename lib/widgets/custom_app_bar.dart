import 'package:flutter/material.dart';
import 'package:lis_keithel_v1/utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int notificationCount;

  const CustomAppBar({
    Key? key,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppBar(
        backgroundColor: AppTheme.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Logo on the left side
            Image.asset(
              'assets/images/logo.png',
              width: 95,
            ),
          ],
        ),
        actions: [
          // Notification bell with badge on the right side
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/icons/bell.png',
                    width: 18,
                  ),
                  onPressed: () {},
                ),
                if (notificationCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        notificationCount > 9
                            ? '9+'
                            : notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
