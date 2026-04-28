class OtpRequestResponse {
  final String status;
  final String message;
  final OtpData data;

  OtpRequestResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: OtpData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class OtpData {
  final String phoneNumber;
  final String sessionId;
  final bool isExistingUser;

  OtpData({
    required this.phoneNumber,
    required this.sessionId,
    required this.isExistingUser,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      phoneNumber: json['phone_number'] as String,
      sessionId: json['session_id'] as String,
      isExistingUser: json['is_existing_user'] as bool,
    );
  }
}

class OtpVerifyResponse {
  final String status;
  final String message;
  final AuthData data;

  OtpVerifyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: AuthData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class AuthData {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;
  final bool isRegistrationComplete;
  final UserData user;

  AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
    required this.isRegistrationComplete,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      isNewUser: json['is_new_user'] as bool,
      isRegistrationComplete: json['is_registration_complete'] as bool,
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserData {
  final String id;
  final String? name;
  final String? email;
  final String phone;
  final String? avatar;
  final String role;
  final bool isVerified;

  UserData({
    required this.id,
    this.name,
    this.email,
    required this.phone,
    this.avatar,
    required this.role,
    required this.isVerified,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool,
    );
  }
}
