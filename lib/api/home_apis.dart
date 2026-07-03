import 'package:nb_utils/nb_utils.dart';
import '../network/network_utils.dart';
import '../screens/home/model/revenue_resp.dart';
import '../utils/api_end_points.dart';
import '../screens/home/model/dashboard_res_model.dart';
import '../utils/app_common.dart';
import '../utils/constants.dart';

class HomeServiceApis {
  static Future<DashboardRes> getDashboard() async {
    if (loginUserData.value.userRole.contains(EmployeeKeyConst.vendor)) {
      return DashboardRes.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.vendorDashboardList, method: HttpMethodType.GET)));
    } else if (loginUserData.value.userRole.contains(EmployeeKeyConst.doctor)) {
      final clinicId = selectedAppClinic.value.id;
      final endpoint = clinicId > 0
          ? "${APIEndPoints.doctorDashboardList}?clinic_id=$clinicId"
          : APIEndPoints.doctorDashboardList;
      return DashboardRes.fromJson(await handleResponse(await buildHttpResponse(endpoint, method: HttpMethodType.GET)));
    } else {
      return DashboardRes.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.receptionistDashboardList, method: HttpMethodType.GET)));
    }
  }

  static Future<RevenueResp> getRevenue() async {
    return RevenueResp.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.revenueDetails, method: HttpMethodType.GET)));
  }
}
