import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:signature/signature.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import '../../../api/core_apis.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';
import '../../auth/model/common_model.dart';
import '../../../api/doctor_apis.dart';
import '../../clinic/add_clinic_form/addresses_apis.dart';
import '../../clinic/add_clinic_form/model/city_list_response.dart';
import '../../clinic/add_clinic_form/model/country_list_response.dart';
import '../../clinic/add_clinic_form/model/state_list_response.dart';
import '../../clinic/model/clinics_res_model.dart';
import '../../service/model/service_list_model.dart';
import '../model/add_doctor_req.dart';
import '../model/commission_list_model.dart';
import '../model/doctor_list_res.dart';
import '../model/qualification_model.dart';

class AddDoctorController extends GetxController {
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController phoneCodeCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();
  TextEditingController aboutSelfCont = TextEditingController();
  TextEditingController expertCont = TextEditingController();
  TextEditingController experienceCont = TextEditingController();
  TextEditingController commissionCont = TextEditingController();
  TextEditingController clinicCenterCont = TextEditingController();
  TextEditingController servicesCont = TextEditingController();
  TextEditingController humanisticCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController stateCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController fbCont = TextEditingController();
  TextEditingController instaCont = TextEditingController();
  TextEditingController twitterCont = TextEditingController();
  TextEditingController dribbleCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  Rx<TextEditingController> signatureCont = TextEditingController().obs;
  TextEditingController latCont = TextEditingController();
  TextEditingController lonCont = TextEditingController();
  TextEditingController postalCont = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneCodeFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode aboutSelfFocus = FocusNode();
  FocusNode expertFocus = FocusNode();
  FocusNode experienceFocus = FocusNode();
  FocusNode commissionFocus = FocusNode();
  FocusNode clinicCenterFocus = FocusNode();
  FocusNode servicesFocus = FocusNode();
  FocusNode humanisticFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode fbFocus = FocusNode();
  FocusNode instaFocus = FocusNode();
  FocusNode twitterFocus = FocusNode();
  FocusNode dribbleFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode signatureFocus = FocusNode();
  FocusNode latFocus = FocusNode();
  FocusNode lonFocus = FocusNode();
  FocusNode postalFocus = FocusNode();

  RxList<ClinicData> selectedClinicList = RxList();
  RxList<ServiceElement> selectedServiceList = RxList();

  RxList<QualificationModel> qualifications = RxList();
  // RxString signatureBase64 = "".obs;
  Rx<Uint8List> signatureUint8List = Uint8List(0).obs;

  //Active/In-active Status
  RxBool status = true.obs;

  Rx<Country> pickedPhoneCode = defaultCountry.obs;

  Rx<CMNModel> selectedGender = CMNModel().obs;

  RxBool isEdit = false.obs;

  TextEditingController searchCont = TextEditingController();

  RxBool isLoading = false.obs;

  RxString doctorImage = "".obs;

  // RxList<XFile> pickedFile = RxList();
  Rx<File> imageFile = File("").obs;
  XFile? pickedFile;

  final GlobalKey<FormState> addDoctorformKey = GlobalKey<FormState>();

  final ScrollController scrollController = ScrollController();

  //Commission
  Rx<CommissionElement> selectedCommission = CommissionElement().obs;
  RxList<CommissionElement> commissionList = RxList();
  RxList<CommissionElement> commissionFilterList = RxList();

  //Error Handle
  RxBool hasErrorFetchingCommission = false.obs;
  RxString errorMessageCommission = "".obs;

  Rx<Doctor> doctorData = Doctor().obs;
  RxString clinicIds = "".obs;
  RxString serviceIds = "".obs;

  // Initialise a controller. It will contains signature points, stroke width and pen color.
  // It will allow you to interact with the widget
  final SignatureController signaturePadCont = SignatureController(
    penStrokeWidth: 2,
    penColor: black,
    exportBackgroundColor: white,
  );

// Address Details
  RxList<CountryData> countryList = RxList();
  RxList<StateData> stateList = RxList();
  RxList<CityData> cityList = RxList();

