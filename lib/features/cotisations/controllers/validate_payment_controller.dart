import 'package:flutter/material.dart';
import '../data_source/validate_payment_data_source.dart';
import '../models/validate_payment_response.dart';

enum ValidatePaymentStatus { initial, loading, success, error }

class ValidatePaymentController extends ChangeNotifier {
  final ValidatePaymentDataSource _dataSource = ValidatePaymentDataSource();

  ValidatePaymentStatus _status = ValidatePaymentStatus.initial;
  ValidatePaymentResponse? _response;
  String? _errorMessage;

  ValidatePaymentStatus get status => _status;
  ValidatePaymentResponse? get response => _response;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ValidatePaymentStatus.loading;
  bool get isSuccess => _status == ValidatePaymentStatus.success;

  Future<ValidatePaymentResponse> verifyQrCode(String token) async {
    _setStatus(ValidatePaymentStatus.loading);
    _clearError();

    try {
      final resp = await _dataSource.verifyQrCode(token);
      _response = resp;
      _setStatus(ValidatePaymentStatus.success);
      return resp;
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(ValidatePaymentStatus.error);
      rethrow;
    }
  }

  void _setStatus(ValidatePaymentStatus s) {
    _status = s;
     Future.microtask(() => notifyListeners());
  }

  void _clearError() {
    _errorMessage = null;
     Future.microtask(() => notifyListeners());
  }
}
