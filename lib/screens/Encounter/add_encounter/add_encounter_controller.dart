// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/api/core_apis.dart';
import 'package:bonkano_meet_pro/screens/Encounter/add_encounter/model/encounter_resp_model.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../appointment/model/appointments_res_model.dart';
import '../../clinic/model/clinics_res_model.dart';
import '../../doctor/model/doctor_list_res.dart';
import '../encounter_dashboard/encounter_dashboard.dart';
import '../model/encounters_list_model.dart';
import 'model/patient_model.dart';

class AddEncountersController extends GetxController {
  //TextFiled Controller
  final GlobalKey<FormState> addEncounterFormKey = GlobalKey();
  TextEditingController dateCont = TextEditingController();
  TextEditingController clinicCont = TextEditingController();
  TextEditingController doctorCont = TextEditingController();
  TextEditingController patientCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();

  FocusNode dateFocus = FocusNode();
  FocusNode clinicFocus = FocusNode();
  FocusNode doctorFocus = FocusNode();
  FocusNode patientFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();

  //Error Clinic
  RxBool hasErrorFetchingClinic = false.obs;
  RxString errorMessageClinic = "".obs;
  //Error Doctor
  RxBool hasErrorFetchingDoctor = false.obs;
  RxString errorMessageDoctor = "".obs;
  //Error Patient
  RxBool hasErrorFetchingPatient = false.obs;
  RxString errorMessagePatient = "".obs;

  //Clinic
  Rx<Future<RxList<ClinicData>>> getClinics = Future(() => RxList<ClinicData>()).obs;
  RxBool isLoading = false.obs;
  RxInt page = 1.obs;
  RxList<ClinicData> clinicList = RxList();
  RxBool isLastPage = false.obs;
  Rx<ClinicData> selectClinic = ClinicData().obs;
  RxString searchClinic = "".obs;

  //Doctors
  Rx<Future<RxList<Doctor>>> doctorsFuture = Future(() => RxList<Doctor>()).obs;
  RxBool isDoctorsLoading = false.obs;
  RxList<Doctor> doctors = RxList();
  RxBool isDoctorsLastPage = false.obs;
  RxInt doctorsPage = 1.obs;
  Rx<Doctor> selectDoctor = Doctor().obs;
  RxString searchDoctor = "".obs;

  //Patient
  Rx<Future<RxList<PatientModel>>> patientFuture = Future(() => RxList<PatientModel>()).obs;
  RxBool isPatientLoading = false.obs;
  RxList<PatientModel> patientList = RxList();
  RxBool isPatientLastPage = false.obs;
  RxInt patientPage = 1.obs;
  Rx<PatientModel> selectPatient = PatientModel().obs;
  RxString searchPatient = "".obs;

  //Save Encounter
  Rx<Future<Rx<EncounterResp>>> saveEncounterFuture = Future(() => EncounterResp().obs).obs;
  Rx<EncounterResp> encounterResp = EncounterResp().obs;

  //Edit Counter Details
  Rx<EncounterElement> editEncounterResp = EncounterElement().obs;

  // Set when this screen is opened from an appointment's check-in flow.
  // Creation must then be tied to that appointment (appointment_id), and
  // patient/clinic/doctor are locked to match it.
  Rx<AppointmentData?> fromAppointment = Rx<AppointmentData?>(null);

  RxString selectedEncounterType = 'consultation'.obs;

  final Map<String, String> encounterTypes = {
    'consultation': 'Consultation',
    'hospitalisation': 'Hospitalisation',
    'eeg': 'Électroencéphalogramme (EEG)',
    'enmg': 'Électroneuromyogramme (ENMG)',
    'potentiels_evoques': 'Potentiels Évoqués',
    'echo_tsa': 'Écho Doppler TSA',
  };

  @override
  void onReady() {
    selectClinic(selectedAppClinic.value);
    getClinicList();
    getPatientList();
    getArgument();
    super.onReady();
  }

  getArgument() {
    if (Get.arguments is List && Get.arguments.length >= 2 && Get.arguments[0] == true && (Get.arguments[1] is EncounterElement)) {
      editEncounterResp(Get.arguments[1]);
      dateCont.text = editEncounterResp.value.encounterDate.dateInDMMMMyyyyFormat;
      descriptionCont.text = editEncounterResp.value.description;
      if (editEncounterResp.value.encounterType.isNotEmpty) {
        selectedEncounterType(editEncounterResp.value.encounterType);
      }
    } else if (Get.arguments is Map && Get.arguments['appointmentData'] is AppointmentData) {
      fromAppointment(Get.arguments['appointmentData']);
      dateCont.text = fromAppointment.value!.appointmentDate.dateInDMMMMyyyyFormat;
    }
  }

  getClinicList({bool showloader = true}) async {
    if (showloader) {
      isLoading(true);
    }
    await getClinics(CoreServiceApis.getClinicList(
      clinicList: clinicList,
      page: page.value,
      search: searchClinic.value,
      lastPageCallBack: (p0) {
        isLastPage(p0);
      },
    )).then((value) async {
      log("Value is ==> $value");
      clinicList(value);
      hasErrorFetchingClinic(false);
      if (editEncounterResp.value.clinicName.isNotEmpty) {
        for (var element in clinicList) {
          if (element.id == editEncounterResp.value.clinicId) {
            selectClinic(element);
            clinicCont.text = element.name;
          }
        }
        await getDoctors();
      } else if (fromAppointment.value != null) {
        for (var element in clinicList) {
          if (element.id == fromAppointment.value!.clinicId) {
            selectClinic(element);
            clinicCont.text = element.name;
          }
        }
        await getDoctors();
      }
    }).catchError((e) {
      hasErrorFetchingClinic(true);
      errorMessageClinic(e.toString());
      toast("Error: $e");
      log("getClinicList err: $e");
    }).whenComplete(() => isLoading(false));
  }

