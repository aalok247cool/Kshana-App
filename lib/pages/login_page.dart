import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isNewUser = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserExists();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkIfUserExists() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    final hasPassword = prefs.getString('userPassword') != null;

    if (userEmail != null && hasPassword) {
      setState(() {
        _isNewUser = false;
        _emailController.text = userEmail;
        _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
      });
    }

    setState(() => _isLoading = false);
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

    // If biometrics are available and enabled, try to authenticate
    if (_isBiometricAvailable && _isBiometricEnabled && !_isNewUser) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint (or face) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      _loginSuccess();
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    if (_isNewUser) {
      // Register new user
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setString('userPassword', _passwordController.text); // In a real app, hash this!
      await prefs.setString('userName', _emailController.text.split('@')[0]); // Default name from email

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully!')),
      );

      _loginSuccess();
    } else {
      // Verify existing user
      final storedPassword = prefs.getString('userPassword');

      if (_passwordController.text == storedPassword) {
        if (_rememberMe) {
          await prefs.setBool('rememberMe', true);
        }

        _loginSuccess();
      } else {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  void _loginSuccess() {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  void _toggleMode() {
    setState(() {
      _isNewUser = !_isNewUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.amber))
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.monetization_on,
                      size: 80,
                      color: Colors.amber,
                    ),
                  ),

                  SizedBox(height: 24),

                  // App Name
                  Text(
                    "Kshana App",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    _isNewUser ? "Create an Account" : "Welcome Back",
                    style: TextStyle(
                      color: Colors.amber.withOpacity(0.8),
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 40),

                  // Email Field
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

                  SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: Colors.amber),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.amber.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.lock, color: Colors.amber),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
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

                  // Remember Me Checkbox (only for login)
                  if (!_isNewUser)
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.amber;
                              }
                              return Colors.amber.withOpacity(0.5);
                            },
                          ),
                        ),
                        Text(
                          "Remember Me",
                          style: TextStyle(color: Colors.amber),
                        ),

                        Spacer(),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.amber),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 24),

                  // Login/Signup Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isNewUser ? "Sign Up" : "Login",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Biometric Login Button (only for existing users)
                  if (_isBiometricAvailable && !_isNewUser)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.fingerprint, color: Colors.black),
                        label: Text(
                          "Login with Biometrics",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _authenticateWithBiometrics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.withOpacity(0.8),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 24),

                  // Toggle between Login and Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isNewUser ? "Already have an account? " : "Don't have an account? ",
                        style: TextStyle(color: Colors.amber.withOpacity(0.8)),
                      ),
                      TextButton(
                        onPressed: _toggleMode,
                        child: Text(
                          _isNewUser ? "Login" : "Sign Up",
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}