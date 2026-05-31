import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (response['success'] == true) {
        final user = User.fromJson(response);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', user.token);
        await prefs.setInt('user_id', user.id);
        await prefs.setString('name', user.name);
        // DO NOT store balance here – it will be fetched from profile API
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      } else {
        _showError(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showRegisterInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create an Account'),
        content: Text('Please visit our website to register:\n\nhttps://quantumxvault.net/auth/register.php'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1120), Color(0xFF050A15)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF3B82F6)]),
                      ),
                      child: Center(
                        child: Text(
                          'W',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'WEALTH ASSURE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Secure Access Portal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 32),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username or Email',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator()
                        : Column(
                            children: [
                              ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2563EB),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('ACCESS DASHBOARD', style: TextStyle(fontSize: 16)),
                              ),
                              SizedBox(height: 12),
                              TextButton(
                                onPressed: _showRegisterInfo,
                                child: Text(
                                  'Don’t have an account? Create one',
                                  style: TextStyle(color: Color(0xFF8B5CF6)),
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
      ),
    );
  }
}
