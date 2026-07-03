import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bonkano_meet_pro/utils/colors.dart';
import 'package:bonkano_meet_pro/utils/constants.dart';
import '../main.dart';

class ViewAllLabel extends StatelessWidget {
  final String label;
  final String? trailingText;
  final List? list;
  final VoidCallback? onTap;
  final int? labelSize;
  final bool isShowAll;
  final Color? trailingTextColor;
  final Color? labelTextColor;

  const ViewAllLabel({
    super.key,
    required this.label,
    this.onTap,
    this.labelSize,
    this.list,
    this.isShowAll = true,
    this.trailingText,
    this.trailingTextColor,
    this.labelTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: boldTextStyle(size: labelSize ?? Constants.labelTextSize, color: labelTextColor)),
        if (isShowAll)
          TextButton(
            onPressed: (list == null ? true : isViewAllVisible(list!))
                ? () {
                    onTap?.call();
                  }
                : null,
            child: (list == null ? true : isViewAllVisible(list!)) ? Text(trailingText ?? locale.value.viewAll, style: boldTextStyle(color: trailingTextColor ?? appColorSecondary, size: 14)) : const SizedBox(),
          )
        else
          46.height,
      ],
    );
  }
}

bool isViewAllVisible(List list) => list.length >= 4;
