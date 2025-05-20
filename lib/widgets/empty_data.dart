import 'package:flutter/material.dart';

import 'ui_text.dart';

Widget emptyData(BuildContext context, [String? msg]) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xff5b5b5b).withOpacity(.2),
          borderRadius: BorderRadius.circular(48),
        ),
        child: const Icon(
          Icons.dns_rounded,
          color: Color(0xff5b5b5b),
          size: 32,
        ),
      ),
      Center(
        child: UiText(
          text: msg ?? 'Data not found',
        ),
      ),
    ],
  );
}
