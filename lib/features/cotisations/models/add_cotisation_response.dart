import 'package:manager_gest_city/features/admin/models/contribution_model.dart';

class AddCotisationResponse {
  final bool success;
  final int statusCode;
  final String message;
  final ContributionModel? data;

  AddCotisationResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory AddCotisationResponse.fromJson(Map<String, dynamic> json) {
    return AddCotisationResponse(
      success: json['success'] == true,
      statusCode: json['status_code'] is int
          ? json['status_code'] as int
          : int.tryParse('${json['status_code']}') ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? ContributionModel.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    return 'AddCotisationResponse(success: $success, statusCode: $statusCode, message: $message, data: $data)';
  }
}
