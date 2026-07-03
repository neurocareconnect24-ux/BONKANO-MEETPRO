import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/empty_error_state_widget.dart';
import '../Encounter/components/all_encounter_card.dart';
import '../Encounter/model/encounters_list_model.dart';
import '../appointment/components/appointment_card.dart';
import '../appointment/model/appointments_res_model.dart';
import 'medical_acts_controller.dart';
import '../Encounter/add_encounter/encounter_dashboard_screen.dart';
import '../appointment/appointment_detail.dart';

class MedicalActsScreen extends StatelessWidget {
  MedicalActsScreen({super.key});

  final MedicalActsController medicalActsCont = Get.put(MedicalActsController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.encounters, // "Actes Médicaux"
      appBarVerticalSize: Get.height * 0.12,
      body: Obx(() {
        if (medicalActsCont.isLoading.value && medicalActsCont.combinedList.isEmpty) {
          return const LoaderWidget();
        }

        return SnapHelperWidget(
          future: Future.value(medicalActsCont.combinedList),
          onSuccess: (data) {
            if (medicalActsCont.combinedList.isEmpty) {
              return NoDataWidget(
                title: "Aucun acte médical trouvé",
                subTitle: "L'historique des soins est vide pour ce patient.",
                imageWidget: const EmptyStateWidget(),
                retryText: locale.value.reload,
                onRetry: () => medicalActsCont.getCombinedList(),
              ).paddingSymmetric(horizontal: 32);
            }

            return AnimatedListView(
              padding: const EdgeInsets.all(16),
              itemCount: medicalActsCont.combinedList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              onSwipeRefresh: () async {
                await medicalActsCont.getCombinedList();
              },
              itemBuilder: (context, index) {
                var item = medicalActsCont.combinedList[index];

                if (item is EncounterElement) {
                  return AllEncounterCard(
                    encounterElement: item,
                    onEncounterClick: () {
                      Get.to(() => EncounterDashboardScreen(), arguments: item.id);
                    },
                  ).paddingBottom(16);
                } else if (item is AppointmentData) {
                  return AppointmentCard(
                    appointment: item,
                    onCheckIn: () {
                       // Optional: implement quick check-in if needed
                    },
                  ).paddingBottom(16);
                }

                return const SizedBox();
              },
            );
          },
        );
      }),
    );
  }
}
