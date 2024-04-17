import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'splashscreen.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? _webViewController;
  String? _base64Image;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  Future<void> checkInternetConnection() async {
    final isConnected = await InternetConnection().hasInternetAccess;
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Scaffold(
        body: Container(
          color: Colors.black,
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show image only if there's no internet connection
                  if (!_isConnected) ...[
                    Container(
                      width: 200, // Adjust the width as needed
                      height: 200, // Adjust the height as needed
                      child: Image.asset(
                        'images/nowifi.png', // Replace with the path to your image asset for no internet connection
                        width: double.infinity, // Full width
                        height: double.infinity, // Full height
                        fit: BoxFit.contain, // Adjust the fit as needed
                      ),
                    ),
                    SizedBox(height: 20), // Spacer between image and button
                    ElevatedButton(
                      onPressed: checkInternetConnection,
                      child: Text('Retry'),
                    ),
                  ],
                ]),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (canPop) async {
        if (await _webViewController?.canGoBack() ?? false) {
          _webViewController?.goBack();
          return;
        } else {
          return;
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: null,
          body: Column(
            children: [
              Expanded(
                child: WebView(
                  initialUrl: 'https://wsap.africa', // Replace with your desired URL
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  javascriptChannels: <JavascriptChannel>{
                    JavascriptChannel(
                      name: 'ImageChannel',
                      onMessageReceived: (JavascriptMessage message) {
                        setState(() {
                          _base64Image = message.message;
                        });
                      },
                    )
                  },
                  navigationDelegate: (NavigationRequest request) async {
                    checkInternetConnection();
                    if (request.url
                        .startsWith('https://api.whatsapp.com/send?phone')) {
                      String phone = "27781892545";
                      String message = "Hi";

                      await _launchURL(
                          "https://wa.me/$phone/?text=${Uri.parse(message)}");
                      return NavigationDecision.prevent;
                    }

                    if (request.url.startsWith('https://www.instagram.com/')) {
                      final urlFinal = request.url.toString();
                      await openBrowserUrl(url: urlFinal, inApp: false);
                      return NavigationDecision.prevent;
                    }

                    if (request.url.startsWith('data:')) {
                      if (_base64Image != null) {
                        _saveImage();
                      }
                      return NavigationDecision.prevent;
                    }

                    return NavigationDecision.navigate;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future openAppUrl({
    required String url,
    bool inApp = true,
  }) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
        mode: LaunchMode.inAppWebView,
      );
    }
  }

  _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _saveImage() async {
    // Request permission

    var status = await Permission.photos.request();
    if (status.isGranted) {
      final bytes = base64Decode(_base64Image!);
      final result = await ImageGallerySaver.saveImage(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to Gallery'),
        ),
      );
    }

  }
}

Future openBrowserUrl({
  required String url,
  bool inApp = false,
}) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }
}