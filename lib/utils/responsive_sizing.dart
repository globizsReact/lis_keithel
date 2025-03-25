import 'package:flutter/material.dart';

class ResponsiveSizing {
  // Singleton instance
  static final ResponsiveSizing _instance = ResponsiveSizing._internal();
  factory ResponsiveSizing() => _instance;
  ResponsiveSizing._internal();

  // Get screen size context
  late BuildContext _context;

  // Initialize with context
  void init(BuildContext context) {
    _context = context;
  }

  // Responsive width
  double width(double percentage) {
    return MediaQuery.of(_context).size.width * percentage;
  }

  // Responsive position
  double position(double percentage) {
    return MediaQuery.of(_context).size.width * percentage;
  }

  // Responsive height
  double height(double percentage) {
    return MediaQuery.of(_context).size.height * percentage;
  }

  // Responsive text size
  double textSize(double baseSize) {
    double screenWidth = MediaQuery.of(_context).size.width;
    // Adjust text size based on screen width
    return baseSize * (screenWidth / 375.0); // 375 is a standard design width
  }

  // Responsive padding
  double padding(double basePadding) {
    double screenWidth = MediaQuery.of(_context).size.width;
    return basePadding * (screenWidth / 375.0);
  }

  // Responsive icon size
  double iconSize(double baseSize) {
    double screenWidth = MediaQuery.of(_context).size.width;
    return baseSize * (screenWidth / 375.0);
  }

  // Responsive app bar height
  double appBarHeight(double baseHeight) {
    double screenHeight = MediaQuery.of(_context).size.height;
    return baseHeight * (screenHeight / 812.0); // iPhone 12/13 Pro height
  }
}
