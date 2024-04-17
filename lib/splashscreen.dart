import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasInternet = true; // Initially assuming internet connection

  @override
  void initState() {
    super.initState();
    checkInternetConnection(); // Check internet connection on init
  }

  Future<void> checkInternetConnection() async {
    _hasInternet = await InternetConnection().hasInternetAccess;
    if (_hasInternet) {
      // If there is an internet connection, navigate after a certain duration
      Future.delayed(Duration(seconds: 10), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WebViewPage(), // Your WebView screen
          ),
        );
      });
    } else {
      // If there is no internet connection, set state to rebuild UI
      setState(() {});
    }
  }

  Future<void> retryConnection() async {
    // Check internet connection when retry button is pressed
    _hasInternet = await InternetConnection().hasInternetAccess;
    if (_hasInternet) {
      // If internet connection is restored, navigate to WebViewPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WebViewPage(), // Your WebView screen
        ),
      );
    } else {
      // If still no internet connection, show error message or handle accordingly
      // You can display a snackbar, dialog, or any other UI element to inform the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show image only if there's no internet connection
              if (!_hasInternet) ...[
                Image.asset(
                  'images/nowifi.png', // Replace with the path to your image asset for no internet connection
                  width: 200, // Adjust the width as needed
                  height: 200, // Adjust the height as needed
                ),
                SizedBox(height: 20), // Spacer between image and button
                ElevatedButton(
                  onPressed: retryConnection,
                  child: Text('Retry'),
                ),
              ],
              // Wrap Image.asset with a Container and set the color to black
              if (_hasInternet)
                Container(
                  width: 200, // Adjust the width as needed
                  height: 200, // Adjust the height as needed
                  child: Image.asset(
                    'images/splashscreen.png', // Replace with the path to your image asset
                    width: double.infinity, // Full width
                    height: double.infinity, // Full height
                    fit: BoxFit.contain, // Adjust the fit as needed
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
