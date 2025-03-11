import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<double> itemWidths = [
      45,
      90,
      80,
      90,
      70,
      120,
      90,
      80,
      110,
      130,
    ];

    return SizedBox(
      height: 30,
      child: ListView.builder(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: itemWidths.length,
        itemBuilder: (context, index) {
          double itemWidth = itemWidths[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: itemWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
