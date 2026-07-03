import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/Encounter/generate_invoice/model/encounter_details_resp.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';

import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/price_widget.dart';

class FinalAmountWidget extends StatelessWidget {
  final ServiceDetails serviceDetails;
  const FinalAmountWidget({super.key, required this.serviceDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(locale.value.servicePrice, style: primaryTextStyle(size: 12, color: dividerColor)).expand(),
            PriceWidget(
              price: serviceDetails.servicePriceData.servicePrice,
              color: isDarkMode.value ? null : darkGrayTextColor,
              size: 12,
              isBoldText: true,
            ),
          ],
        ),
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(locale.value.discountAmount, style: primaryTextStyle(size: 12, color: dividerColor)).expand(),
            PriceWidget(
              price: num.parse(serviceDetails.servicePriceData.discountAmount.toString()).toStringAsFixed(Constants.DECIMAL_POINT).toDouble(),
              color: isDarkMode.value ? null : darkGrayTextColor,
              size: 12,
              isBoldText: true,
            ),
          ],
        ),
        8.height,
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: serviceDetails.taxData.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(serviceDetails.taxData[index].title, style: primaryTextStyle(size: 12, color: dividerColor)).expand(),
                PriceWidget(
                  price: serviceDetails.taxData[index].amount,
                  color: isDarkMode.value ? null : darkGrayTextColor,
                  size: 12,
                  isBoldText: true,
                ),
              ],
            ).paddingBottom(8);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(locale.value.totalPayableAmountWithTax, style: primaryTextStyle(size: 12, color: isDarkMode.value ? null : darkGrayTextColor)).expand(),
            PriceWidget(
              price: serviceDetails.servicePriceData.totalAmount,
              color: appColorPrimary,
              size: 14,
              isBoldText: true,
            ),
          ],
        ),
        8.height,
      ],
    );
  }
}
