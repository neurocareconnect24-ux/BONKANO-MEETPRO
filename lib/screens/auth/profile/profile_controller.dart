// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/auth_apis.dart';
import '../../../utils/app_common.dart';
import '../sign_in_sign_up/signin_screen.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    getAboutPageData();
  }

  handleLogout() async {
    if (isLoading.value) return;
    isLoading(true);
    log('HANDLELOGOUT: called');
    await AuthServiceApis.logoutApi().then((value) {
      isLoading(false);
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      AuthServiceApis.clearData();
      isLoading(false);
      Get.offAll(() => SignInScreen());
    });
  }

  ///Get About Pages
  getAboutPageData({bool isFromSwipeRefresh = false}) {
    if (!isFromSwipeRefresh) {
      isLoading(true);
    }
    isLoading(true);
    AuthServiceApis.getAboutPageData().then((value) {
      isLoading(false);
      aboutPages(value.data);
    }).onError((error, stackTrace) {
      isLoading(false);
      toast(error.toString());
    });
  }
}