  Rx<CountryData> selectedCountry = CountryData().obs;
  Rx<StateData> selectedState = StateData().obs;
  Rx<CityData> selectedCity = CityData().obs;

  //Error Country
  RxBool hasErrorFetchingCountry = false.obs;
  RxString errorMessageCountry = "".obs;
  //Error State
  RxBool hasErrorFetchingState = false.obs;
  RxString errorMessageState = "".obs;
  //Error City
  RxBool hasErrorFetchingCity = false.obs;
  RxString errorMessageCity = "".obs;

  RxInt countryId = 0.obs;
  RxInt stateId = 0.obs;
  RxInt cityId = 0.obs;
  RxString commissionIds = "".obs;

  @override
  void onInit() async {
    if (Get.arguments is Doctor) {
      doctorData(Get.arguments as Doctor);
      isEdit(true);
      await getDoctorDetail();
      if (doctorData.value.doctorId == loginUserData.value.id) {
        final userPASSWORD = getValueFromLocal(SharedPreferenceConst.USER_PASSWORD);
        if (userPASSWORD is String) {
          passwordCont.text = userPASSWORD;
          confirmPasswordCont.text = userPASSWORD;
        }
      }
    } else {
      init();
    }
    getCommission(isInit: true);
    signaturePadCont.addListener(() {});
    super.onInit();
  }

  Future<void> getDoctorDetail() async {
    isLoading(true);
    await CoreServiceApis.getDoctorDetail(doctorId: doctorData.value.doctorId).then((res) {
      doctorData(res.value);
      qualifications(res.value.qualifications
          .map((e) => QualificationModel(
                index: qualifications.length,
                degreeCont: TextEditingController(text: e.degree),
                universityCont: TextEditingController(text: e.university),
                yearCont: TextEditingController(text: e.year),
                degreeFocus: FocusNode(),
                universityFocus: FocusNode(),
                yearFocus: FocusNode(),
              ))
          .toList());
      initializFormData(res);
      getClinicAndService();
      init();
    }).catchError((e) {
      log("getDoctorDetails error $e");
    }).whenComplete(() => isLoading(false));
  }

  void initializFormData(Rx<Doctor> doctor) {
    firstNameCont.text = doctor.value.firstName;
    lastNameCont.text = doctor.value.lastName;
    emailCont.text = doctor.value.email;
    fbCont.text = doctor.value.facebookLink;
    instaCont.text = doctor.value.instagramLink;
    twitterCont.text = doctor.value.twitterLink;
    dribbleCont.text = doctor.value.dribbbleLink;
    aboutSelfCont.text = doctor.value.aboutSelf;
    experienceCont.text = doctor.value.experience;
    expertCont.text = doctor.value.expert;
    selectedGender(genders.firstWhere((element) => element.slug.toString() == doctor.value.gender.toLowerCase(), orElse: () => CMNModel(id: 3, name: "Other", slug: "other")));
    addressCont.text = doctor.value.address;
    signatureCont.value.text = doctor.value.signature;
    try {
      if (doctor.value.signature.isNotEmpty) {
        signatureUint8List(base64Decode(doctor.value.signature));
      }
    } catch (e) {
      try {
        if (doctor.value.signature.isNotEmpty) {
          signatureUint8List(base64.decode(signatureCont.value.text.split(',').last));
        }
      } catch (e) {
        log('re try signatureUint8List Err: $e');
      }
      log('signatureUint8List Err: $e');
    }
    doctorImage(doctor.value.profileImage);
    cityId(doctor.value.cityId.toInt());
    stateId(doctor.value.stateId.toInt());
    countryId(doctor.value.countryId.toInt());
    postalCont.text = doctor.value.pincode;
    latCont.text = doctor.value.latitude;
    lonCont.text = doctor.value.longitude;
    try {
      phoneCont.text = doctor.value.mobile.replaceAll("+${pickedPhoneCode.value.phoneCode}", "").trim();
      pickedPhoneCode(CountryParser.parsePhoneCode(doctor.value.mobile.extractPhoneCodeAndNumber.$1));
    } catch (e) {
      pickedPhoneCode(Country.from(json: defaultCountry.toJson()));
      phoneCont.text = doctor.value.mobile.replaceAll("+${pickedPhoneCode.value.phoneCode}", "").trim();
      log('CountryParser.parsePhoneCode Err: $e');
    }
    status(doctor.value.status.getBoolInt());
  }

