class CreateCardRequest {
  final String? name; // Added name
  final int? companyId;
  final String? position;
  final List<String>? phones;
  final List<String>? emails;
  final List<String>? addresses;
  final String? bio;
  final String? profileImage;

  CreateCardRequest({
    this.name,
    this.companyId,
    this.position,
    this.phones,
    this.emails,
    this.addresses,
    this.bio,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null && name!.isNotEmpty) data['name'] = name; // Include name
    if (companyId != null) data['company_id'] = companyId;
    if (position != null && position!.isNotEmpty) data['position'] = position;
    if (phones != null && phones!.isNotEmpty) data['phones'] = phones;
    if (emails != null && emails!.isNotEmpty) data['emails'] = emails;
    if (addresses != null && addresses!.isNotEmpty) {
      data['addresses'] = addresses;
    }
    if (bio != null && bio!.isNotEmpty) data['bio'] = bio;
    if (profileImage != null && profileImage!.isNotEmpty) {
      data['profile_image'] = profileImage;
    }
    return data;
  }
}
