import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import 'package:bonkano_meet_pro/utils/common_base.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import 'clinical_details_controller.dart';
import 'components/notes_component.dart';
import 'components/observation_component.dart';
import 'components/otherinfo_component.dart';
import 'components/prescription_component.dart';
import 'components/problem_component.dart';

class ClinicalDetailsScreen extends StatelessWidget {
  ClinicalDetailsScreen({super.key});
  final ClinicalDetailsController clincalDetailCont = Get.put(ClinicalDetailsController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.clinicalDetail,
      isBlurBackgroundinLoader: true,
      isLoading: clincalDetailCont.isLoading,
      appBarVerticalSize: Get.height * 0.12,
      body: Form(
        key: clincalDetailCont.clinicalDetailsFormKey,
        child: AnimatedScrollView(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            ProblemComponent(clincalDetailCont: clincalDetailCont).visible(appConfigs.value.isEncounterProblem),
            ObservationComponent(clincalDetailCont: clincalDetailCont).visible(appConfigs.value.isEncounterObservation),
            NotesComponent(clincalDetailCont: clincalDetailCont).visible(appConfigs.value.isEncounterNote),
            // 24.height,
            // Divider(color: context.dividerColor.withValues(alpha: 0.2),height: 1),
            PrescriptionComponent(clincalDetailCont: clincalDetailCont).visible(appConfigs.value.isEncounterPrescription),
            OtherInfoComponent(clincalDetailCont: clincalDetailCont).paddingBottom(16),
            54.height
          ],
        ),
      ),
      widgetsStackedOverBody: [
        Positioned(
          bottom: 16 + MediaQuery.of(context).padding.bottom,
          height: 50,
          width: Get.width,
          child: Obx(
            () => AppButton(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: Get.width,
              text: locale.value.save,
              color: appColorSecondary,
              textStyle: appButtonTextStyleWhite,
              shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
              onTap: () {
                if (clincalDetailCont.clinicalDetailsFormKey.currentState!.validate()) {
                  clincalDetailCont.saveEncounterDashboard();
                }
              },
            ).visible(clincalDetailCont.encounterData.value.status &&
                (clincalDetailCont.selectedProblems.isNotEmpty || clincalDetailCont.selectedObservation.isNotEmpty || clincalDetailCont.selectedNotes.isNotEmpty || clincalDetailCont.prescriptionList.isNotEmpty)),
          ),
        ),
      ],
    );
  }
}
