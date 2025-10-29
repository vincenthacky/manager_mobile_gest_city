// /Users/kouameteddysaoure/Projects/community-handler/admin/lib/features/admin/model/home_response.dart

import 'package:manager_gest_city/features/admin/models/home_model.dart';

class HomeResponse {
  final bool success;
  final int statusCode;
  final String message;
  final AdminData? data;

  HomeResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      success: json['success'] as bool? ?? false,
      statusCode: json['status_code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? AdminData.fromJson(Map<String, dynamic>.from(json['data'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }

  HomeResponse copyWith({
    bool? success,
    int? statusCode,
    String? message,
    AdminData? data,
  }) {
    return HomeResponse(
      success: success ?? this.success,
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'HomeResponse(success: $success, statusCode: $statusCode, message: $message, data: $data)';
  }
}
