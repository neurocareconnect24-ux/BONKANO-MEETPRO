import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/Encounter/clinical_details/clinical_details_controller.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import '../../../../components/cached_image_widget.dart';
import '../../../../generated/assets.dart';
import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/view_all_label_component.dart';
import 'add_prescription_component.dart';

class PrescriptionComponent extends StatelessWidget {
  final ClinicalDetailsController clincalDetailCont;
  const PrescriptionComponent({super.key, required this.clincalDetailCont});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ViewAllLabel(
          label: locale.value.prescription,
          trailingText: locale.value.add,
          isShowAll: clincalDetailCont.encounterData.value.status,
          onTap: () {
            clincalDetailCont.getClearPrescription();
            Get.bottomSheet(AddPrescriptionComponent());
          },
        ).paddingLeft(16),
        Obx(
          () => clincalDetailCont.prescriptionList.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: boxDecorationDefault(
                    color: context.cardColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(locale.value.prescription, style: primaryTextStyle(size: 12, color: appColorSecondary)),
                )
              : Obx(
                  () => AnimatedListView(
                    shrinkWrap: true,
                    listAnimationType: ListAnimationType.None,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: clincalDetailCont.prescriptionList.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: boxDecorationDefault(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clincalDetailCont.prescriptionList[index].name,
                                  style: boldTextStyle(size: 14, color: isDarkMode.value ? null : darkGrayTextColor),
                                ).expand(),
                                InkWell(
                                  onTap: () {
                                    clincalDetailCont.getEditData(index);
                                    Get.bottomSheet(AddPrescriptionComponent(isEdit: true, index: index));
                                  },
                                  child: const CachedImageWidget(
                                    url: Assets.iconsIcEditReview,
                                    height: 14,
                                    width: 14,
                                    color: iconColor,
                                  ),
                                ).visible(clincalDetailCont.encounterData.value.status),
                                12.width.visible(clincalDetailCont.encounterData.value.status),
                                InkWell(
                                  onTap: () {
                                    showConfirmDialogCustom(
                                      context,
                                      primaryColor: appColorPrimary,
                                      title: locale.value.doYouWantToPerformThisAction,
                                      positiveText: locale.value.delete,
                                      negativeText: locale.value.cancel,
                                      onAccept: (ctx) {
                                        clincalDetailCont.prescriptionList.removeAt(index);
                                      },
                                    );
                                  },
                                  child: const CachedImageWidget(
                                    url: Assets.iconsIcDelete,
                                    height: 14,
                                    width: 14,
                                    color: iconColor,
                                  ),
                                ).visible(clincalDetailCont.encounterData.value.status),
                              ],
                            ),
                            6.height,
                            Text(clincalDetailCont.prescriptionList[index].instruction, style: primaryTextStyle(size: 12, color: dividerColor)),
                            16.height,
                            Divider(color: isDarkMode.value ? borderColor.withValues(alpha: 0.2) : context.dividerColor.withValues(alpha: 0.2), height: 1),
                            16.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${locale.value.frequency}: ',
                                        style: primaryTextStyle(color: dividerColor, size: 12),
                                      ),
                                      TextSpan(
                                        text: clincalDetailCont.prescriptionList[index].frequency,
                                        style: secondaryTextStyle(size: 12, weight: FontWeight.w600, color: isDarkMode.value ? null : darkGrayTextColor),
                                      ),
                                    ],
                                  ),
                                ).expand(),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${locale.value.days}: ',
                                        style: primaryTextStyle(color: dividerColor, size: 12),
                                      ),
                                      TextSpan(
                                        text: clincalDetailCont.prescriptionList[index].duration,
                                        style: secondaryTextStyle(size: 12, weight: FontWeight.w600, color: isDarkMode.value ? null : darkGrayTextColor),
                                      ),
                                    ],
                                  ),
                                ).expand()
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ).paddingSymmetric(horizontal: 16),
      ],
    );
  }
}
