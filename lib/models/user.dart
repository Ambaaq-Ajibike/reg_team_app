class User {
  final String memberNo;
  final String firstName;
  final String lastName;
  final List<dynamic> roles;

  User({
    required this.memberNo,
    required this.firstName,
    required this.lastName,
    required this.roles,
  });

  // Mock factory method
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      memberNo: json['userName'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      roles: json['roles'] as List<dynamic>,
    );
  }
} 