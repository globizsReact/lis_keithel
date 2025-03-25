import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';
import '../widgets/custom_toast.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);

    // Access SharedPreferences instance
    final sharedPreferences = ref.watch(sharedPreferencesProvider);

    // Retrieve the fullname from SharedPreferences
    final fullname = sharedPreferences.getString('fullname') ?? 'Guest';

    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.appBarHeight(65)),
        child: Padding(
          padding: EdgeInsets.all(
            responsive.padding(8),
          ),
          child: AppBar(
            backgroundColor: AppTheme.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'My Profile',
              style: TextStyle(
                fontSize: responsive.textSize(23),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.padding(23),
          vertical: responsive.padding(2),
        ),
        child: Column(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.lightOrange,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.padding(20),
                vertical: responsive.padding(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: responsive.width(0.56),
                        child: Text(
                          fullname,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: responsive.textSize(19),
                            fontWeight: FontWeight.w800,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: responsive.height(0.01),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/phone.png',
                            width: responsive.width(0.035),
                            gaplessPlayback: true,
                          ),
                          SizedBox(
                            width: responsive.width(0.02),
                          ),
                          Text(
                            '+91 7629 865 803',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: responsive.textSize(13),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: responsive.height(0.005),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/icons/address.png',
                            width: responsive.width(0.037),
                            gaplessPlayback: true,
                          ),
                          SizedBox(
                            width: responsive.width(0.02),
                          ),
                          SizedBox(
                            width: responsive.width(0.5),
                            child: Text(
                              'Kwakeithel Thokchom Leikai',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: responsive.textSize(13),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  Image.asset(
                    'assets/images/profileS.png',
                    width: responsive.width(0.18),
                    gaplessPlayback: true,
                  )
                ],
              ),
            ),
            SizedBox(
              height: responsive.height(0.04),
            ),
            AccountButton(
              image: 'assets/icons/house.png',
              name: 'Update Address',
              route: '/update-address',
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16.0), // Set border radius here
                    ),
                    title: const Text(
                      'Update',
                      style: TextStyle(
                        color: AppTheme.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                        'Are you sure want to update your location?'),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          context.pop();

                          try {
                            // Fetch the location
                            await ref
                                .read(locationProvider.notifier)
                                .fetchLocation();

                            // Get the updated location
                            final currentLocation = ref.read(locationProvider);

                            if (currentLocation != null) {
                              // Send location to API
                              await sendLocationToApi(currentLocation);
                            } else {
                              // Show error toast if location is null
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Failed to get location. Please check your permissions.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            // Close loading dialog and show error

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.red)),
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
                        SizedBox(
                          width: responsive.width(0.045),
                        ),
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
            ),
            AccountButton(
              image: 'assets/icons/medal.png',
              name: 'My Reward points',
              route: '/reward-points',
            ),
            AccountButton(
              image: 'assets/icons/password.png',
              name: 'Change Password',
              route: '/change-password',
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16.0), // Set border radius here
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppTheme.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text('Are you sure want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await authNotifier.logout();
                          context.pop();
                          ref.read(selectedIndexProvider.notifier).state = 0;
                          context.go('/');

                          CustomToast.show(
                            context: context,
                            message: 'Logout successfully',
                            icon: Icons.check,
                            backgroundColor: AppTheme.orange,
                            textColor: Colors.white,
                            gravity: ToastGravity.CENTER,
                            duration: Duration(seconds: 3),
                          );
                        },
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.red)),
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
                          'assets/icons/logout.png',
                          width: responsive.width(0.05),
                          gaplessPlayback: true,
                        ),
                        SizedBox(
                          width: responsive.width(0.045),
                        ),
                        Text(
                          'Logout',
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
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text(
                    'Powered by',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/icons/globizs.png',
                  width: responsive.width(0.15),
                )
              ],
            ),
            SizedBox(
              height: responsive.height(0.03),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountButton extends StatelessWidget {
  final String route;
  final String image;
  final String name;

  const AccountButton({
    Key? key,
    required this.route,
    required this.image,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        context.push(route);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: responsive.padding(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  image,
                  width: responsive.width(0.05),
                  gaplessPlayback: true,
                ),
                SizedBox(
                  width: responsive.width(0.045),
                ),
                Text(
                  name,
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
