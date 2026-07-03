import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/Encounter/generate_invoice/model/encounter_details_resp.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/price_widget.dart';

class ServicePriceWidget extends StatelessWidget {
  final ServiceDetails serviceDetails;
  const ServicePriceWidget({super.key, required this.serviceDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(serviceDetails.name, style: boldTextStyle(size: 14, weight: FontWeight.w600, color: isDarkMode.value ? null : darkGrayTextColor)),
          10.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(locale.value.price, style: primaryTextStyle(size: 12, color: dividerColor)).expand(),
              PriceWidget(
                price: serviceDetails.servicePriceData.serviceAmount,
                color: appColorPrimary,
                size: 14,
                isBoldText: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
