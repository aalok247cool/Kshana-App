import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Privacy Policy", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle("Privacy Policy"),
            _buildLastUpdated("Last updated: April 27, 2025"),

            _buildParagraph(
                "Welcome to our Earning App. We respect your privacy and are committed to protecting your personal data. This Privacy Policy will inform you about how we look after your personal data when you use our application and tell you about your privacy rights and how the law protects you."
            ),

            _buildSectionHeader("1. Information We Collect"),
            _buildParagraph(
                "We collect several different types of information for various purposes to provide and improve our Service to you:"
            ),
            _buildBulletPoint("Personal Data: Name, email address, phone number, gender, and profile picture"),
            _buildBulletPoint("Usage Data: Information on how you use the application"),
            _buildBulletPoint("Device Data: Information about your device, including device type, operating system, and unique device identifiers"),
            _buildBulletPoint("Location Data: With your consent, we may collect and process information about your location"),

            _buildSectionHeader("2. How We Use Your Information"),
            _buildParagraph(
                "We use the collected data for various purposes:"
            ),
            _buildBulletPoint("To provide and maintain our Service"),
            _buildBulletPoint("To notify you about changes to our Service"),
            _buildBulletPoint("To allow you to participate in interactive features of our Service"),
            _buildBulletPoint("To provide customer support"),
            _buildBulletPoint("To gather analysis or valuable information so that we can improve our Service"),
            _buildBulletPoint("To monitor the usage of our Service"),
            _buildBulletPoint("To detect, prevent and address technical issues"),
            _buildBulletPoint("To process payments and prevent fraudulent transactions"),

            _buildSectionHeader("3. Data Security"),
            _buildParagraph(
                "The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security."
            ),

            _buildSectionHeader("4. Your Data Protection Rights"),
            _buildParagraph(
                "You have the following data protection rights:"
            ),
            _buildBulletPoint("The right to access, update or delete the information we have on you"),
            _buildBulletPoint("The right of rectification - the right to have your information corrected if it is inaccurate or incomplete"),
            _buildBulletPoint("The right to object - the right to object to our processing of your Personal Data"),
            _buildBulletPoint("The right of restriction - the right to request that we restrict the processing of your personal information"),
            _buildBulletPoint("The right to data portability - the right to be provided with a copy of the information we have on you in a structured, machine-readable and commonly used format"),
            _buildBulletPoint("The right to withdraw consent - the right to withdraw your consent at any time where we relied on your consent to process your personal information"),

            _buildSectionHeader("5. Children's Privacy"),
            _buildParagraph(
                "Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If you are a parent or guardian and you are aware that your child has provided us with Personal Data, please contact us. If we become aware that we have collected Personal Data from children without verification of parental consent, we take steps to remove that information from our servers."
            ),

            _buildSectionHeader("6. Changes to This Privacy Policy"),
            _buildParagraph(
                "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the 'last updated' date at the top of this Privacy Policy."
            ),
            _buildParagraph(
                "You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page."
            ),

            _buildSectionHeader("7. Contact Us"),
            _buildParagraph(
                "If you have any questions about this Privacy Policy, please contact us:"
            ),
            _buildBulletPoint("By email: kshana2025@gmail.com"),

            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'kshana2025@gmail.com',
                      queryParameters: {
                        'subject': 'Privacy Policy Question',
                      }
                  );

                  try {
                    await launchUrl(emailUri);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open email app. Email: kshana2025@gmail.com')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Contact Us About Privacy",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLastUpdated(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.amber.withOpacity(0.7),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.amber.withOpacity(0.9),
          fontSize: 16,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: Colors.amber, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.amber.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}