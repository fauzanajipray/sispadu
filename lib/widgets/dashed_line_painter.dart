import 'package:flutter/material.dart';

import '../constant/app_color.dart';

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColor.dividerColor // Warna garis
      ..strokeWidth = 1 // Ketebalan garis
      ..style = PaintingStyle.stroke;

    var maxWidth = size.width;
    var dashWidth = 2; // Panjang garis putus
    var dashSpace = 2; // Jarak antar garis putus
    double startX = 0;

    while (startX < maxWidth) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
