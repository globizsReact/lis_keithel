import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  static void show({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 14.0,
    ToastGravity gravity = ToastGravity.CENTER,
    Duration duration = const Duration(seconds: 2),
  }) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toastWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor),
            const SizedBox(width: 12.0),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toastWidget,
      gravity: gravity,
      toastDuration: duration,
    );
  }
}
