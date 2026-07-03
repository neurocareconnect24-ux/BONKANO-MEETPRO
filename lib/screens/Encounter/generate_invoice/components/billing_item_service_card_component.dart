import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../components/cached_image_widget.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/colors.dart';
import '../../../service/model/service_list_model.dart';
import 'billing_service_list_controller.dart';

class BillingSelectServiceCardComponent extends StatelessWidget {
  final ServiceElement serviceData;
  BillingSelectServiceCardComponent({super.key, required this.serviceData});

  final BillingServicesController serviceListCont = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          serviceListCont.singleServiceSelect(serviceData);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: boxDecorationDefault(
            borderRadius: BorderRadius.circular(6),
            color: context.cardColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedImageWidget(
                url: serviceData.serviceImage,
                width: 52,
                radius: 6,
                fit: BoxFit.cover,
                height: 52,
              ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(serviceData.name.toString(), style: boldTextStyle(size: 14, color: isDarkMode.value ? null : darkGrayTextColor)),
                  2.height,
                  Text(serviceData.description.toString(), style: primaryTextStyle(size: 12, color: dividerColor)),
                ],
              ).expand(),
              12.width,
              Obx(
                () => Radio(
                  value: serviceData.id,
                  groupValue: serviceListCont.singleServiceSelect.value.id,
                  onChanged: (val) {
                    serviceListCont.singleServiceSelect(serviceData);
                  },
                  activeColor: appColorPrimary,
                  visualDensity: VisualDensity.compact,
                  toggleable: true, // Optional: Allows deselecting the radio button if required.
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
