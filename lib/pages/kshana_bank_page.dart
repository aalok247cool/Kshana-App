import 'package:flutter/material.dart';

class KshanaBankPage extends StatelessWidget {
  const KshanaBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Kshana Bank'),
        backgroundColor: Colors.amber.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Welcome! Gain 1000 coins by completing tasks for 3 days within your first 7 days.",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),

            // 4 Glowing Boxes
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildGoldBox("Coin Locker", Icons.lock),
                  _buildGoldBox("Kshana (Crypto)", Icons.currency_bitcoin),
                  _buildGoldBox("Buy Coins", Icons.monetization_on),
                  _buildGoldBox("Take Loan", Icons.account_balance),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldBox(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amberAccent.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.amber, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
