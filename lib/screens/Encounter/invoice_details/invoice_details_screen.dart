import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/components/loader_widget.dart';
import 'package:bonkano_meet_pro/main.dart';
import 'package:bonkano_meet_pro/screens/Encounter/invoice_details/components/payment_component.dart';
import 'package:bonkano_meet_pro/screens/Encounter/invoice_details/invoice_details_controller.dart';
import 'package:bonkano_meet_pro/screens/Encounter/invoice_details/model/billing_details_resp.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import '../../../components/app_scaffold.dart';
import '../../../utils/common_base.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../generate_invoice/components/add_billing_item_component.dart';
import '../generate_invoice/components/add_final_discount_component.dart';
import 'components/billing_items_widget.dart';
import 'components/clinic_info_component.dart';
import 'components/invoice_component.dart';
import 'components/patient_detail_component.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  InvoiceDetailsScreen({super.key});

  final InvoiceDetailsController invoiceDetailsCon = Get.put(InvoiceDetailsController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.invoiceDetail,
      hasLeadingWidget: true,
      isBlurBackgroundinLoader: true,
      isLoading: invoiceDetailsCon.isLoading,
      appBarVerticalSize: Get.height * 0.12,
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () async {
            return await invoiceDetailsCon.getInvoiceDetail(showLoader: true);
          },
          child: SnapHelperWidget(
            future: invoiceDetailsCon.getInvoiceDetailFuture.value,
            initialData: invoiceDetailsCon.invoiceData.value.serviceName.isEmpty ? null : invoiceDetailsCon.invoiceData.value,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.value.reload,
                imageWidget: const ErrorStateWidget(),
                onRetry: () {
                  invoiceDetailsCon.getInvoiceDetail();
                },
              ).paddingSymmetric(horizontal: 24);
            },
            loadingWidget: invoiceDetailsCon.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (invoiceDetailData) {
              BillingDetailModel billingDetails = invoiceDetailData;
              if (invoiceDetailsCon.isLoading.value) {
                return const Offstage();
              } else {
                return AnimatedScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: locale.value.invoiceId,
                                style: primaryTextStyle(color: dividerColor, size: 14),
                              ),
                              TextSpan(
                                text: '  #${billingDetails.id}',
                                style: secondaryTextStyle(size: 14, weight: FontWeight.w600, color: appColorSecondary),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => SizedBox(
                            height: 26,
                            child: AppButton(
                              padding: EdgeInsets.zero,
                              textStyle: secondaryTextStyle(color: Colors.white),
                              shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
                              onTap: () {
                                invoiceDetailsCon.getClearBillingItem();
                                Get.bottomSheet(AddBillingItemComponent());
                              },
                              child: Text(locale.value.addBillingItem, style: primaryTextStyle(size: 14, color: white)).paddingSymmetric(horizontal: 8),
                            ),
                          ).visible(invoiceDetailsCon.isEditMode.value),
                        ),
                      ],
                    ).paddingAll(16),
                    InvoiceComponent(
                      title: locale.value.clinicInfo,
                      child: ClinicInfoComponent(
                        clinicData: billingDetails,
                      ),
                    ),
                    16.height,
                    InvoiceComponent(
                      title: locale.value.patientDetails,
                      child: PatientDetailComponent(
                        patientData: billingDetails,
                      ),
                    ),
                    16.height,
                    if (invoiceDetailsCon.billingItemList.isNotEmpty)
                      InvoiceComponent(
                        title: locale.value.services,
                        child: BillingItemsWidget(),
                      ),
                    if (invoiceDetailsCon.billingItemList.isNotEmpty)
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                if (billingDetails.totalAmount > 0) {
                                  invoiceDetailsCon.invoiceData.value.paymentStatus = 1;
                                  invoiceDetailsCon.invoiceData.refresh();
                                } else {
                                  toast(locale.value.pleaseAddService);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(locale.value.paid, style: primaryTextStyle(size: 12, color: dividerColor)).expand(),
                                    Icon(
                                      invoiceDetailsCon.invoiceData.value.paymentStatus == 1 ? Icons.radio_button_checked_outlined : Icons.radio_button_off_outlined,
                                      size: 20,
                                      color: invoiceDetailsCon.invoiceData.value.paymentStatus == 1 ? appColorPrimary : borderColor,
                                    ),
                                  ],
                                ),
                              ),
                            ).expand(),
                            10.width,
                            InkWell(
                              onTap: () {
                                invoiceDetailsCon.invoiceData.value.paymentStatus = 0;
                                invoiceDetailsCon.invoiceData.refresh();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderColor)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(locale.value.unpaid, style: primaryTextStyle(size: 12, color: dividerColor)).expand(),
                                    Icon(
                                      invoiceDetailsCon.invoiceData.value.paymentStatus == 0 ? Icons.radio_button_checked_outlined : Icons.radio_button_off_outlined,
                                      size: 20,
                                      color: invoiceDetailsCon.invoiceData.value.paymentStatus == 0 ? appColorPrimary : borderColor,
                                    ),
                                  ],
                                ),
                              ),
                            ).expand(),
                          ],
                        ).paddingSymmetric(horizontal: 16).paddingTop(16).visible(invoiceDetailsCon.isEditMode.value && invoiceDetailsCon.invoiceData.value.paymentStatus == 0),
                      ),
                    if (invoiceDetailsCon.billingItemList.isNotEmpty)
                      InvoiceComponent(
                        title: locale.value.payment,
                        trailingText: locale.value.addDiscount,
                        showSeeAll: invoiceDetailsCon.isEditMode.value,
                        onSeeAllTap: () {
                          invoiceDetailsCon.setFinalDiscountFormData();
                          Get.bottomSheet(AddFinalDiscountComponent(paymentData: billingDetails));
                        },
                        child: PaymentComponent(
                          paymentData: billingDetails,
                        ),
                      ),
                    Obx(() => invoiceDetailsCon.isEditMode.value ? 52.height : const Offstage())
                  ],
                );
              }
            },
          ),
        ),
      ),
      widgetsStackedOverBody: [
        Obx(
          () => invoiceDetailsCon.isEditMode.value &&
                  (!invoiceDetailsCon.invoiceData.value.serviceId.isNegative || invoiceDetailsCon.billingItemList.isNotEmpty) &&
                  invoiceDetailsCon.invoiceData.value.paymentStatus == 1 &&
                  invoiceDetailsCon.encounter.value.status
              ? Positioned(
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                  height: 50,
                  width: Get.width,
                  child: AppButton(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    width: Get.width,
                    text: locale.value.closeCheckoutEncounter,
                    color: appColorSecondary,
                    textStyle: appButtonTextStyleWhite,
                    shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
                    onTap: () {
                      invoiceDetailsCon.saveGenerateInvoice(showLoader: true);
                      invoiceDetailsCon.isEditMode.value = false;
                    },
                  ),
                )
              : const Offstage(),
        ),
      ],
    );
  }
}