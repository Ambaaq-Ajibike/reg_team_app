class GuestRegistrationRequest {
  final String guestOwner;
  final String lastName;
  final String firstName;
  final String middleName;
  final String phoneNumber;
  final String email;
  final String gender;
  final String address;

  GuestRegistrationRequest({
    required this.guestOwner,
    required this.lastName,
    required this.firstName,
    required this.middleName,
    required this.phoneNumber,
    required this.email,
    required this.gender,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'guestOwner': guestOwner,
      'lastName': lastName,
      'firstName': firstName,
      'middleName': middleName,
      'phoneNumber': phoneNumber,
      'email': email,
      'gender': gender,
      'address': address,
    };
  }
}

class GuestRegistrationResponse {
  final dynamic data;
  final List<String> messages;
  final bool succeeded;

  GuestRegistrationResponse({
    this.data,
    required this.messages,
    required this.succeeded,
  });

  factory GuestRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return GuestRegistrationResponse(
      data: json['data'],
      messages: (json['messages'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ?? [],
      succeeded: json['succeeded'] ?? false,
    );
  }
} 