import 'user_model.dart';

class LoginResponse {
  final bool success;
  final int statusCode;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      statusCode: json['status_code'] as int,
      message: json['message'] as String,
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class LoginData {
  final UserModel user;
  final TokensData tokens;

  LoginData({required this.user, required this.tokens});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokensData.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': tokens.toJson()};
  }

  // convenience getters for backward compatibility with code that expects a plain access token
  String get accessToken => tokens.accessToken;
  String get refreshToken => tokens.refreshToken;
  int get expiresIn => tokens.expiresIn;
}

class TokensData {
  final String accessToken;
  final int expiresIn;
  final String refreshToken;

  TokensData({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory TokensData.fromJson(Map<String, dynamic> json) {
    return TokensData(
      accessToken: json['access_token'] as String? ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
    };
  }
}
