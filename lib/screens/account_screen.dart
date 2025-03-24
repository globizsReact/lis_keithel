import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel_v1/providers/providers.dart';
import 'package:lis_keithel_v1/utils/theme.dart';
import 'package:lis_keithel_v1/widgets/custom_toast.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);

    // Access SharedPreferences instance
    final sharedPreferences = ref.watch(sharedPreferencesProvider);

    // Retrieve the fullname from SharedPreferences
    final fullname = sharedPreferences.getString('fullname') ?? 'Guest';
    // Location
    final location = ref.watch(locationProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppBar(
            backgroundColor: AppTheme.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'My Profile',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightOrange,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullname,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.black,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/phone.png',
                            width: 15,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            '+91 7629 865 803',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/address.png',
                            width: 15,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Kwakeithel Thokchom Leikai',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  Image.asset(
                    'assets/images/profileS.png',
                    width: 60,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            AccountButton(
              image: 'assets/icons/house.png',
              name: 'Update Address',
              route: '/update-address',
            ),
            // SizedBox(
            //   height: 20,
            // ),

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
                          width: 18,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'Update My Geolocation',
                          style: TextStyle(
                            color: AppTheme.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/icons/arrowR.png',
                      width: 15,
                    ),
                  ],
                ),
              ),
            ),

            // SizedBox(
            //   height: 20,
            // ),
            AccountButton(
              image: 'assets/icons/medal.png',
              name: 'My Reward points',
              route: '/reward-points',
            ),
            // SizedBox(
            //   height: 20,
            // ),
            AccountButton(
              image: 'assets/icons/password.png',
              name: 'Change Password',
              route: '/change-password',
            ),
            // SizedBox(
            //   height: 20,
            // ),
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
                            fontSize: 16.0,
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
                          width: 18,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: AppTheme.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/icons/arrowR.png',
                      width: 15,
                    ),
                  ],
                ),
              ),
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
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        context.push(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  image,
                  width: 18,
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/icons/arrowR.png',
              width: 15,
            ),
          ],
        ),
      ),
    );
  }
}
