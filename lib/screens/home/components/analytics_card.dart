import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/colors.dart';

class AnalyticsCard extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String countText;
  final String icon;
  const AnalyticsCard({
    super.key,
    this.onTap,
    required this.title,
    required this.countText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(color: context.cardColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Marquee(
                  child: Text(countText, style: boldTextStyle(color: appColorSecondary, size: 24)),
                ).expand(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: boxDecorationDefault(color: isDarkMode.value ? Colors.grey.withValues(alpha: 0.05) : extraLightPrimaryColor, shape: BoxShape.circle),
                  child: CachedImageWidget(
                    url: icon,
                    height: 18,
                    width: 18,
                    color: appColorPrimary,
                  ),
                )
              ],
            ),
            24.height,
            Text(title, style: primaryTextStyle()).fit(),
          ],
        ),
      ),
    );
  }
}