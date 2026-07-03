import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/common_base.dart';
import '../../../../utils/constants.dart';
import '../../../service/model/service_list_model.dart';
import '../../invoice_details/invoice_details_controller.dart';
import '../model/billing_item_model.dart';
import 'billing_item_service_list_screen.dart';

class AddBillingItemComponent extends StatelessWidget {
  final int? index;
  final BillingItem? billingItem;

  AddBillingItemComponent({super.key, this.billingItem, this.index});

  final InvoiceDetailsController invoiceDetailsCon = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
      ),
      child: Form(
        key: invoiceDetailsCon.addBillFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                billingItem != null ? locale.value.editBillingItem : locale.value.addBillingItem,
                style: secondaryTextStyle(
                  size: 16,
                  weight: FontWeight.w600,
                  color: isDarkMode.value ? null : darkGrayTextColor,
                ),
              ),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: invoiceDetailsCon.servicesCont,
                focus: invoiceDetailsCon.servicesFocus,
                nextFocus: invoiceDetailsCon.priceFocus,
                textFieldType: TextFieldType.MULTILINE,
                minLines: 1,
                readOnly: true,
                onTap: () {
                  Get.to(() => BillingServicesListScreen(), arguments: invoiceDetailsCon.selectService.value)?.then((value) {
                    log('VALUE: ${value.runtimeType}');
                    if (value is ServiceElement) {
                      invoiceDetailsCon.selectService(value);
                      invoiceDetailsCon.servicesCont.text = invoiceDetailsCon.selectService.value.name;
                      invoiceDetailsCon.quantityCont.text = "1";

                      invoiceDetailsCon.serviceAmount.value = invoiceDetailsCon.selectService.value.assignDoctor.isNotEmpty
                          ? invoiceDetailsCon.selectService.value.assignDoctor.firstWhere((element) => element.doctorId == invoiceDetailsCon.invoiceData.value.doctorId).priceDetail
                              .servicePrice
                          : invoiceDetailsCon.selectService.value.charges;
                      invoiceDetailsCon.priceCont.text = invoiceDetailsCon.selectService.value.assignDoctor.isNotEmpty
                          ? invoiceDetailsCon.selectService.value.assignDoctor
                              .firstWhere((element) => element.doctorId == invoiceDetailsCon.invoiceData.value.doctorId)
                              .priceDetail
                              .serviceAmount
                              .toStringAsFixed(appCurrency.value.noOfDecimal)
                              .formatNumberWithComma(seperator: appCurrency.value.thousandSeparator)
                          : invoiceDetailsCon.selectService.value.charges.toString();

                      // B18: Pre-fill per-item discount from service defaults
                      if (invoiceDetailsCon.selectService.value.discountValue > 0) {
                        invoiceDetailsCon.itemDiscountCont.text = invoiceDetailsCon.selectService.value.discountValue.toString();
                        invoiceDetailsCon.itemDiscountType(invoiceDetailsCon.selectService.value.discountType.isNotEmpty
                            ? invoiceDetailsCon.selectService.value.discountType
                            : DiscountType.PERCENTAGE);
                      } else {
                        invoiceDetailsCon.itemDiscountCont.clear();
                        invoiceDetailsCon.itemDiscountType(DiscountType.PERCENTAGE);
                      }
                    }
                  });
                },
                decoration: inputDecoration(
                  context,
                  hintText: locale.value.selectService,
                  fillColor: context.cardColor,
                  filled: true,
                  suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: darkGray.withValues(alpha: 0.5)),
                ),
              ),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: invoiceDetailsCon.priceCont,
                textFieldType: TextFieldType.NUMBER,
                focus: invoiceDetailsCon.priceFocus,
                isValidationRequired: true,
                readOnly: true,
                decoration: inputDecoration(
                  context,
                  fillColor: context.cardColor,
                  filled: true,
                  hintText: locale.value.price,
                ),
              ),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(size: 12),
                controller: invoiceDetailsCon.quantityCont,
                textFieldType: TextFieldType.NUMBER,
                focus: invoiceDetailsCon.quantityFocus,
                isValidationRequired: true,
                decoration: inputDecoration(
                  context,
                  fillColor: context.cardColor,
                  filled: true,
                  hintText: locale.value.quantity,
                ),
              ),
              16.height,
              // B18: Per-item discount field
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      textStyle: primaryTextStyle(size: 12),
                      controller: invoiceDetailsCon.itemDiscountCont,
                      textFieldType: TextFieldType.NUMBER,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: locale.value.discount,
                      ),
                    ),
                  ),
                  8.width,
                  Obx(
                    () => DropdownButton<String>(
                      value: invoiceDetailsCon.itemDiscountType.value,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: DiscountType.PERCENTAGE, child: const Text('%')),
                        DropdownMenuItem(value: DiscountType.FIXED, child: Text(appCurrency.value.currencySymbol)),
                      ],
                      onChanged: (val) {
                        if (val != null) invoiceDetailsCon.itemDiscountType(val);
                      },
                    ),
                  ),
                ],
              ),
              16.height,
              AppButton(
                width: Get.width,
                text: locale.value.save,
                color: appColorSecondary,
                textStyle: appButtonTextStyleWhite,
                shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
                onTap: () {
                  if (invoiceDetailsCon.addBillFormKey.currentState!.validate()) {
                    Get.back();
                    invoiceDetailsCon.saveBillingItem(billingItem: billingItem, index: index ?? 0);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}