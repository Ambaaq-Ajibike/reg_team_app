class Member {
  final String id;
  final String memberNumber;
  final String name;
  final String jamaat;
  final String circuit;
  bool isCheckedIn;
  DateTime? checkInTime;
  String? checkedInBy;

  Member({
    required this.id,
    required this.memberNumber,
    required this.name,
    required this.jamaat,
    required this.circuit,
    this.isCheckedIn = false,
    this.checkInTime,
    this.checkedInBy,
  });

  // Mock factory method
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      memberNumber: json['memberNumber'] as String,
      name: json['name'] as String,
      jamaat: json['jamaat'] as String,
      circuit: json['circuit'] as String,
      isCheckedIn: json['isCheckedIn'] as bool? ?? false,
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime'] as String) : null,
      checkedInBy: json['checkedInBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberNumber': memberNumber,
      'name': name,
      'jamaat': jamaat,
      'circuit': circuit,
      'isCheckedIn': isCheckedIn,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkedInBy': checkedInBy,
    };
  }
} 