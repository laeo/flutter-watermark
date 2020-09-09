import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

class Watermark {
  Watermark.draw(Canvas canvas, ui.Image image, String text, TextStyle style,
      int padding, Size size) {
    // 计算四边形的对角线长度
    double dimension =
        math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2));

    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: image,
        fit: BoxFit.cover);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..blendMode = BlendMode.multiply);

    // 完整覆盖下的正方形面积
    double rectSize = math.pow(dimension, 2);
    // 根据面积与字符大小计算文本重复次数
    int textRepeating =
        ((rectSize / math.pow(style.fontSize, 2)) / (text.length + padding))
            .round(); // text.length + 1 是因为要添加个空格字符

    math.Point pivotPoint = math.Point(dimension / 2, dimension / 2);
    canvas.translate(pivotPoint.x, pivotPoint.y);
    canvas.rotate(-45 * math.pi / 180);
    canvas.translate(
        -pivotPoint.distanceTo(math.Point(0, size.height)),
        -pivotPoint.distanceTo(
            math.Point(0, 0))); // 计算文本区域起始坐标分别到图片左侧顶部与底部的距离，作为文本区域移动的距离。

    var textPainter = TextPainter(
      text: TextSpan(
          text: (text.padRight(text.length + padding)) * textRepeating,
          style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
    );
    textPainter.layout(maxWidth: dimension);
    textPainter.paint(canvas, Offset.zero);

    canvas.restore();
  }
}
