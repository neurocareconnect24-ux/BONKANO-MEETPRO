import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../api/core_apis.dart';
import '../../../../api/doctor_apis.dart';
import '../../../../main.dart';
import '../../../clinic/add_clinic_form/model/clinic_session_response.dart';
import '../../../clinic/model/clinics_res_model.dart';
import '../../model/doctor_list_res.dart';
import 'model/doctor_session_model.dart';
import 'package:bonkano_meet_pro/screens/service/model/service_list_model.dart';

class AddSessionController extends GetxController {
  Rx<String> breStartTime = "09:00:00".obs;
  Rx<String> breEndTime = "18:00:00".obs;
  RxBool isLoading = false.obs;
  RxBool isSearchText = false.obs;
  Rx<ClinicData> selectClinicName = ClinicData().obs;
  Rx<Doctor> selectDoctorData = Doctor().obs;
  Rx<ServiceElement> selectServiceData = ServiceElement(status: false.obs).obs;

  Rx<Future<RxList<ClinicSessionModel>>> getDoctorsSessionFuture = Future(() => RxList<ClinicSessionModel>()).obs;
  RxList<ClinicSessionModel> doctorSessionList = RxList();
  Rx<DoctorSessionModel> doctorSessionModel = DoctorSessionModel().obs;
  
  RxList<ServiceElement> serviceList = RxList();

  @override
  void onInit() {
    if (Get.arguments is DoctorSessionModel) {
      doctorSessionModel(Get.arguments);
      selectDoctorData(Doctor(doctorId: doctorSessionModel.value.doctorId, fullName: doctorSessionModel.value.fullName));
      selectClinicName(ClinicData(id: doctorSessionModel.value.clinicId, name: doctorSessionModel.value.clinicName));
      getServiceList();
    }
    super.onInit();
  }

  getServiceList() async {
    isLoading(true);
    await CoreServiceApis.getServiceList(
      doctorId: selectDoctorData.value.doctorId,
      clinicId: selectClinicName.value.id,
      serviceList: serviceList,
    ).then((value) {
      if (serviceList.isNotEmpty) {
        selectServiceData(serviceList.first);
        getDoctorSessionList();
      } else {
        doctorSessionList.clear();
      }
    }).catchError((e) {
      toast("Error fetching services: $e");
    }).whenComplete(() => isLoading(false));
  }

  getDoctorSessionList({bool showloader = true}) async {
    doctorSessionList.clear();
    if (showloader) {
      isLoading(true);
    }
    await getDoctorsSessionFuture(DoctorApis.getDoctorSessionList(
      clinicId: selectClinicName.value.id, 
      doctorId: selectDoctorData.value.doctorId, 
      serviceId: selectServiceData.value.id,
      doctorSessionResp: doctorSessionList
    )).then((value) {
      // weeklyList.clear();
      // for (var element in doctorSessionList) {
      //   weeklyList.add(WeekListModel(day: element.day, startTime: element.startTime, endTime: element.endTime, isHoliday: element.isHoliday, breaks: element.breaks));
      // }
    }).catchError((e) {
      toast("Error: $e");
      log("getClinicSession err: $e");
    }).whenComplete(() => isLoading(false));
  }

  saveSession() async {
    isLoading(true);
    await CoreServiceApis.saveSession(doctorId: selectDoctorData.value.doctorId, request: {
      "doctor_id": selectDoctorData.value.doctorId, 
      "clinic_id": selectClinicName.value.id, 
      "service_id": selectServiceData.value.id,
      "weekdays": doctorSessionList.toJson()
    }).then((value) async {
      toast(value.message.trim().isEmpty ? locale.value.sessionSavedSuccessfully : value.message.trim());
      Get.back(result: true);
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  bool isBreakValid({
    required String weekStartTime,
    required String weekEndTime,
    required List<BreakListModel> breaks,
    required String breakStart,
    required String breakEnd,
  }) {
    DateTime breakStart1 = DateTime.parse("2024-01-01 $breakStart");
    DateTime breakEnd1 = DateTime.parse("2024-01-01 $breakEnd");
    for (var interval in breaks) {
      DateTime startTime = DateTime.parse("2024-01-01 ${interval.breakStartTime}");
      DateTime endTime = DateTime.parse("2024-01-01 ${interval.breakEndTime}");
      if ((breakStart1.isBefore(startTime) && breakEnd1.isBefore(startTime)) || (breakStart1.isAfter(endTime) && breakEnd1.isAfter(endTime))) {
        continue;
      } else {
        return false;
      }
    }
    return true;
  }
}
