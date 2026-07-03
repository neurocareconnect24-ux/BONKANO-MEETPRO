import 'dart:io';

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/Encounter/add_encounter/model/encounter_resp_model.dart';
import 'package:bonkano_meet_pro/screens/service/model/service_list_model.dart';
import '../models/base_response_model.dart';
import '../network/network_utils.dart';
import '../screens/Encounter/add_encounter/model/patient_model.dart';
import '../screens/Encounter/body_chart/model/body_chart_resp.dart';
import '../screens/Encounter/generate_invoice/model/encounter_details_resp.dart';
import '../screens/Encounter/generate_invoice/model/service_details_resp.dart';
import '../screens/Encounter/invoice_details/model/billing_details_resp.dart';
import '../screens/Encounter/model/enc_dashboard_detail_res.dart';
import '../screens/Encounter/model/encounter_invoice_resp.dart';
import '../screens/Encounter/model/encounters_list_model.dart';
import '../screens/Encounter/model/get_soap_res.dart';
import '../screens/Encounter/model/medical_reports_res_model.dart';
import '../screens/Encounter/model/problems_observations_model.dart';
import '../screens/appointment/add_appointment/appointment_slot_model.dart';
import '../screens/appointment/model/appointment_invoice_res.dart';
import '../screens/appointment/model/other_patient_list_res.dart';
import '../screens/appointment/model/save_booking_res.dart';
import '../screens/auth/model/login_response.dart';
import '../screens/payout/model/payout_model.dart';
import '../screens/appointment/model/appointment_details_resp.dart';
import '../screens/appointment/model/encounter_detail_model.dart';
import '../screens/clinic/add_clinic_form/model/specialization_resp.dart';
import '../screens/clinic/model/clinics_res_model.dart';
import '../screens/doctor/model/doctor_list_res.dart';
import '../screens/doctor/model/review_model.dart';
import '../screens/doctor/doctor_session/add_session/model/doctor_session_model.dart';
import '../screens/receptionist/model/receptionist_res_model.dart';
import '../screens/requests/model/service_request_model.dart';
import '../utils/api_end_points.dart';
import '../utils/app_common.dart';
import '../utils/constants.dart';
import '../screens/appointment/model/appointments_res_model.dart';
import '../screens/category/model/all_category_model.dart';
import '../screens/appointment/model/review_res_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../screens/appointment/model/agora_token_res_model.dart';

