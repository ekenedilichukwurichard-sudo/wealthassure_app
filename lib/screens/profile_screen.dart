import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _user = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await ApiService.getProfile(token);
      if (response['success'] == true) {
        setState(() {
          _user = response['user'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF2563EB),
                    child: Text(
                      _user['username']?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(fontSize: 50, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Username'),
                    subtitle: Text(_user['username'] ?? ''),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(_user['email'] ?? ''),
                  ),
                  ListTile(
                    leading: Icon(Icons.admin_panel_settings),
                    title: Text('Role'),
                    subtitle: Text(_user['role'] ?? ''),
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Joined'),
                    subtitle: Text(_user['joined_date'] ?? ''),
                  ),
                ],
              ),
            ),
    );
  }
}
