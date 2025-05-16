// lib/screens/ledger_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lis_keithel/screens/product_screen.dart';
import 'package:lis_keithel/utils/responsive_sizing.dart';
import 'package:lis_keithel/utils/theme.dart';
import 'package:lis_keithel/widgets/simple_app_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../models/models.dart';
import '../providers/ledger_provider.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectFirstProduct();
    });
  }

  void _selectFirstProduct() {
    final productsAsyncValue = ref.read(productsProvider);
    productsAsyncValue.whenData((products) {
      if (products.isNotEmpty && ref.read(selectedProductIdProvider) == null) {
        Future(() {
          ref.read(selectedProductIdProvider.notifier).state =
              products.first.productId;
          ref.read(currentPageProvider.notifier).state = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: SimpleAppBar(title: 'My Ledgers'),
      body: Consumer(
        builder: (context, ref, child) {
          final productsAsyncValue = ref.watch(productsProvider);
          final selectedProductId = ref.watch(selectedProductIdProvider);

          // Check if products list is empty
          if (productsAsyncValue.hasValue &&
              productsAsyncValue.value!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/ledgerE.png',
                    width: responsive.width(0.2),
                  ),
                  SizedBox(height: responsive.height(0.02)),
                  Text(
                    'No ledger found',
                    style: TextStyle(
                      fontSize: responsive.textSize(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.height(0.025)),
                ],
              ),
            );
          }

          // Check if ledger entries are empty
          if (selectedProductId != null) {
            final ledgerEntriesAsyncValue = ref.watch(productLedgerProvider);
            if (ledgerEntriesAsyncValue.hasValue &&
                ledgerEntriesAsyncValue.value!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt_outlined, size: 50, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No ledger entries found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
          }

          // Default UI when products and ledgers exist
          return Column(
            children: [
              // Products List Tab
              const ProductsList(),
              const SizedBox(height: 20),
              const Expanded(child: LedgerDetailsList()),
            ],
          );
        },
      ),
    );
  }
}

class ProductsList extends ConsumerWidget {
  const ProductsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);
    final selectedProductId = ref.watch(selectedProductIdProvider);

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return productsAsyncValue.when(
      data: (products) {
        return SizedBox(
          height: 38,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.padding(22),
            ),
            child: ListView.builder(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isSelected = product.productId == selectedProductId ||
                    (selectedProductId == null && index == 0);

                return Padding(
                  padding: EdgeInsets.only(right: responsive.padding(14.0)),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedProductIdProvider.notifier).state =
                          product.productId;
                      ref.read(currentPageProvider.notifier).state = 1;
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
                        capitalizeWords(product.productName),
                        style: TextStyle(
                          fontSize: responsive.textSize(14),
                          color: isSelected ? AppTheme.orange : AppTheme.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () {
        return SizedBox(
          height: 38,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.padding(22),
            ),
            child: ListView.builder(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: 5, // Simulate 5 placeholder items
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: responsive.padding(14.0)),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: responsive.padding(100), // Adjust width as needed
                      height: responsive.padding(30), // Adjust height as needed
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class LedgerDetailsList extends ConsumerWidget {
  const LedgerDetailsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProductId = ref.watch(selectedProductIdProvider);
    final currentPage = ref.watch(currentPageProvider);

    if (selectedProductId == null) {
      return const Center(child: Text('Select a product to view ledger'));
    }

    final ledgerEntriesAsyncValue = ref.watch(productLedgerProvider);

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Column(
      children: [
        Expanded(
          child: ledgerEntriesAsyncValue.when(
            data: (entries) {
              if (entries.isEmpty) {
                return const Center(
                  child: Text('No ledger entries found'),
                );
              }

              // Calculate the running balance
              double runningBalance = 0;
              final entriesWithBalance = entries.map((entry) {
                runningBalance += (entry.credit - entry.debit);
                return {
                  'entry': entry,
                  'balance': runningBalance,
                };
              }).toList();

              // Check if pagination is needed
              final showPagination = entriesWithBalance.length > 10;

              // Paginate the entries
              final paginatedEntries = entriesWithBalance
                  .skip((currentPage - 1) * 10)
                  .take(10)
                  .toList();

              // Create a DataTable widget to display ledger entries
              return SingleChildScrollView(
                clipBehavior: Clip.none,
                scrollDirection: Axis.vertical, // Vertical scrolling
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Horizontal scrolling
                  child: DataTable(
                    columnSpacing: 16.0, // Adjust spacing between columns
                    headingRowColor:
                        MaterialStateProperty.all(Colors.grey[200]),
                    columns: const [
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Credit',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Debit',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Balance',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Remark',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: paginatedEntries.map((item) {
                      final entry = item['entry'] as ProductLedgerEntry;
                      final balance = item['balance'] as double;
                      // Format date as DD/MM/YY
                      final formattedDate =
                          DateFormat('dd/MM/yy').format(entry.transactionDate);
                      return DataRow(cells: [
                        DataCell(Text(formattedDate)),
                        DataCell(Center(
                          child: entry.credit > 0
                              ? Text('${entry.credit}',
                                  style: const TextStyle(color: Colors.green))
                              : const Text('-'),
                        )),
                        DataCell(Center(
                          child: entry.debit > 0
                              ? Text('${entry.debit}',
                                  style: const TextStyle(color: Colors.red))
                              : const Text('-'),
                        )),
                        DataCell(
                            Center(child: Text(balance.toStringAsFixed(2)))),
                        DataCell(
                            Text(entry.remark.isNotEmpty ? entry.remark : '-')),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ),
        // Pagination controls
        Consumer(
          builder: (context, ref, child) {
            final entriesAsyncValue = ref.watch(productLedgerProvider);
            if (entriesAsyncValue.hasValue &&
                entriesAsyncValue.value!.isNotEmpty) {
              final totalEntries = entriesAsyncValue.value!.length;
              final showPagination = totalEntries > 10;
              final hasNextPage = (currentPage * 10) < totalEntries;

              if (!showPagination) {
                return const SizedBox.shrink(); // Hide pagination if not needed
              }

              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: currentPage > 1
                          ? () => ref.read(currentPageProvider.notifier).state--
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 16,
                    ),
                    const SizedBox(width: 8),
                    Text('Page $currentPage',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: hasNextPage
                          ? () => ref.read(currentPageProvider.notifier).state++
                          : null, // Disable "Next" if no more items
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 16,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

// class LedgerDetailsList extends ConsumerWidget {
//   const LedgerDetailsList({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedProductId = ref.watch(selectedProductIdProvider);
//     final currentPage = ref.watch(currentPageProvider);

//     if (selectedProductId == null) {
//       return const Center(child: Text('Select a product to view ledger'));
//     }

//     final ledgerEntriesAsyncValue = ref.watch(productLedgerProvider);

//     // Initialize responsive sizing
//     ResponsiveSizing().init(context);
//     final responsive = ResponsiveSizing();

//     return Column(
//       children: [
//         Expanded(
//           child: ledgerEntriesAsyncValue.when(
//             data: (entries) {
//               if (entries.isEmpty) {
//                 return const Center(
//                   child: Text('No ledger entries found'),
//                 );
//               }

//               // Calculate the running balance
//               double runningBalance = 0;
//               final entriesWithBalance = entries.map((entry) {
//                 runningBalance += (entry.credit - entry.debit);
//                 return {
//                   'entry': entry,
//                   'balance': runningBalance,
//                 };
//               }).toList();

//               // Create a DataTable widget to display ledger entries
//               return SingleChildScrollView(
//                 clipBehavior: Clip.none,
//                 scrollDirection: Axis.vertical, // Vertical scrolling
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal, // Horizontal scrolling
//                   child: DataTable(
//                     columnSpacing: 16.0, // Adjust spacing between columns
//                     headingRowColor:
//                         MaterialStateProperty.all(Colors.grey[200]),
//                     columns: const [
//                       DataColumn(
//                           label: Text('Date',
//                               style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataColumn(
//                           label: Text('Credit',
//                               style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataColumn(
//                           label: Text('Debit',
//                               style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataColumn(
//                           label: Text('Balance',
//                               style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataColumn(
//                           label: Text('Remark',
//                               style: TextStyle(fontWeight: FontWeight.bold))),
//                     ],
//                     rows: entriesWithBalance.map((item) {
//                       final entry = item['entry'] as ProductLedgerEntry;
//                       final balance = item['balance'] as double;
//                       // Format date as DD/MM/YY
//                       final formattedDate =
//                           DateFormat('dd/MM/yy').format(entry.transactionDate);

//                       return DataRow(cells: [
//                         DataCell(Text(formattedDate)),
//                         DataCell(Center(
//                           child: entry.credit > 0
//                               ? Text('${entry.credit}',
//                                   style: const TextStyle(color: Colors.green))
//                               : const Text('-'),
//                         )),
//                         DataCell(Center(
//                           child: entry.debit > 0
//                               ? Text('${entry.debit}',
//                                   style: const TextStyle(color: Colors.red))
//                               : const Text('-'),
//                         )),
//                         DataCell(
//                             Center(child: Text(balance.toStringAsFixed(2)))),
//                         DataCell(
//                             Text(entry.remark.isNotEmpty ? entry.remark : '-')),
//                       ]);
//                     }).toList(),
//                   ),
//                 ),
//               );
//             },
//             loading: () => const Center(child: CircularProgressIndicator()),
//             error: (error, _) => Center(child: Text('Error: $error')),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 onPressed: currentPage > 1
//                     ? () => ref.read(currentPageProvider.notifier).state--
//                     : null,
//                 icon: const Icon(Icons.arrow_back, size: 18),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 splashRadius: 16,
//               ),
//               const SizedBox(width: 8),
//               Text('Page $currentPage', style: const TextStyle(fontSize: 14)),
//               const SizedBox(width: 8),
//               IconButton(
//                 onPressed: () => ref.read(currentPageProvider.notifier).state++,
//                 icon: const Icon(Icons.arrow_forward, size: 18),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 splashRadius: 16,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
