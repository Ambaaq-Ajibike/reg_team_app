class RegistrationResponse {
  final List<RegistrationData> data;
  final List<String> messages;
  final bool succeeded;

  RegistrationResponse({
    required this.data,
    required this.messages,
    required this.succeeded,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => RegistrationData.fromJson(item))
          .toList() ?? [],
      messages: (json['messages'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ?? [],
      succeeded: json['succeeded'] ?? false,
    );
  }
}

class RegistrationData {
  final String id;
  final String membershipNumber;
  final String registrationNumber;
  final String lastName;
  final String firstName;
  final String? middleName;
  final String? phoneNumber;
  final String? email;
  final String? jamaatName;
  final int jamaatId;
  final int circuitId;
  final String circuitName;
  final String gender;
  final String? address;
  final String registrationConfirmed;
  final String? photo;
  final String qrCode;
  final String qrCodeImage;
  final String? auxiliaryBody;
  final int status;
  final String participantTypeId;
  final String? participantType;
  final String? eventName;
  final bool isDeleted;
  final bool isCheckedIn;
  final String createdOn;
  final String? createdBy;
  final bool isVolunteer;

  RegistrationData({
    required this.id,
    required this.membershipNumber,
    required this.registrationNumber,
    required this.lastName,
    required this.firstName,
    this.middleName,
    this.phoneNumber,
    this.email,
    this.jamaatName,
    required this.jamaatId,
    required this.circuitId,
    required this.circuitName,
    required this.gender,
    this.address,
    required this.registrationConfirmed,
    this.photo,
    required this.qrCode,
    required this.qrCodeImage,
    this.auxiliaryBody,
    required this.status,
    required this.participantTypeId,
    this.participantType,
    this.eventName,
    required this.isDeleted,
    required this.isCheckedIn,
    required this.createdOn,
    this.createdBy,
    required this.isVolunteer,
  });

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      id: json['id'] ?? '',
      membershipNumber: json['membershipNumber'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      lastName: json['lastName'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      jamaatName: json['jamaatName'],
      jamaatId: json['jamaatId'] ?? 0,
      circuitId: json['circuitId'] ?? 0,
      circuitName: json['circuitName'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'],
      registrationConfirmed: json['registrationConfirmed'] ?? '',
      photo: json['photo'],
      qrCode: json['qrCode'] ?? '',
      qrCodeImage: json['qrCodeImage'] ?? '',
      auxiliaryBody: json['auxiliaryBody'],
      status: json['status'] ?? 0,
      participantTypeId: json['participantTypeId'] ?? '',
      participantType: json['participantType'],
      eventName: json['eventName'],
      isDeleted: json['isDeleted'] ?? false,
      isCheckedIn: json['isCheckedIn'] ?? false,
      createdOn: json['createdOn'] ?? '',
      createdBy: json['createdBy'],
      isVolunteer: json['isVolunteer'] ?? false,
    );
  }

  String get fullName {
    final parts = [firstName, middleName, lastName].where((part) => part != null && part.isNotEmpty);
    return parts.join(' ');
  }
} 