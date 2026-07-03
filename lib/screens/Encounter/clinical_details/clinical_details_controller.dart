import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../api/core_apis.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../add_encounter/model/prescription_model.dart';
import '../model/enc_dashboard_req.dart';
import '../model/encounter_invoice_resp.dart';
import '../model/encounters_list_model.dart';
import '../model/problems_observations_model.dart';
import 'dart:developer' as dev;

class ClinicalDetailsController extends GetxController {
  //TextField Controller
  final GlobalKey<FormState> clinicalDetailsFormKey = GlobalKey();

  TextEditingController otherInfoCont = TextEditingController();

  //Bill TextField Controller
  final GlobalKey<FormState> addPrescriptionFormKey = GlobalKey();
  TextEditingController nameCont = TextEditingController();
  TextEditingController frequencyCont = TextEditingController();
  TextEditingController durationCont = TextEditingController();
  TextEditingController instructionCont = TextEditingController();

  //FocusNode
  FocusNode nameFocus = FocusNode();
  FocusNode frequencyFocus = FocusNode();
  FocusNode durationFocus = FocusNode();
  FocusNode instructionFocus = FocusNode();

  //Clinic
  Rx<Future<RxList<CMNElement>>> getProblems = Future(() => RxList<CMNElement>()).obs;
  Rx<Future<RxList<CMNElement>>> getObservations = Future(() => RxList<CMNElement>()).obs;
  RxBool isLoading = false.obs;

  Rx<EncounterElement> encounterData = EncounterElement().obs;

  RxList<CMNElement> observations = RxList();
  RxList<CMNElement> selectedObservation = RxList();

  RxList<CMNElement> problems = RxList();
  RxList<CMNElement> selectedProblems = RxList();

  RxList<CMNElement> notes = RxList();
  RxList<CMNElement> selectedNotes = RxList();

  //Get Prescription
  RxList<Prescription> prescriptionList = RxList();
  Rx<EncounterInvoiceResp> downloadPrescriptionRes = EncounterInvoiceResp().obs;

  ///Search
  TextEditingController searchCont = TextEditingController();
  RxBool isSearchText = false.obs;
  StreamController<String> searchStream = StreamController<String>();
  final _scrollController = ScrollController();

  getClearPrescription() {
    nameCont.clear();
    frequencyCont.clear();
    durationCont.clear();
    instructionCont.clear();
  }

  savePrescription() {
    final name = nameCont.text.trim();
    if (name.isEmpty) {
      toast(locale.value.thisFieldIsRequired);
      return;
    }
    prescriptionList.add(
      Prescription(
        name: name,
        frequency: frequencyCont.text.trim(),
        duration: durationCont.text.trim(),
        instruction: instructionCont.text.trim(),
      ),
    );
    Get.back();
  }

  getEditData(index) {
    nameCont.text = prescriptionList[index].name;
    frequencyCont.text = prescriptionList[index].frequency;
    durationCont.text = prescriptionList[index].duration;
    instructionCont.text = prescriptionList[index].instruction;
  }

  saveEditData(index) {
    final name = nameCont.text.trim();
    if (name.isEmpty) {
      toast(locale.value.thisFieldIsRequired);
      return;
    }
    prescriptionList[index].name = name;
    prescriptionList[index].frequency = frequencyCont.text.trim();
    prescriptionList[index].duration = durationCont.text.trim();
    prescriptionList[index].instruction = instructionCont.text.trim();
    prescriptionList.refresh();
    Get.back();
  }

  @override
  void onInit() {
    if (Get.arguments is EncounterElement) {
      encounterData(Get.arguments as EncounterElement);
    }
    getEncouterDetails();
    _scrollController.addListener(() => Get.context != null ? hideKeyboard(Get.context) : null);
    searchStream.stream.debounce(const Duration(milliseconds: 750)).listen((type) {
      if (type == EncounterDropdownTypes.encounterProblem) {
        getEncProblems();
      } else if (type == EncounterDropdownTypes.encounterObservations) {
        getEncObservations();
      } else if (type == EncounterDropdownTypes.encounterNotes) {
        setSelectedValues(type: EncounterDropdownTypes.encounterNotes);
      }
    });
    getEncProblems();
    getEncObservations();
    super.onInit();
  }

