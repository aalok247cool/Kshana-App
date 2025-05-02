import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class InstagramZonePage extends StatefulWidget {
  const InstagramZonePage({Key? key}) : super(key: key);

  @override
  _InstagramZonePageState createState() => _InstagramZonePageState();
}

class _InstagramZonePageState extends State<InstagramZonePage> {
  late WebViewController _controller;

  int _totalCoins = 0;
  int _todayEarnings = 0;
  int _minutesWatched = 0;

  final int _maxMinutesPerDay = 90; // 1.5 hours max per day
  final int _coinsPerMinute = 1;

  bool _isShowingAd = false;
  bool _isTimerActive = false;

  Timer? _watchTimer;
  Timer? _adTimer;

  int _secondsWatched = 0;
  int _secondsUntilNextAd = 0;
  final int _adIntervalSeconds = 300; // 5 minutes

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
            if (request.url.contains('instagram.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.instagram.com/'));
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    _adTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('instagramLastResetDate');
    final today = DateTime.now().toString().split(' ')[0];

    if (lastResetDate != today) {
      await prefs.setString('instagramLastResetDate', today);
      await prefs.setInt('instagramMinutesWatched', 0);
      await prefs.setInt('instagramTodayEarnings', 0);
    }

    setState(() {
      _totalCoins = prefs.getInt('coinBalance') ?? 0;
      _minutesWatched = prefs.getInt('instagramMinutesWatched') ?? 0;
      _todayEarnings = prefs.getInt('instagramTodayEarnings') ?? 0;
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
    final minutesWatched = prefs.getInt('instagramMinutesWatched') ?? 0;
    final todayEarnings = prefs.getInt('instagramTodayEarnings') ?? 0;

    await prefs.setInt('coinBalance', currentCoins + _coinsPerMinute);
    await prefs.setInt('instagramMinutesWatched', minutesWatched + 1);
    await prefs.setInt('instagramTodayEarnings', todayEarnings + _coinsPerMinute);

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

    // Pause Instagram video if possible (best effort)
    try {
      await _controller.runJavaScript('document.querySelector("video")?.pause();');
    } catch (e) {
      print("Error pausing video: $e");
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int remainingSeconds = 5;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Timer.periodic(Duration(seconds: 1), (timer) {
              if (remainingSeconds <= 0) {
                timer.cancel();
                if (mounted) {
                  Navigator.of(context).pop();
                  _awardAdBonus();
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
                setStateDialog(() {
                  remainingSeconds--;
                });
              }
            });

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
                  onPressed: () {}, // Disable skip for demo
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: Text('Skip ($remainingSeconds)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _awardAdBonus() async {
    final adBonus = 5;

    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt('coinBalance') ?? 0;
    final todayEarnings = prefs.getInt('instagramTodayEarnings') ?? 0;

    await prefs.setInt('coinBalance', currentCoins + adBonus);
    await prefs.setInt('instagramTodayEarnings', todayEarnings + adBonus);

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
        title: Text('Instagram Zone'),
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
          Container(
            color: Colors.red.shade800,
            padding: EdgeInsets.all(8),
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
          if (_isTimerActive && !_isShowingAd)
            Container(
              color: Colors.amber.withOpacity(0.2),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
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