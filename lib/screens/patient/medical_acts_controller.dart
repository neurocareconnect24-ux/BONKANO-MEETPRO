import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import '../Encounter/model/encounters_list_model.dart';
import '../appointment/model/appointments_res_model.dart';
import '../Encounter/add_encounter/model/patient_model.dart';

class MedicalActsController extends GetxController {
  RxList<dynamic> combinedList = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  
  late PatientModel patient;

  @override
  void onInit() {
    if (Get.arguments is PatientModel) {
      patient = Get.arguments;
      getCombinedList();
    }
    super.onInit();
  }

  Future<void> getCombinedList() async {
    isLoading(true);
    try {
      // Fetch Encounters (Actes)
      List<EncounterElement> encounters = [];
      await CoreServiceApis.getEncounterList(
        patientId: patient.id,
        encounterList: encounters,
        page: 1,
        perPage: 100, // Fetch a good chunk
      );
      
      // Fetch Appointments (Consultations)
      List<AppointmentData> appointments = [];
      await CoreServiceApis.getAppointmentList(
        patientId: patient.id,
        appointments: appointments,
        page: 1,
        perPage: 100,
      );
      
      // Combine and Sort by Date Descending
      List<dynamic> combined = [...encounters, ...appointments];
      combined.sort((a, b) {
        DateTime dateA = _getDateTime(a);
        DateTime dateB = _getDateTime(b);
        return dateB.compareTo(dateA);
      });
      
      combinedList(combined);
    } catch (e) {
      log('Error fetching medical acts: $e');
    } finally {
      isLoading(false);
    }
  }

  DateTime _getDateTime(dynamic item) {
    if (item is EncounterElement) {
      return DateTime.tryParse(item.encounterDate) ?? DateTime(1900);
    } else if (item is AppointmentData) {
      // Use startDateTime or appointmentDate
      return DateTime.tryParse(item.startDateTime) ?? DateTime.tryParse(item.appointmentDate) ?? DateTime(1900);
    }
    return DateTime(1900);
  }
}
