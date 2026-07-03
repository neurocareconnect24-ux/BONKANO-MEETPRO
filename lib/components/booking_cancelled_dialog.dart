import 'package:flutter/material.dart';
import 'package:bonkano_meet_pro/generated/assets.dart';
import 'package:bonkano_meet_pro/main.dart';
import 'package:bonkano_meet_pro/screens/appointment/model/appointments_res_model.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingCancelledDialog extends StatefulWidget {
  final AppointmentData status;
  final String? currentStatus;

  const BookingCancelledDialog({super.key, required this.status, this.currentStatus});

  @override
  State<BookingCancelledDialog> createState() => _BookingCancelledDialogState();
}

class _BookingCancelledDialogState extends State<BookingCancelledDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: context.width(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    16.height,
                    Image.asset(Assets.iconsIcCheck, height: 62),
                    32.height,
                    Text(locale.value.yourAppointmentHasBeenSuccessfullyCancelled, style: boldTextStyle(size: 16)),
                    8.height,
                    Text(locale.value.appointmentRefundWillBeProcessedWithingHoursIfApplicable, textAlign: TextAlign.center, style: primaryTextStyle(size: 12, color: textSecondaryColor)),
                    32.height,
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: boxDecorationDefault(
                        color: appColorSecondary.withValues(alpha: 0.1),
                        border: Border.all(color: appColorSecondary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        locale.value.noteCheckYourAppointmentHistoryForRefundDetailsIfApplicable,
                        style: boldTextStyle(color: appColorSecondary, size: 12),
                      ),
                    ),
                    24.height,
                    AppButton(
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
                      color: appColorSecondary,
                      height: 40,
                      text: locale.value.ok,
                      textStyle: boldTextStyle(color: Colors.white, weight: FontWeight.w600, size: 12),
                      width: context.width() - context.navigationBarHeight,
                      onTap: () {
                        finish(context, true);
                      },
                    ).paddingSymmetric(horizontal: 100),
                    8.height,
                  ],
                ).paddingAll(16)
              ],
            ),
          ),
        ),
        // Obx(
        //         () => LoaderWidget().withSize(height: 80, width: 80)//.visible(appStore.isLoading),
        // )
      ],
    );
  }
}