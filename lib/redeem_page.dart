import 'package:flutter/material.dart';

class RedeemPage extends StatelessWidget {
  final int currentCoins;
  final Function(int) onRedeem;

  const RedeemPage({
    super.key,
    required this.currentCoins,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Redeem Coins'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child:
            currentCoins >= 50000
                ? ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text("Confirm Redemption"),
                            content: const Text(
                              "Are you sure you want to redeem 50,000 coins (₹500)?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  onRedeem(50000); // Deduct 50,000 coins
                                  Navigator.pop(context);
                                  Navigator.pop(
                                    context,
                                  ); // Go back to dashboard
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "🎉 Redemption successful! ₹500 will be processed.",
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Yes, Redeem"),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('Redeem ₹500 for 50,000 coins'),
                )
                : const Text('You need at least 50,000 coins to redeem ₹500'),
      ),
    );
  }
}
