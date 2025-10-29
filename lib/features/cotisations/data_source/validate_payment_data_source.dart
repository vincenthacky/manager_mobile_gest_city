import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/validate_payment_response.dart';

class ValidatePaymentDataSource {
  final Dio _dio = DioClient.instance;

  /// Sends a POST request to /contributions/verify-qrcode?token=<token>
  Future<ValidatePaymentResponse> verifyQrCode(String token) async {
    try {
      final response = await _dio.post(
        '/contributions/verify-qrcode',
        queryParameters: {'token': token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        return ValidatePaymentResponse.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Erreur lors de la vérification du QR code',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? e.message;
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: errorMessage,
        );
      }
      rethrow;
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
}
