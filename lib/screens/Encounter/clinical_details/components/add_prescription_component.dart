import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import '../../../../generated/assets.dart';
import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/common_base.dart';
import '../clinical_details_controller.dart';

class AddPrescriptionComponent extends StatelessWidget {
  final bool isEdit;
  final int? index;
  AddPrescriptionComponent({super.key, this.isEdit = false, this.index});

  final ClinicalDetailsController clincalDetailCont = Get.put(ClinicalDetailsController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
      ),
      child: Form(
        key: clincalDetailCont.addPrescriptionFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? locale.value.editPrescription : locale.value.editPrescription, style: secondaryTextStyle(size: 16, weight: FontWeight.w600, color: isDarkMode.value ? null : darkGrayTextColor)),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: clincalDetailCont.nameCont,
                textFieldType: TextFieldType.NAME,
                focus: clincalDetailCont.nameFocus,
                isValidationRequired: true,
                decoration: inputDecoration(
                  context,
                  fillColor: context.cardColor,
                  filled: true,
                  hintText: locale.value.name,
                ),
                suffix: commonLeadingWid(imgPath: Assets.iconsIcUser, color: iconColor, size: 10).paddingAll(16),
              ),
              16.height,
              // AppDropDownWidget(
              //   selectValue: genInvoiceCon.selectFrequency.isEmpty ? null : genInvoiceCon.selectFrequency.value.toString(),
              //   onChanged: (value) {
              //     genInvoiceCon.selectFrequency(value);
              //   },
              //   items: genInvoiceCon.frequencyList.map((item) {
              //     return DropdownMenuItem(
              //       value: item,
              //       child: Text(item),
              //     );
              //   }).toList(),
              //   hintText: "Frequency",
              // ),
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: clincalDetailCont.frequencyCont,
                textFieldType: TextFieldType.NUMBER,
                focus: clincalDetailCont.frequencyFocus,
                isValidationRequired: true,
                decoration: inputDecoration(
                  context,
                  fillColor: context.cardColor,
                  filled: true,
                  hintText: locale.value.frequency,
                ),
                // suffix: commonLeadingWid(imgPath: Assets.iconsIcDropdown, color: iconColor, size: 10).paddingSymmetric(horizontal: 20, vertical: 16),
              ),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: clincalDetailCont.durationCont,
                textFieldType: TextFieldType.NUMBER,
                focus: clincalDetailCont.durationFocus,
                isValidationRequired: true,
                decoration: inputDecoration(
                  context,
                  fillColor: context.cardColor,
                  filled: true,
                  hintText: locale.value.duration,
                ),
                suffix: commonLeadingWid(imgPath: Assets.iconsIcClock, color: iconColor, size: 10).paddingAll(16),
              ),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: clincalDetailCont.instructionCont,
                minLines: 3,
                focus: clincalDetailCont.instructionFocus,
                textFieldType: TextFieldType.MULTILINE,
                keyboardType: TextInputType.multiline,
                isValidationRequired: false,
                decoration: inputDecoration(
                  context,
                  hintText: locale.value.instruction,
                  fillColor: context.cardColor,
                  filled: true,
                ),
              ),
              16.height,
              AppButton(
                width: Get.width,
                text: locale.value.save,
                color: appColorSecondary,
                textStyle: appButtonTextStyleWhite,
                shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
                onTap: () {
                  if (clincalDetailCont.addPrescriptionFormKey.currentState!.validate()) {
                    if (isEdit) {
                      clincalDetailCont.saveEditData(index);
                    } else {
                      clincalDetailCont.savePrescription();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
