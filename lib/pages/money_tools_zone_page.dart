import 'package:flutter/material.dart';
import 'kshana_pay_page.dart';
import 'kshana_bank_page.dart';
import 'kshana_secure_page.dart';
import 'kshana_remit_page.dart';

class MoneyToolsZonePage extends StatelessWidget {
  const MoneyToolsZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Tools'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFeatureCard(context, 'Kshana Pay', Icons.qr_code_scanner, const KshanaPayPage()),
          _buildFeatureCard(context, 'Kshana Bank', Icons.account_balance_wallet, KshanaBankPage()),
          _buildFeatureCard(context, 'Kshana Secure', Icons.lock, KshanaSecurePage()),
          _buildFeatureCard(context, 'Kshana Remit', Icons.send_to_mobile, const KshanaRemitPage()),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        color: Colors.amber.shade100,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.deepOrange),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
