import 'company_social_model.dart';

class CompanyModel {
  final int id;
  final String name;
  final String? industry;
  final String? businessType;
  final String? description;
  final String? address;
  final String? website;
  final String? phone;
  final String? email;
  final int? createdBy;
  final List<CompanySocialModel> socials;

  CompanyModel({
    required this.id,
    required this.name,
    this.industry,
    this.businessType,
    this.description,
    this.address,
    this.website,
    this.phone,
    this.email,
    this.createdBy,
    required this.socials,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      industry: json['industry'],
      businessType: json['business_type'],
      description: json['description'],
      address: json['address'],
      website: json['website'],
      phone: json['phone'],
      email: json['email'],
      createdBy: json['created_by'] is int
          ? json['created_by']
          : int.tryParse(json['created_by']?.toString() ?? ''),
      socials: (json['socials'] as List? ?? []).map((e) {
        if (e is Map) {
          return CompanySocialModel.fromJson(Map<String, dynamic>.from(e));
        }
        return CompanySocialModel(id: 0, platform: '', url: '');
      }).toList(),
    );
  }
}
