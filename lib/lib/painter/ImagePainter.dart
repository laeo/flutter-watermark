import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:watersec/lib/watermark/watermark.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final String text;
  final TextStyle style;
  final int space;

  ImagePainter({this.image, this.text, this.style, this.space});

  @override
  void paint(Canvas canvas, Size size) {
    Watermark.draw(canvas, image, text, style, space, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
