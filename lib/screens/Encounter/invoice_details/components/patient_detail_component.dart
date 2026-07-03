import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/Encounter/invoice_details/model/billing_details_resp.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import 'package:bonkano_meet_pro/utils/common_base.dart';
import '../../../../components/cached_image_widget.dart';
import '../../../../generated/assets.dart';
import '../../../../utils/app_common.dart';

class PatientDetailComponent extends StatelessWidget {
  final BillingDetailModel patientData;
  const PatientDetailComponent({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            patientData.userName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: boldTextStyle(
              size: 14,
              weight: FontWeight.w600,
              color: isDarkMode.value ? null : darkGrayTextColor,
            ),
          ),
          8.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CachedImageWidget(
                url: Assets.iconsIcUser,
                height: 14,
                width: 14,
                color: iconColor,
              ),
              14.width,
              Text(
                patientData.userGender.capitalizeFirst!,
                style: secondaryTextStyle(
                  size: 12,
                  color: dividerColor,
                ),
              ),
            ],
          ),
          8.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CachedImageWidget(
                url: Assets.iconsIcCalendar,
                height: 14,
                width: 14,
                color: iconColor,
              ),
              12.width,
              Text(
                patientData.userDob.toString().dateInDMMMMyyyyFormat,
                style: secondaryTextStyle(
                  size: 12,
                  color: dividerColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
