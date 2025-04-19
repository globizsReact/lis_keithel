import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel/providers/location_provider.dart';
import 'package:lis_keithel/utils/responsive_sizing.dart';
import 'package:lis_keithel/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lis_keithel/widgets/custom_toast.dart';

class UpdateLocation extends ConsumerStatefulWidget {
  const UpdateLocation({super.key});

  @override
  ConsumerState<UpdateLocation> createState() => _UpdateLocationState();
}

class _UpdateLocationState extends ConsumerState<UpdateLocation> {
  @override
  Widget build(BuildContext context) {
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: const Text(
              'Update',
              style: TextStyle(
                color: AppTheme.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text('Are you sure want to update your location?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // First close the confirmation dialog
                  Navigator.of(dialogContext).pop();

                  // Then show loading overlay
                  showLoadingOverlay(context);

                  try {
                    // Fetch the location
                    await ref.read(locationProvider.notifier).fetchLocation();

                    // Get the updated location
                    final currentLocation = ref.read(locationProvider);

                    if (currentLocation != null) {
                      // Send location to API
                      await sendLocationToApi(context, currentLocation);

                      // Hide loading overlay
                      hideLoadingOverlay(context);
                    } else {
                      // Hide loading overlay
                      hideLoadingOverlay(context);
                    }
                  } catch (e) {
                    // Hide loading overlay
                    hideLoadingOverlay(context);
                  }
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/location.png',
                  width: responsive.width(0.05),
                ),
                SizedBox(width: responsive.width(0.045)),
                Text(
                  'Update My Geolocation',
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.textSize(16),
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/icons/arrowR.png',
              width: responsive.width(0.04),
            ),
          ],
        ),
      ),
    );
  }
}

// Add these methods to your widget class or create a separate utility class
OverlayEntry? _loadingOverlay;

void showLoadingOverlay(BuildContext context) {
  // Hide any existing overlay first
  hideLoadingOverlay(context);

  final overlay = Overlay.of(context);
  _loadingOverlay = OverlayEntry(
    builder: (context) => Material(
      color: Colors.black54, // Semi-transparent background
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Updating location...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(_loadingOverlay!);
}

void hideLoadingOverlay(BuildContext context) {
  _loadingOverlay?.remove();
  _loadingOverlay = null;
}