  getClinicAndService() {
    List<ClinicData> selClinicList = [];
    for (var element in doctorData.value.clinics) {
      selClinicList.add(ClinicData(id: element.clinicId, name: element.name));
    }
    selectClinics(clinicList: selClinicList);
    List<ServiceElement> selectsServices = [];
    for (var element in doctorData.value.services) {
      selectsServices.add(ServiceElement(id: element.serviceId, name: element.name, status: false.obs));
    }
    selectServices(serviceList: selectsServices);
  }

  Future<void> init() async {
    if (countryId.value != 0) {
      await getCountry();
      await getStates(countryId: countryId.value);
      if (stateId.value != 0) {
        await getCity(stateId: stateId.value);
      }
    } else {
      await getCountry();
    }
  }

  Future<void> getCountry({String searchTxt = ''}) async {
    isLoading(true);

    await UserAddressesApis.getCountryList(searchTxt: searchTxt).then((value) async {
      countryList.clear();
      countryList(value);

      for (var e in value) {
        if (e.id == countryId.value) {
          selectedCountry(e);
          countryCont.text = selectedCountry.value.name;
        }
      }
      hasErrorFetchingCountry(false);
    }).catchError((e) {
      hasErrorFetchingCountry(true);
      errorMessageCountry(e.toString());
      toast(e.toString(), print: true);
    }).whenComplete(() => isLoading(false));
  }

  Future<void> getStates({required int countryId, String searchTxt = ''}) async {
    isLoading(true);

    await UserAddressesApis.getStateList(countryId: countryId, searchTxt: searchTxt).then((value) async {
      stateList.clear();
      stateList(value);
      for (var e in value) {
        if (e.id == stateId.value) {
          selectedState(e);
          stateCont.text = selectedState.value.name;
        }
      }
      hasErrorFetchingState(false);
    }).catchError((e) {
      hasErrorFetchingState(true);
      errorMessageState(e.toString());
      toast(e.toString(), print: true);
    }).whenComplete(() => isLoading(false));
  }

  Future<void> getCity({required int stateId, String searchTxt = ''}) async {
    isLoading(true);

    await UserAddressesApis.getCityList(stateId: stateId, searchTxt: searchTxt).then((value) async {
      cityList.clear();
      cityList(value);
      for (var e in value) {
        if (e.id == cityId.value) {
          selectedCity(e);
          cityCont.text = selectedCity.value.name;
        }
      }
      hasErrorFetchingCity(false);
    }).catchError((e) {
      hasErrorFetchingCity(true);
      errorMessageCity(e.toString());
      toast(e.toString(), print: true);
    }).whenComplete(() => isLoading(false));
  }

  void resetCity() {
    selectedCity(CityData());
    cityCont.clear();
    cityList.clear();
  }

  void resetState() {
    selectedState(StateData());
    stateCont.clear();
    stateList.clear();
  }

