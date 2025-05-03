import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';

class InstagramZonePage extends StatefulWidget {
  @override
  _InstagramZonePageState createState() => _InstagramZonePageState();
}

class _InstagramZonePageState extends State<InstagramZonePage> {
  bool _isWebViewVisible = false;
  InAppWebViewController? _webViewController;
  int _coinBalance = 425;

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

  // Fixed method to open Instagram directly
  Future<void> _openInstagram() async {
    // Use the standard Instagram app scheme
    final Uri instagramUri = Uri.parse('instagram://');

    try {
      print("Checking if Instagram can be launched...");
      bool canLaunch = await canLaunchUrl(instagramUri);

      if (canLaunch) {
        print("Launching Instagram app...");
        bool launched = await launchUrl(
          instagramUri,
          mode: LaunchMode.externalApplication,
        );

        print("Launch result: $launched");
        if (!launched) {
          setState(() => _isWebViewVisible = true);
        }
      } else {
        print("Instagram app not installed");
        // Try to open Play Store instead
        final Uri playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.instagram.android');

        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri);
        } else {
          setState(() => _isWebViewVisible = true);
        }
      }
    } catch (e) {
      print("Error launching Instagram: $e");
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
        title: Text('Instagram Zone'),
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
      body: Column(
        children: [
          Expanded(
            child: _isWebViewVisible
                ? InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri('https://www.instagram.com')),
              initialOptions: InAppWebViewGroupOptions(
                android: AndroidInAppWebViewOptions(
                  // Fix for the AndroidForceDark error - try a simpler approach
                  useHybridComposition: true,
                  // Omit forceDark completely if it causes errors
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
                  // Use Icon instead of Image to avoid asset errors
                  Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Colors.pink[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Connect with us on Instagram!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _openInstagram,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Open Instagram'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.pink[400],
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
                      'Open Instagram in WebView instead',
                      style: TextStyle(color: Colors.purple[400]),
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
    );
  }
}