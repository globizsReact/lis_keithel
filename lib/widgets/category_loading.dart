import 'package:flutter/material.dart';
import '../utils/responsive_sizing.dart';
import 'package:shimmer/shimmer.dart';

class CategoryLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<double> itemWidths = [
      45,
      78,
      60,
      70,
      100,
      120,
      90,
      80,
      110,
      130,
    ];

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return SizedBox(
      height: responsive.height(0.032),
      child: ListView.builder(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: itemWidths.length,
        itemBuilder: (context, index) {
          double itemWidth = itemWidths[index];

          return Padding(
            padding: EdgeInsets.only(right: responsive.padding(11)),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: itemWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
