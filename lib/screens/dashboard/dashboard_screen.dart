import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/api/auth_apis.dart';
import 'package:bonkano_meet_pro/screens/auth/model/login_response.dart';
import 'package:bonkano_meet_pro/utils/local_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../appointment/appointments_controller.dart';
import '../home/home_controller.dart';
import '../payout/payout_history_controller.dart';
import 'components/btm_nav_item.dart';
import 'dashboard_controller.dart';
import 'components/menu.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController dashboardController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: locale.value.pressBackAgainToExitApp,
      child: Scaffold(
        body: Stack(
          children: [
            Obx(() => dashboardController.screen[dashboardController.currentIndex.value]),
            Obx(
              () => Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? fullDarkCanvasColor.withValues(alpha: 0.9) : canvasColor.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode.value ? appBodyColor.withValues(alpha: 0.3) : canvasColor.withValues(alpha: 0.3),
                        offset: Offset(0, isDarkMode.value ? 5 : 20),
                        blurRadius: isDarkMode.value ? 5 : 20,
                      ),
                    ],
                    //  border: Border.all(color: dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...List.generate(
                        dashboardController.bottomNavItems.length,
                        (index) {
                          BottomBarItem navBar = dashboardController.bottomNavItems[index];
                          return Obx(
                            () => BtmNavItem(
                              navBar: navBar,
                              isFirst: index == 0,
                              isLast: index == dashboardController.bottomNavItems.length - 1,
                              press: () {
                                if (!isLoggedIn.value && (index == 1 || index == 2)) {
                                  doIfLoggedIn(() {
                                    handleChangeTabIndex(index);
                                  });
                                } else {
                                  handleChangeTabIndex(index);
                                }
                              },
                              selectedNav: dashboardController.selectedBottonNav.value,
                            ),
                          );
                        },
                      ),
                    ],
                  ).fit(),
                ),
              ).paddingSymmetric(vertical: 15),
            )
          ],
        ),
        extendBody: true,
      ),
    );
  }

  void handleChangeTabIndex(int index) {
    hideKeyBoardWithoutContext();
    dashboardController.selectedBottonNav(dashboardController.bottomNavItems[index]);
    dashboardController.currentIndex(index);
    try {
      String type = dashboardController.bottomNavItems[index].type;
      if (type == BottomItem.home.name || (type == BottomItem.settings.name && isLoggedIn.value)) {
        HomeController hCont = Get.find();
        hCont.getDashboardDetail(showLoader: false);
      } else if (isLoggedIn.value && type == BottomItem.appointment.name) {
        AppointmentsController aCont = Get.find();
        aCont.searchCont.clear();
        aCont.page(1);
        aCont.getAppointmentList();
      } else if (type == BottomItem.profile.name || type == BottomItem.payout.name) {
        AuthServiceApis.viewProfile().then((data) {
          loginUserData(UserData(
            id: loginUserData.value.id,
            firstName: data.userData.firstName,
            lastName: data.userData.lastName,
            userName: "${data.userData.firstName} ${data.userData.lastName}",
            mobile: data.userData.mobile,
            email: data.userData.email,
            userRole: loginUserData.value.userRole,
            gender: data.userData.gender,
            address: data.userData.address,
            apiToken: loginUserData.value.apiToken,
            profileImage: data.userData.profileImage,
            loginType: loginUserData.value.loginType,
            selectedClinic: selectedAppClinic.value,
          ));
          setValueToLocal(SharedPreferenceConst.USER_DATA, loginUserData.toJson());
        }).catchError((e) {
          toast(e.toString());
        });
        if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor) && type == BottomItem.payout.name) {
          PayoutHistoryCont pCont = Get.find();
          pCont.page(1);
          pCont.getPayoutList();
        }
      }
    } catch (e) {
      log('onItemSelected Err: $e');
    }
  }
}