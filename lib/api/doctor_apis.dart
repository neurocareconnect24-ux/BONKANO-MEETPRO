import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/doctor/model/commission_list_model.dart';
import 'package:http/http.dart' as http;
import '../models/base_response_model.dart';
import '../network/network_utils.dart';
import '../screens/clinic/add_clinic_form/model/clinic_session_response.dart';
import '../utils/api_end_points.dart';

class DoctorApis {
  static Future<CommissionListRes> getCommission() async {
    return CommissionListRes.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.doctorCommissionList, method: HttpMethodType.GET)));
  }

  /*static Future<BaseResponseModel> addServices({required Map request, String? categoryId, required String type}) async {
    String categoryIdParam = categoryId != null ? '&category_id=$categoryId' : "";
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.addService}?$categoryIdParam&type=$type", request: request, method: HttpMethodType.POST)));
  }
*/

  static Future<dynamic> addDoctor({bool isEdit = false, int? doctorId, required Map<String, dynamic> request, List<File>? files, Function(dynamic)? onSuccess}) async {
    if (isEdit) {
      request.remove("password");
      request.remove("confirm_password");
    }
    log("Reuest is ${request.toString()}");
    var multiPartRequest = await getMultiPartRequest(isEdit ? "${APIEndPoints.updateDoctor}/$doctorId" : APIEndPoints.saveDoctor);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(await http.MultipartFile.fromPath('profile_image', files.validate().first.path.validate()));
    }

    /*  if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(await getMultipartImages(files: files.validate(), name: 'medical_report'));
      // multiPartRequest.fields['attachment_count'] = files.validate().length.toString();
    } */

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    /* await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      final baseResponseModel = BaseResponseModel.fromJson(jsonDecode(temp));
      toast(baseResponseModel.message, print: true);
      onSuccess?.call();
    }, onError: (error) {
      toast(error.toString(), print: true);
    }); */
    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        log("Response: ${jsonDecode(data)}");
        final baseResponseModel = BaseResponseModel.fromJson(jsonDecode(data));
        if (baseResponseModel.message.isNotEmpty) toast(baseResponseModel.message, print: true);
        onSuccess?.call(data);
      },
      onError: (error) {
        throw error;
      },
    ).catchError((error) {
      throw error;
    });
  }

  //Doctor Session List
  static Future<RxList<ClinicSessionModel>> getDoctorSessionList({required int clinicId, required int doctorId, int? serviceId, required List<ClinicSessionModel> doctorSessionResp}) async {
    String sId = serviceId != null ? '&service_id=$serviceId' : '';
    final resp = ClinicSessionResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.doctorSessionList}?clinic_id=$clinicId&doctor_id=$doctorId$sId", method: HttpMethodType.GET)));
    doctorSessionResp.addAll(resp.data);
    return doctorSessionResp.obs;
  }

  static Future<BaseResponseModel> deleteDoctor({required int doctorId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.deleteDoctor}/$doctorId', method: HttpMethodType.POST)));
  }
}
