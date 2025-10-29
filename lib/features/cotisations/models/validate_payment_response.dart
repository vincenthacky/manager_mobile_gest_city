class ValidatePaymentResponse {
  final bool success;
  final int statusCode;
  final String message;

  ValidatePaymentResponse({
    required this.success,
    required this.statusCode,
    required this.message,
  });

  factory ValidatePaymentResponse.fromJson(Map<String, dynamic> json) {
    return ValidatePaymentResponse(
      success: json['success'] == true,
      statusCode: (json['status_code'] is int)
          ? json['status_code'] as int
          : int.tryParse(json['status_code']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}