class CoreServiceApis {
  static Future<RxList<CategoryElement>> getCategoryList({
    int page = 1,
    int perPage = 50,
    required List<CategoryElement> categories,
    Function(bool)? lastPageCallBack,
  }) async {
    final categoryListRes = CategoryListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getCategoryList}?per_page=$perPage&page=$page", method: HttpMethodType.GET)));
    if (page == 1) categories.clear();
    categories.addAll(categoryListRes.data);
    lastPageCallBack?.call(categoryListRes.data.length != perPage);
    return categories.obs;
  }

  static Future<RxList<ServiceElement>> getServiceList(
      {int page = 1,
      int perPage = 10,
      required List<ServiceElement> serviceList,
      Function(bool)? lastPageCallBack,
      int? categoryId,
      int? clinicId,
      int? doctorId,
      String search = '',
      String params = ''}) async {
    String catId = categoryId != null && !categoryId.isNegative ? '&category_id=$categoryId' : '';
    String clinicid = clinicId != null && !clinicId.isNegative ? '&clinic_id=$clinicId' : '';
    String doctorid = doctorId != null && !doctorId.isNegative ? '&doctor_id=$doctorId' : '';
    String searchService = search.isNotEmpty ? '&search=$search' : '';
    String newParams = params.isNotEmpty ? '&$params' : '';
    final serviceListRes = ServiceListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.getServices}?per_page=$perPage&page=$page$searchService$catId$clinicid$doctorid$newParams", method: HttpMethodType.GET)));
    if (page == 1 || search.isNotEmpty) serviceList.clear();
    serviceList.addAll(serviceListRes.data);
    lastPageCallBack?.call(serviceListRes.data.length != perPage);
    return serviceList.obs;
  }

  static Future<RxList<EncounterElement>> getEncounterList({
    int page = 1,
    int perPage = 10,
    int? clinicId,
    int? patientId,
    required List<EncounterElement> encounterList,
    Function(bool)? lastPageCallBack,
  }) async {
    String clinicid = clinicId != null && !clinicId.isNegative ? '&clinic_id=$clinicId' : '';
    String patientid = patientId != null && !patientId.isNegative ? '&patient_id=$patientId' : '';
    final encounterListRes =
        EncounterListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getEncounterList}?per_page=$perPage&page=$page$clinicid$patientid", method: HttpMethodType.GET)));
    if (page == 1) encounterList.clear();
    encounterList.addAll(encounterListRes.data);
    lastPageCallBack?.call(encounterListRes.data.length != perPage);
    return encounterList.obs;
  }

  //Get Body Chart List
  static Future<RxList<BodyChartModel>> getBodyChartLists({
    //To-do Change Models
    int page = 1,
    int perPage = 10,
    int? encounterId,
    required List<BodyChartModel> bodyChartList, //To-do Change Models
    Function(bool)? lastPageCallBack,
  }) async {
    String encounter = encounterId != null && !encounterId.isNegative ? '&encounter_id=$encounterId' : '';
    final bodyChartDetails =
        BodyChartResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.bodyChartDetails}?per_page=$perPage&page=$page$encounter", method: HttpMethodType.GET)));
    if (page == 1) bodyChartList.clear();
    bodyChartList.addAll(bodyChartDetails.data);
    lastPageCallBack?.call(bodyChartDetails.data.length != perPage);
    return bodyChartList.obs;
  }

  static Future<BaseResponseModel> deleteBodyChart({required int chartId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.deleteBodychart}/$chartId', method: HttpMethodType.POST)));
  }

  static Future<RxList<Doctor>> getDoctors({
    int page = 1,
    String search = '',
    dynamic perPage = 10,
    required List<Doctor> doctors,
    Function(bool)? lastPageCallBack,
    int? clinicId,
  }) async {
    String clncId = clinicId != null && !clinicId.isNegative ? '&clinic_id=$clinicId' : '';
    String searchDoc = search.isNotEmpty ? '&search=$search' : '';
    final doctorListRes = DoctorListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getDoctors}?per_page=$perPage&page=$page$clncId$searchDoc", method: HttpMethodType.GET)));
    if (page == 1) doctors.clear();
    doctors.addAll(doctorListRes.data);
    lastPageCallBack?.call(doctorListRes.data.length != perPage);
    return doctors.obs;
  }

  static Future<AppointmentEncounterDetailModel> getEncounterDetail({required int encounterId}) async {
    return AppointmentEncounterDetailModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.encounterDashboardDetail}?encounter_id=$encounterId", method: HttpMethodType.GET)));
  }

  static Future<RxList<RequestElement>> getRequestList({
    int page = 1,
    int perPage = 50,
    required List<RequestElement> requests,
    Function(bool)? lastPageCallBack,
  }) async {
    final requestListRes = RequestListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getRequestList}?per_page=$perPage&page=$page", method: HttpMethodType.GET)));
    if (page == 1) requests.clear();
    requests.addAll(requestListRes.data);
    lastPageCallBack?.call(requestListRes.data.length != perPage);
    return requests.obs;
  }

  static Future<void> saveRequestService({
    bool isEdit = false,
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.saveRequestService);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(await http.MultipartFile.fromPath('file_url', files.validate().first.path.validate()));
    }

    /*  if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(await getMultipartImages(files: files.validate(), name: 'medical_report'));
      multiPartRequest.fields['attachment_count'] = files.validate().length.toString();
    } */

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      final baseResponseModel = BaseResponseModel.fromJson(jsonDecode(temp));
      toast(baseResponseModel.message, print: true);
      onSuccess?.call();
    }, onError: (error) {
      toast(error.toString(), print: true);
    });
  }

  static Future<RxList<ReceptionistData>> getReceptionistList({
    int page = 1,
    int perPage = 50,
    required List<ReceptionistData> receptionists,
    Function(bool)? lastPageCallBack,
  }) async {
    final requestListRes = ReceptionistListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getReceptionistList}?per_page=$perPage&page=$page", method: HttpMethodType.GET)));
    if (page == 1) receptionists.clear();
    receptionists.addAll(requestListRes.data);
    lastPageCallBack?.call(requestListRes.data.length != perPage);
    return receptionists.obs;
  }

  static Future<BaseResponseModel> deleteReceptionist({required int receptionistId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.deleteReceptionist}/$receptionistId', method: HttpMethodType.POST)));
  }

  static Future<void> saveReceptionist({
    bool isEdit = false,
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.saveReceptionist);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(await http.MultipartFile.fromPath('file_url', files.validate().first.path.validate()));
    }

    /*  if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(await getMultipartImages(files: files.validate(), name: 'medical_report'));
      // multiPartRequest.fields['attachment_count'] = files.validate().length.toString();
    } */

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      final baseResponseModel = BaseResponseModel.fromJson(jsonDecode(temp));
      toast(baseResponseModel.message, print: true);
      onSuccess?.call();
    }, onError: (error) {
      toast(error.toString(), print: true);
    });
  }

  // Save Body Chart Request
  static Future<void> saveBodyChart({
    bool isEdit = false,
    int? id,
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    var multiPartRequest = await getMultiPartRequest(isEdit ? "${APIEndPoints.updateBodychart}/$id" : APIEndPoints.saveBodychart);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));
    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(await http.MultipartFile.fromPath('file_url', files.validate().first.path.validate()));
    }

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");

    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      final baseResponseModel = BaseResponseModel.fromJson(jsonDecode(temp));
      toast(baseResponseModel.message, print: true);
      onSuccess?.call();
    }, onError: (error) {
      toast(error.toString(), print: true);
    });
  }

  static Future<RxList<AppointmentData>> getAppointmentList({
    int page = 1,
    String search = '',
    int? patientId,
    int? serviceId,
    int? doctorId,
    int? clinicId,
    String? filterByStatus,
    int perPage = Constants.perPageItem,
    required List<AppointmentData> appointments,
    Function(bool)? lastPageCallBack,
  }) async {
    String pId = patientId != null && !patientId.isNegative ? '&user_id=$patientId' : '';
    String sId = serviceId != null && !serviceId.isNegative ? '&service_id=$serviceId' : '';
    String dId = doctorId != null && !doctorId.isNegative ? '&doctor_id=$doctorId' : '';
    String cId = clinicId != null && !clinicId.isNegative ? '&clinic_id=$clinicId' : '';
    String searchBooking = search.isNotEmpty ? '&search=$search' : '';
    String statusFilter = filterByStatus != null && filterByStatus.isNotEmpty ? '&status=$filterByStatus' : '';
    final bookingRes = AppointmentListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.getAppointments}?page=$page&per_page=$perPage$pId$sId$dId$cId$statusFilter$searchBooking", method: HttpMethodType.GET)));
    if (page == 1) appointments.clear();
    appointments.addAll(bookingRes.data.validate());

    lastPageCallBack?.call(bookingRes.data.validate().length != perPage);

    return appointments.obs;
  }

  // static Future<AppointmentData> getAppointmentDetail({required int appointmentId}) async {
  //   return AppointmentData.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getAppointmentDetail}?appointment_id=$appointmentId", method: HttpMethodType.GET)));
  // }
  static Future<AppointmentData> getAppointmentDetail({
    int? appointmentId,
    String notifyId = "",
    required AppointmentData appointMentDet,
  }) async {
    String appointment = appointmentId != null ? 'appointment_id=$appointmentId' : '';
    String notificationId = appointMentDet.notificationId.trim().isNotEmpty ? '&notification_id=${appointMentDet.notificationId}' : '';
    final res = AppointmentDetailsResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getAppointmentDetail}?$appointment$notificationId", method: HttpMethodType.GET)));
    appointMentDet = res.data;
    return appointMentDet;
    // return AppointmentData.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getAppointmentDetail}?appointment_id=$appointmentId", method: HttpMethodType.GET)));
  }

  static Future<BaseResponseModel> updateBooking({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.bookingUpdate, request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> updateStatus({required Map request, required int appointmentId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.updateStatus}/$appointmentId', request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> saveSession({required Map request, required int doctorId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.saveSession}/$doctorId", request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> assignDoctor({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.assignDoctor, request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> updateReview({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveRating, request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> deleteReview({required int id}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.deleteRating, request: {"id": id}, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> changeAppointmentStatus({required int id, required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.updateStatus}/$id", request: request, method: HttpMethodType.POST)));
  }

  static Future<EmployeeReviewRes> getEmployeeReviews({
    int? empId,
    int page = 1,
    int perPage = Constants.perPageItem,
    Function(bool)? lastPageCallBack,
  }) async {
    if (isLoggedIn.value) {
      String employeeId = empId != null ? '&employee_id=$empId' : '';
      final reviewRes = EmployeeReviewRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getRating}?per_page=$perPage&page=$page$employeeId", method: HttpMethodType.GET)));
      lastPageCallBack?.call(reviewRes.reviewData.length != perPage);
      return reviewRes;
    } else {
      return EmployeeReviewRes();
    }
  }

  static Future<BillingDetailModel> getBillingDetails({
    int? encounterId,
    required BillingDetailModel billingDetails,
  }) async {
    String encounter = encounterId != null && !encounterId.isNegative ? '&encounter_id=$encounterId' : '';
    final reviewRes = BillingDetailsResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.billingRecordDetail}?$encounter", method: HttpMethodType.GET)));
    billingDetails = reviewRes.data;
    return billingDetails;
  }

  //get Encounter Details
  static Future<EncounterDetailModel> getEncounterDet({
    int? encounterId,
    required EncounterDetailModel encounterDetModel,
  }) async {
    String encounter = encounterId != null && !encounterId.isNegative ? 'encounter_id=$encounterId' : '';
    final reviewRes = EncounterDetailResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.encounterDetail}?$encounter", method: HttpMethodType.GET)));
    encounterDetModel = reviewRes.data;
    return encounterDetModel;
  }

  //Save Encounter Details
  static Future<BaseResponseModel> saveInvoice({
    required Map<String, dynamic> request,
  }) async {
    final res = BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveBillingDetails, request: request, method: HttpMethodType.POST)));
    return res;
  }

