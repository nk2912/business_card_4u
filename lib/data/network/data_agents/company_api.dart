import '../../models/company_model.dart';

abstract class CompanyApi {
  Future<List<CompanyModel>> listCompanies();
  Future<CompanyModel> getCompany(int id);
  Future<CompanyModel> createCompany(Map<String, dynamic> data);
  Future<CompanyModel> updateCompany(int id, Map<String, dynamic> data);
  Future<void> deleteCompany(int id);
}
