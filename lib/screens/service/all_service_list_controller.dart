import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bonkano_meet_pro/screens/clinic/model/clinics_res_model.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import '../../api/core_apis.dart';
import '../../utils/constants.dart';
import '../doctor/model/doctor_list_res.dart';
import 'assing_doctor_screen_controller.dart';
import 'manage_service/service_apis.dart';
import 'model/service_list_model.dart';

class AllServicesController extends GetxController {
  Rx<Future<RxList<ServiceElement>>> serviceListFuture = Future(() => RxList<ServiceElement>()).obs;
  RxBool isLoading = false.obs;
  RxList<ServiceElement> serviceList = RxList();
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  RxBool isSearchServiceText = false.obs;
  TextEditingController searchServiceCont = TextEditingController();

  StreamController<String> searchServiceStream = StreamController<String>();
  final _scrollController = ScrollController();

  Rx<Doctor> doctorData = Doctor().obs;
  Rx<ClinicData> clinicData = ClinicData().obs;

  RxList<ServiceElement> selecteService = RxList();
  Rx<ServiceElement> singleServiceSelect = ServiceElement(status: false.obs).obs;

  RxString appBarTitle = locale.value.services.obs;

  @override
  void onInit() {
    try {
      log('GET.ARGUMENTS: ${Get.arguments.runtimeType}');
      if (Get.arguments is Doctor) {
        doctorData(Get.arguments);
        if (doctorData.value.firstName.isNotEmpty) {
          appBarTitle("${doctorData.value.firstName}${locale.value.sServices}");
        }
      }

      if (Get.arguments is ClinicData) {
        clinicData(Get.arguments);

        if (clinicData.value.name.isNotEmpty) {
          appBarTitle("${clinicData.value.name}${locale.value.sServices}");
        }
      }

      if (Get.arguments is List && Get.arguments.isNotEmpty) {
        if (Get.arguments[0] is Doctor) {
          doctorData(Get.arguments[0]);
          if (doctorData.value.firstName.isNotEmpty) {
            appBarTitle("${doctorData.value.firstName}${locale.value.sServices}");
          }
        }

        if (Get.arguments.length > 1 && Get.arguments[1] is ServiceElement) {
          singleServiceSelect(Get.arguments[1]);
        }

        if (Get.arguments.length > 2 && Get.arguments[2] is ClinicData) {
          clinicData(Get.arguments[2]);
        }
      }
    } catch (e) {
      log('AllServicesCont Get.arguments onInit E: $e');
    }

    super.onInit();
  }

  @override
  void onReady() {
    _scrollController.addListener(() => Get.context != null ? hideKeyboard(Get.context) : null);
    searchServiceStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getAllServices();
    });
    getAllServices();
    getSelServicesList();
    super.onReady();
  }

  getSelServicesList() {
    if (Get.arguments is List<ServiceElement>) {
      selecteService.addAll(Get.arguments as List<ServiceElement>);
    }
  }

  bool checkSelServiceList({required ServiceElement service}) {
    for (var element in selecteService) {
      if (element.id == service.id) {
        return true;
      }
    }
    return false;
  }

  Future<void> getAllServices({bool showloader = true}) async {
    if (showloader) {
      isLoading(true);
    }
    await serviceListFuture(
      CoreServiceApis.getServiceList(
        page: page.value,
        serviceList: serviceList,
        clinicId: clinicData.value.id.isNegative && loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) ? selectedAppClinic.value.id : clinicData.value.id,
        doctorId: doctorData.value.doctorId,
        search: searchServiceCont.text.trim(),
        lastPageCallBack: (p0) {
          isLastPage(p0);
        },
      ),
    ).then((value) {
      getDoctorCharges();
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      log("getServiceList Err : $e");
    }).whenComplete(() => isLoading(false));
  }

  void getDoctorCharges() {
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) {
      try {
        for (var service in serviceList) {
          for (var assignDoctor in service.assignDoctor) {
            if (assignDoctor.doctorId == loginUserData.value.id && assignDoctor.clinicId == selectedAppClinic.value.id && assignDoctor.serviceId == service.id) {
              service.doctorCharges = assignDoctor.charges;
            }
          }
        }
      } catch (e) {
        log('getServicePrice Errr: $e');
      }
    }
  }

  Future<void> updateServicesStatus({required int id, required int status}) async {
    if (isLoading.value) return; // Returns from here if already call in progress
    isLoading(true);
    ServiceFormApis.updateServicesStatus(serviceId: id, request: {"status": status}).then((value) {
      toast(value.message.trim().isNotEmpty ? value.message.trim() : locale.value.statusUpdatedSuccessfully);
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() => isLoading(false));
  }

  changeServicePrice({required int serviceId, required String price}) async {
    if (selectedAppClinic.value.id <= 0) {
      toast(locale.value.pleaseSelectClinic);
      return;
    }
    isLoading(true);
    await CoreServiceApis.assignDoctor(request: {
      "service_id": serviceId,
      "clinic_id": selectedAppClinic.value.id,
      "assign_doctors": [SelectDoctor(doctorId: loginUserData.value.id, price: price.trim()).toJson()]
    }).then((value) async {
      Get.back(result: true);
      toast(value.message.isNotEmpty ? value.message : locale.value.priceUpdatedSuccessfully);
      getAllServices();
    }).catchError((e) {
      toast(e.toString());
      log('changeServicePrice Errr: $e');
    }).whenComplete(() => isLoading(false));
  }

  @override
  void onClose() {
    searchServiceStream.close();
    if (Get.context != null) {
      _scrollController.removeListener(() => hideKeyboard(Get.context));
    }
    super.onClose();
  }
}