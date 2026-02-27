import 'company_model.dart';
import 'user_model.dart';

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
  final UserModel? user;
  final String cardType;
  final String? qrCodeData;
  final List<dynamic>? socialLinks;
  final bool isFriend;
  final String friendStatus;
  final String? tag;

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
    this.user,
    this.cardType = 'my_card',
    this.qrCodeData,
    this.socialLinks,
    this.isFriend = false,
    this.friendStatus = 'none',
    this.tag,
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
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      cardType: json['card_type'] ?? 'my_card',
      qrCodeData: json['qr_code_data'],
      socialLinks: json['social_links'] != null
          ? List<dynamic>.from(json['social_links'])
          : null,
      isFriend: json['is_friend'] ?? false,
      friendStatus: json['friend_status'] ?? 'none',
      tag: json['tag'],
    );
  }

  factory BusinessCardModel.empty() {
    return BusinessCardModel(
      id: 0,
      fullName: '',
      position: '',
      phones: [],
      emails: [],
      addresses: [],
    );
  }
}
