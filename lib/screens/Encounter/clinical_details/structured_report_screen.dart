import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/components/app_scaffold.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/encounter/clinical_details/structured_report_controller.dart';
import 'package:bonkano_meet_pro/main.dart';
import 'package:bonkano_meet_pro/utils/common_base.dart';

class StructuredReportScreen extends StatelessWidget {
  final int encounterId;
  final String encounterType;

  const StructuredReportScreen({
    super.key,
    required this.encounterId,
    required this.encounterType,
  });

  Widget _buildFieldWidget(BuildContext context, Map section, StructuredReportController controller) {
    final String key = section['key']?.toString() ?? '';
    final String label = section['label']?.toString() ?? '';
    final String type = section['type']?.toString() ??
        ((key.contains('duree') || key.contains('date') || key.contains('eim') || key.contains('type'))
            ? 'text'
            : 'textarea');
    final String placeholder = section['placeholder']?.toString() ?? '';

    if (type == 'boolean') {
      return Obx(() {
        final bool isSelected = controller.formData[key] == true || controller.formData[key] == 1;
        return SwitchListTile(
          title: Text(label, style: primaryTextStyle()),
          value: isSelected,
          activeColor: context.primaryColor,
          onChanged: (val) {
            controller.updateField(key, val);
          },
        ).paddingBottom(16);
      });
    }

    if (type == 'select') {
      return Obx(() {
        final List<String> options = (section['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        final currentValue = controller.formData[key]?.toString();
        return DropdownButtonFormField<String>(
          decoration: inputDecoration(context, labelText: label),
          value: options.contains(currentValue) ? currentValue : null,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) {
            controller.updateField(key, val);
          },
        ).paddingBottom(16);
      });
    }

    return TextFormField(
      initialValue: controller.formData[key]?.toString() ?? '',
      key: ValueKey(key),
      decoration: inputDecoration(context, labelText: label).copyWith(
        hintText: placeholder.isNotEmpty ? placeholder : null,
      ),
      maxLines: type == 'textarea' ? 4 : 1,
      onChanged: (val) {
        controller.updateField(key, val);
      },
    ).paddingBottom(16);
  }

  @override
  Widget build(BuildContext context) {
    final StructuredReportController controller = Get.put(
      StructuredReportController(encounterId: encounterId, encounterType: encounterType),
    );

    return Obx(() {
      if (controller.isLoading.value && controller.reportSections.isEmpty) {
        return AppScaffoldNew(
          appBartitleText: encounterType.toUpperCase(),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final String title = controller.reportTypeLabel.value.isNotEmpty
          ? controller.reportTypeLabel.value
          : encounterType.toUpperCase();

      return AppScaffoldNew(
        appBartitleText: title,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: boldTextStyle(size: 18),
                  ),
                  16.height,
                  
                  // 1. Render general/default sections (no group)
                  ... (controller.groupedSections[''] ?? []).map((section) {
                    if (section is! Map) return const Offstage();
                    return _buildFieldWidget(context, section, controller);
                  }).toList(),

                  // 2. Render grouped sections under cards
                  ... controller.groups.map((groupName) {
                    final sectionsInGroup = controller.groupedSections[groupName] ?? [];
                    if (sectionsInGroup.isEmpty) return const Offstage();
                    return Card(
                      elevation: 1.5,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              groupName.toUpperCase(),
                              style: boldTextStyle(size: 14, color: context.primaryColor),
                            ).paddingBottom(12),
                            ... sectionsInGroup.map((section) {
                              if (section is! Map) return const Offstage();
                              return _buildFieldWidget(context, section, controller);
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  32.height,
                  AppButton(
                    onTap: () => controller.saveReport(),
                    text: locale.value.save,
                    textStyle: boldTextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 40 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
            if (controller.isLoading.value) const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    });
  }
}
