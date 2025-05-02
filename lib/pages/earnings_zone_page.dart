import 'package:flutter/material.dart';
import 'kshana_reels_page.dart';
import 'media_zone_page.dart';
import 'task_zone_page.dart';
import 'package:kshana_app/pages/referral_zone.dart';
import 'surprise_zone.dart';

class EarningsZonePage extends StatelessWidget {
  const EarningsZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildFeatureCard(context, 'Kshana Exports (Coming Soon)', Icons.local_shipping, null),
          _buildFeatureCard(context, 'Kshana Reels', Icons.video_library, const KshanaReelsPage()),
          _buildFeatureCard(context, 'Media Paid Zone', Icons.ondemand_video, const MediaPaidZonePage()),
          _buildFeatureCard(context, 'Task Zone', Icons.task_alt, TaskZonePage(onTaskCompleted: (int completedTasks) {
            // You can handle the completedTasks here if needed
          })),
          _buildFeatureCard(context, 'Referral Zone', Icons.share, const ReferralZonePage()),
          _buildFeatureCard(context, 'Surprise Zone', Icons.card_giftcard, SurpriseZonePage(
            currentCoins: 0,
            onCoinsEarned: (earned) {},
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Widget? page) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Coming Soon"),
              content: const Text("Kshana Exports will be available in a future update."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        color: Colors.deepPurple.shade100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
