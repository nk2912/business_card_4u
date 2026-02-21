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
    required this.socials,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      name: json['name'] ?? '',
      industry: json['industry'],
      businessType: json['business_type'],
      description: json['description'],
      address: json['address'],
      website: json['website'],
      phone: json['phone'],
      email: json['email'],
      socials: (json['socials'] as List? ?? [])
          .map((e) => CompanySocialModel.fromJson(e))
          .toList(),
    );
  }
}
