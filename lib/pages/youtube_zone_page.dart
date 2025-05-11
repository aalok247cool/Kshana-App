import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class YouTubeZonePage extends StatefulWidget {
  final Function(int)? onCoinsEarned;

  const YouTubeZonePage({
    super.key,
    this.onCoinsEarned,
  });

  @override
  _YouTubeZonePageState createState() => _YouTubeZonePageState();
}

class _YouTubeZonePageState extends State<YouTubeZonePage> with WidgetsBindingObserver {
  int _coinBalance = 425;
  bool _youtubeIsOpen = false;
  DateTime? _youtubeOpenedTime;

  // Ad timer variables
  Timer? _backgroundTimer;
  int _timeUntilNextAd = 3 * 60; // 3 minutes in seconds

  // Ad state
  bool _isShowingAd = false;
  int _adWatchTime = 0;
  int _requiredAdWatchTime = 0;
  Timer? _adWatchTimer;
  bool _adReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCoinBalance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundTimer?.cancel();
    _adWatchTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _youtubeIsOpen) {
      // User returned to the app - check if it's time for an ad
      if (_youtubeOpenedTime != null) {
        final timeSpent = DateTime.now().difference(_youtubeOpenedTime!).inSeconds;

        if (timeSpent >= _timeUntilNextAd) {
          _youtubeIsOpen = false;
          _showAd();
        } else {
          setState(() {
            _timeUntilNextAd -= timeSpent;
          });
        }
      }
    }
  }

  // Load saved coin balance
  Future<void> _loadCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coinBalance = prefs.getInt('coinBalance') ?? 425;
    });
  }

  // Save coin balance
  Future<void> _saveCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coinBalance', _coinBalance);
  }

  // Open YouTube and start background timer
  Future<void> _openYouTube() async {
    final Uri youtubeUri = Uri.parse('youtube://');

    try {
      bool canLaunch = await canLaunchUrl(youtubeUri);

      if (canLaunch) {
        // Start background timer before launching YouTube
        _startBackgroundTimer();

        // Record when YouTube is opened
        _youtubeOpenedTime = DateTime.now();
        _youtubeIsOpen = true;

        // Launch YouTube
        bool launched = await launchUrl(
          youtubeUri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          _showErrorSnackBar("Could not open YouTube app");
          _youtubeIsOpen = false;
          _backgroundTimer?.cancel();
        }
      } else {
        // YouTube app not installed, try Play Store
        final Uri playStoreUri = Uri.parse(
            'https://play.google.com/store/apps/details?id=com.google.android.youtube'
        );

        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri);
        } else {
          _showErrorSnackBar("Could not open YouTube app or Play Store");
        }
      }
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Start background timer for ads
  void _startBackgroundTimer() {
    // Cancel any existing timer
    _backgroundTimer?.cancel();

    // Reset timer to 3 minutes
    _timeUntilNextAd = 3 * 60;

    // Start new timer
    _backgroundTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Decrement time
      _timeUntilNextAd--;

      // When timer reaches zero, set ad ready flag
      if (_timeUntilNextAd <= 0) {
        _backgroundTimer?.cancel();
        _adReady = true;
      }
    });
  }

  // Show the ad overlay
  void _showAd() {
    setState(() {
      _isShowingAd = true;

      // For testing: use shorter time (5-15 seconds)
      _requiredAdWatchTime = Random().nextInt(10) + 5;
      // For production: 60-120 seconds
      // _requiredAdWatchTime = Random().nextInt(61) + 60;

      _adWatchTime = 0;
    });

    // Start timer to track ad watching progress
    _adWatchTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _adWatchTime++;

        if (_adWatchTime >= _requiredAdWatchTime) {
          _adWatchTimer?.cancel();
          _awardCoinsAndResetTimer();
        }
      });
    });
  }

  // Award coins and reset timer
  void _awardCoinsAndResetTimer() {
    int coinsEarned = Random().nextInt(21) + 10;

    setState(() {
      _coinBalance += coinsEarned;
      _isShowingAd = false;
    });

    _saveCoinBalance();

    if (widget.onCoinsEarned != null) {
      widget.onCoinsEarned!(coinsEarned);
    }

    _showCongratulationDialog(coinsEarned);
  }

  // Show congratulation dialog
  void _showCongratulationDialog(int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.amber, width: 2),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration, color: Colors.amber, size: 50),
              SizedBox(height: 10),
              Text(
                'Congratulations!',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You earned $coinsEarned coins for watching the ad!',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                'New Balance: $_coinBalance coins',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openYouTube(); // Go back to YouTube
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Back to YouTube'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // User stays in Kshana app
              },
              child: Text(
                'Stay in Kshana',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to show an ad when returning to the app
    if (_adReady) {
      // Reset flag and show ad after build completes
      _adReady = false;
      Future.microtask(() => _showAd());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Zone'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber),
                SizedBox(width: 4),
                Text('$_coinBalance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // YouTube logo
                    Icon(
                      Icons.play_circle_fill,
                      size: 70,
                      color: Colors.red,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'YouTube Zone',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Watch YouTube videos and earn Kshana coins!',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),

                    // How it works section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'How to earn coins:',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildStepRow('1. Open YouTube and watch videos', Icons.check_circle),
                          SizedBox(height: 8),
                          _buildStepRow('2. Return to Kshana every 3 minutes', Icons.check_circle),
                          SizedBox(height: 8),
                          _buildStepRow('3. Watch a short ad in Kshana', Icons.check_circle),
                          SizedBox(height: 8),
                          _buildStepRow('4. Earn 10-30 coins for each ad', Icons.check_circle),
                          SizedBox(height: 8),
                          _buildStepRow('5. Return to YouTube and repeat!', Icons.check_circle),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // YouTube button
                    ElevatedButton.icon(
                      onPressed: _openYouTube,
                      icon: Icon(Icons.play_arrow),
                      label: Text('Open YouTube'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Show ad overlay when needed
      floatingActionButton: _isShowingAd ? null : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Ad overlay
      bottomSheet: _isShowingAd ? _buildAdOverlay() : null,
    );
  }

  // Helper to build the ad overlay
  Widget _buildAdOverlay() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ADVERTISEMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library,
                          size: 40,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Kshana Ad',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _adWatchTime / _requiredAdWatchTime,
                              color: Colors.amber,
                              backgroundColor: Colors.grey[700],
                              minHeight: 10,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Please wait: ${_formatTime(_requiredAdWatchTime - _adWatchTime)}',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Watch to earn coins!',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build step rows
  Widget _buildStepRow(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}