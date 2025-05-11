import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KshanaReelsPage extends StatefulWidget {
  const KshanaReelsPage({super.key});

  @override
  _KshanaReelsPageState createState() => _KshanaReelsPageState();
}

class _KshanaReelsPageState extends State<KshanaReelsPage> {
  int _totalCoins = 0;
  int _todayEarnings = 0;
  int _videosWatched = 0;
  final int _maxVideosPerDay = 50;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('reelsLastResetDate');
    final today = DateTime.now().toString().split(' ')[0]; // Get just the date part

    // Reset daily count if it's a new day
    if (lastResetDate != today) {
      await prefs.setString('reelsLastResetDate', today);
      await prefs.setInt('videosWatchedToday', 0);
      await prefs.setInt('todayReelsEarnings', 0);
    }

    setState(() {
      _totalCoins = prefs.getInt('coinBalance') ?? 0;
      _videosWatched = prefs.getInt('videosWatchedToday') ?? 0;
      _todayEarnings = prefs.getInt('todayReelsEarnings') ?? 0;
    });
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: 60),
    );

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      // Simulate upload process
      await Future.delayed(Duration(seconds: 3));

      // Award coins for uploading
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = prefs.getInt('coinBalance') ?? 0;
      final uploadBonus = 10; // Bonus coins for uploading

      await prefs.setInt('coinBalance', currentCoins + uploadBonus);

      setState(() {
        _totalCoins = currentCoins + uploadBonus;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video uploaded! You earned $uploadBonus bonus coins.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _awardCoinsForWatching() async {
    if (_videosWatched >= _maxVideosPerDay) return;

    final coinsPerVideo = 2;
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt('coinBalance') ?? 0;
    final videosWatched = prefs.getInt('videosWatchedToday') ?? 0;
    final todayEarnings = prefs.getInt('todayReelsEarnings') ?? 0;

    await prefs.setInt('coinBalance', currentCoins + coinsPerVideo);
    await prefs.setInt('videosWatchedToday', videosWatched + 1);
    await prefs.setInt('todayReelsEarnings', todayEarnings + coinsPerVideo);

    setState(() {
      _totalCoins = currentCoins + coinsPerVideo;
      _videosWatched = videosWatched + 1;
      _todayEarnings = todayEarnings + coinsPerVideo;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned $coinsPerVideo coins!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade800,
        title: Text('Kshana Reels'),
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
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade800.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade800),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Today\'s Stats',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatCard(
                            'Videos Watched',
                            '$_videosWatched/$_maxVideosPerDay',
                            Icons.visibility,
                          ),
                          SizedBox(width: 20),
                          _buildStatCard(
                            'Coins Earned',
                            '$_todayEarnings',
                            Icons.monetization_on,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Watch reels to earn coins!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _awardCoinsForWatching,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: Icon(Icons.play_circle_filled),
                  label: Text(
                    'Watch a Reel',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Or upload your own reel!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Stats overlay
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today: $_videosWatched/$_maxVideosPerDay',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Earned: $_todayEarnings coins',
                    style: TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Upload progress indicator
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 20),
                    Text(
                      'Uploading your video...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideo,
        backgroundColor: Colors.amber.shade800,
        tooltip: 'Upload a Reel',
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade800),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.amber, size: 30),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}