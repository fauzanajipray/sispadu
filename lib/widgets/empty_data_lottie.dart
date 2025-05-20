import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sispadu/helpers/helpers.dart';

Widget emptyDataLottie(BuildContext context, {String? msg}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        // height: 500,
        child: Center(
          child: Lottie.asset('assets/lottie/empty_data.json',
              reverse: true, alignment: Alignment.center),
        ),
      ),
      if (msg != null)
        Text(
          capitalizeEach(msg),
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.primary),
        )
    ],
  );
}
