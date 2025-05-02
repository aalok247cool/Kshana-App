import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Terms and Conditions", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Terms and Conditions for Kshana App",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildSection(
                "1. Acceptance of Terms",
                "By downloading, installing, or using the Kshana App, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the app."
            ),
            _buildSection(
                "2. User Accounts",
                "You are responsible for maintaining the confidentiality of your account information and password. You are responsible for all activities that occur under your account."
            ),
            _buildSection(
                "3. Coins and Rewards",
                "Coins earned in the app have no real-world monetary value unless explicitly stated. Redemption of coins is subject to verification and approval. The app reserves the right to modify the coin system at any time."
            ),
            _buildSection(
                "4. KYC Verification",
                "KYC verification may be required for certain features or redemptions. You agree to provide accurate and truthful information during the KYC process."
            ),
            _buildSection(
                "5. User Conduct",
                "You agree not to use the app for any illegal purposes or in any manner that could damage, disable, or impair the app's functionality."
            ),
            _buildSection(
                "6. Privacy",
                "Your privacy is important to us. Please refer to our Privacy Policy for information on how we collect, use, and disclose your personal information."
            ),
            _buildSection(
                "7. Modifications",
                "We reserve the right to modify these Terms and Conditions at any time. Continued use of the app after any modifications constitutes your acceptance of the revised terms."
            ),
            _buildSection(
                "8. Termination",
                "We reserve the right to terminate or suspend your account at our sole discretion, without notice, for conduct that we believe violates these Terms and Conditions or is harmful to other users, us, or third parties, or for any other reason."
            ),
            _buildSection(
                "9. Disclaimer of Warranties",
                "The app is provided 'as is' without warranties of any kind, either express or implied."
            ),
            _buildSection(
                "10. Contact",
                "If you have any questions about these Terms and Conditions, please contact us through the Help & Support section of the app."
            ),
            SizedBox(height: 20),
            Text(
              "Last Updated: April 28, 2025",
              style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}