  getPatientList({bool showloader = true}) async {
    if (showloader) {
      isLoading(true);
    }
    await patientFuture(CoreServiceApis.getPatientsList(
      patientsList: patientList,
      page: page.value,
      // SECURITY FIX P0-7: Appliquer le filtre clinique pour TOUS les rôles (doctor + vendor + receptionist)
      // Avant: seul le doctor filtrait par clinique, le vendor voyait TOUS les patients
      clinicId: selectedAppClinic.value.id > 0 ? selectedAppClinic.value.id : null,
      search: searchPatient.value,
      lastPageCallBack: (p0) {},
    )).then((value) {
      hasErrorFetchingPatient(false);
      if (editEncounterResp.value.userName.isNotEmpty) {
        for (var element in patientList) {
          if (element.id == editEncounterResp.value.userId) {
            selectPatient(element);
            patientCont.text = element.fullName;
          }
        }
      } else if (fromAppointment.value != null) {
        for (var element in patientList) {
          if (element.id == fromAppointment.value!.userId) {
            selectPatient(element);
            patientCont.text = element.fullName;
          }
        }
      }
    }).catchError((e) {
      hasErrorFetchingPatient(true);
      errorMessagePatient(e.toString());
      toast("Error: $e");
      log("getPatientsList err: $e");
    }).whenComplete(() => isLoading(false));
  }

  Future<void> getDoctors({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await doctorsFuture(
      CoreServiceApis.getDoctors(
        page: doctorsPage.value,
        doctors: doctors,
        search: searchDoctor.value,
        clinicId: selectClinic.value.id,
        lastPageCallBack: (p0) {
          isDoctorsLastPage(p0);
        },
      ),
    ).then((value) {
      hasErrorFetchingDoctor(false);
      log('value.length ==> ${value.length}');
      if (editEncounterResp.value.doctorName.isNotEmpty) {
        for (var element in doctors) {
          if (element.doctorId == editEncounterResp.value.doctorId) {
            selectDoctor(element);
            doctorCont.text = element.fullName;
          }
        }
      } else if (fromAppointment.value != null) {
        for (var element in doctors) {
          if (element.doctorId == fromAppointment.value!.doctorId) {
            selectDoctor(element);
            doctorCont.text = element.fullName;
          }
        }
      }
    }).catchError((e) {
      hasErrorFetchingDoctor(true);
      errorMessageDoctor(e.toString());
      log("getDoctors error $e");
    }).whenComplete(() => isLoading(false));
  }

  saveEncounter({bool showloader = true}) async {
    if (isLoading.value) return;
    Map<String, dynamic> request = {
      "encounter_date": dateCont.text.dateInyyyyMMddFormat.toString(),
      "clinic_id": selectClinic.value.id.toString(),
      "doctor_id": loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) ? loginUserData.value.id : selectDoctor.value.doctorId.toString(),
      "user_id": selectPatient.value.id.toString(),
      "description": descriptionCont.text.isEmpty ? "" : descriptionCont.text.toString()
    };
    if (fromAppointment.value != null) {
      request["appointment_id"] = fromAppointment.value!.id.toString();
    }
    if (showloader) {
      isLoading(true);
    }
    await saveEncounterFuture(CoreServiceApis.saveEncounter(request: request, encounterResp: encounterResp.value)).then((value) {
      encounterResp(value.value);
      if (fromAppointment.value != null) {
        final appointment = fromAppointment.value!;
        Get.off(
          () => EncountersDashboardScreen(
            encounterDetail: EncounterElement(
              id: encounterResp.value.id,
              appointmentId: appointment.id,
              clinicId: appointment.clinicId,
              clinicName: appointment.clinicName,
              doctorId: appointment.doctorId,
              doctorName: appointment.doctorName,
              encounterDate: appointment.appointmentDate,
              userId: appointment.userId,
              userName: appointment.userName,
              userImage: appointment.userImage,
              address: appointment.address,
              userEmail: appointment.userEmail,
              description: descriptionCont.text,
            ),
          ),
        );
      } else {
        Get.back(result: true);
      }
    }).catchError((e) {
      toast("Error: $e");
      log("getEncounterResp err: $e");
    }).whenComplete(() => isLoading(false));
  }

  //Update Encounter
  editEncounter({bool showloader = true}) async {
    if (isLoading.value) return;
    Map<String, dynamic> request = {
      "encounter_date": dateCont.text.dateInyyyyMMddFormat.toString(),
      "clinic_id": selectClinic.value.id.toString(),
      "doctor_id": loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) ? loginUserData.value.id : selectDoctor.value.doctorId.toString(),
      "user_id": selectPatient.value.id.toString(),
      "description": descriptionCont.text.toString()
    };
    if (showloader) {
      isLoading(true);
    }
    await saveEncounterFuture(CoreServiceApis.editEncounter(request: request, id: editEncounterResp.value.id, encounterResp: encounterResp.value)).then((value) {
      encounterResp(value.value);
      Get.back(result: true);
    }).catchError((e) {
      toast("Error: $e");
      log("getEncounterResp err: $e");
    }).whenComplete(() => isLoading(false));
  }

  @override
  void onClose() {
    dateCont.dispose();
    clinicCont.dispose();
    doctorCont.dispose();
    patientCont.dispose();
    descriptionCont.dispose();
    dateFocus.dispose();
    clinicFocus.dispose();
    doctorFocus.dispose();
    patientFocus.dispose();
    descriptionFocus.dispose();
    super.onClose();
  }
}
