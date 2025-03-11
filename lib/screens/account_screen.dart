import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lis_keithel_v1/utils/theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        'Sushil Khundrakpam',
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
            AccountButton(
              image: 'assets/icons/location.png',
              name: 'Update My Geolocation',
              route: '/update-geolocation',
            ),
            // SizedBox(
            //   height: 20,
            // ),
            AccountButton(
              image: 'assets/icons/medal.png',
              name: 'My Reward points',
              route: '/update-geolocation',
            ),
            // SizedBox(
            //   height: 20,
            // ),
            AccountButton(
              image: 'assets/icons/password.png',
              name: 'Change Password',
              route: '/update-geolocation',
            ),
            // SizedBox(
            //   height: 20,
            // ),
            AccountButton(
              image: 'assets/icons/logout.png',
              name: 'Logout',
              route: '/update-geolocation',
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
        context.go(route);
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
