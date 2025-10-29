import 'package:dio/dio.dart';
import 'package:manager_gest_city/features/admin/models/contribution_response.dart';
import '../../../core/network/dio_client.dart';
import '../models/home_response.dart';

class AdminHomeDataSource {
  final Dio _dio = DioClient.instance;

  Future<HomeResponse> getHomeData() async {
    try {
      final response = await _dio.get("/admin/home");

      if (response.statusCode == 200) {
        return HomeResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "Erreur lors de la récupération des informations",
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            'Erreur lors de la récupération des informations';
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

  Future<ContributionListResponse> getContributions({
    int perPage = 3,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final qp = <String, dynamic>{'per_page': perPage};
      if (queryParameters != null) qp.addAll(queryParameters);

      final response = await _dio.get(
        '/contributions',
        queryParameters: qp,
      );

      if (response.statusCode == 200) {
        return ContributionListResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Erreur lors de la récupération des cotisations',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            'Erreur lors de la récupération des cotisations';
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
