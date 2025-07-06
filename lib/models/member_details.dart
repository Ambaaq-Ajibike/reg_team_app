class MemberDetails {
  final String chandaNo;
  final String surname;
  final String firstName;
  final String auxillaryBodyName;
  final String? middleName;
  final String dateOfBirth;
  final String? email;
  final String? phoneNo;
  final int jamaatId;
  final String jamaatName;
  final int circuitId;
  final String? circuitCode;
  final String circuitName;
  final String sex;
  final String maritalStatus;
  final String? address;
  final String? nextOfKinPhoneNo;
  final String? nextOfKinName;
  final String nationality;
  final String? photoUrl;
  final bool isVolunteer;
  final bool hasRegistered;

  MemberDetails({
    required this.chandaNo,
    required this.surname,
    required this.firstName,
    required this.auxillaryBodyName,
    this.middleName,
    required this.dateOfBirth,
    this.email,
    this.phoneNo,
    required this.jamaatId,
    required this.jamaatName,
    required this.circuitId,
    this.circuitCode,
    required this.circuitName,
    required this.sex,
    required this.maritalStatus,
    this.address,
    this.nextOfKinPhoneNo,
    this.nextOfKinName,
    required this.nationality,
    this.photoUrl,
    required this.isVolunteer,
    required this.hasRegistered,
  });

  factory MemberDetails.fromJson(Map<String, dynamic> json) {
    return MemberDetails(
      chandaNo: json['chandaNo'] ?? '',
      surname: json['surname'] ?? '',
      firstName: json['firstName'] ?? '',
      auxillaryBodyName: json['auxillaryBodyName'] ?? '',
      middleName: json['middleName'],
      dateOfBirth: json['dateOfBirth'] ?? '',
      email: json['email'],
      phoneNo: json['phoneNo'],
      jamaatId: json['jamaatId'] ?? 0,
      jamaatName: json['jamaatName'] ?? '',
      circuitId: json['circuitId'] ?? 0,
      circuitCode: json['circuitCode'],
      circuitName: json['circuitName'] ?? '',
      sex: json['sex'] ?? '',
      maritalStatus: json['maritalStatus'] ?? '',
      address: json['address'],
      nextOfKinPhoneNo: json['nextOfKinPhoneNo'],
      nextOfKinName: json['nextOfKinName'],
      nationality: json['nationality'] ?? '',
      photoUrl: json['photoUrl'],
      isVolunteer: json['isVolunteer'] ?? false,
      hasRegistered: json['hasRegistered'] ?? false,
    );
  }

  String get fullName {
    final parts = [firstName, middleName, surname].where((part) => part != null && part.isNotEmpty);
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'chandaNo': chandaNo,
      'surname': surname,
      'firstName': firstName,
      'auxillaryBodyName': auxillaryBodyName,
      'middleName': middleName,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'phoneNo': phoneNo,
      'jamaatId': jamaatId,
      'jamaatName': jamaatName,
      'circuitId': circuitId,
      'circuitCode': circuitCode,
      'circuitName': circuitName,
      'sex': sex,
      'maritalStatus': maritalStatus,
      'address': address,
      'nextOfKinPhoneNo': nextOfKinPhoneNo,
      'nextOfKinName': nextOfKinName,
      'nationality': nationality,
      'photoUrl': photoUrl,
      'isVolunteer': isVolunteer,
      'hasRegistered': hasRegistered,
    };
  }
} 