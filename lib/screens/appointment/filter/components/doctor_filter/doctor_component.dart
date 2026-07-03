import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/main.dart';
import 'package:bonkano_meet_pro/screens/doctor/model/doctor_list_res.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import '../../../../../components/cached_image_widget.dart';
import '../../../../../components/loader_widget.dart';
import '../../../../../utils/empty_error_state_widget.dart';
import '../../filter_controller.dart';
import '../../../../../generated/assets.dart';
import '../../../../../utils/common_base.dart';
import 'filter_search_doctor_component.dart';

class FilterDoctorComponent extends StatelessWidget {
  final FilterController filterCont = Get.put(FilterController());

  FilterDoctorComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        FilterSearchDoctorComponent(
          filterClinicController: filterCont,
          onFieldSubmitted: (p0) {
            hideKeyboard(context);
          },
        ).paddingSymmetric(horizontal: 16),
        12.height,
        Obx(
          () => SnapHelperWidget(
            future: filterCont.doctorsFuture.value,
            errorBuilder: (error) {
              return AnimatedScrollView(
                padding: const EdgeInsets.all(16),
                children: [
                  NoDataWidget(
                    title: error,
                    retryText: locale.value.reload,
                    imageWidget: const ErrorStateWidget(),
                    onRetry: () {
                      filterCont.doctorPage(1);
                      filterCont.getDoctorsList();
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 32);
            },
            loadingWidget: const LoaderWidget(),
            onSuccess: (data) {
              if (filterCont.doctors.isEmpty) {
                return AnimatedScrollView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    NoDataWidget(
                      title: locale.value.noClinicsFoundAtAMoment,
                      subTitle: locale.value.looksLikeThereIsNoClinicsWellKeepYouPostedWhe,
                      retryText: locale.value.reload,
                      imageWidget: const EmptyStateWidget(),
                      onRetry: () async {
                        filterCont.doctorPage(1);
                        filterCont.getDoctorsList();
                      },
                    ),
                  ],
                ).paddingSymmetric(horizontal: 32).visible(!filterCont.isDoctorLoading.value);
              } else {
                return Obx(
                  () => Stack(
                    children: [
                      AnimatedScrollView(
                        children: List.generate(filterCont.doctors.length, (index) {
                          Doctor doctor = filterCont.doctors[index];
                          return InkWell(
                            onTap: () {
                              filterCont.selectedDoctor(doctor);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(6),
                                  decoration: boxDecorationDefault(
                                    color: context.cardColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CachedImageWidget(
                                        url: doctor.profileImage,
                                        height: 75,
                                        width: 75,
                                        fit: BoxFit.cover,
                                        topLeftRadius: 6,
                                        bottomLeftRadius: 6,
                                      ),
                                      8.width,
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          8.height,
                                          Text(
                                            doctor.fullName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: primaryTextStyle(
                                              size: 12,
                                            ),
                                          ),
                                          6.height,
                                          Row(
                                            children: [
                                              Text(
                                                doctor.expert,
                                                style: secondaryTextStyle(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ).expand(),
                                            ],
                                          ),
                                          6.height,
                                        ],
                                      ).expand(),
                                      8.width,
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: commonLeadingWid(
                                    imgPath: Assets.imagesConfirm,
                                    color: whiteTextColor,
                                    size: 8,
                                  ).circularLightPrimaryBg(color: appColorPrimary, padding: 6),
                                ).visible(filterCont.selectedDoctor.value.id == doctor.id),
                              ],
                            ),
                          );
                        }),
                        onNextPage: () async {
                          if (!filterCont.isDoctorLoading.value) {
                            filterCont.doctorPage(filterCont.doctorPage.value + 1);
                            filterCont.getDoctor();
                          }
                        },
                        onSwipeRefresh: () async {
                          filterCont.doctorPage(1);
                          return await filterCont.getDoctorsList(showloader: false);
                        },
                      ),
                      if (filterCont.isDoctorLoading.isTrue) const LoaderWidget()
                    ],
                  ),
                );
              }
            },
          ),
        ).paddingOnly(bottom: 16 + MediaQuery.of(context).padding.bottom, left: 8, right: 8).expand(),
      ],
    );
  }
}
