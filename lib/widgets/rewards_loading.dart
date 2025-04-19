import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RewardsLoading extends StatelessWidget {
  const RewardsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> itemWidths = [
      70,
      60,
      120,
      70,
    ];

    return Column(
      children: [
        SizedBox(
          height: 35,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ListView.builder(
              itemCount: itemWidths.length, // Number of shimmer items
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                double itemWidth = itemWidths[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      // Height of the container
                      width: itemWidth,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 8, // Number of shimmer items
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 100, // Height of the container
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