//Save Billing Items
  static Future<BaseResponseModel> saveBillingItems({
    required Map<String, dynamic> request,
  }) async {
    final res = BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveBillingItems, request: request, method: HttpMethodType.POST)));
    return res;
  }

  //delete Billing Items
  static Future<BaseResponseModel> deleteBillingItems({
    required int id,
  }) async {
    final res = BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.deleteBillingItems}/$id", method: HttpMethodType.POST)));
    return res;
  }

  //get Service Details
  static Future<ServiceDetails> getServiceDetails({
    int? encounterId,
    int? serviceId,
    required ServiceDetails serviceDetails,
  }) async {
    String encounter = encounterId != null && !encounterId.isNegative ? 'encounter_id=$encounterId' : '';
    String service = serviceId != null && !serviceId.isNegative ? '&service_id=$serviceId' : '';
    final reviewRes = ServiceDetailResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.serviceDetail}?$encounter$service", method: HttpMethodType.GET)));
    serviceDetails = reviewRes.data;
    return serviceDetails;
  }

  static Future<RxList<DoctorSessionModel>> getDoctorSessionList({
    int page = 1,
    String search = '',
    int? clinicId,
    int perPage = Constants.perPageItem,
    required List<DoctorSessionModel> doctorSession,
    Function(bool)? lastPageCallBack,
  }) async {
    String cId = clinicId != null && !clinicId.isNegative ? '&clinic_id=$clinicId' : '';
    final doctorSes = DoctorSessionResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getDoctorSession}?page=$page&per_page=$perPage$cId", method: HttpMethodType.GET)));
    if (page == 1) doctorSession.clear();
    doctorSession.addAll(doctorSes.data.validate());
    lastPageCallBack?.call(doctorSes.data.validate().length != perPage);
    return doctorSession.obs;
  }

  //Get Specialization List
  static Future<RxList<SpecializationModel>> getSpecializationList({
    int page = 1,
    var perPage = Constants.perPageItem,
    String search = '',
    required List<SpecializationModel> specializationList,
    Function(bool)? lastPageCallBack,
  }) async {
    String searchSpec = search.trim().isNotEmpty ? '&search=$search' : '';
    var res = SpecializationResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getSpecializationList}?per_page=$perPage&page=$page$searchSpec", method: HttpMethodType.GET)));
    if (page == 1) specializationList.clear();
    specializationList.addAll(res.data.validate());
    lastPageCallBack?.call(res.data.validate().length != perPage);
    return specializationList.obs;
  }

  //Get Clinic List
  static Future<RxList<ClinicData>> getClinicList({
    int page = 1,
    String search = '',
    int? serviceId,
    var perPage = Constants.perPageItem,
    required List<ClinicData> clinicList,
    Function(bool)? lastPageCallBack,
  }) async {
    String searchClinic = search.isNotEmpty ? '&search=$search' : '';
    String service = serviceId != null ? '&service_id=$serviceId' : '';
    var res = ClinicListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getClinics}?per_page=$perPage&page=$page$searchClinic$service", method: HttpMethodType.GET)));
    if (page == 1) clinicList.clear();
    clinicList.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return clinicList.obs;
  }

  //Get Patient List
  static Future<RxList<PatientModel>> getPatientsList({
    int page = 1,
    String search = '',
    String filter = '',
    int? doctorId,
    int? clinicId,
    var perPage = Constants.perPageItem,
    required List<PatientModel> patientsList,
    Function(bool)? lastPageCallBack,
  }) async {
    String searchPatient = search.isNotEmpty ? '&search=$search' : '';
    String filterPatient = filter.isNotEmpty ? '&filter=$filter' : '';
    String dId = doctorId != null && !doctorId.isNegative ? '&doctor_id=$doctorId' : '';
    String cId = clinicId != null && !clinicId.isNegative ? '&clinic_id=$clinicId' : '';
    var res = PatientListModel.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.getPatientsList}?per_page=$perPage&page=$page$searchPatient$filterPatient$dId$cId", method: HttpMethodType.GET)));
    if (page == 1) patientsList.clear();
    patientsList.addAll(res.data.validate());
    lastPageCallBack?.call(res.data.validate().length != perPage);
    return patientsList.obs;
  }

  //Create Patient
  static Future<PatientModel> createPatient({required Map<String, dynamic> request}) async {
    var res = await handleResponse(await buildHttpResponse(APIEndPoints.createPatient, method: HttpMethodType.POST, request: request));
    return PatientModel.fromJson(res['data']);
  }

  //Get Payout List
  static Future<RxList<PayoutModel>> getPayoutList({
    int page = 1,
    var perPage = Constants.perPageItem,
    required List<PayoutModel> payoutList,
    Function(bool)? lastPageCallBack,
  }) async {
    var res = PayoutListModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getDoctorPayoutHistory}?per_page=$perPage&page=$page", method: HttpMethodType.GET)));
    if (page == 1) payoutList.clear();
    payoutList.addAll(res.data.validate());
    lastPageCallBack?.call(res.data.validate().length != perPage);
    return payoutList.obs;
  }

  //Get Doctor Details
  static Future<Rx<Doctor>> getDoctorDetail({required int doctorId}) async {
    var res = DoctorDetailRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.doctorDetails}?doctor_id=$doctorId", method: HttpMethodType.GET)));
    return res.data.obs;
  }

  static Future<Rx<ReceptionistData>> getReceptionistDetail({required int receptionistId}) async {
    var response = await handleResponse(await buildHttpResponse(
        "${APIEndPoints.receptionistDetails}?receptionist_id=$receptionistId", method: HttpMethodType.GET));

    // Check if response contains data field
    if (response is Map<String, dynamic> && response.containsKey("data")) {
      var receptionistData = ReceptionistData.fromJson(response["data"]);
      return receptionistData.obs;
    } else {
      return ReceptionistData().obs; // Return default object if response is invalid
    }
  }

  //Get Review List
  static Future<RxList<ReviewModel>> getReviewList({
    int? doctorId,
    int page = 1,
    var perPage = Constants.perPageItem,
    required List<ReviewModel> reviewList,
    Function(bool)? lastPageCallBack,
  }) async {
    var res = ReviewListModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getRating}?per_page=$perPage&page=$page&doctor_id=$doctorId", method: HttpMethodType.GET)));
    if (page == 1) reviewList.clear();
    reviewList.addAll(res.data.validate());
    lastPageCallBack?.call(res.data.validate().length != perPage);
    return reviewList.obs;
  }

  //Save Encounter
  static Future<Rx<EncounterResp>> saveEncounter({required Map request, required EncounterResp encounterResp}) async {
    var res = AddEncounterResp.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveEncounter, request: request, method: HttpMethodType.POST)));
    encounterResp = res.data;
    return encounterResp.obs;
  }

  //Edit Encounter
  static Future<Rx<EncounterResp>> editEncounter({required Map request, required int id, required EncounterResp encounterResp}) async {
    var res = AddEncounterResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.editEncounter}/$id", request: request, method: HttpMethodType.POST)));
    encounterResp = res.data;
    return encounterResp.obs;
  }

  //Delete Encounter
  static Future<Rx<BaseResponseModel>> deleteEncounter({required int id}) async {
    var res = BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.deleteEncounter}/$id", method: HttpMethodType.POST)));
    return res.obs;
  }

  //Get Clinic List
  static Future<RxList<CMNElement>> getEncProblems({String search = ''}) async {
    String searchProblems = search.isNotEmpty ? '&search=$search' : '';
    var res = ProblemsListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.getEncProblemObservations}?type=${EncounterDropdownTypes.encounterProblem}$searchProblems", method: HttpMethodType.GET)));
    return res.data.obs;
  }

  //Get Clinic List
  static Future<RxList<CMNElement>> getEncObservations({String search = ''}) async {
    String searchObservations = search.isNotEmpty ? '&search=$search' : '';
    var res = ProblemsListRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.getEncProblemObservations}?type=${EncounterDropdownTypes.encounterObservations}$searchObservations", method: HttpMethodType.GET)));
    return res.data.obs;
  }

  //Get Clinic List
  static Future<RxList<MedicalReport>> getMedicalReports({
    int page = 1,
    required int encounterId,
    var perPage = Constants.perPageItem,
    required List<MedicalReport> medicalReports,
    Function(bool)? lastPageCallBack,
  }) async {
    var res = MedicalReportsRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.getMedicalReport}?per_page=$perPage&page=$page&encounter_id=$encounterId", method: HttpMethodType.GET)));
    if (page == 1) medicalReports.clear();
    medicalReports.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return medicalReports.obs;
  }

  static Future<BaseResponseModel> deleteMedicalReports({required int reportId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.deleteMedicalReport}/$reportId', method: HttpMethodType.GET)));
  }

  static Future<void> saveMedicalReport({
    int? reportId,
    bool isEdit = false,
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    var multiPartRequest = await getMultiPartRequest(isEdit ? "${APIEndPoints.updateMedicalReport}/$reportId" : APIEndPoints.saveMedicalReport);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(await http.MultipartFile.fromPath('file_url', files.validate().first.path.validate()));
    }

    /*  if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(await getMultipartImages(files: files.validate(), name: 'medical_report'));
      multiPartRequest.fields['attachment_count'] = files.validate().length.toString();
    } */

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      final baseResponseModel = BaseResponseModel.fromJson(jsonDecode(temp));
      log("--------------------${baseResponseModel.message}");
      toast(baseResponseModel.message, print: true);
      onSuccess?.call();
    }, onError: (error) {
      toast(error.toString(), print: true);
    });
  }

  //
  static Future<RxList<MedicalReport>> getPrescription({
    int page = 1,
    required int encounterId,
    var perPage = Constants.perPageItem,
    required List<MedicalReport> medicalReports,
    Function(bool)? lastPageCallBack,
  }) async {
    var res =
        MedicalReportsRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getPrescription}?per_page=$perPage&page=$page&encounter_id=$encounterId", method: HttpMethodType.GET)));
    if (page == 1) medicalReports.clear();
    medicalReports.addAll(res.data);
    lastPageCallBack?.call(res.data.length != perPage);
    return medicalReports.obs;
  }

  static Future<BaseResponseModel> deletePrescription({required int reportId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.deletePrescription}/$reportId', method: HttpMethodType.GET)));
  }

  static Future<void> savePrescription({
    int? reportId,
    bool isEdit = false,
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    var multiPartRequest = await getMultiPartRequest(isEdit ? "${APIEndPoints.updatePrescription}/$reportId" : APIEndPoints.savePrescription);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(await http.MultipartFile.fromPath('file_url', files.validate().first.path.validate()));
    }

    /*  if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(await getMultipartImages(files: files.validate(), name: 'medical_report'));
      multiPartRequest.fields['attachment_count'] = files.validate().length.toString();
    } */

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      final baseResponseModel = BaseResponseModel.fromJson(jsonDecode(temp));
      toast(baseResponseModel.message, print: true);
      onSuccess?.call();
    }, onError: (error) {
      toast(error.toString(), print: true);
    });
  }

  static Future<BaseResponseModel> saveEncounterDashboard({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveEncounterDashboard, request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> saveSOAP({required Map request, required int encounterId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.saveSOAP}/$encounterId", request: request, method: HttpMethodType.POST)));
  }

  static Future<Rx<GetSOAPRes>> getSOAP(int encounterId) async {
    final res = GetSOAPRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getSOAP}/$encounterId", method: HttpMethodType.GET)));
    return res.obs;
  }

  static Future<BaseResponseModel> saveStructuredReport({required int encounterId, required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveStructuredReport, request: {"encounter_id": encounterId, "data": request}, method: HttpMethodType.POST)));
  }

  static Future<Map<String, dynamic>> getStructuredReport(int encounterId) async {
    final res = await handleResponse(await buildHttpResponse("${APIEndPoints.getStructuredReport}/$encounterId", method: HttpMethodType.GET));
    if (res is Map) {
      return Map<String, dynamic>.from(res);
    }
    return {};
  }

  static Future<Rx<EncounterDashboardDetail>> encounterDashboardDetail(int encounterId) async {
    final res = EncounterDashboardRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.encounterDashboardDetail}?encounter_id=$encounterId", method: HttpMethodType.GET)));
    return res.data.obs;
  }

  static Future<Rx<EncounterInvoiceResp>> downloadEncounter(int encounterId) async {
    final res = EncounterInvoiceResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.encounterInvoice}?id=$encounterId", method: HttpMethodType.GET)));
    return res.obs;
  }

  static Future<Rx<AppointmentInvoiceResp>> appointmentInvoice(int appointmentId) async {
    final res = AppointmentInvoiceResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.downloadInvoice}?id=$appointmentId", method: HttpMethodType.GET)));
    return res.obs;
  }

  static Future<Rx<EncounterInvoiceResp>> downloadPrescription(int encounterId) async {
    final res = EncounterInvoiceResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.downloadPrescription}?id=$encounterId", method: HttpMethodType.GET)));
    return res.obs;
  }

  static Future<RxList<String>> getTimeSlots({
    required RxList<String> slots,
    required String date,
    required int clinicId,
    required int doctorId,
    required int serviceId,
  }) async {
    final timeSlotsRes = TimeSlotsRes.fromJson(
        await handleResponse(await buildHttpResponse("${APIEndPoints.getTimeSlots}?appointment_date=$date&doctor_id=$doctorId&clinic_id=$clinicId&service_id=$serviceId", method: HttpMethodType.GET)));
    slots(timeSlotsRes.slots);
    return slots;
  }

  static Future<void> saveBookApi({required Map<String, dynamic> request}) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.saveBooking);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));
    log("saveBooking-----------$request");

    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      // toast(baseResponseModel.message, print: true);
      try {
        saveBookingRes(SaveBookingRes.fromJson(jsonDecode(temp)));
      } catch (e) {
        log('SaveBookingRes.fromJson E: $e');
      }
    }, onError: (error) {
      toast(error.toString(), print: true);
    });
  }

  //Payment
  static Future<BaseResponseModel> savePayment({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.savePayment, request: request, method: HttpMethodType.POST)));
  }

  /// Fetch Other Patient List
  static Future<RxList<UserData>> otherMemberPatientList({
    int page = 1,
    int perPage = 10,
    required String patientId,
    required List<UserData> memberList,
    Function(bool)? lastPageCallBack,
  }) async {
    OtherPatientListRes memberListRes = OtherPatientListRes.fromJson(await handleResponse(await buildHttpResponse(
      "${APIEndPoints.otherMemberPatientList}?patient_id=$patientId&per_page=$perPage&page=$page",
      method: HttpMethodType.GET,
    )));
    if (page == 1) memberList.clear();
    memberList.addAll(memberListRes.data);
    lastPageCallBack?.call(memberListRes.data.length != perPage);
    return memberList.obs;
  }

  /// Get Agora Token for Video Call
  static Future<AgoraTokenRes> getAgoraToken({required int appointmentId}) async {
    return AgoraTokenRes.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.getAgoraToken}?appointment_id=$appointmentId",
          method: HttpMethodType.GET,
        ),
      ),
    );
  }
}