class CompanySocialModel {
  final int id;
  final String platform;
  final String url;

  CompanySocialModel({
    required this.id,
    required this.platform,
    required this.url,
  });

  factory CompanySocialModel.fromJson(Map<String, dynamic> json) {
    return CompanySocialModel(
      id: json['id'],
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
