import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../data/models/company_model.dart';
import '../../data/network/data_agents/company_api_impl.dart';

class CompanyProvider extends ChangeNotifier {
  final _api = CompanyApiImpl(DioClient.create());

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  List<CompanyModel> companies = [];

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
      }
      return e.message ?? "Network Error";
    }
    return e.toString().replaceFirst("Exception: ", "");
  }

  Future<void> fetchCompanies() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      companies = await _api.listCompanies();
    } catch (e) {
      errorMessage = _extractErrorMessage(e);
      debugPrint('COMPANY FETCH ERROR: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<CompanyModel?> createCompany(Map<String, dynamic> data) async {
    try {
      isSaving = true;
      errorMessage = null;
      notifyListeners();
      final company = await _api.createCompany(data);
      companies = [company, ...companies];
      return company;
    } catch (e, stack) {
      errorMessage = _extractErrorMessage(e);
      debugPrint('COMPANY CREATE ERROR: $e');
      debugPrint('STACK: $stack');
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<CompanyModel?> updateCompany(int id, Map<String, dynamic> data) async {
    try {
      isSaving = true;
      errorMessage = null;
      notifyListeners();
      final updated = await _api.updateCompany(id, data);
      final idx = companies.indexWhere((c) => c.id == id);
      if (idx != -1) {
        companies[idx] = updated;
        companies = List.of(companies);
      }
      return updated;
    } catch (e, stack) {
      errorMessage = _extractErrorMessage(e);
      debugPrint('COMPANY UPDATE ERROR: $e');
      debugPrint('STACK: $stack');
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCompany(int id) async {
    try {
      errorMessage = null;
      notifyListeners();
      await _api.deleteCompany(id);
      companies.removeWhere((c) => c.id == id);
      return true;
    } catch (e) {
      errorMessage = _extractErrorMessage(e);
      debugPrint('COMPANY DELETE ERROR: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }
}
