import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';

class YouTubeZonePage extends StatefulWidget {
  const YouTubeZonePage({super.key});

  @override
  _YouTubeZonePageState createState() => _YouTubeZonePageState();
}

class _YouTubeZonePageState extends State<YouTubeZonePage> {
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

  // Method to open YouTube directly
  Future<void> _openYoutube() async {
    // Use the standard YouTube app scheme
    final Uri youtubeUri = Uri.parse('youtube://');

    try {
      print("Checking if YouTube can be launched...");
      bool canLaunch = await canLaunchUrl(youtubeUri);

      if (canLaunch) {
        print("Launching YouTube app...");
        bool launched = await launchUrl(
          youtubeUri,
          mode: LaunchMode.externalApplication,
        );

        print("Launch result: $launched");
        if (!launched) {
          setState(() => _isWebViewVisible = true);
        }
      } else {
        print("YouTube app not installed");
        // Try to open Play Store instead
        final Uri playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.google.android.youtube');

        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri);
        } else {
          setState(() => _isWebViewVisible = true);
        }
      }
    } catch (e) {
      print("Error launching YouTube: $e");
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
        title: Text('YouTube Zone'),
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
              initialUrlRequest: URLRequest(url: WebUri('https://www.youtube.com')),
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
                    Icons.play_circle_fill,
                    size: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Connect with us on YouTube!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _openYoutube,
                    icon: Icon(Icons.play_arrow),
                    label: Text('Open YouTube'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.red,
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
                      'Open YouTube in WebView instead',
                      style: TextStyle(color: Colors.red[400]),
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
    margin: EdgeInsets.only(bottom: 16),
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
