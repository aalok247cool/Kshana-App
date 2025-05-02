import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String _generatedOtp = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Check if email exists
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('userEmail');

    if (storedEmail != _emailController.text) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email not found')),
      );
      return;
    }

    // Generate a 6-digit OTP
    _generatedOtp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    // In a real app, you would send this OTP via email or SMS
    // For demo purposes, we'll just show it in a dialog

    setState(() {
      _isOtpSent = true;
      _isLoading = false;
    });

    // Show OTP in dialog (for demo only)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('OTP Sent', style: TextStyle(color: Colors.amber)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'An OTP has been sent to your email.',
                style: TextStyle(color: Colors.amber),
              ),
              SizedBox(height: 16),
              Text(
                'Demo OTP: $_generatedOtp',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
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

  Future<void> _resetPassword() async {
    if (_otpController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_otpController.text != _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Update password
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPassword', _newPasswordController.text);

    setState(() => _isLoading = false);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset successfully')),
    );

    // Navigate back to login
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Reset Password", style: TextStyle(color: Colors.amber)),
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.amber))
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Colors.amber,
                ),

                SizedBox(height: 24),

                Text(
                  _isOtpSent ? "Verify OTP" : "Forgot Password",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  _isOtpSent
                      ? "Enter the OTP sent to your email and set a new password"
                      : "Enter your email to receive a password reset OTP",
                  style: TextStyle(
                    color: Colors.amber.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 32),

                if (!_isOtpSent)
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.amber),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.amber.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.email, color: Colors.amber),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),

                if (_isOtpSent) ...[
                  TextField(
                    controller: _otpController,
                    style: TextStyle(color: Colors.amber),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "OTP",
                      labelStyle: TextStyle(color: Colors.amber.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.pin, color: Colors.amber),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),

                  SizedBox(height: 16),

                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.amber),
                    decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: TextStyle(color: Colors.amber.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.lock, color: Colors.amber),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                ],

                SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isOtpSent ? _resetPassword : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isOtpSent ? "Reset Password" : "Send OTP",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                if (_isOtpSent)
                  TextButton(
                    onPressed: _sendOtp,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}