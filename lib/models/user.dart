class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String token;
  final double balance;
  final String kycStatus;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.balance,
    required this.kycStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
      balance: (json['balance'] ?? 0).toDouble(),
      kycStatus: json['kyc_status'] ?? 'pending',
    );
  }
}
