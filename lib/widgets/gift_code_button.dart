import 'package:flutter/material.dart';

class GiftCodeField extends StatelessWidget {
  const GiftCodeField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(13.0),
      ),
      child: Row(
        children: [
          // Text field takes most of the space
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                hintText: 'Enter gift card code here (if)',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ),

          // Divider line
          Container(
            width: 1.0,
            height: 30.0,
            color: Colors.grey.shade300,
          ),

          // Apply button
          TextButton(
            onPressed: () {
              // Add your apply code logic here
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              minimumSize: const Size(80, 48),
              foregroundColor: Colors.orange,
            ),
            child: const Text(
              'Apply',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
