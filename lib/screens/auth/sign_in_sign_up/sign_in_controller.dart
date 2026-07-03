// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../clinic/model/clinics_res_model.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../home/choose_clinic_screen.dart';
import '../../home/home_controller.dart';
import '../model/clinic_center_argument_model.dart';
import '../model/login_response.dart';
import '../../../api/auth_apis.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';
import '../../../utils/secure_storage.dart';
import '../model/login_roles_model.dart';
import '../services/social_logins.dart';

class SignInController extends GetxController {
  RxBool isNavigateToDashboard = false.obs;
  final GlobalKey<FormState> signInformKey = GlobalKey();

  RxBool isRememberMe = true.obs;
  RxBool isLoading = false.obs;
  RxString userName = "".obs;

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  Rx<LoginRoleData> selectedLoginRole = LoginRoleData().obs;

  void toggleSwitch() {
    isRememberMe.value = !isRememberMe.value;
  }

  @override
  void onInit() {
    if (appConfigs.value.isDummyCredential != 1) {
      emailCont.text = '';
      passwordCont.text = '';
      isRememberMe.value = false;
    } else {
      if (!appConfigs.value.isMultiVendor) {
        loginRoles.removeWhere((item) => item.userType == EmployeeKeyConst.vendor);
      } else if (loginRoles.indexWhere((item) => item.userType == EmployeeKeyConst.vendor) == -1) {
        loginRoles.add(vendorLoginRole);
      }
      if (Get.arguments is bool) {
        isNavigateToDashboard(Get.arguments == true);
      }
      final userIsRemeberMe = getValueFromLocal(SharedPreferenceConst.IS_REMEMBER_ME);
      final userNameFromLocal = getValueFromLocal(SharedPreferenceConst.USER_NAME);
      if (userNameFromLocal is String) {
        userName(userNameFromLocal);
      }
      if (userIsRemeberMe == true) {
        final userEmail = getValueFromLocal(SharedPreferenceConst.USER_EMAIL);
        if (userEmail is String) {
          emailCont.text = userEmail;
        }
        // SECURITY FIX P0-2: Lire le mot de passe depuis le stockage sécurisé (chiffré)
        SecureStorage.readPassword().then((storedPassword) {
          if (storedPassword != null && storedPassword.isNotEmpty) {
            passwordCont.text = storedPassword;
          }
        });
      }
      if ((!appConfigs.value.isMultiVendor) && (selectedLoginRole.value.userType == EmployeeKeyConst.vendor)) {
        emailCont.text = "";
        passwordCont.text = "";
        selectedLoginRole(LoginRoleData());
      }
    }
    super.onInit();
  }

  /// Retourne true si l'identifiant est un numéro de téléphone (pas un email)
  bool _isPhoneNumber(String identifier) => !identifier.contains('@');

  Future<void> saveForm() async {
    if (isLoading.value) return;
    hideKeyBoardWithoutContext();
    if (!selectedLoginRole.value.id.isNegative) {
      isLoading(true);

      final identifier = emailCont.text.trim();
      final isPhone = _isPhoneNumber(identifier);

      Map<String, dynamic> req = {
        if (isPhone) 'mobile': identifier else 'email': identifier,
        'password': passwordCont.text.trim(),
        UserKeys.userType: selectedLoginRole.value.userType,
      };

      await AuthServiceApis.loginUser(request: req).then((value) async {
        handleLoginResponse(loginResponse: value);
      }).catchError((e) {
        isLoading(false);
        toast(e.toString(), print: true);
      });
    } else {
      toast(locale.value.pleaseSelectRoleToLogin);
    }
  }

  googleSignIn() async {
    isLoading(true);
    await GoogleSignInAuthService.signInWithGoogle().then((value) async {
      Map request = {
        UserKeys.contactNumber: value.mobile,
        UserKeys.email: value.email,
        UserKeys.firstName: value.firstName,
        UserKeys.lastName: value.lastName,
        UserKeys.username: value.userName,
        UserKeys.profileImage: value.profileImage,
        UserKeys.userType: selectedLoginRole.value.userType,
        UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_GOOGLE,
      };
      log('signInWithGoogle REQUEST: $request');

      /// Social Login Api
      await AuthServiceApis.loginUser(request: request, isSocialLogin: true).then((value) async {
        handleLoginResponse(loginResponse: value, isSocialLogin: true);
      }).catchError((e) {
        isLoading(false);
        toast(e.toString(), print: true);
      });
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  appleSignIn() async {
    isLoading(true);
    await GoogleSignInAuthService.signInWithApple().then((value) async {
      Map request = {
        UserKeys.contactNumber: value.mobile,
        UserKeys.email: value.email,
        UserKeys.firstName: value.firstName,
        UserKeys.lastName: value.lastName,
        UserKeys.username: value.userName,
        UserKeys.profileImage: value.profileImage,
        UserKeys.userType: selectedLoginRole.value.userType,
        UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_APPLE,
      };
      log('signInWithGoogle REQUEST: $request');

      /// Social Login Api
      await AuthServiceApis.loginUser(request: request, isSocialLogin: true).then((value) async {
        handleLoginResponse(loginResponse: value, isSocialLogin: true);
      }).catchError((e) {
        isLoading(false);
        toast(e.toString(), print: true);
      });
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void handleLoginResponse({required UserResponse loginResponse, bool isSocialLogin = false}) {
    if (loginResponse.userData.userRole.contains(EmployeeKeyConst.vendor) ||
        loginResponse.userData.userRole.contains(EmployeeKeyConst.doctor) ||
        loginResponse.userData.userRole.contains(EmployeeKeyConst.receptionist)) {
      loginUserData(loginResponse.userData);
      loginUserData.value.isSocialLogin = isSocialLogin;
      loginUserData.value.userType = selectedLoginRole.value.userType;
      setValueToLocal(SharedPreferenceConst.USER_DATA, loginUserData.toJson());
      // SECURITY FIX P0-2: Stocker le mot de passe dans le stockage sécurisé (chiffré)
      // au lieu de GetStorage en clair. Pour le social login, on supprime tout mot de passe stocké.
      if (isSocialLogin) {
        SecureStorage.deletePassword();
      } else {
        SecureStorage.savePassword(passwordCont.text.trim());
      }
      isLoggedIn(true);
      setValueToLocal(SharedPreferenceConst.IS_LOGGED_IN, true);
      setValueToLocal(SharedPreferenceConst.IS_REMEMBER_ME, isRememberMe.value);
      if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) && selectedAppClinic.value.id.isNegative) {
        Get.to(
          () => ChooseClinicScreen(),
          arguments: ClinicCenterArgumentModel(
            selectedClinc: selectedAppClinic.value,
          ),
        )?.then((value) {
          if (value is ClinicData) {
            selectedAppClinic(value);
            loginUserData.value.selectedClinic = value;
            loginUserData.refresh();
            setValueToLocal(SharedPreferenceConst.USER_DATA, loginUserData.toJson());
            Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
              Get.put(HomeController());
            }));
          }
        });
      } else {
        Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
          Get.put(HomeController());
        }));
      }
    } else {
      toast(locale.value.sorryUserCannotSignin);
    }
    isLoading(false);
  }

  @override
  void onClose() {
    emailCont.dispose();
    passwordCont.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
