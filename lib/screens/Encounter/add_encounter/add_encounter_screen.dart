import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/Encounter/add_encounter/components/doctor_list_widget.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import 'package:bonkano_meet_pro/utils/constants.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/bottom_selection_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import 'add_encounter_controller.dart';
import 'components/clinic_list_widget.dart';
import 'components/patient_list_widget.dart';

class AddEncounterScreen extends StatelessWidget {
  AddEncounterScreen({super.key});
  final AddEncountersController addEncountersCont = Get.put(AddEncountersController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.addEncounter,
      appBarVerticalSize: Get.height * 0.12,
      isBlurBackgroundinLoader: true,
      isLoading: addEncountersCont.isLoading,
      body: Obx(
        () => SizedBox(
          height: Get.height,
          child: Form(
            key: addEncountersCont.addEncounterFormKey,
            child: AnimatedScrollView(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              listAnimationType: ListAnimationType.None,
              children: [
                Text('*${locale.value.fillPatientEncounterDetails}', style: boldTextStyle(size: 12, weight: FontWeight.w600, fontStyle: FontStyle.italic, color: appColorSecondary)),
                16.height,
                AppTextField(
                  textStyle: primaryTextStyle(size: 12),
                  controller: addEncountersCont.dateCont,
                  textFieldType: TextFieldType.NAME,
                  readOnly: true,
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: addEncountersCont.editEncounterResp.value.encounterDate.dateInyyyyMMddHHmmFormat.isAfter(DateTime.now()) ? addEncountersCont.editEncounterResp.value.encounterDate.dateInyyyyMMddHHmmFormat : DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );

                    if (selectedDate != null) {
                      addEncountersCont.dateCont.text = selectedDate.formatDateYYYYmmdd();
                    } else {
                      log("Date is not selected");
                    }
                  },
                  decoration: inputDecoration(
                    context,
                    hintText: locale.value.date,
                    fillColor: context.cardColor,
                    filled: true,
                    suffixIcon: commonLeadingWid(imgPath: Assets.iconsIcCalendar, color: iconColor, size: 10).paddingAll(16),
                  ),
                ),
                AppTextField(
                  textStyle: primaryTextStyle(size: 12),
                  controller: addEncountersCont.clinicCont,
                  focus: addEncountersCont.clinicFocus,
                  textFieldType: TextFieldType.NAME,
                  readOnly: true,
                  onTap: () async {
                    serviceCommonBottomSheet(
                      context,
                      child: Obx(
                        () => BottomSelectionSheet(
                          title: locale.value.chooseClinic,
                          hintText: locale.value.searchForClinic,
                          hasError: addEncountersCont.hasErrorFetchingClinic.value,
                          isEmpty: !addEncountersCont.isLoading.value && addEncountersCont.clinicList.isEmpty,
                          errorText: addEncountersCont.errorMessageClinic.value,
                          isLoading: addEncountersCont.isLoading,
                          searchApiCall: (p0) {
                            log("Search Spec ==> $p0");
                            addEncountersCont.searchClinic(p0);
                            addEncountersCont.getClinicList();
                          },
                          onRetry: () {
                            addEncountersCont.getClinicList();
                          },
                          listWidget: ClinicListWidget(clinicList: addEncountersCont.clinicList).expand(),
                        ),
                      ),
                    );
                  },
                  decoration: inputDecoration(
                    context,
                    hintText: locale.value.selectClinic,
                    fillColor: context.cardColor,
                    filled: true,
                    suffixIcon: commonLeadingWid(imgPath: Assets.iconsIcHospital, color: iconColor, size: 10).paddingSymmetric(vertical: 16),
                  ),
                ).paddingTop(16).visible(loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)),
                if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor) && addEncountersCont.selectClinic.value.id > 0 && addEncountersCont.doctors.isNotEmpty)
                  AppTextField(
                    textStyle: primaryTextStyle(size: 12),
                    controller: addEncountersCont.doctorCont,
                    focus: addEncountersCont.doctorFocus,
                    textFieldType: TextFieldType.NAME,
                    readOnly: true,
                    onTap: () async {
                      serviceCommonBottomSheet(
                        context,
                        child: Obx(
                          () => BottomSelectionSheet(
                            title: locale.value.chooseDoctor,
                            hintText: locale.value.searchDoctorHere,
                            hasError: addEncountersCont.hasErrorFetchingDoctor.value,
                            isEmpty: !addEncountersCont.isLoading.value && addEncountersCont.doctors.isEmpty,
                            errorText: addEncountersCont.errorMessageDoctor.value,
                            isLoading: addEncountersCont.isLoading,
                            searchApiCall: (p0) {
                              log("Search  ==> $p0");
                              addEncountersCont.searchDoctor(p0);
                              addEncountersCont.getDoctors();
                            },
                            onRetry: () {
                              addEncountersCont.getDoctors();
                            },
                            listWidget: DoctorListWidget(doctorList: addEncountersCont.doctors).expand(),
                          ),
                        ),
                      );
                    },
                    decoration: inputDecoration(
                      context,
                      hintText: locale.value.doctor,
                      fillColor: context.cardColor,
                      filled: true,
                      suffixIcon: commonLeadingWid(imgPath: Assets.iconsIcHospital, color: iconColor, size: 10).paddingSymmetric(vertical: 16),
                    ),
                  ).paddingTop(16),
                AppTextField(
                  textStyle: primaryTextStyle(size: 12),
                  controller: addEncountersCont.patientCont,
                  focus: addEncountersCont.patientFocus,
                  textFieldType: TextFieldType.NAME,
                  readOnly: true,
                  onTap: () async {
                    serviceCommonBottomSheet(
                      context,
                      child: Obx(
                        () => BottomSelectionSheet(
                          title: locale.value.choosePatient,
                          hintText: locale.value.searchForPatient,
                          hasError: addEncountersCont.hasErrorFetchingPatient.value,
                          isEmpty: !addEncountersCont.isLoading.value && addEncountersCont.patientList.isEmpty,
                          errorText: addEncountersCont.errorMessagePatient.value,
                          isLoading: addEncountersCont.isLoading,
                          searchApiCall: (p0) {
                            log("Search  ==> $p0");
                            addEncountersCont.searchPatient(p0);
                            addEncountersCont.getPatientList();
                          },
                          onRetry: () {
                            addEncountersCont.getPatientList();
                          },
                          listWidget: PatientListWidget(patientList: addEncountersCont.patientList).expand(),
                        ),
                      ),
                    );
                  },
                  decoration: inputDecoration(
                    context,
                    hintText: locale.value.patient,
                    fillColor: context.cardColor,
                    filled: true,
                    suffixIcon: commonLeadingWid(imgPath: Assets.iconsIcPatients, color: iconColor, size: 10).paddingSymmetric(vertical: 16),
                  ),
                ).paddingTop(16),
                16.height,
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: inputDecoration(
                      context,
                      hintText: "Type d'acte médical",
                      labelText: "Type d'acte médical",
                      fillColor: context.cardColor,
                      filled: true,
                    ),
                    value: addEncountersCont.selectedEncounterType.value,
                    items: addEncountersCont.encounterTypes.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value, style: primaryTextStyle()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        addEncountersCont.selectedEncounterType(val);
                      }
                    },
                  ),
                ),
                16.height,
                AppTextField(
                  textStyle: primaryTextStyle(size: 12),
                  controller: addEncountersCont.descriptionCont,
                  minLines: 3,
                  textFieldType: TextFieldType.MULTILINE,
                  isValidationRequired: false,
                  decoration: inputDecoration(
                    context,
                    hintText: locale.value.description,
                    fillColor: context.cardColor,
                    filled: true,
                  ),
                ),
                62.height
              ],
            ),
          ),
        ),
      ),
      widgetsStackedOverBody: [
        Positioned(
          bottom: 16 + MediaQuery.of(context).padding.bottom,
          height: 50,
          width: Get.width,
          child: AppButton(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: Get.width,
            text: locale.value.save,
            color: appColorSecondary,
            textStyle: appButtonTextStyleWhite,
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
            onTap: () {
              if (addEncountersCont.addEncounterFormKey.currentState!.validate()) {
                if (Get.arguments is List && Get.arguments.isNotEmpty && Get.arguments[0] == true) {
                  addEncountersCont.editEncounter();
                } else {
                  addEncountersCont.saveEncounter();
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
