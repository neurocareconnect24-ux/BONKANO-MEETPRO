import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/clinic/model/clinics_res_model.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';

import '../../../../components/cached_image_widget.dart';
import '../clinic_center_controller.dart';

class ClinicCenterCardWidget extends StatelessWidget {
  final ClinicData clinicData;
  final ClinicCenterController clinicListController;
  const ClinicCenterCardWidget({
    super.key,
    required this.clinicData,
    required this.clinicListController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (clinicListController.isSingleSelect.value) {
          clinicListController.singleClinicSelect(clinicData);
        } else {
          if (clinicListController.checkSelClinicList(clinic: clinicData)) {
            clinicListController.selectedClinics.removeWhere((element) => element.id == clinicData.id);
            clinicListController.checkSelClinicList(clinic: clinicData);
          } else {
            clinicListController.selectedClinics.add(clinicData);
            clinicListController.checkSelClinicList(clinic: clinicData);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(
          borderRadius: BorderRadius.circular(6),
          color: context.cardColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImageWidget(
              url: clinicData.clinicImage,
              width: 52,
              radius: 6,
              fit: BoxFit.cover,
              height: 52,
            ),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(clinicData.name.toString(), style: boldTextStyle(size: 14, color: isDarkMode.value ? null : darkGrayTextColor)),
                2.height,
                Text(clinicData.description.toString(), style: primaryTextStyle(size: 12, color: dividerColor)),
              ],
            ).expand(),
            12.width,
            Obx(
              () => clinicListController.isSingleSelect.value
                  ? Radio(
                      value: clinicData.id,
                      groupValue: clinicListController.singleClinicSelect.value.id,
                      onChanged: (val) async {
                        clinicListController.singleClinicSelect(clinicData);
                      },
                    )
                  : Checkbox(
                      checkColor: whiteColor,
                      value: clinicListController.checkSelClinicList(clinic: clinicData),
                      activeColor: appColorPrimary,
                      visualDensity: VisualDensity.compact,
                      onChanged: (val) async {
                        if (clinicListController.checkSelClinicList(clinic: clinicData)) {
                          clinicListController.selectedClinics.removeWhere((element) => element.id == clinicData.id);
                          clinicListController.checkSelClinicList(clinic: clinicData);
                        } else {
                          clinicListController.selectedClinics.add(clinicData);
                          clinicListController.checkSelClinicList(clinic: clinicData);
                        }
                      },
                      side: const BorderSide(color: secondaryTextColor, width: 1.5),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
