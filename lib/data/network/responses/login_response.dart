class LoginResponse {
  final String token;
  final Map<String, dynamic> user;
  final String? message;

  LoginResponse({
    required this.token,
    required this.user,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: json['user'],
      message: json['message']?.toString(),
    );
  }
}
