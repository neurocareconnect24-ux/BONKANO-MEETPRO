// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/api/core_apis.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bonkano_meet_pro/screens/Encounter/add_encounter/model/patient_model.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../doctor/model/doctor_list_res.dart';
import '../../service/model/service_list_model.dart';
import '../appointments_controller.dart';
import 'components/doctor_filter/doctor_component.dart';
import 'components/patient_filter/patient_component.dart';
import 'components/service_filter/service_component.dart';
import 'components/status_filter/status_filter.dart';

class FilterController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  Rx<Future<RxList<PatientModel>>> gePatientFuture = Future(() => RxList<PatientModel>()).obs;
  RxList<PatientModel> patientList = RxList();
  Rx<PatientModel> selectedPatient = PatientModel().obs;
  RxInt patientPage = 1.obs;
  RxString filterType = "".obs;

  //Service List
  Rx<Future<RxList<ServiceElement>>> serviceListFuture = Future(() => RxList<ServiceElement>()).obs;
  RxBool isServiceLoading = false.obs;
  RxList<ServiceElement> serviceList = RxList();
  RxBool isServiceLastPage = false.obs;
  RxInt servicePage = 1.obs;
  RxBool isSearchServiceText = false.obs;
  TextEditingController searchServiceCont = TextEditingController();
  StreamController<String> searchServiceStream = StreamController<String>();
  final _scrollServiceController = ScrollController();
  Rx<ServiceElement> selectedServiceData = ServiceElement(status: false.obs).obs;

  // Doctors
  Rx<Future<RxList<Doctor>>> doctorsFuture = Future(() => RxList<Doctor>()).obs;
  RxBool isDoctorLoading = false.obs;
  RxList<Doctor> doctors = RxList();
  RxBool isDoctorLastPage = false.obs;
  RxInt doctorPage = 1.obs;
  Rx<Doctor> selectedDoctor = Doctor().obs;

  ///Search
  TextEditingController searchDoctorCont = TextEditingController();
  RxBool isDoctorSearchText = false.obs;
  StreamController<String> searchDoctorStream = StreamController<String>();
  final _scrollDoctorController = ScrollController();

  ///Search
  TextEditingController patientSearchCont = TextEditingController();
  RxBool isSearchText = false.obs;
  StreamController<String> searchStream = StreamController<String>();
  final _scrollController = ScrollController();
  RxList filterList = ["Patient", "Service", "Doctor", "Status"].obs;
  RxList statusList = [
    {"title": "Pending", "value": StatusConst.pending},
    {"title": "Confirmed", "value": StatusConst.confirmed},
    {"title": "Check-in", "value": StatusConst.check_in},
    {"title": "Completed", "value": StatusConst.checkout},
    {"title": "Cancelled", "value": StatusConst.cancelled},
  ].obs;
  RxString status = "".obs;

  @override
  void onInit() {
    getArgs();
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) {
      filterList = ["Patient", "Service", "Status"].obs;
    }
    filterType(filterList[0]);
    getPatient();
    getService();
    getDoctor();
    super.onInit();
  }

  void getArgs() {
    try {
      if (Get.arguments[0] is PatientModel) {
        selectedPatient(Get.arguments[0]);
      }
    } catch (e) {
      log('Get.arguments[0] E: $e');
    }

    try {
      if (Get.arguments[1] is Doctor) {
        selectedDoctor(Get.arguments[1]);
      }
    } catch (e) {
      log('Get.arguments[1] E: $e');
    }

    try {
      if (Get.arguments[2] is ServiceElement) {
        selectedServiceData(Get.arguments[2]);
      }
    } catch (e) {
      log('Get.arguments[2] E: $e');
    }

    try {
      if (Get.arguments[3] is String) {
        status(Get.arguments[3]);
      }
    } catch (e) {
      log('Get.arguments[3] E: $e');
    }

    log('selectedPatient: ${selectedPatient.value.id}');
    log('selectedDoctor: ${selectedDoctor.value.id}');
    log('selectedServiceData: ${selectedServiceData.value.id}');
    log('status: ${status.value}');
  }

  getPatientList({bool showloader = true, String search = ""}) async {
    if (showloader) {
      isLoading(true);
    }
    await gePatientFuture(CoreServiceApis.getPatientsList(
      page: patientPage.value,
      search: patientSearchCont.text.trim(),
      patientsList: patientList,
      clinicId: loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) || loginUserData.value.userRole.contains(EmployeeKeyConst.receptionist) ? selectedAppClinic.value.id : null,
      lastPageCallBack: (p0) {
        isLastPage(p0);
      },
    )).then((value) {}).catchError((e) {
      log('getPatientList: $e');
    }).whenComplete(() => isLoading(false));
  }

  //get patient Info
  getPatient() {
    _scrollController.addListener(() => Get.context != null ? hideKeyboard(Get.context) : null);
    searchStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getPatientList();
    });
    getPatientList();
  }

  //get Service Info
  getService() {
    _scrollServiceController.addListener(() => Get.context != null ? hideKeyboard(Get.context) : null);
    searchServiceStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getServicesList();
    });
    getServicesList();
  }

  getServicesList({bool showloader = true, String search = ""}) async {
    if (showloader) {
      isServiceLoading(true);
    }
    await serviceListFuture(CoreServiceApis.getServiceList(
      serviceList: serviceList,
      clinicId: loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) || loginUserData.value.userRole.contains(EmployeeKeyConst.receptionist) ? selectedAppClinic.value.id : null,
      search: searchServiceCont.text.trim(),
      page: servicePage.value,
      lastPageCallBack: (p0) {
        isServiceLastPage(p0);
      },
    )).then((value) {}).catchError((e) {
      log('getServiceList: $e');
    }).whenComplete(() => isServiceLoading(false));
  }

  //Doctors
  getDoctor() {
    _scrollDoctorController.addListener(() => Get.context != null ? hideKeyboard(Get.context) : null);
    searchDoctorStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getDoctorsList();
    });
    getDoctorsList();
  }

  Future<void> getDoctorsList({bool showloader = true}) async {
    if (showloader) {
      isDoctorLoading(true);
    }
    await doctorsFuture(
      CoreServiceApis.getDoctors(
        page: doctorPage.value,
        doctors: doctors,
        clinicId: loginUserData.value.userRole.contains(EmployeeKeyConst.receptionist) ? selectedAppClinic.value.id : null,
        search: searchDoctorCont.text.trim(),
        lastPageCallBack: (p0) {
          isDoctorLastPage(p0);
        },
      ),
    ).then((value) {}).catchError((e) {
      log("getDoctors error $e");
    }).whenComplete(() => isDoctorLoading(false));
  }

  @override
  void onClose() {
    searchStream.close();
    searchServiceStream.close();
    if (Get.context != null) {
      _scrollController.removeListener(() => hideKeyboard(Get.context));
      _scrollServiceController.removeListener(() => hideKeyboard(Get.context));
    }
    super.onClose();
  }

  clearFilter() {
    selectedPatient(PatientModel());
    selectedDoctor(Doctor());
    selectedServiceData(ServiceElement(status: false.obs));
    status("");
    AppointmentsController appointmentsCont = Get.put(AppointmentsController());
    Get.back();
    if (appointmentsCont.selectedDoctor.value.doctorId > 0 || appointmentsCont.selectedServiceData.value.id > 0 || appointmentsCont.selectedPatient.value.id > 0 || appointmentsCont.status.isNotEmpty) {
      appointmentsCont.selectedDoctor(selectedDoctor.value);
      appointmentsCont.selectedServiceData(selectedServiceData.value);
      appointmentsCont.selectedPatient(selectedPatient.value);
      appointmentsCont.status(status.value);
      appointmentsCont.getAppointmentList();
    }
  }

  viewFilterWidget() {
    switch (filterType.value) {
      case "Patient":
        return PatientComponent().expand(flex: 2);
      case "Service":
        return FilterServiceComponent().expand(flex: 2);
      case "Doctor":
        return FilterDoctorComponent().expand(flex: 2);
      case "Status":
        return FilterStatusComponent().expand(flex: 2);
      default:
        getPatient();
        return PatientComponent().expand(flex: 2);
    }
  }

  Widget applyButton() {
    return AppButton(
      width: Get.width,
      text: locale.value.apply,
      color: appColorSecondary,
      textStyle: appButtonTextStyleWhite,
      onTap: () {
        AppointmentsController appointmentsCont = Get.find();
        appointmentsCont.selectedDoctor(selectedDoctor.value);
        appointmentsCont.selectedServiceData(selectedServiceData.value);
        appointmentsCont.selectedPatient(selectedPatient.value);
        appointmentsCont.status(status.value);
        Get.back();
        appointmentsCont.getAppointmentList();
      },
    );
  }
}
