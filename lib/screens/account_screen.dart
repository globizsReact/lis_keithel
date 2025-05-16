import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:lis_keithel/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';
import '../providers/providers.dart';
import '../utils/responsive_sizing.dart';
import '../utils/theme.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late ResponsiveSizing responsive;

  // Variables to store the fetched data
  String name = '';
  String phone = '';
  String address = '';

// Loading state
  bool isLoading = false;

// Flag to check if data has already been fetched
  bool isDataFetched = false;

// Function to fetch data from the API
  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Access SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Always get the latest address from SharedPreferences
      final cachedAddress = prefs.getString('address') ?? '';

      // Check if data is already stored in SharedPreferences
      if (prefs.containsKey('name') &&
          prefs.containsKey('phone') &&
          prefs.containsKey('address')) {
        setState(() {
          name = prefs.getString('name') ?? '';
          phone = prefs.getString('phone') ?? '';
          address = prefs.getString('address') ?? '';
          isLoading = false;
          isDataFetched = true;
        });
        return;
      }

      // Retrieve the token from SharedPreferences
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in SharedPreferences');
      }

      final url = '${Config.baseUrl}/clients/myprofile';

      // Replace with your API endpoint
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonData = json.decode(response.body);

        debugPrint(response.body);

        // Extract the required fields from the response
        final fetchedName = jsonData['msg']['name'];
        final fetchedPhone = jsonData['msg']['phone'];
        final fetchedAddress = jsonData['msg']['leikai'];

        // Save the fetched data to SharedPreferences
        await prefs.setString('name', fetchedName);
        await prefs.setString('phone', fetchedPhone);
        await prefs.setString('address', fetchedAddress);
        // final mostRecentAddress =
        //     cachedAddress.isNotEmpty && cachedAddress != fetchedAddress
        //         ? cachedAddress
        //         : fetchedAddress;

        setState(() {
          name = fetchedName;
          phone = fetchedPhone;
          address = fetchedAddress;
          isLoading = false; // Stop loading after data is fetched
          isDataFetched = true; // Mark data as fetched
        });
      } else {
        setState(() {
          name = prefs.getString('name') ?? '';
          phone = prefs.getString('phone') ?? '';
          address = cachedAddress;
          isLoading = false;
          isDataFetched = true;
        });

        // Handle error cases
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Handle exceptions
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        name = prefs.getString('name') ?? '';
        phone = prefs.getString('phone') ?? '';
        address = prefs.getString('address') ?? '';
        isLoading = false;
      });

      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize responsive sizing in initState
    responsive = ResponsiveSizing();
    if (!isDataFetched) {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing for the current context
    responsive.init(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(responsive.appBarHeight(65)),
        child: Padding(
          padding: EdgeInsets.all(responsive.padding(8)),
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
            isLoading
                ? const Center(
                    child: ProfileCardLoading(),
                  ) // Show loader while loading
                : Container(
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
                                name,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: responsive.textSize(19),
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.black,
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.height(0.01)),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icons/phone.png',
                                  width: responsive.width(0.035),
                                  gaplessPlayback: true,
                                ),
                                SizedBox(width: responsive.width(0.02)),
                                Text(
                                  '+91 $phone',
                                  style: TextStyle(
                                    color: AppTheme.grey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: responsive.textSize(13),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsive.height(0.005)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/address.png',
                                  width: responsive.width(0.037),
                                  gaplessPlayback: true,
                                ),
                                SizedBox(width: responsive.width(0.02)),
                                SizedBox(
                                  width: responsive.width(0.5),
                                  child: Text(
                                    address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: AppTheme.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsive.textSize(13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/profileS.png',
                          width: responsive.width(0.18),
                          gaplessPlayback: true,
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: responsive.height(0.04)),
            AccountButton(
              image: 'assets/icons/ledger.png',
              name: 'My Ledger',
              route: '/ledger',
            ),
            AccountButton(
              image: 'assets/icons/house.png',
              name: 'Update Address',
              route: '/update-address',
            ),
            // Geo Location
            UpdateLocation(),
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
                      borderRadius: BorderRadius.circular(16.0),
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
                          context.pop();
                          await ref.read(authProvider.notifier).logout();
                          ref.read(selectedIndexProvider.notifier).state = 0;
                          context.go('/');
                          CustomToast.show(
                            context: context,
                            message: 'Logout successfully',
                            icon: Icons.check,
                            backgroundColor: AppTheme.green,
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
                        SizedBox(width: responsive.width(0.045)),
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
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Image.asset(
                  'assets/icons/globizs.png',
                  width: responsive.width(0.15),
                ),
              ],
            ),
            SizedBox(height: responsive.height(0.03)),
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
  final VoidCallback? fetchData;

  const AccountButton(
      {Key? key,
      required this.route,
      required this.image,
      required this.name,
      this.fetchData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize responsive sizing
    ResponsiveSizing().init(context);
    final responsive = ResponsiveSizing();

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        // Navigate to the specified route
        context.push(route);

        if (fetchData != null) {
          fetchData!(); // Fetch data before navigation
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: responsive.padding(13)),
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
                SizedBox(width: responsive.width(0.045)),
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
