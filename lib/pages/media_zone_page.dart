import 'package:flutter/material.dart';
import 'youtube_zone_page.dart';
import 'instagram_zone_page.dart';
import 'facebook_zone_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaPaidZonePage extends StatelessWidget {
  const MediaPaidZonePage({super.key});

  // Check current user tier (to be implemented later)
  Future<String> _getUserMembershipTier() async {
    // This would be replaced with your actual membership tier logic
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('membershipTier') ?? 'Basic';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Paid Zone',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black87, // Dark background
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earn coins by watching content!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Browse your favorite platforms and earn coins while watching videos, reels, and posts.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.amber.shade200,
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<String>(
                future: _getUserMembershipTier(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.amber,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Current Tier: ${snapshot.data}',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildPlatformCard(
                      context,
                      'YouTube',
                      'Watch videos and earn coins',
                      Colors.red,
                      Icons.play_circle_filled,
                          () {
                        // Show ad intention message before navigating
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ads will appear every 3 minutes to help you earn coins.'),
                            backgroundColor: Colors.black87,
                          ),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => YouTubeZonePage()),
                        );
                      },
                    ),
                    _buildPlatformCard(
                      context,
                      'Instagram',
                      'Browse reels and posts',
                      Colors.purple.shade700,
                      Icons.camera_alt,
                          () {
                        // Show ad intention message before navigating
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ads will appear every 3 minutes to help you earn coins.'),
                            backgroundColor: Colors.black87,
                          ),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InstagramZonePage()),
                        );
                      },
                    ),
                    _buildPlatformCard(
                      context,
                      'Facebook',
                      'Check your feed and watch videos',
                      Colors.blue.shade800,
                      Icons.facebook,
                          () {
                        // Show ad intention message before navigating
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ads will appear every 3 minutes to help you earn coins.'),
                            backgroundColor: Colors.black87,
                          ),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FacebookZonePage()),
                        );
                      },
                    ),
                    _buildPlatformCard(
                      context,
                      'More Coming Soon',
                      'Stay tuned for more platforms',
                      Colors.grey.shade700,
                      Icons.more_horiz,
                          () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('More platforms coming soon!'),
                          backgroundColor: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformCard(
      BuildContext context,
      String title,
      String subtitle,
      Color color,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: color),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}