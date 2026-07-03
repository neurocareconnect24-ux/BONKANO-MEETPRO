import 'dart:convert';
import 'dart:io';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/clinic/model/clinics_res_model.dart';

import '../models/base_response_model.dart';
import '../network/network_utils.dart';
import '../screens/clinic/add_clinic_form/model/clinic_session_response.dart';
import '../screens/clinic/model/clinic_detail_model.dart';
import '../utils/api_end_points.dart';
import '../utils/app_common.dart';
import '../utils/constants.dart';
import '../screens/clinic/model/clinic_gallery_model.dart';

class ClinicApis {
  static Future<RxList<ClinicData>> getClinicList({
    String search = '',
    int page = 1,
    var perPage = Constants.perPageItem,
    required List<ClinicData> clinicList,
    Function(bool)? lastPageCallBack,
    bool isReceptionistRegister = false,
    bool isDoctorRegister = false,
    int? doctorId,
  }) async {
    String searchService = search.isNotEmpty ? '&search=$search' : '';

    String receptionistLogin = isReceptionistRegister ? '&receptionist_login=1' : '';

    var res = ClinicListRes.fromJson(await handleResponse(
        await buildHttpResponse("${isReceptionistRegister || isDoctorRegister ? APIEndPoints.getClinicListToRegister : APIEndPoints.getClinics}?per_page=$perPage&page=$page$searchService$receptionistLogin", method: HttpMethodType.GET)));

    if (page == 1) clinicList.clear();
    clinicList.addAll(res.data.validate());

    lastPageCallBack?.call(res.data.validate().length != perPage);

    return clinicList.obs;
  }

  static Future<ClinicDetailModel> getClinicDetails({required int clinicId}) async {
    return ClinicDetailModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getClinicDetails}?clinic_id=$clinicId', method: HttpMethodType.GET)));
  }

  static Future<RxList<ClinicData>> getClinicListWithDoctor({
    int? doctorId,
    String search = '',
    int page = 1,
    var perPage = Constants.perPageItem,
    required List<ClinicData> clinicList,
    Function(bool)? lastPageCallBack,
  }) async {
    String searchService = search.isNotEmpty ? '&search=$search' : '';
    String doctor = doctorId.toString().isNotEmpty ? '&doctor_id=$doctorId' : '';
    var res = ClinicListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getClinics}?per_page=$perPage&page=$page$doctor$searchService", method: HttpMethodType.GET)));

    if (page == 1) clinicList.clear();
    clinicList.addAll(res.data.validate());

    lastPageCallBack?.call(res.data.validate().length != perPage);

    return clinicList.obs;
  }

  static Future<dynamic> addEditClinc({
    bool isEdit = false,
    int? clinicId,
    ClinicData? clinicData,
    required Map<String, dynamic> request,
    // List<XFile>? files,
    File? imageFile,
    Function(dynamic)? onSuccess,
  }) async {
    if (isLoggedIn.value) {
      MultipartRequest multiPartRequest = await getMultiPartRequest(isEdit ? "${APIEndPoints.updateClinic}/$clinicId" : APIEndPoints.saveClinic);
      multiPartRequest.fields.addAll(await getMultipartFields(val: request));
      if (imageFile != null) {
        // multiPartRequest.files.addAll(await getMultipartImages2(files: files.validate(), name: 'feature_image'));
        multiPartRequest.files.add(await MultipartFile.fromPath('file_url', imageFile.path));
      }

      log("Multipart ${jsonEncode(multiPartRequest.fields)}");
      log("Multipart Images ${multiPartRequest.files.map((e) => e.filename)}");
      multiPartRequest.headers.addAll(buildHeaderTokens());

      await sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (data) async {
          onSuccess?.call(data);
        },
        onError: (error) {
          throw error;
        },
      ).catchError((error) {
        throw error;
      });
    }
  }

  static Future<BaseResponseModel> deleteClinic({required int clinicId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.deleteClinic}/$clinicId', method: HttpMethodType.POST)));
  }

  static Future<RxList<GalleryData>> getClinicGalleryList({
    int page = 1,
    int perPage = 10,
    required List<GalleryData> galleryList,
    Function(bool)? lastPageCallBack,
    int clinicId = -1,
  }) async {
    String clncId = clinicId != -1 ? '&clinic_id=$clinicId' : '';
    final galleryListRes = ClinicGalleryModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getClinicGallery}?per_page=$perPage&page=$page$clncId", method: HttpMethodType.GET)));
    if (page == 1) galleryList.clear();
    galleryList.addAll(galleryListRes.data);
    lastPageCallBack?.call(galleryListRes.data.length != perPage);
    return galleryList.obs;
  }

  //Save Gallery Images
  static Future<dynamic> saveClinicGallery({
    required Map<String, dynamic> request,
    List<File>? imageFile,
    Function(dynamic)? onSuccess,
  }) async {
    if (isLoggedIn.value) {
      MultipartRequest multiPartRequest = await getMultiPartRequest(APIEndPoints.saveClinicGallery);
      multiPartRequest.fields.addAll(await getMultipartFields(val: request));
      // SECURITY FIX P0-6: Corrigé || en && pour éviter un crash null
      // Avec ||, si imageFile est null, imageFile!.isNotEmpty provoque un crash
      if (imageFile != null && imageFile.isNotEmpty) {
        for (var i = 0; i < imageFile.length; i++) {
          multiPartRequest.files.add(await MultipartFile.fromPath('gallery_images[$i]', imageFile[i].path));
        }
      }
      multiPartRequest.headers.addAll(buildHeaderTokens());
      await sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (data) async {
          onSuccess?.call(data);
        },
        onError: (error) {
          throw error;
        },
      ).catchError((error) {
        throw error;
      });
    }
  }

  //Delete Gallery List
  // static Future<BaseResponseModel> deleteClinicGallery({required Map request}) async {
  //   return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveClinicGallery, request: request, method: HttpMethodType.POST)));
  // }

  static Future<dynamic> deleteClinicGallery({
    required Map<String, dynamic> request,
    Function(dynamic)? onSuccess,
  }) async {
    if (isLoggedIn.value) {
      MultipartRequest multiPartRequest = await getMultiPartRequest(APIEndPoints.saveClinicGallery);
      multiPartRequest.fields.addAll(await getMultipartFields(val: request));
      multiPartRequest.headers.addAll(buildHeaderTokens());
      await sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (data) async {
          onSuccess?.call(data);
        },
        onError: (error) {
          throw error;
        },
      ).catchError((error) {
        throw error;
      });
    }
  }

  //Clinic Session List
  static Future<RxList<ClinicSessionModel>> getClinicSessionList({required int clinicId, required List<ClinicSessionModel> clinicSessionResp}) async {
    final resp = ClinicSessionResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.clinicSessionList}?clinic_id=$clinicId", method: HttpMethodType.GET)));
    clinicSessionResp.addAll(resp.data);
    return clinicSessionResp.obs;
  }

  //Save Clinic Session
  static Future<RxList<ClinicSessionModel>> saveClinicSession({required Map request, required List<ClinicSessionModel> clinicSessionResp}) async {
    final resp = ClinicSessionResp.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveClinicSession, request: request, method: HttpMethodType.POST)));
    toast(resp.message);
    clinicSessionResp.addAll(resp.data);
    return clinicSessionResp.obs;
  }
}
