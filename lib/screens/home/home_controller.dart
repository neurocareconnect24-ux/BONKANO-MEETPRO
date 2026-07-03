import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../dashboard/dashboard_controller.dart';
import 'model/dashboard_res_model.dart';
import '../../api/home_apis.dart';
import 'model/revenue_chart_data.dart';
import 'model/revenue_resp.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isRefresh = false.obs;
  TextEditingController searchCont = TextEditingController();
  Rx<Future<DashboardRes>> getDashboardDetailFuture = Future(() => DashboardRes(data: DashboardData())).obs;
  Rx<DashboardRes> dashboardData = DashboardRes(data: DashboardData()).obs;
  PageController recentAppointmentPageController = PageController();
  PageController servicesPageController = PageController();
  PageController clinicsPageController = PageController();
  RxInt currentAppoinmentPage = 0.obs;
  RxInt currentServicePage = 0.obs;
  RxInt currentClinicPage = 0.obs;
  RxString chartValue = "".obs;
  RxList<String> revenueList = ['Yearly', 'Monthly', 'Weekly'].obs;
  Rx<Future<RevenueResp>> getRevenueDetailFuture = Future(() => RevenueResp(data: RevenueModel())).obs;
  Rx<RevenueResp> revenueData = RevenueResp(data: RevenueModel()).obs;
  RxList<RevenueChartData> chartData = RxList();
  List<String> daysList = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  RxBool showAddServiceComp = false.obs;

  @override
  void onReady() {
    chartValue.value = revenueList[0];
    getDashboardDetail();
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)) {
      getRevenueChartDetails();
    }
    super.onReady();
  }

  ///Get ChooseService List
  getDashboardDetail({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    getAppConfigurations();
    await getDashboardDetailFuture(HomeServiceApis.getDashboard()).then((value) {
      handleDashboardRes(value);
    }).catchError((e) {
      log("getDashboard api err $e");
    }).whenComplete(() => isLoading(false));
  }

  ///Get RevenueChart
  getRevenueChartDetails({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await getRevenueDetailFuture(HomeServiceApis.getRevenue()).then((value) {
      revenueData(value);
      setChartDetails(filter: revenueList[0]);
    }).catchError((e) {
      log("getRevenue api err $e");
    }).whenComplete(() => isLoading(false));
  }

  setChartDetails({required String filter}) {
    chartData.clear();
    if (filter == revenueList[0]) {
      revenueData.value.data.yearChartData.forEachIndexed((element, index) {
        chartData.add(RevenueChartData(month: revenueData.value.data.monthNames[index], revenue: element.toString().toDouble()));
      });
    } else if (filter == revenueList[1]) {
      revenueData.value.data.monthChartData.forEachIndexed((element, index) {
        chartData.add(RevenueChartData(month: revenueData.value.data.weekNames[index], revenue: element.toString().toDouble()));
      });
    } else if (filter == revenueList[2]) {
      revenueData.value.data.weekChartData.forEachIndexed((element, index) {
        chartData.add(RevenueChartData(month: daysList[index], revenue: element.toString().toDouble()));
      });
    } else {
      revenueData.value.data.yearChartData.forEachIndexed((element, index) {
        chartData.add(RevenueChartData(month: revenueData.value.data.monthNames[index], revenue: element.toString().toDouble()));
      });
    }
  }

  void handleDashboardRes(DashboardRes value) {
    dashboardData(value);
    unreadNotificationCount(value.data.unReadCount);
    if (dashboardData.value.data.receptionistClinic.isNotEmpty) selectedAppClinic(dashboardData.value.data.receptionistClinic.first);
    getDoctorCharges();
    //More Logic....
  }

  void getDoctorCharges() {
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) {
      try {
        for (var service in dashboardData.value.data.doctorServices) {
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
    showAddServiceComp(
        (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) && dashboardData.value.data.doctorTotalServiceCount < 1) || (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor) && dashboardData.value.data.vendorTotalService < 1));
  }

  revenueFilter({required String value}) {
    chartValue(value);
    setChartDetails(filter: value);
  }

  updateStatus({required String status, required int id, required bool isBack, required BuildContext context}) {
    showConfirmDialogCustom(
      context,
      primaryColor: appColorPrimary,
      title: locale.value.doYouWantToPerformThisAction,
      positiveText: locale.value.yes,
      negativeText: locale.value.cancel,
      onAccept: (ctx) async {
        isLoading(true);
        CoreServiceApis.changeAppointmentStatus(
          id: id,
          request: {'status': postStatus(status: status)},
        ).then((value) {
          toast(locale.value.statusHasBeenUpdated);
          if (isBack) {
            Get.back();
          }
          getDashboardDetail();
        }).catchError((e) {
          isLoading(false);
          toast(e.toString());
        });
      },
    );
  }

  @override
  void onClose() {
    searchCont.dispose();
    recentAppointmentPageController.dispose();
    servicesPageController.dispose();
    clinicsPageController.dispose();
    super.onClose();
  }
}
