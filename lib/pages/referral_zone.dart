import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReferralZonePage extends StatefulWidget {
  const ReferralZonePage({super.key});

  static Future<void> markTaskCompletionForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final formattedToday = '${today.year}-${today.month}-${today.day}';
    List<String> completedDays =
        prefs.getStringList('completedReferralDays') ?? [];
    if (!completedDays.contains(formattedToday)) {
      completedDays.add(formattedToday);
      await prefs.setStringList('completedReferralDays', completedDays);
    }
  }

  static Future<bool> checkTaskCompletionForThreeDays() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completedDays =
        prefs.getStringList('completedReferralDays') ?? [];
    return completedDays.length >= 3;
  }

  static Future<void> rewardReferralIfEligible() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyRewarded = prefs.getBool('referralRewardGiven') ?? false;
    if (alreadyRewarded) return;
    final completed = await checkTaskCompletionForThreeDays();
    if (completed) {
      int currentCoins = prefs.getInt('coins') ?? 0;
      prefs.setInt('coins', currentCoins + 1000);
      prefs.setBool('referralRewardGiven', true);
      debugPrint('🎉 Referral reward of 1000 coins given!');
    }
  }

  @override
  State<ReferralZonePage> createState() => _ReferralZonePageState();
}

class _ReferralZonePageState extends State<ReferralZonePage> {
  final String referralCode = 'KSHANA123';
  List<String> referralProgress = ["🕒", "🕒", "🕒"];

  @override
  void initState() {
    super.initState();
    _loadReferralProgress();
  }

  void _copyReferralLink(BuildContext context) {
    String referralLink = 'https://kshana.app/signup?ref=$referralCode';
    Clipboard.setData(ClipboardData(text: referralLink));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(
      content: Text('Referral link copied!'),
      backgroundColor: Colors.amber,
    ));
    saveActivationDate();
  }

  Future<void> _loadReferralProgress() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completedDays =
        prefs.getStringList('completedReferralDays') ?? [];
    List<String> progress = ["🕒", "🕒", "🕒"];
    for (int i = 0; i < completedDays.length && i < 3; i++) {
      progress[i] = "✅";
    }
    setState(() {
      referralProgress = progress;
    });
  }

  void _launchShareIntent(BuildContext context) async {
    final message =
        'Join Kshana and earn rewards! Use my code: $referralCode \nhttps://kshana.app/signup?ref=$referralCode';
    final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
        content: Text('Could not open WhatsApp'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void saveActivationDate() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('activation_date', now.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Referral Zone',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Referral Code:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(
              referralCode,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _copyReferralLink(context),
              icon: const Icon(Icons.copy),
              label: const Text('Copy Referral Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _launchShareIntent(context),
              icon: const Icon(FontAwesomeIcons.whatsapp),
              label: const Text('Share via WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF25D366), // WhatsApp green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Invite your friends to Kshana and earn 100 coins\nwhen they join using your code!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Referral Bonus Status (3 Days):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return Column(
                  children: [
                    Text(
                      "Day ${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      referralProgress[index],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}