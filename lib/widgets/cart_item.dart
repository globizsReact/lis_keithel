import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lis_keithel/providers/cart_provider.dart';
import 'package:lis_keithel/utils/responsive_sizing.dart';
import 'package:lis_keithel/utils/theme.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

// Calculate the total amount based on product type
    String totalAmountText = '';
    if (cartItem.product.productTypeId == '2') {
      // Weight-based product (type 2): Use quantityKg for calculation
      totalAmountText =
          'Rs. ${(cartItem.product.price * cartItem.quantityKg).toStringAsFixed(2)}';
    } else {
      // Count-based product: Use quantityPcs for calculation
      totalAmountText =
          'Rs. ${(cartItem.product.price * cartItem.quantityPcs).toStringAsFixed(2)}';
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive.padding(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cartItem.product.photo == null
                ? Image.asset(
                    'assets/images/placeholder.png',
                    width: responsive.width(0.25),
                    height: responsive.height(0.11),
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: cartItem.product.photo!,
                    width: responsive.width(0.25),
                    height: responsive.height(0.11),
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Image.asset('assets/images/placeholder.png'),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
          ),
          SizedBox(width: responsive.width(0.04)),
          // Product details
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cartItem.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.black,
                            fontSize: responsive.textSize(15),
                          ),
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          child: Image.asset(
                            'assets/icons/trash.png',
                            width: responsive.width(0.04),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${cartItem.product.price}/${cartItem.product.uomCode}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.textSize(11),
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.height(0.02)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalAmountText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Decrement button
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onPressed: () {
                            if (cartItem.quantityPcs > 1) {
                              onQuantityChanged(cartItem.quantityPcs - 1);
                            }
                          },
                        ),
                        // Quantity
                        Container(
                          width: responsive.width(0.1),
                          alignment: Alignment.center,
                          child: Text(
                            '${cartItem.quantityPcs}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Increment button
                        _buildQuantityButton(
                          icon: Icons.add,
                          onPressed: () {
                            onQuantityChanged(cartItem.quantityPcs + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.orange),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
        ),
      ),
    );
  }
}
