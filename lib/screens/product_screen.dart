import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/responsive_sizing.dart';

// models
import '../models/models.dart';
// provider
import '../providers/providers.dart';
// widgets
import '../widgets/widgets.dart';
// utils
import '../utils/theme.dart';

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

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        appBar: CustomAppBar(),
        body: Column(
          children: [
            // Filter buttons
            SizedBox(
              height: responsive.height(0.01),
            ),
            Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.padding(23),
                ),
                child: categoriesState.isLoading
                    ? CategoryLoading()
                    : SizedBox(
                        height: responsive.height(0.032),
                        child: ListView.builder(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          itemCount: categoriesState.categories.length,
                          itemBuilder: (context, index) {
                            final category = categoriesState.categories[index];
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: responsive.padding(14.0)),
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
                                left: responsive.padding(23),
                                right: responsive.padding(23),
                                top: responsive.padding(18),
                                bottom: cartItems.isNotEmpty
                                    ? responsive.padding(75)
                                    : responsive.padding(18)),
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
                    bottom: responsive.position(0.05),
                    left: responsive.position(0.04),
                    right: responsive.position(0.04),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedIndexProvider.notifier).state = 1;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: responsive.padding(15),
                            vertical: responsive.padding(19)),
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
                                SizedBox(width: responsive.width(0.02)),
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

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).setCategory(category.id);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: responsive.padding(17),
            vertical: responsive.padding(6)),
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
            fontSize: responsive.textSize(17),
            color: isSelected ? AppTheme.orange : AppTheme.grey,
            fontWeight: FontWeight.w600,
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
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Container(
      margin: EdgeInsets.only(bottom: responsive.padding(15)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 5.0,
            offset: const Offset(0, 5),
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
              height: responsive.height(0.178),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: responsive.padding(19),
                vertical: responsive.padding(5.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: responsive.textSize(15),
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      'Rs. ${product.price}/-',
                      style: TextStyle(
                        fontSize: responsive.textSize(11),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.orange,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/icons/cartAdd.png',
                  width: responsive.width(0.07),
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
