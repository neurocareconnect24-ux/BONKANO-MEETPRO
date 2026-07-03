import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import 'change_password_controller.dart';

import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final ChangePassController changePassController = Get.put(ChangePassController());
  final GlobalKey<FormState> _changePassformKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.changePassword,
      appBarVerticalSize: Get.height * 0.12,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _changePassformKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              32.height,
              SizedBox(
                width: Get.width * 0.8,
                child: Text(
                  locale.value.yourNewPasswordMust,
                  style: secondaryTextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
              64.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: changePassController.oldPasswordCont, // Optional
                textFieldType: TextFieldType.PASSWORD, obscureText: true,
                decoration: inputDecoration(context, fillColor: context.cardColor, filled: true, hintText: locale.value.oldPassword),
                suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, color: appColorPrimary, size: 12).paddingAll(14),
                suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: appColorPrimary).paddingAll(14),
              ),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: changePassController.newpasswordCont, // Optional
                textFieldType: TextFieldType.PASSWORD, obscureText: true,
                decoration: inputDecoration(context, fillColor: context.cardColor, filled: true, hintText: locale.value.newPassword),
                suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, color: appColorPrimary, size: 12).paddingAll(14),
                suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: appColorPrimary, size: 12).paddingAll(14),
              ),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: changePassController.confirmPasswordCont,
                // Optional
                textFieldType: TextFieldType.PASSWORD, obscureText: true,
                decoration: inputDecoration(
                  context,
                  fillColor: context.cardColor,
                  filled: true,
                  hintText: locale.value.confirmNewPassword,
                ),
                suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, color: appColorPrimary, size: 12).paddingAll(14),
                suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: appColorPrimary, size: 12).paddingAll(14),
              ),
              64.height,
              AppButton(
                width: Get.width,
                text: locale.value.submit,
                textStyle: appButtonTextStyleWhite,
                onTap: () async {
                  ifNotTester(() async {
                    if (await isNetworkAvailable()) {
                      if (_changePassformKey.currentState!.validate()) {
                        _changePassformKey.currentState!.save();
                        changePassController.saveForm();
                      }
                    } else {
                      toast(locale.value.yourInternetIsNotWorking);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}