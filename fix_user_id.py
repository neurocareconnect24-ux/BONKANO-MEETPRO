import codecs

file_path = 'D:/KIVIAPP/AdminKiviApp/lib/screens/Encounter/add_encounter/add_encounter_controller.dart'

with codecs.open(file_path, 'r', 'utf-8') as f:
    content = f.read()

# Replacements
content = content.replace('"user_id": selectPatient.value.id.toString(),', '"patient_id": selectPatient.value.id.toString(),')

with codecs.open(file_path, 'w', 'utf-8') as f:
    f.write(content)

print("Replaced user_id with patient_id successfully!")
