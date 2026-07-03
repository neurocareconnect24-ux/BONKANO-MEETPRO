import 'package:bonkano_meet_pro/screens/clinic/model/clinics_res_model.dart';

class UserResponse {
  bool status;
  UserData userData;
  String message;

  UserResponse({
    this.status = false,
    required this.userData,
    this.message = "",
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      status: json['status'] is bool ? json['status'] : false,
      userData: json['data'] is Map ? UserData.fromJson(json['data']) : UserData(),
      message: json['message'] is String ? json['message'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': userData.toJson(),
      'message': message,
    };
  }
}

class UserData {
  int id;
  String firstName;
  String lastName;
  String userName;
  String address;
  String mobile;
  String email;
  String gender;
  List<String> userRole;
  String apiToken;
  String profileImage;
  String loginType;
  bool isSocialLogin;
  String userType;
  String city;
  String state;
  String country;
  String pinCode;
  String dateOfBirth;

  //To Handle selectedClinic for Doctor And Receptniost Roles
  ClinicData? selectedClinic;

  UserData({
    this.id = -1,
    this.firstName = "",
    this.lastName = "",
    this.userName = "",
    this.address = "",
    this.mobile = "",
    this.email = "",
    this.gender = "",
    this.userRole = const <String>[],
    this.apiToken = "",
    this.profileImage = "",
    this.loginType = "",
    this.isSocialLogin = false,
    this.userType = "",
    this.selectedClinic,
    this.city = "",
    this.state = "",
    this.country = "",
    this.pinCode = "",
    this.dateOfBirth = "",
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] is int ? json['id'] : -1,
      firstName: json['first_name'] is String ? json['first_name'] : "",
      lastName: json['last_name'] is String ? json['last_name'] : "",
      userName: json['user_name'] is String ? json['user_name'] : "${json['first_name']} ${json['last_name']}",
      mobile: json['mobile'] is String ? json['mobile'] : "",
      address: json['address'] is String ? json['address'] : "",
      email: json['email'] is String ? json['email'] : "",
      gender: json['gender'] is String ? json['gender'] : "",
      userRole: json['user_role'] is List ? List<String>.from(json['user_role'].map((x) => x)) : [],
      apiToken: json['api_token'] is String ? json['api_token'] : "",
      profileImage: json['profile_image'] is String ? json['profile_image'] : "",
      loginType: json['login_type'] is String ? json['login_type'] : "",
      isSocialLogin: json['is_social_login'] is bool ? json['is_social_login'] : false,
      userType: json['user_type'] is String ? json['user_type'] : "",
      city: json['city'] is String ? json['city'] : "",
      state: json['state'] is String ? json['state'] : "",
      country: json['country'] is String ? json['country'] : "",
      pinCode: json['pinCode'] is String ? json['pinCode'] : "",
      dateOfBirth: json['date_of_birth'] is String ? json['date_of_birth'] : "",
      selectedClinic: json['selected_clinic'] is Map ? ClinicData.fromJson(json['selected_clinic']) : ClinicData(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'user_name': userName,
      'mobile': mobile,
      'address': address,
      'email': email,
      'gender': gender,
      'user_role': userRole.map((e) => e).toList(),
      'api_token': apiToken,
      'profile_image': profileImage,
      'login_type': loginType,
      'is_social_login': isSocialLogin,
      'user_type': userType,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'date_of_birth': dateOfBirth,
      'selected_clinic': selectedClinic?.toJson(),
    };
  }
}
