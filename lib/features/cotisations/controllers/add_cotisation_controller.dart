import 'package:flutter/material.dart';
import '../data_source/add_cotisation_data_source.dart';
import '../models/add_cotisation_response.dart';

enum AddCotisationStatus { initial, loading, success, error }

class AddCotisationController extends ChangeNotifier {
  final AddCotisationDataSource _dataSource = AddCotisationDataSource();

  AddCotisationStatus _status = AddCotisationStatus.initial;
  AddCotisationResponse? _response;
  String? _errorMessage;

  AddCotisationStatus get status => _status;
  AddCotisationResponse? get response => _response;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AddCotisationStatus.loading;
  bool get hasError => _status == AddCotisationStatus.error;
  bool get isSuccess => _status == AddCotisationStatus.success;

  /// Create a new contribution using the provided [payload].
  ///
  /// On success the controller's [response] will be populated and
  /// [status] set to [AddCotisationStatus.success]. On failure the
  /// error is stored and [status] set to [AddCotisationStatus.error].
  Future<AddCotisationResponse> createContribution(
      Map<String, dynamic> payload) async {
    _setStatus(AddCotisationStatus.loading);
    _clearError();

    try {
      final resp = await _dataSource.createContribution(payload);
      _response = resp;
      _setStatus(AddCotisationStatus.success);
      return resp;
    } catch (e) {
      _setError(e.toString());
      _setStatus(AddCotisationStatus.error);
      rethrow;
    }
  }

  void _setStatus(AddCotisationStatus status) {
    _status = status;
     Future.microtask(() => notifyListeners());
  }

  void _setError(String error) {
    _errorMessage = error;
     Future.microtask(() => notifyListeners());
  }

  void _clearError() {
    _errorMessage = null;
    Future.microtask(() =>  notifyListeners());
  }
}
