import 'package:flutter/material.dart';
import 'kshana_reels_page.dart';
import 'media_zone_page.dart';
import 'task_zone_page.dart';
import 'package:kshana_app/pages/referral_zone.dart';
import 'surprise_zone.dart';


class EarningsZonePage extends StatelessWidget {
  final Function(int)? onCoinSpent;
  final int coinBalance;

  const EarningsZonePage({
    super.key,
    this.onCoinSpent,
    required this.coinBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black87, // Dark background for the whole page
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2, // Add just this line
          children: [
            _buildFeatureCard(context, 'Kshana Exports (Coming Soon)', Icons.local_shipping, null),
            _buildFeatureCard(context, 'Kshana Reels', Icons.video_library, const KshanaReelsPage()),
            _buildFeatureCard(context, 'Media Paid Zone', Icons.ondemand_video, const MediaPaidZonePage()),
            _buildFeatureCard(context, 'Task Zone', Icons.task_alt, TaskZonePage(onTaskCompleted: (int completedTasks) {
            })),
            _buildFeatureCard(context, 'Referral Zone', Icons.share, const ReferralZonePage()),
            _buildFeatureCard(context, 'Surprise Zone', Icons.card_giftcard, SurprizeZone(
              coinBalance: coinBalance, // Use the passed balance instead of hardcoding
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Widget? page) {
    return GestureDetector(
      onTap: () async {  // Add async here
        if (page != null) {
          final result = await Navigator.push(  // Add await and capture result
            context,
            MaterialPageRoute(builder: (context) => page),
          );

          // Handle the result if it's from SurprizeZone
          if (result != null && title == 'Surprise Zone') {
            // Pass result back to main dashboard
            Navigator.pop(context, result);
          }
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Coming Soon", style: TextStyle(color: Colors.amber)),
              content: const Text("Kshana Exports will be available in a future update."),
              backgroundColor: Colors.black87,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(color: Colors.amber)),
                ),
              ],
            ),
          );
        }
      },

      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        color: Colors.black,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Add padding to prevent overflow
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keep this to minimize height
                children: [
                  Icon(icon, size: 42, color: Colors.amber), // Slightly smaller icon
                  const SizedBox(height: 8), // Smaller spacing
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14, // Slightly smaller text
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis, // Handle text overflow gracefully
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}