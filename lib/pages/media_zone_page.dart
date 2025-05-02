import 'package:flutter/material.dart';
import 'youtube_zone_page.dart';
import 'instagram_zone_page.dart';
import 'facebook_zone_page.dart';

class MediaPaidZonePage extends StatelessWidget {
  const MediaPaidZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Paid Zone'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earn coins by watching content!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Browse your favorite platforms and earn coins while watching videos, reels, and posts.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
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
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YouTubeZonePage()),
                    ),
                  ),
                  _buildPlatformCard(
                    context,
                    'Instagram',
                    'Browse reels and posts',
                    Colors.purple.shade700,
                    Icons.camera_alt,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InstagramZonePage()),
                    ),
                  ),
                  _buildPlatformCard(
                    context,
                    'Facebook',
                    'Check your feed and watch videos',
                    Colors.blue.shade800,
                    Icons.facebook,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FacebookZonePage()),
                    ),
                  ),
                  _buildPlatformCard(
                    context,
                    'More Coming Soon',
                    'Stay tuned for more platforms',
                    Colors.grey.shade700,
                    Icons.more_horiz,
                        () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('More platforms coming soon!')),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}