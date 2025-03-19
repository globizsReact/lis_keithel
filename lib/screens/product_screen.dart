import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// models
import '../models/models.dart';
// provider
import '../providers/providers.dart';
// widgets
import '../widgets/widgets.dart';
// utils
import 'package:lis_keithel_v1/utils/theme.dart';

String capitalizeWords(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch categories and products again

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesStateProvider.notifier).fetchCategories();

      ref.read(productsProvider.notifier).fetchProducts();
    });
  }

  // Pull-to-refresh logic
  Future<void> _refreshData() async {
    // Fetch categories and products again
    await Future.wait([
      ref
          .read(categoriesStateProvider.notifier)
          .fetchCategories(forceFetch: true),
      ref.read(productsProvider.notifier).fetchProducts(forceFetch: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesStateProvider);
    final productsState = ref.watch(productsProvider);
    // final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);

    final cartItems = ref.watch(cartProvider);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        appBar: CustomAppBar(),
        body: Column(
          children: [
            // Filter buttons
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                ),
                child: categoriesState.isLoading
                    ? CategoryLoading()
                    : SizedBox(
                        height: 30,
                        child: ListView.builder(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          itemCount: categoriesState.categories.length,
                          itemBuilder: (context, index) {
                            final category = categoriesState.categories[index];
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: _buildCategoryButton(category),
                              ),
                            );
                          },
                        ),
                      )),

            // Product listing
            Expanded(
                child: Stack(
              children: [
                productsState.isLoading
                    ? ProductLoading()
                    : productsState.error != null
                        ? Center(child: Text('Error: ${productsState.error}'))
                        : ListView.builder(
                            padding: EdgeInsets.only(
                                left: 25.0,
                                right: 25.0,
                                top: 20,
                                bottom: cartItems.isNotEmpty ? 80 : 20),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  showQuantitySelector(context, product);
                                },
                                child: ProductCard(
                                  product: product,
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
      ),
    );
  }

  Widget _buildCategoryButton(
    Category category,
  ) {
    final isSelected = ref.watch(selectedCategoryProvider) == category.id;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).setCategory(category.id);
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
          capitalizeWords(category.name),
          style: TextStyle(
            fontSize: 18,
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
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
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
            child: CachedNetworkImage(
              imageUrl: product.photo,
              placeholder: (context, url) =>
                  Image.asset('assets/images/placeholder.png'),
              errorWidget: (context, url, error) => Icon(Icons.error),
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
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      'Rs. ${product.price}/-',
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
                  width: 27,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends ConsumerWidget {
  final Category category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // Set the selected category when tapped
        ref.read(selectedCategoryProvider.notifier).setCategory(category.name);

        // Navigate to products screen with this category selected
      },
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.network(
                    category.photo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                          child: Icon(Icons.image_not_supported));
                    },
                  ),
                ),
              ),
            ),

            // Category details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
