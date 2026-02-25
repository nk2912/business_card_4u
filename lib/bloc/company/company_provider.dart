import 'package:flutter/material.dart';

import '../../core/network/dio_client.dart';
import '../../data/models/company_model.dart';
import '../../data/network/data_agents/company_api_impl.dart';

class CompanyProvider extends ChangeNotifier {
  final _api = CompanyApiImpl(DioClient.create());

  bool isLoading = false;
  bool isSaving = false;
  List<CompanyModel> companies = [];

  Future<void> fetchCompanies() async {
    try {
      isLoading = true;
      notifyListeners();
      companies = await _api.listCompanies();
    } catch (e) {
      debugPrint('COMPANY FETCH ERROR: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<CompanyModel?> createCompany(Map<String, dynamic> data) async {
    try {
      isSaving = true;
      notifyListeners();
      final company = await _api.createCompany(data);
      companies = [company, ...companies];
      return company;
    } catch (e) {
      debugPrint('COMPANY CREATE ERROR: $e');
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<CompanyModel?> updateCompany(int id, Map<String, dynamic> data) async {
    try {
      isSaving = true;
      notifyListeners();
      final updated = await _api.updateCompany(id, data);
      final idx = companies.indexWhere((c) => c.id == id);
      if (idx != -1) {
        companies[idx] = updated;
        companies = List.of(companies);
      }
      return updated;
    } catch (e) {
      debugPrint('COMPANY UPDATE ERROR: $e');
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCompany(int id) async {
    try {
      await _api.deleteCompany(id);
      companies.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('COMPANY DELETE ERROR: $e');
      return false;
    }
  }
}
