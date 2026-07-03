// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import 'package:bonkano_meet_pro/utils/local_storage.dart';
import '../api/auth_apis.dart';
import '../utils/common_base.dart';
import '../utils/constants.dart';
import 'auth/model/app_configuration_res.dart';
import 'auth/model/login_response.dart';
import 'auth/sign_in_sign_up/signin_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'home/home_controller.dart';

class SplashScreenController extends GetxController {
  Rx<Future<ConfigurationResponse>> appConfigsFuture = Future(() => appConfigs.value).obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    //Get Package Info
    getPackageInfo().then((value) => currentPackageinfo(value));
    init();
  }

  @override
  void onReady() {
    try {
      final getThemeFromLocal = getValueFromLocal(SettingsLocalConst.THEME_MODE);
      if (getThemeFromLocal is int) {
        toggleThemeMode(themeId: getThemeFromLocal);
      } else {
        toggleThemeMode(themeId: THEME_MODE_LIGHT);
      }
    } catch (e) {
      log('getThemeFromLocal from cache E: $e');
    }

    super.onReady();
  }

  void init() {
    getAppConfigurations();
  }

  ///Get ChooseService List
  getAppConfigurations() {
    appConfigsFuture(AuthServiceApis.getAppConfigurations()).then((value) {
      // Si l'API renvoie la devise par défaut (USD/Doller),
      // on force FCFA car le backend NeuroCare est configuré pour le Bénin
      if (value.currency.currencyCode == 'USD' || value.currency.currencyName == 'Doller') {
        appCurrency(Currency());  // Utilise les défauts FCFA
      } else {
        appCurrency(value.currency);
      }
      appConfigs(value);

      /// Place ChatGPT Key Here
      chatGPTAPIkey = value.chatgptKey;

      ///Navigation logic
      if (getValueFromLocal(SharedPreferenceConst.IS_LOGGED_IN) == true) {
        try {
          final userData = getValueFromLocal(SharedPreferenceConst.USER_DATA);
          isLoggedIn(true);
          loginUserData.value = UserData.fromJson(userData);
          selectedAppClinic(loginUserData.value.selectedClinic);
          if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) && selectedAppClinic.value.id.isNegative) {
            AuthServiceApis.clearData();
            Get.offAll(() => SignInScreen());
          } else {
            Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
              Get.put(HomeController());
            }));
          }
        } catch (e) {
          log('SplashScreenController Err: $e');
          Get.offAll(() => SignInScreen());
        }
      } else {
        Get.offAll(() => SignInScreen());
      }
    }).whenComplete(() => isLoading(false));
  }
}
