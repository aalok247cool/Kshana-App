import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class YouTubeZonePage extends StatefulWidget {
  const YouTubeZonePage({super.key});

  @override
  _YouTubeZonePageState createState() => _YouTubeZonePageState();
}

class _YouTubeZonePageState extends State<YouTubeZonePage> {
  late WebViewController _controller;
  int _totalCoins = 0;
  int _todayEarnings = 0;
  int _minutesWatched = 0;
  final int _maxMinutesPerDay = 120; // 2 hours max per day
  final int _coinsPerMinute = 1;
  bool _isShowingAd = false;
  bool _isTimerActive = false;
  Timer? _watchTimer;
  Timer? _adTimer;
  int _secondsWatched = 0;
  int _secondsUntilNextAd = 0;
  final int _adIntervalSeconds = 300; // Show ad every 5 minutes

  @override
  void initState() {
    super.initState();
    _initWebView();
    _loadStats();
    _initAdTimer();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (!_isTimerActive) {
              _startWatchTimer();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('youtube.com') ||
                request.url.contains('youtu.be')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://m.youtube.com'));
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    _adTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('youtubeLastResetDate');
    final today = DateTime.now().toString().split(' ')[0]; // Get just the date part

    // Reset daily count if it's a new day
    if (lastResetDate != today) {
      await prefs.setString('youtubeLastResetDate', today);
      await prefs.setInt('youtubeMinutesWatched', 0);
      await prefs.setInt('youtubeTodayEarnings', 0);
    }

    setState(() {
      _totalCoins = prefs.getInt('coinBalance') ?? 0;
      _minutesWatched = prefs.getInt('youtubeMinutesWatched') ?? 0;
      _todayEarnings = prefs.getInt('youtubeTodayEarnings') ?? 0;
    });
  }

  void _initAdTimer() {
    _secondsUntilNextAd = _adIntervalSeconds;
    _adTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isTimerActive && !_isShowingAd) {
        setState(() {
          _secondsUntilNextAd--;
        });

        if (_secondsUntilNextAd <= 0) {
          _showAd();
        }
      }
    });
  }

  void _startWatchTimer() {
    if (_minutesWatched >= _maxMinutesPerDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You\'ve reached the maximum watch time for today!')),
      );
      return;
    }

    setState(() {
      _isTimerActive = true;
      _secondsWatched = 0;
    });

    _watchTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isTimerActive && !_isShowingAd) {
        setState(() {
          _secondsWatched++;
        });

        // Award coins every minute
        if (_secondsWatched % 60 == 0) {
          _awardCoinsForWatching();
        }
      }
    });
  }

  void _pauseWatchTimer() {
    setState(() {
      _isTimerActive = false;
    });
  }

  Future<void> _awardCoinsForWatching() async {
    if (_minutesWatched >= _maxMinutesPerDay) return;

    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt('coinBalance') ?? 0;
    final minutesWatched = prefs.getInt('youtubeMinutesWatched') ?? 0;
    final todayEarnings = prefs.getInt('youtubeTodayEarnings') ?? 0;

    await prefs.setInt('coinBalance', currentCoins + _coinsPerMinute);
    await prefs.setInt('youtubeMinutesWatched', minutesWatched + 1);
    await prefs.setInt('youtubeTodayEarnings', todayEarnings + _coinsPerMinute);

    setState(() {
      _totalCoins = currentCoins + _coinsPerMinute;
      _minutesWatched = minutesWatched + 1;
      _todayEarnings = todayEarnings + _coinsPerMinute;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned $_coinsPerMinute coins!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showAd() async {
    if (_isShowingAd) return;

    setState(() {
      _isShowingAd = true;
      _secondsUntilNextAd = _adIntervalSeconds;
    });

    // Try to pause YouTube video
    try {
      await _controller.runJavaScript('document.querySelector("video")?.pause();');
    } catch (e) {
      print("Error pausing video: $e");
    }

    // Show ad dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Advertisement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300,
                height: 250,
                color: Colors.grey.shade300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ad_units, size: 50, color: Colors.grey.shade700),
                      SizedBox(height: 20),
                      Text('Advertisement', style: TextStyle(color: Colors.grey.shade700)),
                      SizedBox(height: 40),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Watch this ad to earn extra coins!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Ad can't be skipped for first 5 seconds
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text('Skip (5)'),
            ),
          ],
        );
      },
    );

    // Simulate ad duration (5 seconds for demo)
    int remainingSeconds = 5;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      remainingSeconds--;

      if (remainingSeconds <= 0) {
        timer.cancel();

        if (mounted) {
          Navigator.of(context).pop(); // Close ad dialog

          // Award bonus coins for watching ad
          _awardAdBonus();

          // Try to resume YouTube video
          try {
            _controller.runJavaScript('document.querySelector("video")?.play();');
          } catch (e) {
            print("Error resuming video: $e");
          }

          setState(() {
            _isShowingAd = false;
          });
        }
      } else {
        // Update skip button text
        if (mounted) {
          Navigator.of(context).pop(); // Close current dialog

          // Show updated dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Advertisement'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 300,
                      height: 250,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.ad_units, size: 50, color: Colors.grey.shade700),
                            SizedBox(height: 20),
                            Text('Advertisement', style: TextStyle(color: Colors.grey.shade700)),
                            SizedBox(height: 40),
                            CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Watch this ad to earn extra coins!'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Ad can't be skipped for first 5 seconds
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    child: Text('Skip ($remainingSeconds)'),
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  Future<void> _awardAdBonus() async {
    final adBonus = 5; // 5 coins bonus for watching an ad

    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt('coinBalance') ?? 0;
    final todayEarnings = prefs.getInt('youtubeTodayEarnings') ?? 0;

    await prefs.setInt('coinBalance', currentCoins + adBonus);
    await prefs.setInt('youtubeTodayEarnings', todayEarnings + adBonus);

    setState(() {
      _totalCoins = currentCoins + adBonus;
      _todayEarnings = todayEarnings + adBonus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ad bonus: +$adBonus coins!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Zone'),
        backgroundColor: Colors.red,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '$_totalCoins',
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.red.shade800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today: $_minutesWatched/$_maxMinutesPerDay min',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Earned: $_todayEarnings coins',
                  style: TextStyle(color: Colors.amber),
                ),
              ],
            ),
          ),

          // Ad timer
          if (_isTimerActive && !_isShowingAd)
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: Colors.amber.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Next ad in: ${(_secondsUntilNextAd / 60).floor()}:${(_secondsUntilNextAd % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.amber),
                  ),
                ],
              ),
            ),

          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),

                // Overlay for paused state
                if (!_isTimerActive && !_isShowingAd)
                  GestureDetector(
                    onTap: _startWatchTimer,
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_filled, size: 80, color: Colors.white),
                            SizedBox(height: 20),
                            Text(
                              'Tap to start earning',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isTimerActive
          ? FloatingActionButton(
        onPressed: _pauseWatchTimer,
        backgroundColor: Colors.red,
        child: Icon(Icons.pause),
      )
          : FloatingActionButton(
        onPressed: _startWatchTimer,
        backgroundColor: Colors.red,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}