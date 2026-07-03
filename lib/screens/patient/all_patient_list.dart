import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/main.dart';
import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../utils/empty_error_state_widget.dart';
import 'all_patient_list_controller.dart';
import 'all_patient_list_controller.dart';
import 'components/patient_card.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/app_common.dart';
import '../appointment/add_appointment/add_patient_dialog.dart';class AllPatientList extends StatelessWidget {
  AllPatientList({super.key});

  final AllPatientListcontroller allPatientsCont = Get.put(AllPatientListcontroller());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
        appBartitleText: locale.value.patients,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: allPatientsCont.isLoading,
        floatingActionButton: (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor) || loginUserData.value.userRole.contains(EmployeeKeyConst.receptionist) || loginUserData.value.userRole.contains(EmployeeKeyConst.doctor))
            ? FloatingActionButton(
                onPressed: () async {
                  final newPatient = await showAddPatientDialog(context);
                  if (newPatient != null) {
                    allPatientsCont.patientPage(1);
                    allPatientsCont.getPatientList();
                  }
                },
                backgroundColor: appColorPrimary,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: SnapHelperWidget(
          future: allPatientsCont.patientFuture.value,
          loadingWidget: allPatientsCont.isLoading.value ? const Offstage() : const LoaderWidget(),
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.value.reload,
              imageWidget: const ErrorStateWidget(),
              onRetry: () {
                allPatientsCont.patientPage(1);
                allPatientsCont.getPatientList();
              },
            );
          },
          onSuccess: (res) {
            return Obx(
              () => AnimatedListView(
                shrinkWrap: true,
                itemCount: allPatientsCont.patientList.length,
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.Slide,
                emptyWidget: NoDataWidget(
                  title: locale.value.noPatientsFound,
                  subTitle: locale.value.oppsNoPatientsFoundAtMomentTryAgainLater,
                  imageWidget: const EmptyStateWidget(),
                ).paddingSymmetric(horizontal: 32).visible(!allPatientsCont.isLoading.value),
                onSwipeRefresh: () async {
                  allPatientsCont.patientPage(1);
                  return await allPatientsCont.getPatientList(showloader: false);
                },
                onNextPage: () async {
                  if (!allPatientsCont.isPatientLastPage.value) {
                    allPatientsCont.patientPage++;
                    allPatientsCont.getPatientList();
                  }
                },
                itemBuilder: (ctx, index) {
                  return GestureDetector(
                    onTap: () {
                      // Get.to(() => PatientDetailScreen(), arguments: allPatientsCont.patientList[index]);
                    },
                    child: PatientCardWid(patient: allPatientsCont.patientList[index]).paddingBottom(16),
                  );
                },
              ),
            );
          },
        ).paddingSymmetric(vertical: 16));
  }
}
