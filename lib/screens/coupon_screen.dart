import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/providers.dart';

class CouponsScreen extends ConsumerWidget {
  void _copyToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsProvider);

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'Coupons'),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger a refresh by invalidating the provider
          await ref.refresh(couponsProvider);
        },
        child: couponsAsync.when(
          data: (couponResponse) {
            if (couponResponse.type == 'success') {
              // Success case: Display the list of coupons
              return ListView.builder(
                itemCount: couponResponse.coupons!.length,
                itemBuilder: (context, index) {
                  final coupon = couponResponse.coupons![index];
                  return Container(
                    margin: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 10,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppTheme.lightOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.asset(
                            'assets/icons/coup.png',
                            width: 60,
                          ),
                        ),
                        SizedBox(width: 10),
                        VerticalDottedLine(),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    SizedBox(height: 12),
                                    Text('₹'),
                                  ],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${coupon.discount}',
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: AppTheme.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Column(
                                  children: [
                                    SizedBox(height: 12),
                                    Text('OFF'),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'CODE: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  coupon.code,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => _copyToClipboard(
                            context,
                            coupon.code,
                          ),
                          child: Image.asset(
                            'assets/icons/copy.png',
                            width: 25,
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            } else {
              // Failure case: Display the error message
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/coupons.png',
                      width: responsive.width(0.2),
                    ),
                    SizedBox(height: responsive.height(0.02)),
                    Text(
                      couponResponse.errorMessage ?? "Unknown Error",
                      style: TextStyle(
                        fontSize: responsive.textSize(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: responsive.height(0.025),
                    ),
                  ],
                ),
              );
            }
          },
          loading: () => CouponShimmer(),
          error: (error, stack) => Center(
            child: Text("Error: $error"),
          ),
        ),
      ),
    );
  }
}

class CouponShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10, // Simulate 5 loading items
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: 24, right: 24, bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 15,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                VerticalDottedLine(),
                SizedBox(width: 8),
                Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 15),
                        Text('₹', style: TextStyle(color: Colors.transparent)),
                      ],
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 80,
                      height: 35,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Column(
                      children: [
                        SizedBox(height: 15),
                        Text('OFF',
                            style: TextStyle(color: Colors.transparent)),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  width: 25,
                  height: 25,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
