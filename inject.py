import codecs

file_path = 'D:/KIVIAPP/AdminKiviApp/lib/screens/Encounter/add_encounter/add_encounter_controller.dart'

with codecs.open(file_path, 'r', 'utf-8') as f:
    lines = f.readlines()

# We want to insert the encounterTypes map after `Rx<EncounterElement> editEncounterResp = EncounterElement().obs;`
target_line = "  Rx<EncounterElement> editEncounterResp = EncounterElement().obs;"

# We want to replace `descriptionCont.text = editEncounterResp.value.description;` with it plus the selectedEncounterType
edit_target = "      descriptionCont.text = editEncounterResp.value.description;"

# user_id replacement targets
save_target = '        "user_id": selectPatient.value.id.toString(),\n'
edit_target2 = '        "user_id": selectPatient.value.id.toString(),\n'

new_lines = []
for line in lines:
    if target_line in line:
        new_lines.append(line)
        new_lines.append("\n  RxString selectedEncounterType = 'consultation'.obs;\n\n")
        new_lines.append("  final Map<String, String> encounterTypes = {\n")
        new_lines.append("    'consultation': 'Consultation',\n")
        new_lines.append("    'hospitalisation': 'Hospitalisation',\n")
        new_lines.append("    'eeg': 'Électroencéphalogramme (EEG)',\n")
        new_lines.append("    'enmg': 'Électroneuromyogramme (ENMG)',\n")
        new_lines.append("    'potentiels_evoques': 'Potentiels Évoqués',\n")
        new_lines.append("    'echo_tsa': 'Écho Doppler TSA',\n")
        new_lines.append("  };\n")
    elif edit_target in line:
        new_lines.append(line)
        new_lines.append("      if (editEncounterResp.value.encounterType.isNotEmpty) {\n")
        new_lines.append("        selectedEncounterType(editEncounterResp.value.encounterType);\n")
        new_lines.append("      }\n")
    elif save_target in line:
        new_lines.append('        "patient_id": selectPatient.value.id.toString(),\n')
        new_lines.append('        "encounter_type": selectedEncounterType.value,\n')
    else:
        new_lines.append(line)

with codecs.open(file_path, 'w', 'utf-8') as f:
    f.writelines(new_lines)

print("Injected variables safely.")
