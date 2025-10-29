import 'package:flutter/material.dart';
import 'package:manager_gest_city/features/admin/models/contribution_model.dart';
import '../data_source/home_data_source.dart';
import '../models/home_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeController extends ChangeNotifier {
  final AdminHomeDataSource _adminHomeDataSource = AdminHomeDataSource();

  HomeStatus _status = HomeStatus.initial;
  AdminData? _adminData;
  List<ContributionModel> _contributions = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 10;
  bool _isLoadingMore = false;
  String? _errorMessage;

  HomeStatus get status => _status;
  AdminData? get getAdminData => _adminData;
  List<ContributionModel> get contributions => _contributions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == HomeStatus.loading;
  bool get hasError => _status == HomeStatus.error;
  bool get isLoaded => _status == HomeStatus.loaded;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMore => _currentPage < _lastPage;

  Future<void> loadHomeData() async {
    _setStatus(HomeStatus.loading);
    _clearError();

    try {
      // Load both default contribution and contributions list
      final adminDataResponse = await _adminHomeDataSource
          .getHomeData();
      final contributionsResponse = await _adminHomeDataSource
          .getContributions(perPage: 3);

      _adminData = adminDataResponse.data;
      _contributions = contributionsResponse.data;

      _setStatus(HomeStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(HomeStatus.error);
    }
  }

  Future<void> refreshHomeData() async {
    await loadHomeData();
  }

  /// Fetch contributions separately with optional query parameters used by admin UI
  /// Fetch contributions. By default loads page=1 and replaces existing list.
  /// If [append] is true, fetched items will be appended to existing list.
  Future<void> fetchContributions({
    String? filter,
    String? search,
    int? perPage,
    int page = 1,
    bool append = false,
  }) async {
    if (append) {
      _isLoadingMore = true;
      Future.microtask(() => notifyListeners());
    } else {
      _setStatus(HomeStatus.loading);
      _clearError();
    }

    try {
      final queryParameters = <String, dynamic>{};
      final int effectivePerPage = perPage ?? _perPage;
      queryParameters['per_page'] = effectivePerPage;
      queryParameters['page'] = page;

      if (filter != null && filter.isNotEmpty && filter != 'Toutes') {
        switch (filter) {
          case 'En cours':
            queryParameters['status'] = 'pending';
            break;
          case 'Terminées':
            queryParameters['status'] = 'finished';
            break;
          case 'Avec demandes':
            queryParameters['has_pending_requests'] = true;
            break;
          default:
            queryParameters['filter'] = filter;
        }
      }

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final contributionsResponse = await _adminHomeDataSource.getContributions(queryParameters: queryParameters);

      // update pagination info if available
      if (contributionsResponse.pagination != null) {
        _currentPage = contributionsResponse.pagination!.currentPage;
        _lastPage = contributionsResponse.pagination!.lastPage;
        _perPage = contributionsResponse.pagination!.perPage;
      } else {
        // fallback: if we fetched page 1 and got results less than perPage, set lastPage=1
        _currentPage = page;
        _lastPage = page;
      }

      if (append) {
        _contributions = [..._contributions, ...contributionsResponse.data];
        _isLoadingMore = false;
        Future.microtask(() => notifyListeners());
      } else {
        _contributions = contributionsResponse.data;
        _setStatus(HomeStatus.loaded);
      }
    } catch (e) {
      _setError(e.toString());
      _setStatus(HomeStatus.error);
      _isLoadingMore = false;
    }
  }

  /// Initialize contributions (reset list) and load the first page.
  Future<void> initializeContributions({String? filter, String? search, int? perPage}) async {
    _currentPage = 1;
    _lastPage = 1;
    _perPage = perPage ?? _perPage;
    await fetchContributions(filter: filter, search: search, perPage: perPage, page: 1, append: false);
  }

  /// Fetch next page and append to existing list if available.
  Future<void> fetchNextPage({String? filter, String? search}) async {
    if (_isLoadingMore) return;
    if (_currentPage >= _lastPage) return;
    final next = _currentPage + 1;
    await fetchContributions(filter: filter, search: search, page: next, append: true);
  }

  void _setStatus(HomeStatus status) {
    _status = status;
     Future.microtask(() => notifyListeners());
  }

  void _setError(String error) {
    _errorMessage = error;
     Future.microtask(() => notifyListeners());
  }

  void _clearError() {
    _errorMessage = null;
     Future.microtask(() => notifyListeners());
  }

  void clearError() {
    _clearError();
  }

  // double getProgressPercentage() {
  //   if (_defaultContribution == null) return 0.0;
  //   if (_defaultContribution!.amount == 0) return 0.0;

  //   return (_defaultContribution!.amountReachedTotal /
  //           _defaultContribution!.amount)
  //       .clamp(0.0, 1.0);
  // }

  String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA';
  }
}
