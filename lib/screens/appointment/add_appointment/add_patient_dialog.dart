import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/core_apis.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../Encounter/add_encounter/model/patient_model.dart';

class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();

  final firstNameCont = TextEditingController();
  final lastNameCont = TextEditingController();
  final emailCont = TextEditingController();
  final mobileCont = TextEditingController();
  final passwordCont = TextEditingController();

  String? selectedGender;
  bool isLoading = false;

  @override
  void dispose() {
    firstNameCont.dispose();
    lastNameCont.dispose();
    emailCont.dispose();
    mobileCont.dispose();
    passwordCont.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final cleanPhone = mobileCont.text.trim().replaceAll(RegExp(r'\D'), '');
    final patientEmail = emailCont.text.trim().isNotEmpty
        ? emailCont.text.trim()
        : '$cleanPhone@neurocare.com';

    Map<String, dynamic> request = {
      'first_name': firstNameCont.text.trim(),
      'last_name': lastNameCont.text.trim(),
      'email': patientEmail,
      'mobile': mobileCont.text.trim(),
    };

    if (selectedGender != null && selectedGender!.isNotEmpty) {
      request['gender'] = selectedGender;
    }
    if (passwordCont.text.trim().isNotEmpty) {
      request['password'] = passwordCont.text.trim();
    }

    await CoreServiceApis.createPatient(request: request).then((patient) {
      toast(locale.value.patientCreatedSuccessfully);
      Get.back(result: patient);
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      if (mounted) setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(locale.value.addPatient, style: boldTextStyle(size: 18)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              16.height,
              AppTextField(
                controller: firstNameCont,
                textFieldType: TextFieldType.NAME,
                textStyle: primaryTextStyle(size: 14),
                decoration: inputDecoration(
                  context,
                  hintText: locale.value.firstName,
                  fillColor: context.cardColor,
                  filled: true,
                ),
              ),
              12.height,
              AppTextField(
                controller: lastNameCont,
                textFieldType: TextFieldType.NAME,
                textStyle: primaryTextStyle(size: 14),
                decoration: inputDecoration(
                  context,
                  hintText: locale.value.lastName,
                  fillColor: context.cardColor,
                  filled: true,
                ),
              ),
              12.height,
              AppTextField(
                controller: emailCont,
                textFieldType: TextFieldType.EMAIL,
                textStyle: primaryTextStyle(size: 14),
                isValidationRequired: false,
                decoration: inputDecoration(
                  context,
                  hintText: '${locale.value.email} (${locale.value.optional})',
                  fillColor: context.cardColor,
                  filled: true,
                ),
              ),
              12.height,
              AppTextField(
                controller: mobileCont,
                textFieldType: TextFieldType.PHONE,
                textStyle: primaryTextStyle(size: 14),
                decoration: inputDecoration(
                  context,
                  hintText: locale.value.contactNumber,
                  fillColor: context.cardColor,
                  filled: true,
                ),
              ),
              12.height,
              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                decoration: inputDecoration(
                  context,
                  hintText: locale.value.gender,
                  fillColor: context.cardColor,
                  filled: true,
                ),
                items: [
                  DropdownMenuItem(value: 'male', child: Text(locale.value.male, style: primaryTextStyle(size: 14))),
                  DropdownMenuItem(value: 'female', child: Text(locale.value.female, style: primaryTextStyle(size: 14))),
                ],
                onChanged: (value) => setState(() => selectedGender = value),
              ),
              12.height,
              AppTextField(
                controller: passwordCont,
                textFieldType: TextFieldType.PASSWORD,
                textStyle: primaryTextStyle(size: 14),
                isValidationRequired: false,
                decoration: inputDecoration(
                  context,
                  hintText: '${locale.value.password} (${locale.value.optional})',
                  fillColor: context.cardColor,
                  filled: true,
                ),
              ),
              20.height,
              AppButton(
                width: Get.width,
                color: appColorPrimary,
                enabled: !isLoading,
                onTap: _submit,
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(locale.value.save, style: primaryTextStyle(color: white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the Add Patient dialog and returns the created [PatientModel] or null.
Future<PatientModel?> showAddPatientDialog(BuildContext context) async {
  return await showDialog<PatientModel>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AddPatientDialog(),
  );
}
