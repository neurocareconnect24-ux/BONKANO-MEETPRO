import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/components/loader_widget.dart';
import 'package:bonkano_meet_pro/generated/assets.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../appointment/appointment_detail.dart';
import '../../appointment/model/appointments_res_model.dart';
import '../model/notification_model.dart';
import 'notification_screen_controller.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationScreenController notificationScreenController = Get.put(NotificationScreenController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.notifications,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: notificationScreenController.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: notificationScreenController.getNotifications.value,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.value.reload,
                imageWidget: const ErrorStateWidget(),
                onRetry: () {
                  notificationScreenController.page(1);
                  notificationScreenController.isLoading(true);
                  notificationScreenController.init();
                },
              ).paddingSymmetric(horizontal: 32);
            },
            loadingWidget: notificationScreenController.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (notifications) {
              return AnimatedListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                physics: const AlwaysScrollableScrollPhysics(),
                emptyWidget: NoDataWidget(
                  title: locale.value.stayTunedNoNew,
                  subTitle: locale.value.noNewNotificationsAt,
                  titleTextStyle: primaryTextStyle(),
                  imageWidget: const EmptyStateWidget(),
                  retryText: locale.value.reload,
                  onRetry: () {
                    notificationScreenController.page(1);
                    notificationScreenController.isLoading(true);
                    notificationScreenController.init();
                  },
                ).paddingSymmetric(horizontal: 32).paddingBottom(Get.height * 0.1),
                itemBuilder: (context, index) {
                  NotificationData notification = notificationScreenController.notificationDetail[index];
                  return GestureDetector(
                    onTap: () async {
                      if (notification.data.notificationDetail.id > 0) {
                        await Get.to(
                          () => AppointmentDetail(),
                          arguments: AppointmentData(id: notification.data.notificationDetail.id, notificationId: notification.id),
                        );
                        notificationScreenController.page(1);
                        notificationScreenController.init();
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      decoration: notification.readAt.trim().isEmpty
                          ? boxDecorationDefault(color: isDarkMode.value ? const Color.fromARGB(40, 78, 112, 247) : lightPrimaryColor)
                          : boxDecorationDefault(color: context.cardColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          8.height,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: boxDecorationDefault(color: isDarkMode.value ? canvasColor : lightPrimaryColor, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: CachedImageWidget(
                                  url: Assets.assetsAppLogo,
                                  height: 20,
                                  width: 20,
                                  firstName: "#${notification.data.notificationDetail.id}",
                                  fit: BoxFit.cover,
                                  color: appColorPrimary,
                                  circle: true,
                                ),
                              ),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getAppointmentNotification(notification: notification.data.notificationDetail.type),
                                    style: secondaryTextStyle(size: 14),
                                  ).visible(notification.data.notificationDetail.type.isNotEmpty),
                                  4.height,
                                  RichText(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(text: '#${notification.data.notificationDetail.id}', style: primaryTextStyle(color: appColorSecondary, size: 12, decoration: TextDecoration.none)),
                                        TextSpan(
                                            text:
                                                ' - ${notification.data.notificationDetail.notificationMsg.trim().isNotEmpty ? notification.data.notificationDetail.notificationMsg : notification.data.notificationDetail.appointmentServicesNames}',
                                            style: primaryTextStyle(size: 12)),
                                      ],
                                    ),
                                  ),
                                  4.height,
                                  Text(
                                    notification.createdAt.dateInyyyyMMddHHmmFormat.timeAgoWithLocalization,
                                    style: secondaryTextStyle(),
                                  ),
                                ],
                              ).flexible(),
                            ],
                          ),
                          16.height,
                        ],
                      ).paddingSymmetric(horizontal: 16),
                    ),
                  ).paddingBottom(16);
                },
                onNextPage: () async {
                  if (!notificationScreenController.isLastPage.value) {
                    notificationScreenController.page(notificationScreenController.page.value + 1);
                    notificationScreenController.isLoading(true);
                    notificationScreenController.init();
                    return await Future.delayed(const Duration(seconds: 2), () {
                      notificationScreenController.isLoading(false);
                    });
                  }
                },
                onSwipeRefresh: () async {
                  notificationScreenController.page(1);
                  return await notificationScreenController.init();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}