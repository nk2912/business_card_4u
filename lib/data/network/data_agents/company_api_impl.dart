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
    
    // Ensure body is handled properly
    final List rawList = body is List 
        ? body 
        : (body is Map ? (body['data'] as List? ?? []) : []);
        
    return rawList.map((e) {
      if (e is Map) {
        return CompanyModel.fromJson(Map<String, dynamic>.from(e));
      }
      return CompanyModel.fromJson({}); // Fallback for malformed items
    }).toList();
  }

  @override
  Future<CompanyModel> getCompany(int id) async {
    final Response res = await dio.get('${ApiConstants.companies}/$id');
    return _parseCompanyResponse(res.data);
  }

  @override
  Future<CompanyModel> createCompany(Map<String, dynamic> data) async {
    final Response res = await dio.post(ApiConstants.companies, data: data);
    return _parseCompanyResponse(res.data);
  }

  @override
  Future<CompanyModel> updateCompany(int id, Map<String, dynamic> data) async {
    final Response res = await dio.put('${ApiConstants.companies}/$id', data: data);
    return _parseCompanyResponse(res.data);
  }

  @override
  Future<void> deleteCompany(int id) async {
    await dio.delete('${ApiConstants.companies}/$id');
  }

  /// Helper to parse single company response safely
  CompanyModel _parseCompanyResponse(dynamic body) {
    if (body == null) {
      throw Exception("Response body is null");
    }

    Map<String, dynamic> jsonMap = {};

    if (body is Map) {
      // If response has 'data' key (Laravel Resource), use it
      if (body.containsKey('data') && body['data'] is Map) {
        jsonMap = Map<String, dynamic>.from(body['data']);
      } else {
        // Otherwise use the body itself
        jsonMap = Map<String, dynamic>.from(body);
      }
    } else {
      // Should not happen for valid JSON object response
      throw Exception("Unexpected response format: expected Map, got ${body.runtimeType}");
    }

    return CompanyModel.fromJson(jsonMap);
  }
}
