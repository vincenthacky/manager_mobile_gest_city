import 'dart:convert';

class RefreshResponse {
  final bool success;
  final int statusCode;
  final String message;
  final RefreshData? data;

  RefreshResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory RefreshResponse.fromRawJson(String str) =>
      RefreshResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      RefreshResponse(
        success: json['success'] as bool? ?? false,
        statusCode: json['status_code'] is int
            ? json['status_code'] as int
            : int.tryParse('${json['status_code']}') ?? 0,
        message: json['message'] as String? ?? '',
        data: json['data'] != null
            ? RefreshData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'status_code': statusCode,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };

  RefreshResponse copyWith({
    bool? success,
    int? statusCode,
    String? message,
    RefreshData? data,
  }) => RefreshResponse(
    success: success ?? this.success,
    statusCode: statusCode ?? this.statusCode,
    message: message ?? this.message,
    data: data ?? this.data,
  );

  @override
  String toString() =>
      'RefreshResponse(success: $success, statusCode: $statusCode, message: $message, data: $data)';
}

class RefreshData {
  final Tokens tokens;

  RefreshData({required this.tokens});

  factory RefreshData.fromJson(Map<String, dynamic> json) => RefreshData(
    tokens: Tokens.fromJson(json['tokens'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {'tokens': tokens.toJson()};

  RefreshData copyWith({Tokens? tokens}) =>
      RefreshData(tokens: tokens ?? this.tokens);

  @override
  String toString() => 'RefreshData(tokens: $tokens)';
}

class Tokens {
  final String accessToken;
  final String refreshToken;

  Tokens({required this.accessToken, required this.refreshToken});

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
    accessToken: json['access_token'] as String? ?? '',
    refreshToken: json['refresh_token'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  Tokens copyWith({String? accessToken, String? refreshToken}) => Tokens(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
  );

  @override
  String toString() =>
      'Token(accessToken: $accessToken, refreshToken: $refreshToken)';
}
