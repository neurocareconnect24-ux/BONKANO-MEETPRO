import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/Encounter/encounter_dashboard/components/doctor_card_component.dart';
import 'package:bonkano_meet_pro/screens/Encounter/encounter_dashboard/encounter_dashboard_controller.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../model/encounters_list_model.dart';
import 'components/more_info_component.dart';
import 'components/patient_card_componet.dart';
import '../../chat/chat_screen.dart';

class EncountersDashboardScreen extends StatelessWidget {
  final EncounterElement encounterDetail;
  EncountersDashboardScreen({super.key, required this.encounterDetail});

  final EncountersDashboardController encountersCont = Get.put(EncountersDashboardController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.encounter,
      isLoading: encountersCont.isLoading,
      appBarVerticalSize: Get.height * 0.12,
      actions: [
        IconButton(
          onPressed: () {
            encountersCont.getEncounterInvoice();
          },
          icon: const Icon(
            Icons.download,
            size: 24,
            color: white,
          ),
        ).paddingOnly(right: 10).visible(!encounterDetail.status),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => ChatScreen(),
            arguments: {
              'appointment_id': encounterDetail.id,
              'receiver_id': encounterDetail.userId,
            },
          );
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      body: SizedBox(
        height: Get.height,
        child: AnimatedScrollView(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          padding: const EdgeInsets.all(16),
          listAnimationType: ListAnimationType.Slide,
          children: [
            PatientCardComponent(encounterData: encounterDetail),
            DoctorCardComponent(encounterData: encounterDetail),
            MoreInfoComponent(encounterData: encounterDetail),
          ],
        ),
      ),
    );
  }
}
