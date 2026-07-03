import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../../utils/view_all_label_component.dart';

class HomeComponent extends StatelessWidget {
  final String title;

  final bool showSeeAll;

  final Widget child;

  final Function()? onSeeAllTap;

  const HomeComponent({super.key, this.title = '', this.showSeeAll = false, required this.child, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ViewAllLabel(
          label: title,
          trailingText: locale.value.viewAll,
          isShowAll: showSeeAll,
          onTap: onSeeAllTap,
        ).paddingOnly(left: 16, right: 8),
        child.paddingSymmetric(horizontal: 16)
      ],
    ).paddingTop(16);
  }
}
