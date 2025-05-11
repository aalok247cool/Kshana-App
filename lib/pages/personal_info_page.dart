import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _userIdController.dispose(); // Add this line
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? 'User123';
      _emailController.text = prefs.getString('userEmail') ?? 'user@example.com';
      _phoneController.text = prefs.getString('userPhone') ?? '';
      _dobController.text = prefs.getString('userDob') ?? '';
      _addressController.text = prefs.getString('userAddress') ?? '';
      _userIdController.text = prefs.getString('userId') ?? 'User123'; // Add this line
    });
  }

  Future<void> _saveUserInfo() async {

    final prefs = await SharedPreferences.getInstance();
    final existingId = prefs.getString('userId');


    if (_userIdController.text != existingId && _userIdController.text == 'taken') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This User ID is already taken. Please choose another.')),
      );
      return; // Don't save if ID is taken
    }

    // Debug print to verify the username being saved
    print("SAVING USERNAME: ${_nameController.text}");

    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);
    await prefs.setString('userPhone', _phoneController.text);
    await prefs.setString('userDob', _dobController.text);
    await prefs.setString('userAddress', _addressController.text);
    await prefs.setString('userId', _userIdController.text); // Add this line

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Personal information saved successfully!')),
    );

    // Return true to indicate data was changed
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Personal Information", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.amber),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.amber),
            onPressed: () {
              if (_isEditing) {
                // Save the information
                _saveUserInfo();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoField("Full Name", _nameController, Icons.person),
            _buildInfoField("Email", _emailController, Icons.email),
            _buildInfoField("Phone Number", _phoneController, Icons.phone, keyboardType: TextInputType.phone),
            _buildInfoField("Date of Birth", _dobController, Icons.cake),
            _buildInfoField("Address", _addressController, Icons.home, maxLines: 3),
            _buildInfoField("User ID", _userIdController, Icons.badge),

            SizedBox(height: 20),

            if (!_isEditing) ...[
              Divider(color: Colors.amber.withOpacity(0.5)),
              ListTile(
                leading: Icon(Icons.security, color: Colors.amber),
                title: Text("KYC Status", style: TextStyle(color: Colors.amber)),
                subtitle: Text("Not Verified", style: TextStyle(color: Colors.red)),
                trailing: ElevatedButton(
                  onPressed: () {
                    // We'll implement KYC verification later
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('KYC verification will be implemented soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: Text("Verify", style: TextStyle(color: Colors.black)),
                ),
              ),
              Divider(color: Colors.amber.withOpacity(0.5)),
              ListTile(
                leading: Icon(Icons.verified_user, color: Colors.amber),
                title: Text("Account Status", style: TextStyle(color: Colors.amber)),
                subtitle: Text("Active", style: TextStyle(color: Colors.green)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.amber),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.amber),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.black,
        ),
      ),
    );
  }
}