  //Get Commission List
  getCommission({bool isInit = false}) async {
    isLoading(true);
    await DoctorApis.getCommission().then((value) {
      isLoading(false);
      debugPrint('COMMISSIONIDS---- DOCTORDATA.VALUE.COMMISSIONS.ISNOTEMPTY: ${doctorData.value.commissions.isNotEmpty}');
      debugPrint('COMMISSIONIDS---- ISEDIT.VALUE: ${isEdit.value}');
      debugPrint('COMMISSIONIDS---- ISINIT: $isInit');
      if (isInit && isEdit.value && doctorData.value.commissions.isNotEmpty) {
        final commissionIds = doctorData.value.commissions.map((e) => e.commissionId);
        debugPrint('COMMISSIONIDS $commissionIds -------');
        for (var item in value.data) {
          debugPrint('COMMISSIONIDS $commissionIds CONTAINS(ITEM.ID) ${item.id} =>  ${commissionIds.contains(item.id)}');
          if (commissionIds.contains(item.id)) {
            item.isSelected(true);
          }
        }
      } else if (isInit && commissionList.length == 1) {
        commissionList.first.isSelected(true);
      } else {
        final commissionMap = {for (var item in commissionList) item.id: item.isSelected.value};
        for (var item in value.data) {
          if (commissionMap.containsKey(item.id)) {
            item.isSelected(commissionMap[item.id]);
          }
        }
      }
      commissionList(value.data);
      setCommissionContValue(commissionList: commissionList);
      hasErrorFetchingCommission(false);
    }).onError((error, stackTrace) {
      hasErrorFetchingCommission(true);
      errorMessageCommission(error.toString());
      isLoading(false);
      // toast(error.toString());
    });
  }

  void setCommissionContValue({required List<CommissionElement> commissionList}) {
    commissionIds(commissionList.where((item) => item.isSelected.value && !item.id.isNegative).map((item) => item.id.toString()).toList().join(","));
    commissionCont.text = commissionList.where((e) => e.isSelected.value).map((e) => "${e.title} (${e.commissionValue} ${e.commissionType.toLowerCase().trim().contains(TaxType.PERCENT) ? "%" : appCurrency.value.currencyName})").join(",");
  }

  selectClinics({required List<ClinicData> clinicList}) {
    clinicCenterCont.clear();
    clinicIds("");
    selectedClinicList(clinicList);
    for (var i = 0; i < clinicList.length; i++) {
      if (clinicList[i].name.trim().isNotEmpty) {
        clinicCenterCont.text = "${clinicCenterCont.text}${clinicList[i].name}${clinicList.length - 1 == i ? "" : ", "}";
      }
      clinicIds("${clinicIds.value}${clinicList[i].id}${clinicList.length - 1 == i ? "" : ", "}");
    }
  }

  selectServices({required List<ServiceElement> serviceList}) {
    servicesCont.clear();
    serviceIds("");
    selectedServiceList(serviceList);
    for (var i = 0; i < serviceList.length; i++) {
      if (serviceList[i].name.trim().isNotEmpty) {
        servicesCont.text = "${servicesCont.text}${serviceList[i].name}${serviceList.length - 1 == i ? "" : ", "}";
      }
      serviceIds("${serviceIds.value}${serviceList[i].id}${serviceList.length - 1 == i ? "" : ", "}");
    }
  }

  void searchCommissionFunc({
    required String searchtext,
    required RxList<CommissionElement> commissionFilterList,
    required RxList<CommissionElement> commissionSList,
  }) {
    commissionFilterList.value = List.from(commissionSList.where((element) => element.title.toString().toLowerCase().contains(searchtext.toString().toLowerCase())));
    for (var i = 0; i < commissionFilterList.length; i++) {
      log('SEARCHEDNAMES : ${commissionFilterList[i].toJson()}');
    }
    log('SEARCHEDNAMES.LENGTH: ${commissionFilterList.length}');
  }

  void onCommissionSearchChange(searchtext) {
    searchCommissionFunc(
      searchtext: searchtext,
      commissionFilterList: commissionFilterList,
      commissionSList: commissionList,
    );
  }