  Future<void> getEncouterDetails() async {
    isLoading(true);
    await CoreServiceApis.encounterDashboardDetail(encounterData.value.id).then((res) {
      log('value.length ==> ${res.value.id}');
      selectedProblems(res.value.problems);
      selectedObservation(res.value.observations);
      selectedNotes(res.value.notes);
      prescriptionList(res.value.prescriptions);
      otherInfoCont.text = res.value.otherDetails;
    }).catchError((e) {
      log("getEncouterDetails Err : $e");
    }).whenComplete(() => isLoading(false));
  }

  Future<void> getEncProblems({bool showloader = true}) async {
    if (showloader) {
      isLoading(true);
    }
    await getProblems(CoreServiceApis.getEncProblems(search: searchCont.text.trim())).then((value) {
      for (var element in value) {
        if (problems.indexWhere((p0) => element.id == p0.id).isNegative) {
          problems.add(element);
        }
      }
      setSelectedValues(type: EncounterDropdownTypes.encounterProblem);
    }).catchError((e) {
      log("getEncProblems err: $e");
    }).whenComplete(() => isLoading(false));
  }

  setSelectedValues({required String type}) {
    if (type == EncounterDropdownTypes.encounterProblem) {
      for (int i = 0; i < problems.length; i++) {
        if (selectedProblems.indexWhere((element) => element.id == problems[i].id) != -1) {
          problems[i].isSelected(true);
        } else {
          problems[i].isSelected(false);
        }
      }
    } else if (type == EncounterDropdownTypes.encounterObservations) {
      for (int i = 0; i < observations.length; i++) {
        if (selectedObservation.indexWhere((element) => element.id == observations[i].id) != -1) {
          observations[i].isSelected(true);
        } else {
          observations[i].isSelected(false);
        }
      }
    } else if (type == EncounterDropdownTypes.encounterNotes) {
      for (int i = 0; i < notes.length; i++) {
        if (selectedNotes.indexWhere((element) => element.id == notes[i].id) != -1) {
          notes[i].isSelected(true);
        } else {
          notes[i].isSelected(false);
        }
      }
    }
  }

  Future<void> getEncObservations({bool showloader = true}) async {
    if (showloader) {
      isLoading(true);
    }
    await getObservations(CoreServiceApis.getEncObservations(search: searchCont.text.trim())).then((value) {
      observations(value);
      for (int i = 0; i < observations.length; i++) {
        if (selectedObservation.indexWhere((element) => element.id == observations[i].id) != -1) {
          observations[i].isSelected(true);
        } else {
          observations[i].isSelected(false);
        }
      }
    }).catchError((e) {
      log("getEncObservations err: $e");
    }).whenComplete(() => isLoading(false));
  }

  Future<void> saveEncounterDashboard() async {
    isLoading(true);
    EncounterDashboardReq encounterDashboardReq = EncounterDashboardReq(
      encounterId: encounterData.value.id,
      userId: encounterData.value.userId,
      problems: selectedProblems,
      observations: selectedObservation,
      notes: selectedNotes,
      prescriptions: prescriptionList,
      otherInformation: otherInfoCont.text.trim(),
    );

    dev.log("req => ${jsonEncode(encounterDashboardReq.toJson())}");

    CoreServiceApis.saveEncounterDashboard(request: encounterDashboardReq.toJson()).then((value) {
      toast(value.message);
      Get.back();
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() => isLoading(false));
  }

  Future<void> getDownloadPrescription({bool showloader = true}) async {
    if (showloader) {
      isLoading(true);
    }
    await CoreServiceApis.downloadPrescription(encounterData.value.id).then((res) {
      downloadPrescriptionRes(res.value);
      if (res.value.status == true && res.value.link.isNotEmpty) {
        viewFiles(res.value.link);
      }
    }).catchError((e) {
      log("getEncounterDashboardDetail Err : $e");
    }).whenComplete(() => isLoading(false));
  }

  @override
  void onClose() {
    searchStream.close();
    if (Get.context != null) {
      _scrollController.removeListener(() => hideKeyboard(Get.context));
    }
    super.onClose();
  }
}
