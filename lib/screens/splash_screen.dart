import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/generated/assets.dart';
import '../components/app_scaffold.dart';
import '../components/loader_widget.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../utils/empty_error_state_widget.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  final SplashScreenController splashController = Get.put(SplashScreenController());

  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideAppBar: true,
      scaffoldBackgroundColor: context.cardColor,
      body: Obx(
        () => SnapHelperWidget(
          future: splashController.appConfigsFuture.value,
          loadingWidget: splashController.isLoading.value ? const Offstage() : const LoaderWidget(),
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.value.reload,
              imageWidget: const ErrorStateWidget(),
              onRetry: () {
                splashController.getAppConfigurations();
              },
            ).visible(!splashController.isLoading.value);
          },
          onSuccess: (res) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    Assets.assetsAppLogo,
                    height: 150,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Positioned(
                  height: Get.height * 0.3,
                  bottom: 0,
                  child: const LoaderWidget(isBlurBackground: false, loaderColor: appColorPrimary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}