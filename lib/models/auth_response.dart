class AuthResponse {
  final AuthData data;
  final String message;
  final bool status;

  AuthResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      data: AuthData.fromJson(json['data']),
      message: json['message'] ?? '',
      status: json['status'] ?? false,
    );
  }
}

class AuthData {
  final String userName;
  final String firstName;
  final String lastName;
  final List<String> roles;

  AuthData({
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.roles,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      userName: json['userName'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      roles: (json['roles'] as List<dynamic>?)
          ?.map((role) => role.toString())
          .toList() ?? [],
    );
  }

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles,
    };
  }
} 