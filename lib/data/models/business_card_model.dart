import 'company_model.dart';

class BusinessCardModel {
  final int id;
  final String fullName;
  final String position;
  final List<String> phones;
  final List<String> emails;
  final List<String> addresses;
  final String? bio;
  final String? profileImage;
  final CompanyModel? company;

  BusinessCardModel({
    required this.id,
    required this.fullName,
    required this.position,
    required this.phones,
    required this.emails,
    required this.addresses,
    this.bio,
    this.profileImage,
    this.company,
  });

  factory BusinessCardModel.fromJson(Map<String, dynamic> json) {
    return BusinessCardModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      position: json['position'] ?? '',
      phones: List<String>.from(json['phones'] ?? []),
      emails: List<String>.from(json['emails'] ?? []),
      addresses: List<String>.from(json['addresses'] ?? []),
      bio: json['bio'],
      profileImage: json['profile_image'],
      company: json['company'] != null
          ? CompanyModel.fromJson(json['company'])
          : null,
    );
  }
}
