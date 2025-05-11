import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class PasswordSecurityPage extends StatefulWidget {
  const PasswordSecurityPage({super.key});

  @override
  _PasswordSecurityPageState createState() => _PasswordSecurityPageState();
}

class _PasswordSecurityPageState extends State<PasswordSecurityPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isAppLockEnabled = false;
  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSecuritySettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
      _isAppLockEnabled = prefs.getBool('isAppLockEnabled') ?? false;
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } on PlatformException {
      canCheckBiometrics = false;
    }

    if (!mounted) return;

    setState(() {
      _isBiometricAvailable = canCheckBiometrics;
    });
  }

  Future<void> _saveSecuritySettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricEnabled', _isBiometricEnabled);
    await prefs.setBool('isAppLockEnabled', _isAppLockEnabled);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Security settings saved')),
    );
  }

  Future<void> _changePassword() async {
    // Validate input
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all password fields')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    // Verify current password
    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('userPassword') ?? '';

    if (_currentPasswordController.text != storedPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current password is incorrect')),
      );
      return;
    }

    // Update password
    await prefs.setString('userPassword', _newPasswordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password changed successfully')),
    );

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Password & Security", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Password Change Section
            _buildSectionHeader("Change Password"),

            _buildPasswordField(
              controller: _currentPasswordController,
              label: "Current Password",
              isVisible: _isPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),

            SizedBox(height: 16),

            _buildPasswordField(
              controller: _newPasswordController,
              label: "New Password",
              isVisible: _isNewPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
            ),

            SizedBox(height: 16),

            _buildPasswordField(
              controller: _confirmPasswordController,
              label: "Confirm New Password",
              isVisible: _isConfirmPasswordVisible,
              onToggleVisibility: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),

            SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Update Password",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // Security Settings Section
            _buildSectionHeader("Security Settings"),

            SwitchListTile(
              title: Text("App Lock", style: TextStyle(color: Colors.amber)),
              subtitle: Text(
                "Require password when opening the app",
                style: TextStyle(color: Colors.amber.withOpacity(0.7)),
              ),
              value: _isAppLockEnabled,
              activeColor: Colors.amber,
              onChanged: (value) {
                setState(() {
                  _isAppLockEnabled = value;
                });
                _saveSecuritySettings();
              },
            ),

            if (_isBiometricAvailable)
              SwitchListTile(
                title: Text("Biometric Authentication", style: TextStyle(color: Colors.amber)),
                subtitle: Text(
                  "Use fingerprint or face recognition to unlock the app",
                  style: TextStyle(color: Colors.amber.withOpacity(0.7)),
                ),
                value: _isBiometricEnabled,
                activeColor: Colors.amber,
                onChanged: (value) {
                  setState(() {
                    _isBiometricEnabled = value;
                  });
                  _saveSecuritySettings();
                },
              ),

            SizedBox(height: 32),

            // Security Tips Section
            _buildSectionHeader("Security Tips"),

            _buildSecurityTip(
              "Use a strong password with a mix of letters, numbers, and special characters.",
            ),

            _buildSecurityTip(
              "Enable biometric authentication for an extra layer of security.",
            ),

            _buildSecurityTip(
              "Never share your password or OTP with anyone, including our support team.",
            ),

            _buildSecurityTip(
              "Be cautious of phishing attempts. We will never ask for your password via email or phone.",
            ),

            SizedBox(height: 32),

            // Account Activity Section
            _buildSectionHeader("Recent Account Activity"),

            _buildActivityItem(
              "App Login",
              "Today, 10:30 AM",
              "Device: Android Phone",
            ),

            _buildActivityItem(
              "Password Changed",
              "April 20, 2025",
              "Device: Android Phone",
            ),

            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Full activity log will be available soon')),
                  );
                },
                child: Text(
                  "View Full Activity Log",
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(color: Colors.amber),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.amber,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }

  Widget _buildSecurityTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security, color: Colors.amber, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(color: Colors.amber.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String action, String time, String device) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.amber.withOpacity(0.5)),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.access_time, color: Colors.amber),
        title: Text(action, style: TextStyle(color: Colors.amber)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time, style: TextStyle(color: Colors.amber.withOpacity(0.7))),
            Text(device, style: TextStyle(color: Colors.amber.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}