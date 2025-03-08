import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lis_keithel_v1/providers/cart_provider.dart';
import 'package:lis_keithel_v1/providers/category_provider.dart';
import 'package:lis_keithel_v1/providers/product_provider.dart';
import 'package:lis_keithel_v1/providers/selected_index_provider.dart';
import 'package:lis_keithel_v1/utils/theme.dart';
import 'package:lis_keithel_v1/widgets/custom_app_bar.dart';
import 'package:lis_keithel_v1/widgets/quantity_selector.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() => ref.read(productsProvider.notifier).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);

    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Filter buttons
          SizedBox(
            height: 10,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: _buildCategoryButton(category),
                  );
                }).toList(),
              ),
            ),
          ),

          // Product listing
          Expanded(
              child: Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                    top: 18,
                    bottom: cartItems.isNotEmpty ? 80 : 20),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return GestureDetector(
                    onTap: () {
                      showQuantitySelector(context, product);
                    },
                    child: ProductCard(
                      name: product.name,
                      price: product.price.toString(),
                      imagePath: product.imageUrl,
                    ),
                  );
                },
              ),

              // Bottom checkout bar
              if (cartItems.isNotEmpty)
                Positioned(
                  bottom: 16.0, // Distance from the bottom
                  left: 16.0, // Distance from the left
                  right: 16.0,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedIndexProvider.notifier).state = 1;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB25800),
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(100),
                            blurRadius: 8.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Proceed',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${cartItems.length} Items',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = ref.watch(selectedCategoryProvider) == category;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).setCategory(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightOrange : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.orange : AppTheme.grey,
            width: isSelected ? 1.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? AppTheme.orange : AppTheme.grey,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Product card widget
class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;

  const ProductCard({
    Key? key,
    required this.name,
    required this.price,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: Image.asset(
              imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      'Rs. $price/-',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.orange,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/icons/cartAdd.png',
                  width: 35,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
