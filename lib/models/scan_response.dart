class ScanResponse {
  final String message;
  final String redirect;
  final bool status;

  ScanResponse({
    required this.message,
    required this.redirect,
    required this.status,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    return ScanResponse(
      message: json['message'] ?? '',
      redirect: json['redirect'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'redirect': redirect,
      'status': status,
    };
  }
} 