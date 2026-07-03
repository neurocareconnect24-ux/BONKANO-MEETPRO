import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/components/app_scaffold.dart';
import 'package:bonkano_meet_pro/screens/receptionist/components/add_receptionist_controller.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../clinic/model/clinics_res_model.dart';
import '../../doctor/clinic_center/clinic_center_screen.dart';

class AddReceptionistComponent extends StatelessWidget {
  final bool isEdit;
  final bool isFromEditProfile;

  AddReceptionistComponent({super.key, this.isEdit = false, this.isFromEditProfile = false});

  final AddReceptionistController addReceptionistCont = Get.put(AddReceptionistController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
        appBartitleText: isEdit
            ? locale.value.editReceptionist
            : isFromEditProfile
                ? locale.value.editProfile
                : locale.value.addReceptionist,
        isLoading: addReceptionistCont.isLoading,
        appBarVerticalSize: Get.height * 0.12,
        body: AnimatedScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 60, top: 16),
          children: [
            Obx(
              () => Form(
                key: addReceptionistCont.addReqFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      2.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isEdit ? "Edit Receptionist" : locale.value.addReceptionist,
                            style: secondaryTextStyle(size: 16, weight: FontWeight.w600, color: isDarkMode.value ? null : darkGrayTextColor),
                          ).expand(),
                        ],
                      ),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 12),
                        controller: addReceptionistCont.firstNameCont,
                        focus: addReceptionistCont.firstNameFocus,
                        nextFocus: addReceptionistCont.lastNameFocus,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(
                          context,
                          hintText: locale.value.firstName,
                          fillColor: context.cardColor,
                          filled: true,
                        ),
                        suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, color: secondaryTextColor, size: 12).paddingAll(16),
                      ),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 12),
                        controller: addReceptionistCont.lastNameCont,
                        focus: addReceptionistCont.lastNameFocus,
                        nextFocus: addReceptionistCont.emailFocus,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(
                          context,
                          hintText: locale.value.lastName,
                          fillColor: context.cardColor,
                          filled: true,
                        ),
                        suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, color: secondaryTextColor, size: 12).paddingAll(16),
                      ),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 12),
                        controller: addReceptionistCont.clinicCenterCont,
                        focus: addReceptionistCont.clinicCenterFocus,
                        nextFocus: addReceptionistCont.emailFocus,
                        textFieldType: TextFieldType.MULTILINE,
                        minLines: 1,
                        readOnly: true,
                        onTap: () {
                          Get.to(() => ClinicCenterScreen(), arguments: addReceptionistCont.selectedClinic.value)?.then((value) {
                            if (value is ClinicData) {
                              addReceptionistCont.selectClinics(clinic: value);
                            }
                          });
                        },
                        decoration: inputDecoration(
                          context,
                          hintText: locale.value.selectClinicCenters,
                          fillColor: context.cardColor,
                          filled: true,
                          prefixIconConstraints: BoxConstraints.loose(const Size.square(60)),
                          prefixIcon: (addReceptionistCont.selectedClinic.value.clinicImage.isEmpty && addReceptionistCont.selectedClinic.value.id.isNegative).obs.value
                              ? null
                              : CachedImageWidget(
                                  url: addReceptionistCont.selectedClinic.value.clinicImage,
                                  height: 35,
                                  width: 35,
                                  firstName: addReceptionistCont.selectedClinic.value.name,
                                  fit: BoxFit.cover,
                                  circle: true,
                                  usePlaceholderIfUrlEmpty: true,
                                ).paddingOnly(left: 12, top: 8, bottom: 8, right: 12),
                          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: darkGray.withValues(alpha: 0.5)),
                        ),
                      ),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 12),
                        controller: addReceptionistCont.emailCont,
                        focus: addReceptionistCont.emailFocus,
                        nextFocus: addReceptionistCont.addressFocus,
                        textFieldType: TextFieldType.EMAIL_ENHANCED,
                        decoration: inputDecoration(
                          context,
                          hintText: locale.value.email,
                          fillColor: context.cardColor,
                          filled: true,
                        ),
                        suffix: commonLeadingWid(imgPath: Assets.iconsIcMail, color: secondaryTextColor, size: 12).paddingAll(16),
                      ),
                      16.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locale.value.gender, style: primaryTextStyle()),
                          8.height,
                          Obx(
                            () => HorizontalList(
                              itemCount: genders.length,
                              spacing: 16,
                              runSpacing: 16,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                return Obx(
                                  () => InkWell(
                                    onTap: () {
                                      addReceptionistCont.selectedGender(genders[index]);
                                    },
                                    borderRadius: radius(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: boxDecorationDefault(
                                        color: addReceptionistCont.selectedGender.value.id == genders[index].id ? appColorPrimary : context.scaffoldBackgroundColor,
                                      ),
                                      child: Text(
                                        genders[index].name,
                                        style: secondaryTextStyle(
                                          color: addReceptionistCont.selectedGender.value.id == genders[index].id ? white : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 12),
                        controller: addReceptionistCont.addressCont,
                        focus: addReceptionistCont.addressFocus,
                        nextFocus: addReceptionistCont.phoneFocus,
                        textFieldType: TextFieldType.MULTILINE,
                        minLines: 1,
                        decoration: inputDecoration(
                          context,
                          hintText: locale.value.address,
                          fillColor: context.cardColor,
                          filled: true,
                        ),
                        suffix: commonLeadingWid(imgPath: Assets.iconsIcLocation, size: 12).paddingAll(16),
                      ),
                      16.height,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(
                            () => AppTextField(
                              textStyle: primaryTextStyle(size: 12),
                              textFieldType: TextFieldType.OTHER,
                              controller: TextEditingController(text: "  +${addReceptionistCont.pickedPhoneCode.value.phoneCode}"),
                              focus: addReceptionistCont.phoneCodeFocus,
                              nextFocus: addReceptionistCont.phoneFocus,
                              errorThisFieldRequired: locale.value.thisFieldIsRequired,
                              readOnly: true,
                              onTap: () {
                                pickCountry(context, onSelect: (Country country) {
                                  addReceptionistCont.pickedPhoneCode(country);
                                  addReceptionistCont.phoneCodeCont.text = addReceptionistCont.pickedPhoneCode.value.phoneCode;
                                });
                              },
                              textAlign: TextAlign.center,
                              decoration: inputDecoration(
                                context,
                                hintText: "",
                                prefixIcon: Text(
                                  addReceptionistCont.pickedPhoneCode.value.flagEmoji,
                                ).paddingOnly(top: 2, left: 8),
                                prefixIconConstraints: BoxConstraints.tight(const Size(24, 24)),
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: dividerColor,
                                  size: 22,
                                ).paddingOnly(right: 32),
                                suffixIconConstraints: BoxConstraints.tight(const Size(32, 24)),
                                fillColor: context.cardColor,
                                filled: true,
                              ),
                            ),
                          ).expand(flex: 3),
                          16.width,
                          AppTextField(
                            textStyle: primaryTextStyle(size: 12),
                            textFieldType: TextFieldType.PHONE,
                            controller: addReceptionistCont.phoneCont,
                            focus: addReceptionistCont.phoneFocus,
                            nextFocus: addReceptionistCont.passwordFocus,
                            // maxLength: 10,
                            errorThisFieldRequired: locale.value.thisFieldIsRequired,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                            decoration: inputDecoration(
                              context,
                              hintText: locale.value.contactNumber,
                              fillColor: context.cardColor,
                              filled: true,
                            ),
                            suffix: commonLeadingWid(imgPath: Assets.iconsIcCall, color: secondaryTextColor, size: 12).paddingAll(16),
                          ).expand(flex: 8),
                        ],
                      ),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 12),
                        controller: addReceptionistCont.passwordCont,
                        // Optional
                        focus: addReceptionistCont.passwordFocus,
                        nextFocus: addReceptionistCont.confirmPasswordFocus,
                        textFieldType: TextFieldType.PASSWORD,
                        obscureText: true,
                        decoration: inputDecoration(
                          context,
                          fillColor: context.cardColor,
                          filled: true,
                          hintText: locale.value.password,
                        ),
                        suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, color: appColorPrimary, size: 12).paddingAll(14),
                        suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: appColorPrimary, size: 12).paddingAll(14),
                      ),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 12),
                        controller: addReceptionistCont.confirmPasswordCont,
                        // Optional
                        focus: addReceptionistCont.confirmPasswordFocus,
                        textFieldType: TextFieldType.PASSWORD,
                        obscureText: true,
                        decoration: inputDecoration(
                          context,
                          fillColor: context.cardColor,
                          filled: true,
                          hintText: locale.value.confirmNewPassword,
                        ),
                        suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, color: appColorPrimary, size: 12).paddingAll(14),
                        suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: appColorPrimary, size: 12).paddingAll(14),
                      ),
                      32.height,
                      AppButton(
                        width: Get.width,
                        text: locale.value.save,
                        color: appColorSecondary,
                        textStyle: appButtonTextStyleWhite,
                        shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
                        onTap: () {
                          if (addReceptionistCont.addReqFormKey.currentState!.validate()) {
                            hideKeyboard(context);
                            addReceptionistCont.saveReceptionist();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}