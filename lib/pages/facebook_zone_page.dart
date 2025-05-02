import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class FacebookZonePage extends StatefulWidget {
  const FacebookZonePage({super.key});

  @override
  _FacebookZonePageState createState() => _FacebookZonePageState();
}

class _FacebookZonePageState extends State<FacebookZonePage> {
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
  final int _adIntervalSeconds = 240; // Show ad every 4 minutes

  @override
  void initState() {
    super.initState();
    _loadStats();
    _initAdTimer();
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    _adTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('facebookLastResetDate');
    final today = DateTime.now().toString().split(' ')[0]; // Get just the date part

    // Reset daily count if it's a new day
    if (lastResetDate != today) {
      await prefs.setString('facebookLastResetDate', today);
      await prefs.setInt('facebookMinutesWatched', 0);
      await prefs.setInt('facebookTodayEarnings', 0);
    }

    setState(() {
      _totalCoins = prefs.getInt('coinBalance') ?? 0;
      _minutesWatched = prefs.getInt('facebookMinutesWatched') ?? 0;
      _todayEarnings = prefs.getInt('facebookTodayEarnings') ?? 0;
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
    final minutesWatched = prefs.getInt('facebookMinutesWatched') ?? 0;
    final todayEarnings = prefs.getInt('facebookTodayEarnings') ?? 0;

    await prefs.setInt('coinBalance', currentCoins + _coinsPerMinute);
    await prefs.setInt('facebookMinutesWatched', minutesWatched + 1);
    await prefs.setInt('facebookTodayEarnings', todayEarnings + _coinsPerMinute);

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
    final todayEarnings = prefs.getInt('facebookTodayEarnings') ?? 0;

    await prefs.setInt('coinBalance', currentCoins + adBonus);
    await prefs.setInt('facebookTodayEarnings', todayEarnings + adBonus);

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
        title: Text('Facebook Zone'),
        backgroundColor: Colors.blue.shade800,
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
            color: Colors.blue.shade900,
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

          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.facebook,
                    size: 80,
                    color: Colors.blue.shade300,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Facebook Zone',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade300,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Coming Soon!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isTimerActive ? _pauseWatchTimer : _startWatchTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(
                      _isTimerActive ? 'Pause' : 'Start Earning',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}