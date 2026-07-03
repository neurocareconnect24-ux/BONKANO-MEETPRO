import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/doctor/doctor_session/add_session/add_session_controller.dart';
import 'package:bonkano_meet_pro/screens/service/model/service_list_model.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import '../../../../../main.dart';
import '../../../../../utils/colors.dart';

class ServiceNameComponent extends StatelessWidget {
  ServiceNameComponent({super.key});
  final AddSessionController addSessionCont = Get.put(AddSessionController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => addSessionCont.serviceList.isEmpty
          ? const SizedBox.shrink()
          : Container(
              height: 48.0,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: boxDecorationDefault(
                color: context.cardColor,
                borderRadius: BorderRadius.all(radiusCircular(6)),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ServiceElement>(
                  isExpanded: true,
                  value: addSessionCont.serviceList.contains(addSessionCont.selectServiceData.value) 
                      ? addSessionCont.selectServiceData.value 
                      : addSessionCont.serviceList.first,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    size: 16,
                    color: appBodyColor,
                  ),
                  onChanged: (ServiceElement? newValue) {
                    if (newValue != null) {
                      addSessionCont.selectServiceData(newValue);
                      addSessionCont.getDoctorSessionList();
                    }
                  },
                  items: addSessionCont.serviceList.map<DropdownMenuItem<ServiceElement>>((ServiceElement service) {
                    return DropdownMenuItem<ServiceElement>(
                      value: service,
                      child: Text(
                        service.name,
                        style: secondaryTextStyle(
                          size: 12,
                          color: isDarkMode.value ? null : blackColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ).paddingBottom(16),
    );
  }
}
