import 'package:flutter/material.dart';
import 'dart:math';

class SurpriseZonePage extends StatelessWidget {
  final int currentCoins;
  final Function(int) onCoinsEarned;

  const SurpriseZonePage({
    super.key,
    required this.currentCoins,
    required this.onCoinsEarned,
  });

  @override
  Widget build(BuildContext context) {
    int randomReward = Random().nextInt(91) + 10; // 10 to 100 coins

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 Surprise Zone'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Available Coins: $currentCoins',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                onCoinsEarned(randomReward);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '🎉 You received $randomReward surprise coins!',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('🎁 Claim Surprise Reward'),
            ),
          ],
        ),
      ),
    );
  }
}
