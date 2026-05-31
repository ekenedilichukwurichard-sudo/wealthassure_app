import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _logout();
      return;
    }

    try {
      final response = await ApiService.getProfile(token);
      if (response['success'] == true) {
        setState(() {
          _userName = response['user']['username'];
          _userEmail = response['user']['email'];
          _userRole = response['user']['role'];
          _isLoading = false;
        });
      } else {
        _logout();
      }
    } catch (e) {
      _logout();
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFF0A1120),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.account_circle, size: 50, color: Color(0xFF2563EB)),
                      title: Text('Welcome, $_userName'),
                      subtitle: Text('Role: $_userRole'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProfileScreen()),
                          ).then((_) => _loadProfile());
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildActionCard(Icons.account_balance_wallet, 'Balance', '\$0.00'),
                      _buildActionCard(Icons.history, 'Transactions', 'View'),
                      _buildActionCard(Icons.cloud_upload, 'Deposit', 'Add Funds'),
                      _buildActionCard(Icons.cloud_download, 'Withdraw', 'Request'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String value) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Color(0xFF2563EB)),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(value, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
