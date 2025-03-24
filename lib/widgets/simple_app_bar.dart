import 'package:flutter/material.dart';
import 'package:lis_keithel_v1/utils/theme.dart';

class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;

  const SimpleAppBar({
    Key? key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.iconColor = AppTheme.orange,
    this.onBackPressed,
    this.actions,
    this.leading,
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: AppBar(
        title: Text(
          title,
        ),
        titleSpacing: 0,
        backgroundColor: backgroundColor,
        leading: leading ??
            (Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ), // Modified back button icon
                    color: iconColor,
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  )
                : null),
        actions: actions,
        iconTheme: IconThemeData(color: iconColor),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
