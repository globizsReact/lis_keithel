import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class CouponsScreen extends ConsumerWidget {
  void _copyToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copied: $code")),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Available Coupons")),
      body: couponsAsync.when(
        data: (couponResponse) {
          if (couponResponse.type == 'success') {
            // Success case: Display the list of coupons
            return ListView.builder(
              itemCount: couponResponse.coupons!.length,
              itemBuilder: (context, index) {
                final coupon = couponResponse.coupons![index];
                return ListTile(
                  title: Text(coupon.code),
                  subtitle: Text("Discount: ${coupon.discount}%"),
                  trailing: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(context, coupon.code),
                  ),
                );
              },
            );
          } else {
            // Failure case: Display the error message
            return Center(
              child: Text(
                couponResponse.errorMessage ?? "Unknown Error",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
    );
  }
}
