import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'personal_info_page.dart';
import 'help_support_page.dart';
import 'privacy_policy_page.dart';
import 'password_security_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'terms_conditions_page.dart';



class ProfilePage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const ProfilePage({super.key, required this.onLocaleChange});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  String selectedGender = 'Male';
  String selectedLanguage = 'English';
  File? _imageFile;
  String _userName = 'User123';
  String _userId = 'User123';

  @override
  void initState() {
    super.initState();
    _loadLocalProfileImage();
    _loadUserPreferences();
  }
  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      selectedGender = prefs.getString('selectedGender') ?? 'Male';
      _userName = prefs.getString('userName') ?? 'User123';
      _userId = prefs.getString('userId') ?? 'User123'; // Add this line
    });
  }
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final savedImage = await File(pickedFile.path).copy(
          '${appDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImagePath', savedImage.path);

        if (mounted) {
          setState(() => _imageFile = savedImage);
          await Future.delayed(Duration(milliseconds: 100));
          Navigator.pop(context);
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save image: $e')),
          );
        }
      }
    }
  }

  void _loadLocalProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profileImagePath');

      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          setState(() => _imageFile = file);
        } else {
          await prefs.remove('profileImagePath');
        }
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Select Image', style: TextStyle(color: Colors.amber)),
          actions: [
            TextButton(
              child: Text('Gallery', style: TextStyle(color: Colors.amber)),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            TextButton(
              child: Text('Camera', style: TextStyle(color: Colors.amber)),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(String language) async {
    setState(() {
      selectedLanguage = language;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);

    if (language == 'English') {
      widget.onLocaleChange(Locale('en', 'US'));
    } else if (language == 'Kannada') {
      widget.onLocaleChange(Locale('kn', 'IN'));
    } else if (language == 'Hindi') {
      widget.onLocaleChange(Locale('hi', 'IN'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Profile", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _showImagePickerDialog,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.7),
                            spreadRadius: 3,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.amber,
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.amber),
              title: Text("Language", style: TextStyle(color: Colors.amber)),

              trailing: DropdownButton<String>(
                value: selectedLanguage,
                dropdownColor: Colors.black,
                underline: SizedBox(),
                items: ['English', 'Kannada', 'Hindi'].map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language, style: TextStyle(color: Colors.amber)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) _changeLanguage(newValue);
                },
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Welcome Back, $_userName!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "User ID: $_userId",
              style: TextStyle(color: Colors.amber, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.person, color: Colors.amber),
              title: Text("Personal Info", style: TextStyle(color: Colors.amber)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              onTap: () async {  // Add async keyword here
                final result = await Navigator.push(  // Add await and store the result
                  context,
                  MaterialPageRoute(builder: (context) => PersonalInfoPage()),
                );

                // If personal info was updated, pass the result back to the dashboard
                if (result == true) {
                  print("PERSONAL INFO UPDATED, PASSING RESULT BACK");
                  Navigator.pop(context, true);  // Return true to the dashboard
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.card_membership, color: Colors.amber),
              title: Text("Membership Tiers", style: TextStyle(color: Colors.amber)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              onTap: () {
                _showMembershipTiers(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.amber),
              title: Text("Help & Support", style: TextStyle(color: Colors.amber)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpSupportPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.amber),
              title: Text("Privacy Policy", style: TextStyle(color: Colors.amber)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: Colors.amber),
              title: Text("Password & Security", style: TextStyle(color: Colors.amber)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordSecurityPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.link, color: Colors.amber),
              title: Text("Join us on Instagram", style: TextStyle(color: Colors.amber)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              onTap: () async {
                final Uri instagramUrl = Uri.parse('https://www.instagram.com/kshanaworld/');
                try {
                  if (await launchUrl(instagramUrl, mode: LaunchMode.externalApplication)) {
                    // Launch successful
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open Instagram')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.amber),
              title: Text("Logout", style: TextStyle(color: Colors.amber)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.black,
                      title: Text('Logout', style: TextStyle(color: Colors.amber)),
                      content: Text('Are you sure you want to logout?', style: TextStyle(color: Colors.amber)),
                      actions: [
                        TextButton(
                          child: Text('Cancel', style: TextStyle(color: Colors.amber)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text('Logout', style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('rememberMe', false); // Clear "remember me" setting

                            Navigator.pop(context); // Close dialog
                            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false); // Go to login and clear all routes
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.article, color: Colors.amber),
              title: Text("Terms and Conditions", style: TextStyle(color: Colors.amber)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermsConditionsPage()),
                );
              },
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.wc, color: Colors.amber),
              title: Text("Gender", style: TextStyle(color: Colors.amber)),
              trailing: DropdownButton<String>(
                value: selectedGender,
                dropdownColor: Colors.black,
                underline: SizedBox(),
                items: ['Male', 'Female', 'Other'].map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender, style: TextStyle(color: Colors.amber)),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  setState(() {
                    selectedGender = newValue!;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('selectedGender', selectedGender);
                },
              ),
            ),
            SizedBox(height: 20),
            Center(child: Text("App Version: 1.0.0", style: TextStyle(color: Colors.amber))),
          ],
        ),
      ),
    );
  }

  Widget buildGoldTile({required IconData icon, required String text}) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(text, style: TextStyle(color: Colors.amber)),
      onTap: () {},
    );
  }
}
void _showMembershipTiers(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
        ),
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          controller: controller,
          child: buildMembershipTiers(context),
        ),
      ),
    ),
  );
}
Widget buildMembershipTiers(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.card_membership, color: Colors.amber, size: 30),
          SizedBox(width: 10),
          Text(
            "Membership Tiers",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      SizedBox(height: 10),
      Text(
        "Upgrade your membership to unlock more rewards and features",
        style: TextStyle(color: Colors.white70),
      ),
      SizedBox(height: 20),
      _buildTierCard(
        title: "Basic",
        price: "Free",
        features: [
          "Daily rewards up to 50 coins",
          "Access to standard tasks",
          "Basic referral rewards",
          "Monthly lucky draw entry"
        ],
        color: Colors.grey.shade800,
        borderColor: Colors.amber.withOpacity(0.3),
      ),
      SizedBox(height: 16),
      _buildTierCard(
        title: "Pro",
        price: "₹199/month",
        features: [
          "Daily rewards up to 200 coins",
          "Access to premium tasks",
          "Enhanced referral bonuses",
          "2× monthly lucky draw entries",
          "Ad-free experience"
        ],
        color: Colors.amber.shade900,
        borderColor: Colors.amber,
      ),
      SizedBox(height: 16),
      _buildTierCard(
        title: "Pro Plus",
        price: "₹499/month",
        features: [
          "Daily rewards up to 500 coins",
          "Access to all tasks including exclusives",
          "Maximum referral bonuses",
          "5× monthly lucky draw entries",
          "Ad-free experience",
          "Priority coin redemption",
          "Dedicated customer support"
        ],
        color: Colors.black,
        borderColor: Colors.amber,
        isGradient: true,
      ),
    ],
  );
}

Widget _buildTierCard({
  required String title,
  required String price,
  required List<String> features,
  required Color color,
  required Color borderColor,
  bool isGradient = false,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 2),
      gradient: isGradient
          ? LinearGradient(
        colors: [Colors.black, Color(0xFF3A3A3A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
          : null,
      boxShadow: [
        BoxShadow(
          color: isGradient
              ? Colors.amber.withOpacity(0.3)
              : Colors.black.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Text(
                price,
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        )),
        SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Add your subscription logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              title == "Basic" ? "Current Plan" : "Upgrade Now",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}