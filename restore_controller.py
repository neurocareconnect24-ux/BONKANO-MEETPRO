import codecs

file_path = 'D:/KIVIAPP/AdminKiviApp/lib/screens/Encounter/add_encounter/add_encounter_controller.dart'

with codecs.open(file_path, 'r', 'utf-8') as f:
    content = f.read()

# Restore encounter types and selectedEncounterType
additions = """
  //Edit Counter Details
  Rx<EncounterElement> editEncounterResp = EncounterElement().obs;

  RxString selectedEncounterType = 'consultation'.obs;

  final Map<String, String> encounterTypes = {
    'consultation': 'Consultation',
    'hospitalisation': 'Hospitalisation',
    'eeg': 'Électroencéphalogramme (EEG)',
    'enmg': 'Électroneuromyogramme (ENMG)',
    'potentiels_evoques': 'Potentiels Évoqués',
    'echo_tsa': 'Écho Doppler TSA',
  };
"""

content = content.replace("  //Edit Counter Details\n  Rx<EncounterElement> editEncounterResp = EncounterElement().obs;", additions)

# Restore selectedEncounterType in edit
edit_additions = """      descriptionCont.text = editEncounterResp.value.description;
      if (editEncounterResp.value.encounterType.isNotEmpty) {
        selectedEncounterType(editEncounterResp.value.encounterType);
      }"""
content = content.replace("      descriptionCont.text = editEncounterResp.value.description;", edit_additions)

# Replace user_id with patient_id and add encounter_type in saveEncounter
save_target = """      Map<String, dynamic> request = {
        "encounter_date": dateCont.text.dateInyyyyMMddFormat.toString(),
        "clinic_id": selectClinic.value.id.toString(),
        "doctor_id": loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) ? loginUserData.value.id : selectDoctor.value.doctorId.toString(),
        "user_id": selectPatient.value.id.toString(),
        "description": descriptionCont.text.isEmpty ? "" : descriptionCont.text.toString()
      };"""
save_replace = """      Map<String, dynamic> request = {
        "id": "",
        "encounter_date": dateCont.text.dateInyyyyMMddFormat.toString(),
        "clinic_id": selectClinic.value.id.toString(),
        "doctor_id": loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) ? loginUserData.value.id : selectDoctor.value.doctorId.toString(),
        "patient_id": selectPatient.value.id.toString(),
        "encounter_type": selectedEncounterType.value,
        "description": descriptionCont.text.isEmpty ? "" : descriptionCont.text.toString()
      };"""
content = content.replace(save_target, save_replace)

# Replace user_id with patient_id and add encounter_type in editEncounter
edit_target = """      Map<String, dynamic> request = {
        "encounter_date": dateCont.text.dateInyyyyMMddFormat.toString(),
        "clinic_id": selectClinic.value.id.toString(),
        "doctor_id": loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) ? loginUserData.value.id : selectDoctor.value.doctorId.toString(),
        "user_id": selectPatient.value.id.toString(),
        "description": descriptionCont.text.toString()
      };"""
edit_replace = """      Map<String, dynamic> request = {
        "id": "${editEncounterResp.value.id}",
        "encounter_date": dateCont.text.dateInyyyyMMddFormat.toString(),
        "clinic_id": selectClinic.value.id.toString(),
        "doctor_id": loginUserData.value.userRole.contains(EmployeeKeyConst.doctor) ? loginUserData.value.id : selectDoctor.value.doctorId.toString(),
        "patient_id": selectPatient.value.id.toString(),
        "encounter_type": selectedEncounterType.value,
        "description": descriptionCont.text.toString()
      };"""
content = content.replace(edit_target, edit_replace)

with codecs.open(file_path, 'w', 'utf-8') as f:
    f.write(content)

print("Restored encounter_type and patient_id in AdminKiviApp!")
