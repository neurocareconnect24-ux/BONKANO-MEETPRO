import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/api/core_apis.dart';
import 'package:bonkano_meet_pro/screens/auth/model/common_model.dart';
import 'package:bonkano_meet_pro/screens/clinic/model/clinics_res_model.dart';
import 'package:bonkano_meet_pro/screens/receptionist/model/receptionist_res_model.dart';
import 'package:bonkano_meet_pro/utils/common_base.dart';
import 'package:bonkano_meet_pro/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class AddReceptionistController extends GetxController {
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController clinicCenterCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController phoneCodeCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();

  final GlobalKey<FormState> addReqFormKey = GlobalKey();
  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode clinicCenterFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneCodeFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  Rx<ClinicData> selectedClinic = ClinicData().obs;

  Rx<Country> pickedPhoneCode = defaultCountry.obs;

  Rx<CMNModel> selectedGender = CMNModel().obs;

  RxBool isLoading = false.obs;
  RxBool isEdit = false.obs;
  Rx<ReceptionistData> receptionistData = ReceptionistData().obs;

  @override
  void onInit() async {
    super.onInit();
    if (Get.arguments is ReceptionistData) {
      receptionistData(Get.arguments);
      isEdit(true);
      await getReceptionistDetail();
    }
  }

  Future<void> getReceptionistDetail() async {
    isLoading(true);
    await CoreServiceApis.getReceptionistDetail(receptionistId: receptionistData.value.id).then((res) {
      receptionistData(res.value);
      initializeFormData(receptionistData);
    });
  }

  void initializeFormData(Rx<ReceptionistData> receptionistData) {
    if (isEdit.value) {
      firstNameCont.text = receptionistData.value.firstName;
      lastNameCont.text = receptionistData.value.lastName;
      emailCont.text = receptionistData.value.email;
      phoneCont.text = receptionistData.value.mobile;
      addressCont.text = receptionistData.value.address;
      clinicCenterCont.text = receptionistData.value.clinicName;
      selectedGender(genders.firstWhere((element) => element.slug.toString() == receptionistData.value.gender.toLowerCase(), orElse: () => CMNModel()));
    }
    isLoading(false);
  }

  selectClinics({required ClinicData clinic}) {
    clinicCenterCont.clear();
    selectedClinic(clinic);
    clinicCenterCont.text = clinic.name;
  }

  clearConts() {
    firstNameCont.clear();
    lastNameCont.clear();
    emailCont.clear();
    phoneCodeCont.clear();
    phoneCont.clear();
    passwordCont.clear();
    clinicCenterCont.clear();
    selectedGender();
    addressCont.clear();
    confirmPasswordCont.clear();
  }

  saveReceptionist() async {
    if (isLoading.value) return;
    if (selectedClinic.value.id <= 0) {
      toast('Please select a clinic');
      return;
    }
    isLoading(true);

    Map<String, dynamic> req = {
      'first_name': firstNameCont.text.trim(),
      'last_name': lastNameCont.text.trim(),
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
      'confirm_password': confirmPasswordCont.text.trim(),
      'gender': selectedGender.value.slug,
      'mobile': "+${phoneCont.text.trim().formatPhoneNumber(pickedPhoneCode.value.phoneCode)}",
      'address': addressCont.text.trim(),
      'clinic_id': selectedClinic.value.id
    };

    CoreServiceApis.saveReceptionist(request: req, isEdit: isEdit.value).then((value) async {

      clearConts();
      Get.back(result: true);
    }).catchError((e) {
      toast(e.toString(), print: true);
    }).whenComplete(() => isLoading(false));
  }

  @override
  void onClose() {
    firstNameCont.dispose();
    lastNameCont.dispose();
    clinicCenterCont.dispose();
    emailCont.dispose();
    phoneCodeCont.dispose();
    phoneCont.dispose();
    addressCont.dispose();
    passwordCont.dispose();
    confirmPasswordCont.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    clinicCenterFocus.dispose();
    emailFocus.dispose();
    phoneCodeFocus.dispose();
    phoneFocus.dispose();
    addressFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}