  bool get isShowFullList => commissionFilterList.isEmpty && searchCont.text.trim().isEmpty;

  /* Future<void> handleFilesPickerClick() async {
    final pickedFiles = await pickFiles();
    Set<String> filePathsSet = clincFiles.map((file) => file.name.trim().toLowerCase()).toSet();
    for (var i = 0; i < pickedFiles.length; i++) {
      if (!filePathsSet.contains(pickedFiles[i].name.trim().toLowerCase())) {
        clincFiles.add(pickedFiles[i]);
      }
    }
  } */

  Future<void> addDoctor() async {
    isLoading(true);
    hideKeyBoardWithoutContext();
    AddDoctorReq addDoctorReq = AddDoctorReq(
      firstName: firstNameCont.text.trim(),
      lastName: lastNameCont.text.trim(),
      email: emailCont.text.trim(),
      password: passwordCont.text.trim(),
      confirmPassword: confirmPasswordCont.text.trim(),
      gender: selectedGender.value.slug,
      mobile: "+${pickedPhoneCode.value.phoneCode}${phoneCont.text.trim()}",
      clinicId: clinicIds.value,
      status: status.value.getIntBool().toString(),
      serviceId: serviceIds.value,
      commissionId: commissionIds.value,
      aboutSelf: aboutSelfCont.text,
      expert: expertCont.text,
      facebookLink: fbCont.text.trim(),
      instagramLink: instaCont.text.trim(),
      twitterLink: twitterCont.text.trim(),
      dribbbleLink: dribbleCont.text.trim(),
      address: addressCont.text.trim(),
      city: selectedCity.value.id.toString(),
      state: selectedState.value.id.toString(),
      country: selectedCountry.value.id.toString(),
      pincode: postalCont.text.trim(),
      latitude: latCont.text.trim(),
      longitude: lonCont.text.trim(),
      experience: experienceCont.text,
      signature: signatureCont.value.text,
      qualifications: qualifications,
    );

    DoctorApis.addDoctor(
      isEdit: isEdit.value,
      request: addDoctorReq.toJson(),
      doctorId: doctorData.value.doctorId,
      files: imageFile.value.path.isNotEmpty ? [imageFile.value] : null,
    ).then((resp) {
      // log("Add  $resp");
      if (isEdit.value && doctorData.value.doctorId == loginUserData.value.id) {
        CoreServiceApis.getDoctorDetail(doctorId: doctorData.value.doctorId).then((res) {
          doctorData(res.value);
          loginUserData.value.profileImage = doctorData.value.profileImage;
          debugPrint('DOCTORDATA.VALUE.EMAIL: ${doctorData.value.email}');
          loginUserData.value.email = doctorData.value.email;
          loginUserData.value.firstName = doctorData.value.firstName;
          loginUserData.value.lastName = doctorData.value.lastName;
          setValueToLocal(SharedPreferenceConst.USER_DATA, loginUserData.toJson());
          loginUserData.refresh();
        }).catchError((e) {
          log("getDoctorDetails error $e");
        });
      }
      Get.back(result: true);
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() => isLoading(false));
  }

  Future<void> _handleGalleryClick() async {
    Get.back();
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      doctorImage('');
      imageFile(File(pickedFile!.path));
    }
  }

