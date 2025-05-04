import 'package:flutter/material.dart';
import 'package:kshana_app/utils/shortcut_creator.dart';

// In feature_card.dart
class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? page;
  final String featureKey;
  final String deepLink;
  final Function onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.page,
    required this.featureKey,
    required this.deepLink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.amberAccent,
      child: InkWell(
        onLongPress: () => _showCreateShortcutDialog(context),
        onTap: () => onTap(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.amberAccent),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.amber, blurRadius: 8)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// [Rest of the FeatureCard implementation stays the same]

  void _showCreateShortcutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Create Shortcut',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Do you want to add "$title" to your home screen?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await ShortcutCreator.createShortcut(
                shortcutId: featureKey,
                shortcutName: title,
                iconResourceName: _getIconResourceName(featureKey),
                deepLink: deepLink,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '$title shortcut created on home screen!'
                          : 'Could not create shortcut. Please try again.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: Text(
              'Create',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconResourceName(String featureKey) {
    // Map feature keys to drawable resource names
    switch (featureKey) {
      case 'kshana_pay':
        return 'kshana_pay_icon';
      case 'daily_reward':
        return 'daily_reward_icon';
      case 'earnings':
        return 'earnings_icon';
      case 'kyc':
        return 'kyc_icon';
      default:
        return 'app_icon';
    }
  }
}