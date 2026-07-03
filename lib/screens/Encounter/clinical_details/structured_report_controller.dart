import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/api/core_apis.dart';
import 'package:nb_utils/nb_utils.dart';

class StructuredReportController extends GetxController {
  final int encounterId;
  final String encounterType;
  
  RxMap<String, dynamic> formData = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  
  RxString reportTypeLabel = ''.obs;
  RxList<dynamic> reportSections = <dynamic>[].obs;
  RxMap<String, List<dynamic>> groupedSections = <String, List<dynamic>>{}.obs;
  RxList<String> groups = <String>[].obs;

  StructuredReportController({required this.encounterId, required this.encounterType});

  @override
  void onInit() {
    super.onInit();
    loadReport();
  }

  Future<void> loadReport() async {
    isLoading(true);
    try {
      final response = await CoreServiceApis.getStructuredReport(encounterId);
      
      reportTypeLabel.value = response['type_label']?.toString() ?? '';
      reportSections.value = response['sections'] as List<dynamic>? ?? [];
      
      // Grouping logic
      final Map<String, List<dynamic>> tempGrouped = {};
      final List<String> tempGroups = [];
      
      for (var section in reportSections) {
        if (section is Map) {
          final String group = section['group']?.toString() ?? '';
          if (group.isNotEmpty && !tempGroups.contains(group)) {
            tempGroups.add(group);
          }
          if (!tempGrouped.containsKey(group)) {
            tempGrouped[group] = [];
          }
          tempGrouped[group]!.add(section);
        }
      }
      groupedSections.value = tempGrouped;
      groups.value = tempGroups;
      
      if (response['data'] != null && response['data'] is Map) {
        formData.value = Map<String, dynamic>.from(response['data']);
      } else {
        // Fallback: populate formData with keys and values from the sections list without forcefully stringifying
        final Map<String, dynamic> initialData = {};
        for (var section in reportSections) {
          if (section is Map) {
            final String? key = section['key']?.toString();
            if (key != null) {
              final dynamic val = section['value'];
              if (val is bool) {
                initialData[key] = val;
              } else if (val is num) {
                initialData[key] = val;
              } else {
                initialData[key] = val?.toString() ?? '';
              }
            }
          }
        }
        formData.value = initialData;
      }
    } catch (e) {
      toast("Erreur lors du chargement: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> saveReport() async {
    isLoading(true);
    try {
      final res = await CoreServiceApis.saveStructuredReport(
        encounterId: encounterId,
        request: formData,
      );
      if (res.status == true) {
        toast("Rapport enregistré avec succès");
      } else {
        toast(res.message);
      }
    } catch (e) {
      toast("Erreur de sauvegarde: $e");
    } finally {
      isLoading(false);
    }
  }

  void updateField(String key, dynamic value) {
    formData[key] = value;
  }
}
