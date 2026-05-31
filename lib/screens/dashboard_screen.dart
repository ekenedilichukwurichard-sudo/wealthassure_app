import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _logout();
      return;
    }
    try {
      final data = await ApiService.getProfile(token);
      if (data['success'] == true) {
        setState(() {
          _profile = data;
          _isLoading = false;
        });
      } else {
        _error = data['message'] ?? 'Failed to load profile';
        _isLoading = false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: () => _loadData(),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _profile['user'];
    final financial = _profile['financial'];
    final transactions = _profile['transactions'] as List? ?? [];
    final investments = _profile['active_investments'] as List? ?? [];
    final cryptoCoins = _profile['crypto_coins'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Wealth Assure'),
        backgroundColor: Color(0xFF0A1120),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Balance', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      '£${user['balance']?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStat('Deposits', '£${financial['total_deposits']?.toStringAsFixed(2) ?? '0.00'}'),
                        SizedBox(width: 16),
                        _buildStat('Withdrawn', '£${financial['total_withdraw']?.toStringAsFixed(2) ?? '0.00'}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Crypto Coins
            Text('Your Crypto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (cryptoCoins.isEmpty)
              Center(child: Text('No crypto assets'))
            else
              ...cryptoCoins.map((coin) => Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF2563EB),
                    child: Text(coin['crypto_symbol']?.substring(0,1) ?? '?'),
                  ),
                  title: Text(coin['crypto_name'] ?? coin['symbol']),
                  subtitle: Text('Balance: ${coin['quantity']?.toStringAsFixed(8) ?? '0'} ${coin['crypto_symbol']}'),
                  trailing: Text('≈ £${coin['current_value']?.toStringAsFixed(2) ?? '0.00'}'),
                ),
              )),

            SizedBox(height: 20),

            // Recent Transactions
            Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (transactions.isEmpty)
              Center(child: Text('No transactions'))
            else
              ...transactions.map((tx) => ListTile(
                leading: Icon(
                  tx['type'] == 'deposit' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: tx['type'] == 'deposit' ? Colors.green : Colors.red,
                ),
                title: Text(tx['description'] ?? 'Transaction'),
                subtitle: Text(tx['created_at']),
                trailing: Text(
                  tx['type'] == 'deposit' ? '+£${tx['amount']}' : '-£${tx['amount']}',
                  style: TextStyle(
                    color: tx['type'] == 'deposit' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),

            SizedBox(height: 20),

            // Active Investments
            Text('Active Investments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (investments.isEmpty)
              Center(child: Text('No active investments'))
            else
              ...investments.map((inv) => Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(inv['plan_name'] ?? 'Investment Plan'),
                  subtitle: Text('Invested: £${inv['invested_amount']}'),
                  trailing: Text('ROI: ${inv['daily_roi_percent']}% daily'),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
