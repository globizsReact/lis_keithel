// Separate widget for managing date selection
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lis_keithel/models/models.dart';
import 'package:lis_keithel/providers/cart_provider.dart';
import 'package:lis_keithel/utils/theme.dart';

class DateSelectionWidget extends ConsumerStatefulWidget {
  final List<DeliveryDate> dateOptions;

  DateSelectionWidget({required this.dateOptions});

  @override
  _DateSelectionWidgetState createState() => _DateSelectionWidgetState();
}

class _DateSelectionWidgetState extends ConsumerState<DateSelectionWidget> {
  late DeliveryDate selectedDate; // Holds the currently selected date
  FixedExtentScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    // Set the default date to the first date in the list
    if (widget.dateOptions.isNotEmpty) {
      selectedDate = widget.dateOptions.first;
      _scrollController = FixedExtentScrollController(initialItem: 0);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateDeliveryOption();
      });
    }
  }

  // Add this helper method to update the cart provider
  void _updateDeliveryOption() {
    // Create a DeliveryOption from the selected date
    DeliveryOption deliveryOption = DeliveryOption(
      date: selectedDate.date,
      price: double.tryParse(selectedDate.price.replaceAll(',', '')) ?? 0.0,
    );

    // Update the cart provider
    ref.read(cartProvider.notifier).setDeliveryOption(deliveryOption);
  }

  @override
  void dispose() {
    _scrollController?.dispose(); // Dispose of the scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // Open a centered dialog when the date is tapped
            _openIOSStyleDatePicker(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatDate(selectedDate.date)} (₹ ${selectedDate.price})',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.black,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  void _openIOSStyleDatePicker(BuildContext context) {
    // Find the index of the currently selected date
    int selectedIndex = widget.dateOptions.indexOf(selectedDate);

    // Reset the scroll controller to the selected index
    _scrollController = FixedExtentScrollController(initialItem: selectedIndex);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Add rounded corners
          ), // Remove default padding
          content: SizedBox(
            height: 250,
            width: 500, // Height of the dialog
            child: Column(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _scrollController,
                    itemExtent: 40, // Height of each item
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        selectedDate = widget.dateOptions[index];
                        _updateDeliveryOption();
                      });
                    },
                    children: widget.dateOptions.map((DeliveryDate date) {
                      return Center(
                        child: Text(
                          '${_formatDate(date.date)} - ₹ ${date.price}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Divider(height: 1, thickness: 0.5),
                // Header with "Cancel" and "Done" buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _updateDeliveryOption();
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: AppTheme.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to format the date as '23rd Mar 2025'
  String _formatDate(String dateString) {
    DateTime date =
        DateFormat('yyyy-MM-dd').parse(dateString); // Parse the input date
    int day = date.day;
    String month = DateFormat('MMM').format(date); // Get abbreviated month name
    String year = DateFormat('yyyy').format(date); // Get full year
    String ordinalDay =
        _getOrdinal(day); // Convert day to ordinal (e.g., 23 → 23rd)
    return '$ordinalDay $month $year'; // Combine into '23rd Mar 2025'
  }

  // Helper function to convert a numeric day into its ordinal form
  String _getOrdinal(int day) {
    if (day % 10 == 1 && day != 11) {
      return '${day}st';
    } else if (day % 10 == 2 && day != 12) {
      return '${day}nd';
    } else if (day % 10 == 3 && day != 13) {
      return '${day}rd';
    } else {
      return '${day}th';
    }
  }
}
