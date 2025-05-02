import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final List<FAQItem> _faqItems = [
    FAQItem(
        question: "How do I earn coins in the app?",
        answer: "You can earn coins by completing tasks in various earning zones such as watching videos, completing surveys, referring friends, and more. Each completed task rewards you with a specific number of coins based on its complexity and time requirement."
    ),
    FAQItem(
        question: "How can I withdraw my earnings?",
        answer: "To withdraw your earnings, go to the Wallet section and select 'Withdraw'. You'll need to have completed KYC verification and have a minimum balance of 50,000 coins (equivalent to Rs 500). You can choose to withdraw via bank transfer, UPI, or other available payment methods."
    ),
    FAQItem(
        question: "Why is my account verification pending?",
        answer: "Account verification can take up to 48 hours to complete. Make sure you've provided all required documents correctly. If verification is taking longer, please contact our support team through the 'Contact Us' option."
    ),
    FAQItem(
        question: "How do I update my profile information?",
        answer: "You can update your profile information by going to the Profile page and tapping on 'Personal Info'. From there, tap the edit icon in the top right corner to make changes to your information."
    ),
    FAQItem(
        question: "Is my personal information secure?",
        answer: "Yes, we take data security very seriously. All personal information is encrypted and stored securely. We do not share your information with third parties without your consent. For more details, please refer to our Privacy Policy."
    ),
  ];

  final TextEditingController _queryController = TextEditingController();
  String _userName = 'User';
  String _userEmail = 'user@example.com';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _userEmail = prefs.getString('userEmail') ?? 'user@example.com';
    });
  }

  Future<void> _launchEmail() async {
    // Your actual support email
    final String supportEmail = 'kshana2025@gmail.com';

    // Store the query text
    final String queryText = _queryController.text;

    // Create email URI
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: supportEmail,
        queryParameters: {
          'subject': 'Support Request from $_userName',
          'body': 'User ID: $_userName\nEmail: $_userEmail\n\nQuery: $queryText'
        }
    );

    try {
      // Try to launch email client
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);

        // Clear the text field
        _queryController.clear();

        // Show thank you message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Fallback if email client can't be launched
        _showThankYouDialog();

        // Copy to clipboard as fallback
        Clipboard.setData(ClipboardData(
            text: 'To: $supportEmail\nSubject: Support Request\n\nUser ID: $_userName\nEmail: $_userEmail\n\nQuery: $queryText'
        ));
      }
    } catch (e) {
      // Handle any errors
      _showThankYouDialog();

      // Copy to clipboard as fallback
      Clipboard.setData(ClipboardData(
          text: 'To: $supportEmail\nSubject: Support Request\n\nUser ID: $_userName\nEmail: $_userEmail\n\nQuery: $queryText'
      ));
    }
  }

  // Add the new method right here, after _launchEmail
  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Thank You!', style: TextStyle(color: Colors.amber)),
          content: Text(
            'Your feedback has been received. We will get back to you soon!',
            style: TextStyle(color: Colors.amber),
          ),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.amber)),
              onPressed: () {
                Navigator.pop(context);
                _queryController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Help & Support", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Contact Support Card
            Card(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.amber, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact Support",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _queryController,
                      style: TextStyle(color: Colors.amber),
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Describe your issue or question...",
                        hintStyle: TextStyle(color: Colors.amber.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_queryController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please describe your issue before submitting')),
                            );
                            return;
                          }
                          _launchEmail();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // FAQ Section
            Text(
              "Frequently Asked Questions",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // FAQ Items
            ...List.generate(_faqItems.length, (index) {
              return _buildFAQItem(_faqItems[index]);
            }),

            SizedBox(height: 24),

            // Support Options
            Text(
              "Other Support Options",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildSupportOption(
              icon: Icons.email,
              title: "Email Support",
              subtitle: "kshana2025@gmail.com", // Replace with your actual email
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'kshana2025@gmail.com', // Replace with your actual email
                );
                try {
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    Clipboard.setData(ClipboardData(text: 'kshana2025@gmail.com')); // Replace with your actual email
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email address copied to clipboard')),
                    );
                  }
                } catch (e) {
                  Clipboard.setData(ClipboardData(text: 'kshana2025@gmail.com')); // Replace with your actual email
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email address copied to clipboard')),
                  );
                }
              },
            ),
            _buildSupportOption(
              icon: Icons.chat,
              title: "Live Chat",
              subtitle: "Monday 7 PM - 10 PM only",
              onTap: () {
                // Get current date and time
                final now = DateTime.now();
                final isMonday = now.weekday == DateTime.monday;
                final hour = now.hour;
                final isAvailable = isMonday && hour >= 19 && hour < 22;

                if (isAvailable) {
                  // If it's Monday between 7-10 PM
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.black,
                        title: Text('Live Chat', style: TextStyle(color: Colors.amber)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'For immediate assistance, please contact us via:',
                              style: TextStyle(color: Colors.amber),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: () async {
                                // Launch WhatsApp with your number
                                final whatsappUrl = "https://wa.me/+918296114661"; // Replace with your actual number
                                if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                                  await launchUrl(Uri.parse(whatsappUrl));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Could not open WhatsApp')),
                                  );
                                }
                                Navigator.pop(context);
                              },
                              child: Text('Chat on WhatsApp', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text('Cancel', style: TextStyle(color: Colors.amber)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // If outside chat hours
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.black,
                        title: Text('Live Chat Unavailable', style: TextStyle(color: Colors.amber)),
                        content: Text(
                          'Live chat support is available only on Mondays from 7 PM to 10 PM. Please check back during those hours or use email support.',
                          style: TextStyle(color: Colors.amber),
                        ),
                        actions: [
                          TextButton(
                            child: Text('OK', style: TextStyle(color: Colors.amber)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            _buildSupportOption(
              icon: Icons.phone,
              title: "Call Support",
              subtitle: "+91 8296114661", // Replace with your actual phone number
              onTap: () async {
                final Uri phoneUri = Uri(
                  scheme: 'tel',
                  path: '+918296114661', // Replace with your actual phone number (no spaces)
                );

                try {
                  await launchUrl(phoneUri);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not make a call. Phone: +91 1234567890')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.amber.withOpacity(0.5)),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        iconColor: Colors.amber,
        collapsedIconColor: Colors.amber,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item.answer,
              style: TextStyle(color: Colors.amber.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.amber.withOpacity(0.5)),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber),
        title: Text(title, style: TextStyle(color: Colors.amber)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.amber.withOpacity(0.7))),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}