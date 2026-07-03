import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/screens/doctor/doctor_session/add_session/add_session_screen.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import '../../../../components/cached_image_widget.dart';
import '../../../../generated/assets.dart';
import '../../../../main.dart';
import '../add_session/model/doctor_session_model.dart';

class DcotorSessionCard extends StatelessWidget {
  final DoctorSessionModel doctorSession;
  const DcotorSessionCard({super.key, required this.doctorSession});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadius.all(radiusCircular(6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorSession.fullName.toString(),
                style: boldTextStyle(
                  size: 16,
                ),
              ).expand(),
              IconButton(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Get.to(() => AddSessionScreen(), arguments: doctorSession);
                },
                icon: const CachedImageWidget(
                  url: Assets.iconsIcEditReview,
                  height: 18,
                  width: 18,
                ),
              )
              // 12.width,
              // const CachedImageWidget(
              //   url: Assets.iconsIcDelete,
              //   height: 14,
              //   width: 14,
              //   color: iconColor,
              // ),
            ],
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${locale.value.clinicName}: ',
                  style: primaryTextStyle(
                    color: dividerColor,
                  ),
                ),
                TextSpan(
                  text: doctorSession.clinicName.validate(),
                  style: boldTextStyle(
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
          4.height,
          Text(
            "S'applique à tous les services dans cette clinique",
            style: secondaryTextStyle(size: 10, color: textSecondaryColorGlobal),
          ),
          if (doctorSession.doctorSession.isNotEmpty) ...[
            8.height,
            const Divider(
              color: borderColor,
            ),
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CachedImageWidget(
                  url: Assets.iconsIcBriefcase,
                  height: 16,
                  width: 16,
                ),
                12.width,
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 1.0,
                  children: List.generate(doctorSession.doctorSession.length, (index) {
                    Map<String, String> dayTranslations = {'mon': 'Lun', 'tue': 'Mar', 'wed': 'Mer', 'thu': 'Jeu', 'fri': 'Ven', 'sat': 'Sam', 'sun': 'Dim'};
                    String rawDay = doctorSession.doctorSession[index].toLowerCase();
                    String translatedDay = dayTranslations[rawDay] ?? doctorSession.doctorSession[index].capitalizeFirst!;
                    return Text(
                      doctorSession.doctorSession.length - 1 == index ? translatedDay : "$translatedDay, ",
                      style: primaryTextStyle(size: 12, color: dividerColor, weight: FontWeight.w500),
                    );
                  }),
                ).expand(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
