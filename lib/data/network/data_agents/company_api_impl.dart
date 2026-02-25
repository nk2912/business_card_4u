import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../models/company_model.dart';
import 'company_api.dart';

class CompanyApiImpl implements CompanyApi {
  final Dio dio;

  CompanyApiImpl(this.dio);

  @override
  Future<List<CompanyModel>> listCompanies() async {
    final Response res = await dio.get(ApiConstants.companies);
    final dynamic body = res.data;
    final List data = body is List ? body : (body['data'] as List? ?? []);
    return data.map((e) => CompanyModel.fromJson(e as Map<String, dynamic>)).toList();
    }

  @override
  Future<CompanyModel> getCompany(int id) async {
    final Response res = await dio.get('${ApiConstants.companies}/$id');
    final dynamic body = res.data;
    final Map<String, dynamic> json =
        body is Map<String, dynamic> ? (body['data'] as Map<String, dynamic>? ?? body) : {};
    return CompanyModel.fromJson(json);
  }

  @override
  Future<CompanyModel> createCompany(Map<String, dynamic> data) async {
    final Response res = await dio.post(ApiConstants.companies, data: data);
    final dynamic body = res.data;
    final Map<String, dynamic> json =
        body is Map<String, dynamic> ? (body['data'] as Map<String, dynamic>? ?? body) : {};
    return CompanyModel.fromJson(json);
  }

  @override
  Future<CompanyModel> updateCompany(int id, Map<String, dynamic> data) async {
    final Response res = await dio.put('${ApiConstants.companies}/$id', data: data);
    final dynamic body = res.data;
    final Map<String, dynamic> json =
        body is Map<String, dynamic> ? (body['data'] as Map<String, dynamic>? ?? body) : {};
    return CompanyModel.fromJson(json);
  }

  @override
  Future<void> deleteCompany(int id) async {
    await dio.delete('${ApiConstants.companies}/$id');
  }
}
