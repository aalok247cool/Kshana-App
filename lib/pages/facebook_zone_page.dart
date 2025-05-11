import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';

class FacebookZonePage extends StatefulWidget {
  const FacebookZonePage({super.key});

  @override
  _FacebookZonePageState createState() => _FacebookZonePageState();
}

class _FacebookZonePageState extends State<FacebookZonePage> {
  bool _isWebViewVisible = false;
  InAppWebViewController? _webViewController;
  final int _coinBalance = 425;

  // Ad timer variables
  Timer? _adTimer;
  int _timeUntilNextAd = 5 * 60; // 5 minutes in seconds

  @override
  void initState() {
    super.initState();
    _startAdTimer();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeUntilNextAd > 0) {
          _timeUntilNextAd--;
        } else {
          // Reset timer for next ad
          _timeUntilNextAd = 5 * 60;
        }
      });
    });
  }

  // Method to open Facebook directly
  Future<void> _openFacebook() async {
    // Use the standard Facebook app scheme
    final Uri facebookUri = Uri.parse('fb://');

    try {
      print("Checking if Facebook can be launched...");
      bool canLaunch = await canLaunchUrl(facebookUri);

      if (canLaunch) {
        print("Launching Facebook app...");
        bool launched = await launchUrl(
          facebookUri,
          mode: LaunchMode.externalApplication,
        );

        print("Launch result: $launched");
        if (!launched) {
          setState(() => _isWebViewVisible = true);
        }
      } else {
        print("Facebook app not installed");
        // Try to open Play Store instead
        final Uri playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.facebook.katana');

        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri);
        } else {
          setState(() => _isWebViewVisible = true);
        }
      }
    } catch (e) {
      print("Error launching Facebook: $e");
      setState(() => _isWebViewVisible = true);
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook Zone'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber),
                SizedBox(width: 4),
                Text('$_coinBalance', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isWebViewVisible
                  ? InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri('https://www.facebook.com')),
                initialOptions: InAppWebViewGroupOptions(
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  ),
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.facebook,
                      size: 80,
                      color: Colors.blue[700],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Connect with us on Facebook!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _openFacebook,
                      icon: Icon(Icons.facebook),
                      label: Text('Open Facebook'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isWebViewVisible = true;
                        });
                      },
                      child: Text(
                        'Open Facebook in WebView instead',
                        style: TextStyle(color: Colors.blue[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Ad timer display
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.black.withOpacity(0.7),
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16), // Add margin to prevent overflow
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: Colors.white, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'Next ad in: ${_formatTime(_timeUntilNextAd)}',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}