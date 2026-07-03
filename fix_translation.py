import codecs

file_path = 'D:/KIVIAPP/AdminKiviApp/lib/locale/language_fr.dart'

with codecs.open(file_path, 'r', 'utf-8') as f:
    content = f.read()

# Replacements
content = content.replace("Rencontre", "Acte médical")
content = content.replace("rencontre", "acte médical")
content = content.replace("une acte médical", "un acte médical")
content = content.replace("Une acte médical", "Un acte médical")
content = content.replace("cette acte médical", "cet acte médical")
content = content.replace("la acte médical", "l'acte médical")
content = content.replace("La acte médical", "L'acte médical")
content = content.replace("de acte médical", "d'acte médical")

content = content.replace("docteur", "praticien")
content = content.replace("Docteur", "Praticien")
content = content.replace("médecin", "praticien")
content = content.replace("Médecin", "Praticien")

content = content.replace("réceptionniste", "secrétaire médical")
content = content.replace("Réceptionniste", "Secrétaire médical")

with codecs.open(file_path, 'w', 'utf-8') as f:
    f.write(content)

print("Translations applied successfully!")
