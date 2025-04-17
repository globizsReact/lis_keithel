import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import '../providers/cart_provider.dart';

class QuantitySelector extends ConsumerStatefulWidget {
  final Product product;

  const QuantitySelector({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  ConsumerState<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends ConsumerState<QuantitySelector> {
  // State variables for kg and pcs
  double quantityKg = 1.0;
  int quantityPcs = 1;

  // Controllers for input fields
  late TextEditingController _kgController;
  late TextEditingController _pcsController;
  late TextEditingController _quantityController;

  // Initialize responsive sizing
  late ResponsiveSizing responsive;

  @override
  void initState() {
    super.initState();

    _kgController = TextEditingController(text: quantityKg.toString());
    _pcsController = TextEditingController(text: quantityPcs.toString());
    _quantityController = TextEditingController(text: quantityPcs.toString());
    // Pre-calculate initial values if needed
    // if (widget.product.productTypeId == '2') {
    //   quantityPcs = (quantityKg / widget.product.weightPerPcs).round();
    // }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _kgController.dispose();
    _pcsController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    responsive = ResponsiveSizing()..init(context);

    return Container(
      padding: const EdgeInsets.only(right: 30, left: 30, top: 25, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add to cart',
                style: const TextStyle(
                  fontSize: 21,
                  color: AppTheme.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppTheme.red,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: AppTheme.lightOrange,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Hero(
                    tag: 'productImage_${widget.product.id}',
                    child: widget.product.photo == null
                        ? Image.asset(
                            'assets/images/placeholder.png',
                            width: 70,
                            height: 75,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.product.photo!,
                            width: 70,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Rs. ${widget.product.price}/${widget.product.uomCode == null ? '-' : '${widget.product.uomCode}'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Conditional rendering for quantity input fields
          if (widget.product.productTypeId == '2')
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity (kg)',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: responsive.width(0.3),
                          child: TextField(
                            controller: _kgController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: AppTheme.black,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (value) {
                              setState(() {
                                // Parse the input value
                                quantityKg = double.tryParse(value) ?? 0.0;

                                // Update pcs based on kg
                                quantityPcs =
                                    (quantityKg / widget.product.weightPerPcs)
                                        .round();

                                // Update the pcs controller
                                _pcsController.text = quantityPcs.toString();
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              hintText: 'Enter kg',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: responsive.height(0.04),
                        ),
                        Image.asset(
                          'assets/icons/convert.png',
                          width: responsive.width(0.045),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Quantity (pcs)',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: responsive.width(0.3),
                          child: TextField(
                            controller: _pcsController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: AppTheme.black,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (value) {
                              setState(() {
                                // Parse the input value
                                quantityPcs = int.tryParse(value) ?? 0;

                                // Update kg based on pcs
                                quantityKg =
                                    (quantityPcs * widget.product.weightPerPcs);

                                // Update the kg controller
                                _kgController.text =
                                    quantityKg.toStringAsFixed(2);
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter pcs',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    // border: Border.all(color: AppTheme.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus button
                      _buildQuantityButton(
                        onPressed: () {
                          setState(() {
                            if (quantityPcs > 1) {
                              quantityPcs--; // Decrement quantity
                              _quantityController.text = quantityPcs.toString();
                            }
                          });
                        },
                        icon: Icons.remove,
                        isEnabled: quantityPcs > 1,
                      ),

                      // Quantity display with TextField
                      Container(
                        width: 80,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            color: AppTheme.black,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (value) {
                            // Parse the input value and update state
                            int? newQuantity = int.tryParse(value);
                            if (newQuantity != null && newQuantity > 0) {
                              setState(() {
                                quantityPcs = newQuantity;
                              });
                            } else if (value.isEmpty) {
                              // Allow empty field during typing
                            } else {
                              // Reset to valid value if input is invalid
                              _quantityController.text = quantityPcs.toString();
                            }
                          },
                          onSubmitted: (value) {
                            // Ensure a minimum value of 1
                            int? newQuantity = int.tryParse(value);
                            if (newQuantity == null || newQuantity < 1) {
                              setState(() {
                                quantityPcs = 1;
                                _quantityController.text = '1';
                              });
                            }
                          },
                        ),
                      ),

                      // Plus button
                      _buildQuantityButton(
                        onPressed: () {
                          setState(() {
                            quantityPcs++; // Increment quantity
                            _quantityController.text = quantityPcs.toString();
                          });
                        },
                        icon: Icons.add,
                        isEnabled: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Add to cart button
          SizedBox(
            width: double.infinity,
            height: responsive.height(0.07),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
              ),
              onPressed: () {
                // Validate input before adding to cart
                if (widget.product.productTypeId == '2') {
                  // For type 2 products
                  if (quantityKg <= 0 || quantityPcs <= 0) {
                    _showInvalidQuantityToast(context);
                    return;
                  }

                  ref.read(cartProvider.notifier).addItem(
                        widget.product,
                        quantityPcs,
                        quantityKg: quantityKg,
                      );
                } else {
                  // For other products
                  if (quantityPcs <= 0) {
                    _showInvalidQuantityToast(context);
                    return;
                  }

                  ref.read(cartProvider.notifier).addItem(
                        widget.product,
                        quantityPcs,
                      );
                }

                // Close bottom sheet and show confirmation
                Navigator.pop(context);

                CustomToast.show(
                  context: context,
                  message: 'Added to cart',
                  icon: Icons.check,
                  backgroundColor: AppTheme.green,
                  textColor: Colors.white,
                  fontSize: 16.0,
                  gravity: ToastGravity.CENTER,
                  duration: Duration(seconds: 3),
                );
              },
              child: Text(
                widget.product.productTypeId == '2'
                    ? 'Add to Cart  Rs.${(widget.product.price * quantityKg).toStringAsFixed(2)}/-'
                    : 'Add to Cart  Rs.${(widget.product.price * quantityPcs).toStringAsFixed(2)}/-',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Add padding for bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _showInvalidQuantityToast(BuildContext context) {
    CustomToast.show(
      context: context,
      message: 'Please enter a valid quantity',
      icon: Icons.error,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
      gravity: ToastGravity.CENTER,
      duration: Duration(seconds: 2),
    );
  }

  Widget _buildQuantityButton({
    required VoidCallback onPressed,
    required IconData icon,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: 50,
        height: 47,
        decoration: BoxDecoration(),
        child: Icon(
          icon,
          color: isEnabled ? AppTheme.orange : Colors.grey,
        ),
      ),
    );
  }
}

// Helper method to show the quantity selector bottom sheet
Future<void> showQuantitySelector(BuildContext context, Product product) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: QuantitySelector(product: product),
    ),
  );
}
