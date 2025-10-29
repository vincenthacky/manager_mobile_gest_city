import 'package:dio/dio.dart';
import 'package:manager_gest_city/features/authentication/model/refresh_response.dart';
import '../../../core/network/dio_client.dart';
import '../model/login_response.dart';
import '../model/user_model.dart';

class AuthDataSource {
  final Dio _dio = DioClient.instance;

  Future<LoginResponse> login(String identifiant, String motDePasse) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'phone_or_email': identifiant, 'password': motDePasse},
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Erreur de connexion',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ?? 'Erreur de connexion';
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

  Future<RefreshResponse> refreshToken(String refreshToken) async {
    try {
      var dio = Dio();
      final response = await dio.post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200) {
        return RefreshResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Erreur lors du rafraîchissement du token',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            'Erreur lors du rafraîchissement du token';
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

  Future<void> logout() async {
    try {
      await _dio.post('/api/logout');
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/api/profile');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Erreur lors de la récupération du profil',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            'Erreur lors de la récupération du profil';
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
