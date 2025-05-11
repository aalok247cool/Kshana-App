import 'package:flutter/material.dart';

class SpendCoinsPage extends StatelessWidget {
  final int currentCoins;
  final Function(int) onCoinsSpent;

  const SpendCoinsPage({
    super.key,
    required this.currentCoins,
    required this.onCoinsSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('🪙 Spend Coins'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Coins: $currentCoins',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildActionButton(
              context,
              title: 'Unlock Premium Features',
              description: 'Get access to locked zones and tools.',
              cost: 100,
              currentCoins: currentCoins,
              onConfirmed: () => onCoinsSpent(100),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              title: 'Boost Earnings',
              description: 'Increase your coin rewards for the day.',
              cost: 300,
              currentCoins: currentCoins,
              onConfirmed: () => onCoinsSpent(300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String description,
    required int cost,
    required int currentCoins,
    required VoidCallback onConfirmed,
  }) {
    return ElevatedButton.icon(
      onPressed:
          currentCoins >= cost
              ? () async {
                bool confirm = await showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirm Purchase'),
                        content: Text('Spend $cost coins to $title?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                );

                if (confirm) {
                  onConfirmed();
                  Navigator.pop(context);
                }
              }
              : null,
      icon: const Icon(Icons.info_outline),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(description, style: const TextStyle(fontSize: 12)),
        ],
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        backgroundColor: currentCoins >= cost ? Colors.purple : Colors.grey,
        foregroundColor: Colors.white,
      ),
    );
  }
}
