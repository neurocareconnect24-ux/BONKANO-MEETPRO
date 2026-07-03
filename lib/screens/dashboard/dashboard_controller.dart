// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/payout/payout_history.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../utils/local_storage.dart';
import '../../utils/push_notification_service.dart';
import '../payout/payout_history_controller.dart';
import '../auth/other/settings_screen.dart';
import '../auth/profile/profile_controller.dart';
import '../auth/profile/profile_screen.dart';
import '../../api/auth_apis.dart';
import '../appointment/appointments_controller.dart';
import '../appointment/appointments_screen.dart';
import '../home/home_controller.dart';
import '../home/home_screen.dart';
import '../Encounter/all_encounters_screen.dart';
import 'components/menu.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isLoading = false.obs;

  RxList<BottomBarItem> bottomNavItems = [
    BottomBarItem(title: locale.value.home, icon: Assets.navigationIcHomeOutlined, activeIcon: Assets.navigationIcHomeFilled, type: BottomItem.home.name),
    BottomBarItem(title: locale.value.appointments, icon: Assets.navigationIcCalenderOutlined, activeIcon: Assets.navigationIcCalenderFilled, type: BottomItem.appointment.name),
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) BottomBarItem(title: locale.value.encounters, icon: Assets.iconsIcEncounter, activeIcon: Assets.iconsIcEncounter, type: BottomItem.encounter.name),
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)) BottomBarItem(title: locale.value.payouts, icon: Assets.iconsIcTotalPayout, activeIcon: Assets.iconsIcTotalPayout, type: BottomItem.payout.name),
    isLoggedIn.value
        ? BottomBarItem(title: locale.value.profile, icon: Assets.navigationIcUserOutlined, activeIcon: Assets.navigationIcUserFilled, type: BottomItem.profile.name)
        : BottomBarItem(title: locale.value.settings, icon: Assets.iconsIcSettingOutlined, activeIcon: Assets.iconsIcSetting, type: BottomItem.settings.name),
  ].obs;

  Rx<BottomBarItem> selectedBottonNav = BottomBarItem(title: locale.value.home, icon: Assets.navigationIcHomeOutlined, activeIcon: Assets.navigationIcHomeFilled, type: BottomItem.home.name).obs;

  RxList<StatelessWidget> screen = [
    HomeScreen(),
    AppointmentsScreen(),
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) AllEncountersScreen(),
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)) PayoutHistory(isFromBottomBar: true),
    isLoggedIn.value ? ProfileScreen() : SettingScreen(),
  ].obs;

  @override
  void onInit() {
    if (!isLoggedIn.value) {
      ProfileController().getAboutPageData();
    }
    PushNotificationService().registerFCMandTopics();
    getAppConfigurations(isFromDashboard: true).then((value) {
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.context != null) {
          showForceUpdateDialog(Get.context!);
        }
      });
    });
    super.onInit();
  }

  @override
  void onReady() {
    reloadBottomTabs();
    if (Get.context != null) {
      View.of(Get.context!).platformDispatcher.onPlatformBrightnessChanged = () {
        WidgetsBinding.instance.handlePlatformBrightnessChanged();
        try {
          final getThemeFromLocal = getValueFromLocal(SettingsLocalConst.THEME_MODE);
          if (getThemeFromLocal is int) {
            toggleThemeMode(themeId: getThemeFromLocal);
          }
        } catch (e) {
          log('getThemeFromLocal from cache E: $e');
        }
      };
    }
    super.onReady();
  }

  void reloadBottomTabs() {
    log('reloadBottomTabs ISLOGGEDIN.VALUE: ${isLoggedIn.value}');
    bottomNavItems([
      BottomBarItem(title: locale.value.home, icon: Assets.navigationIcHomeOutlined, activeIcon: Assets.navigationIcHomeFilled, type: BottomItem.home.name),
      BottomBarItem(title: locale.value.appointments, icon: Assets.navigationIcCalenderOutlined, activeIcon: Assets.navigationIcCalenderFilled, type: BottomItem.appointment.name),
      if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) BottomBarItem(title: locale.value.encounters, icon: Assets.iconsIcEncounter, activeIcon: Assets.iconsIcEncounter, type: BottomItem.encounter.name),
      if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)) BottomBarItem(title: locale.value.payouts, icon: Assets.iconsIcTotalPayout, activeIcon: Assets.iconsIcTotalPayout, type: BottomItem.payout.name),
      isLoggedIn.value
          ? BottomBarItem(title: locale.value.profile, icon: Assets.navigationIcUserOutlined, activeIcon: Assets.navigationIcUserFilled, type: BottomItem.profile.name)
          : BottomBarItem(title: locale.value.settings, icon: Assets.iconsIcSettingOutlined, activeIcon: Assets.iconsIcSetting, type: BottomItem.settings.name),
    ]);
    screen(<StatelessWidget>[
      HomeScreen(),
      AppointmentsScreen(),
      if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) AllEncountersScreen(),
      if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)) PayoutHistory(isFromBottomBar: true),
      isLoggedIn.value ? ProfileScreen() : SettingScreen(),
    ]);

    selectedBottonNav(bottomNavItems[currentIndex.value]);
  }
}

///Get ChooseService List
Future<void> getAppConfigurations({bool isFromDashboard = false}) async {
  await AuthServiceApis.getAppConfigurations().then((value) async {
    appConfigs(value);

    /// Place ChatGPT Key Here
    chatGPTAPIkey = value.chatgptKey;
  }).onError((error, stackTrace) {
    toast(error.toString());
  });
}

changebottomIndex(index) {
  DashboardController dCont = Get.find();
  dCont.selectedBottonNav(dCont.bottomNavItems[index]);
  dCont.currentIndex(index);
  String type = dCont.bottomNavItems[index].type;
  try {
    if (type == BottomItem.home.name || (type == BottomItem.settings.name && isLoggedIn.value)) {
      HomeController hCont = Get.find();
      hCont.getDashboardDetail(showLoader: false);
    } else if (isLoggedIn.value && type == BottomItem.appointment.name) {
      AppointmentsController aCont = Get.find();
      aCont.page(1);
      aCont.getAppointmentList();
    } else if (type == BottomItem.payout.name) {
      if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)) {
        PayoutHistoryCont pCont = Get.find();
        pCont.page(1);
        pCont.getPayoutList();
      }
    }
  } catch (e) {
    log('onItemSelected Err: $e');
  }
}