  Future<void> _handleCameraClick() async {
    Get.back();
    pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      doctorImage('');
      imageFile(File(pickedFile!.path));
    }
  }

  void showImagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: locale.value.gallery,
              leading: const Icon(Icons.image, color: appColorPrimary),
              onTap: () async {
                _handleGalleryClick();
              },
            ),
            SettingItemWidget(
              title: locale.value.camera,
              leading: const Icon(Icons.camera, color: appColorPrimary),
              onTap: () {
                _handleCameraClick();
              },
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  void showSignaturePad(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: locale.value.gallery,
              leading: const Icon(Icons.image, color: appColorPrimary),
              onTap: () async {
                _handleGalleryClick();
              },
            ),
            SettingItemWidget(
              title: locale.value.camera,
              leading: const Icon(Icons.camera, color: appColorPrimary),
              onTap: () {
                _handleCameraClick();
              },
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  signatureBottomSheet(BuildContext context) {
    return Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: boxDecorationDefault(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          color: context.cardColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(locale.value.addYourSignature, style: boldTextStyle(size: 14)).expand(),
                  appCloseIconButton(
                    context,
                    onPressed: () {
                      Get.back();
                    },
                    size: 11,
                  )
                ],
              ),
              2.height,
              Text(locale.value.verifyWithEaseYourDigitalMark, style: primaryTextStyle(size: 12, color: dividerColor)),
              12.height,
              Stack(
                children: [
                  Container(
                    decoration: boxDecorationDefault(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDarkMode.value ? borderColorDark : borderColor),
                      color: isDarkMode.value ? borderColorDark : borderColor,
                    ),
                    child: Signature(
                      key: const Key('signature'),
                      controller: signaturePadCont,
                      height: 180,
                      width: double.infinity,
                      backgroundColor: isDarkMode.value ? borderColorDark : borderColor,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        signaturePadCont.clear();
                      },
                      child: Container(
                        height: 26,
                        width: 60,
                        alignment: Alignment.center,
                        decoration: boxDecorationDefault(
                          color: redColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(6),
                          ),
                        ),
                        child: Text(locale.value.clear, style: primaryTextStyle(size: 14, color: white)),
                      ),
                    ),
                  ),
                ],
              ),
              18.height,
              AppButton(
                width: Get.width,
                text: locale.value.save,
                color: appColorSecondary,
                textStyle: appButtonTextStyleWhite,
                shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
                onTap: () async {
                  if (signaturePadCont.isNotEmpty) {
                    final signValue = await signaturePadCont.toPngBytes(height: 1000, width: 1000);
                    if (signValue != null) {
                      signatureUint8List(signValue);
                      signatureCont.value.text = base64Encode(signatureUint8List.value as List<int>);
                    }
                    Get.back();
                  } else {
                    toast("${locale.value.addYourSignature}!!");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    signaturePadCont.clear();
    if (Get.context != null) {
      signaturePadCont.removeListener(() => hideKeyboard(Get.context));
    }
    // Dispose TextEditingControllers
    firstNameCont.dispose();
    lastNameCont.dispose();
    emailCont.dispose();
    phoneCodeCont.dispose();
    phoneCont.dispose();
    passwordCont.dispose();
    confirmPasswordCont.dispose();
    aboutSelfCont.dispose();
    expertCont.dispose();
    experienceCont.dispose();
    commissionCont.dispose();
    clinicCenterCont.dispose();
    servicesCont.dispose();
    humanisticCont.dispose();
    countryCont.dispose();
    stateCont.dispose();
    cityCont.dispose();
    fbCont.dispose();
    instaCont.dispose();
    twitterCont.dispose();
    dribbleCont.dispose();
    addressCont.dispose();
    signatureCont.value.dispose();
    latCont.dispose();
    lonCont.dispose();
    postalCont.dispose();
    searchCont.dispose();
    // Dispose FocusNodes
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    phoneCodeFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    aboutSelfFocus.dispose();
    expertFocus.dispose();
    experienceFocus.dispose();
    commissionFocus.dispose();
    clinicCenterFocus.dispose();
    servicesFocus.dispose();
    humanisticFocus.dispose();
    countryFocus.dispose();
    stateFocus.dispose();
    cityFocus.dispose();
    fbFocus.dispose();
    instaFocus.dispose();
    twitterFocus.dispose();
    dribbleFocus.dispose();
    addressFocus.dispose();
    signatureFocus.dispose();
    latFocus.dispose();
    lonFocus.dispose();
    postalFocus.dispose();
    super.onClose();
  }
}
