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
  final bool isExistingUser;
  final bool canProceed;

  OtpData({
    required this.isExistingUser,
    required this.canProceed,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      isExistingUser: json['is_existing_user'] as bool? ?? false,
      canProceed: json['can_proceed'] as bool? ?? true,
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

class DeviceMetadata {
  final String deviceId;
  final String deviceName;
  final String manufacturer;
  final String brand;
  final String androidVersion;
  final String platform;
  final String fcmToken;

  DeviceMetadata({
    required this.deviceId,
    required this.deviceName,
    required this.manufacturer,
    required this.brand,
    required this.androidVersion,
    required this.platform,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'manufacturer': manufacturer,
      'brand': brand,
      'android_version': androidVersion,
      'platform': platform,
      'fcm_token': fcmToken,
    };
  }
}

class FirebaseLoginRequest {
  final String idToken;
  final DeviceMetadata device;

  FirebaseLoginRequest({
    required this.idToken,
    required this.device,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_token': idToken,
      'device': device.toJson(),
    };
  }
}

class OtpVerifyRequest {
  final String idToken;
  final String? name;
  final DeviceMetadata device;

  OtpVerifyRequest({
    required this.idToken,
    this.name,
    required this.device,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_token': idToken,
      'name': name,
      'device': device.toJson(),
    };
  }
}
