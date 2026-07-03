import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/clinic/clinic_list_screen.dart';
import 'package:bonkano_meet_pro/screens/doctor/doctor_list_screen.dart';
import '../../../components/app_scaffold.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../doctor/add_doctor/add_doctor_form.dart';
import '../../doctor/doctor_session/add_session/add_session_screen.dart';
import '../../doctor/doctor_session/add_session/model/doctor_session_model.dart';
import '../../doctor/model/doctor_list_res.dart';
import '../../receptionist/receptionist_list_screen.dart';
import '../../requests/request_list_screen.dart';
import 'common_horizontal_profile_widget.dart';
import 'edit_user_profile.dart';
import 'edit_user_profile_controller.dart';
import 'profile_controller.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../other/settings_screen.dart';
import '../other/about_us_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.profile,
        hasLeadingWidget: false,
        isLoading: profileController.isLoading,
        appBarVerticalSize: Get.height * 0.12,
        body: AnimatedScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(
                  () => ProfilePicHorizotalWidget(
                    heroTag: loginUserData.value.profileImage,
                    profileImage: loginUserData.value.profileImage,
                    firstName: loginUserData.value.firstName,
                    lastName: loginUserData.value.lastName,
                    userName: loginUserData.value.userName,
                    subInfo: loginUserData.value.email,
                    onCameraTap: () {
                      EditUserProfileController editUserProfileController = EditUserProfileController(isProfilePhoto: true);
                      editUserProfileController.showBottomSheet(context);
                    },
                  ).onTap((){
                    if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) {
                      final doctorData = Doctor(
                        id: loginUserData.value.id,
                        doctorId: loginUserData.value.id,
                        firstName: loginUserData.value.firstName,
                        lastName: loginUserData.value.lastName,
                        email: loginUserData.value.email,
                        profileImage: loginUserData.value.profileImage,
                        address: loginUserData.value.address,
                      );
                      Get.to(() => AddDoctorForm(isFromEditProfile: true), arguments: doctorData);
                    } else {
                      Get.to(() => EditUserProfileScreen(), duration: const Duration(milliseconds: 800));
                    }
                  }),
                ),
                16.height,
                SettingItemWidget(
                  decoration: boxDecorationDefault(color: context.cardColor),
                  title: locale.value.editProfile,
                  subTitle: locale.value.personalizeYourProfile,
                  splashColor: transparentColor,
                  onTap: () {
                    if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) {
                      final doctorData = Doctor(
                        id: loginUserData.value.id,
                        doctorId: loginUserData.value.id,
                        firstName: loginUserData.value.firstName,
                        lastName: loginUserData.value.lastName,
                        email: loginUserData.value.email,
                        profileImage: loginUserData.value.profileImage,
                        address: loginUserData.value.address,
                      );
                      Get.to(() => AddDoctorForm(isFromEditProfile: true), arguments: doctorData);
                    } else {
                      Get.to(() => EditUserProfileScreen(), duration: const Duration(milliseconds: 800));
                    }
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcEditprofileOutlined, color: appColorPrimary).circularLightPrimaryBg(),
                  trailing: trailing,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16),
                SettingItemWidget(
                  decoration: boxDecorationDefault(color: context.cardColor),
                  title: locale.value.clinics,
                  subTitle: locale.value.manageClinics,
                  splashColor: transparentColor,
                  onTap: () {
                    Get.to(() => ClinicListScreen());
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcClinic, color: appColorPrimary).circularLightPrimaryBg(),
                  trailing: trailing,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16).visible(loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)),
                SettingItemWidget(
                  decoration: boxDecorationDefault(color: context.cardColor),
                  title: locale.value.manageSessions,
                  subTitle: locale.value.changeOrAddYourSessions,
                  splashColor: transparentColor,
                  onTap: () {
                    Get.to(() => AddSessionScreen(),
                        arguments: DoctorSessionModel(
                          doctorId: loginUserData.value.id,
                          clinicId: selectedAppClinic.value.id,
                          fullName: loginUserData.value.userName,
                        ));
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcTimeOutlined, color: appColorPrimary).circularLightPrimaryBg(),
                  trailing: trailing,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16).visible(loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)),
                SettingItemWidget(
                  decoration: boxDecorationDefault(color: context.cardColor),
                  title: locale.value.doctors,
                  subTitle: locale.value.manageDoctors,
                  splashColor: transparentColor,
                  onTap: () {
                    Get.to(() => DoctorsListScreen());
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcDoctor, color: appColorPrimary).circularLightPrimaryBg(),
                  trailing: trailing,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16).visible(!loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)),
                SettingItemWidget(
                  decoration: boxDecorationDefault(color: context.cardColor),
                  title: locale.value.requests,
                  subTitle: locale.value.requestForServiceCategoryAndSpecialization,
                  splashColor: transparentColor,
                  onTap: () {
                    Get.to(() => RequestListScreen());
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcRequest, color: appColorPrimary).circularLightPrimaryBg(),
                  trailing: trailing,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16).visible(loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)),
                SettingItemWidget(
                  decoration: boxDecorationDefault(color: context.cardColor),
                  title: locale.value.receptionists,
                  subTitle: locale.value.allReceptionist,
                  splashColor: transparentColor,
                  onTap: () {
                    Get.to(() => ReceptionistListScreen());
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcReceptionist, color: appColorPrimary).circularLightPrimaryBg(),
                  trailing: trailing,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16).visible(loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)),
                SettingItemWidget(
                  title: locale.value.settings,
                  decoration: boxDecorationDefault(color: context.cardColor),
                  subTitle: "${locale.value.changePassword},${locale.value.themeAndMore}",
                  splashColor: transparentColor,
                  onTap: () {
                    Get.to(() => SettingScreen());
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcSetting, color: appColorPrimary).circularLightPrimaryBg(),
                  trailing: trailing,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16),
                SettingItemWidget(
                  title: locale.value.aboutApp,
                  decoration: boxDecorationDefault(color: context.cardColor),
                  subTitle: locale.value.privacyPolicyTerms,
                  splashColor: transparentColor,
                  onTap: () {
                    Get.to(() => const AboutScreen());
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcInfo, color: appColorPrimary).circularLightPrimaryBg(),
                  trailing: trailing,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16),

                SettingItemWidget(
                  title: locale.value.logout,
                  decoration: boxDecorationDefault(color: context.cardColor),
                  subTitle: locale.value.securelyLogOutOfAccount,
                  splashColor: transparentColor,
                  onTap: () {
                    showConfirmDialogCustom(
                      primaryColor: appColorPrimary,
                      context,
                      negativeText: locale.value.cancel,
                      positiveText: locale.value.logout,
                      onAccept: (_) {
                        profileController.handleLogout();
                      },
                      dialogType: DialogType.CONFIRMATION,
                      subTitle: locale.value.doYouWantToLogout,
                      title: locale.value.ohNoYouAreLeaving,
                    );
                  },
                  titleTextStyle: boldTextStyle(size: 14),
                  leading: commonLeadingWid(imgPath: Assets.iconsIcLogout, color: appColorPrimary).circularLightPrimaryBg(),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                ).paddingTop(16),
                30.height,
                VersionInfoWidget(prefixText: '${locale.value.version}  ', textStyle: primaryTextStyle(color: secondaryTextColor)).center(),
                32.height,
              ],
            ).paddingSymmetric(horizontal: 16),
          ],
        ),
      ),
    );
  }

  Widget get trailing => const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: darkGray);
}