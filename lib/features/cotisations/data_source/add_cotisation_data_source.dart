import 'package:dio/dio.dart';
import 'package:manager_gest_city/features/cotisations/models/add_cotisation_response.dart';
import '../../../core/network/dio_client.dart';

class AddCotisationDataSource {
  final Dio _dio = DioClient.instance;

  Future<AddCotisationResponse> createContribution(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post('/contributions', data: payload);

      // The server returns 201 on created; accept 200/201 for flexibility.
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ensure we provide a Map<String, dynamic> to fromJson
        final data = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        return AddCotisationResponse.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Erreur lors de la création de la cotisation',
        );
      }
    } on DioException catch (e) {
      // Try to produce a useful message when the server responded with error body
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            'Erreur lors de la création de la cotisation';
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: errorMessage,
        );
      } else {
        throw DioException(
          requestOptions: e.requestOptions,
          message: 'Erreur de réseau. Vérifiez votre connexion internet.',
        );
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
}
