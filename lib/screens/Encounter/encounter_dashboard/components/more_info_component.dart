import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/generated/assets.dart';
import 'package:bonkano_meet_pro/screens/Encounter/invoice_details/invoice_details_screen.dart';
import 'package:bonkano_meet_pro/screens/Encounter/medical_Report/medical_reports_screen.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import 'package:bonkano_meet_pro/utils/common_base.dart';
import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../appointment/appointment_detail.dart';
import '../../../appointment/model/appointments_res_model.dart';
import '../../body_chart/body_chart_screen.dart';
import '../../clinical_details/clinical_details_screen.dart';
import '../../clinical_details/structured_report_screen.dart';
import '../../clinical_details/soap_screen.dart';
import '../../model/encounters_list_model.dart';

class MoreInfoComponent extends StatelessWidget {
  final EncounterElement encounterData;
  const MoreInfoComponent({super.key, required this.encounterData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(locale.value.moreInformation, style: boldTextStyle(size: 14, weight: FontWeight.w600, color: isDarkMode.value ? null : darkGrayTextColor)),
        8.height,
        SettingItemWidget(
          title: locale.value.clinicDetail,
          decoration: boxDecorationDefault(
            color: context.cardColor,
          ),
          subTitle: locale.value.patientHealthInformation,
          splashColor: transparentColor,
          onTap: () {
            Get.to(() => ClinicalDetailsScreen(), arguments: encounterData);
          },
          titleTextStyle: boldTextStyle(size: 14),
          leading: commonLeadingWid(imgPath: Assets.iconsIcHospital, color: appColorSecondary),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: darkGray),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ),
        SettingItemWidget(
          title: encounterData.typeLabel.isNotEmpty
              ? "Rapport : ${encounterData.typeLabel}"
              : "Rapport : ${encounterData.encounterType.toUpperCase()}",
          decoration: boxDecorationDefault(
            color: context.cardColor,
          ),
          subTitle: "Détails de l'acte médical structuré",
          splashColor: transparentColor,
          onTap: () {
            Get.to(() => StructuredReportScreen(encounterId: encounterData.id.validate(), encounterType: encounterData.encounterType));
          },
          titleTextStyle: boldTextStyle(size: 14),
          leading: commonLeadingWid(imgPath: Assets.iconsIcFile, color: appColorSecondary),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: darkGray),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ).paddingTop(16),
        SettingItemWidget(
          title: locale.value.bodyChart,
          decoration: boxDecorationDefault(
            color: context.cardColor,
          ),
          subTitle: locale.value.showBodyChartRelatedInformation,
          splashColor: transparentColor,
          onTap: () {
            Get.to(() => BodyChartScreen(), arguments: encounterData);
          },
          titleTextStyle: boldTextStyle(size: 14),
          leading: commonLeadingWid(imgPath: Assets.iconsIcPerson, color: appColorSecondary),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: darkGray),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ).paddingTop(16).visible(appConfigs.value.isBodyChart),
        SettingItemWidget(
          title: locale.value.viewReport,
          decoration: boxDecorationDefault(
            color: context.cardColor,
          ),
          subTitle: locale.value.showReportRelatedInformation,
          splashColor: transparentColor,
          onTap: () {
            Get.to(() => MedicalReportsScreen(), arguments: encounterData);
          },
          titleTextStyle: boldTextStyle(size: 14),
          leading: commonLeadingWid(imgPath: Assets.iconsIcFile, color: appColorSecondary),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: darkGray),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ).paddingTop(16),
        SettingItemWidget(
          title: "SOAP", //Don't Translate its sort form of Subjective, Objective, Assessment, and Plan
          decoration: boxDecorationDefault(
            color: context.cardColor,
          ),
          subTitle: locale.value.subjectiveObjectiveAssessmentAndPlan,
          splashColor: transparentColor,
          onTap: () {
            Get.to(() => SOAPScreen(), arguments: encounterData);
          },
          titleTextStyle: boldTextStyle(size: 14),
          leading: commonLeadingWid(imgPath: Assets.iconsIcSoap, color: appColorSecondary),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: darkGray),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ).paddingTop(16).visible(appConfigs.value.viewPatientSoap),
        SettingItemWidget(
          title: locale.value.billDetails,
          decoration: boxDecorationDefault(
            color: context.cardColor,
          ),
          subTitle: locale.value.showBillDetailsRelatedInformation,
          splashColor: transparentColor,
          onTap: () {
            Get.to(() => InvoiceDetailsScreen(), arguments: encounterData);
          },
          titleTextStyle: boldTextStyle(size: 14),
          leading: commonLeadingWid(imgPath: Assets.iconsIcInvoice, color: appColorSecondary),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: darkGray),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ).paddingTop(16),
        SettingItemWidget(
          title: locale.value.appointment,
          decoration: boxDecorationDefault(
            color: context.cardColor,
          ),
          subTitle: "Voir le rendez-vous associé",
          splashColor: transparentColor,
          onTap: () {
            Get.to(() => AppointmentDetail(), arguments: AppointmentData(id: encounterData.appointmentId));
          },
          titleTextStyle: boldTextStyle(size: 14),
          leading: commonLeadingWid(imgPath: Assets.iconsIcCalendar, color: appColorSecondary),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: darkGray),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ).paddingTop(16).visible(encounterData.appointmentId > 0),
        16.height,
      ],
    );
  }
}
