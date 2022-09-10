import 'package:flutter/material.dart';

class CustomTabIndicator extends BoxDecoration {
  final BoxPainter _painter;

  CustomTabIndicator({required Color indicatorColor}) : _painter = _TabIndicatorPainter(indicatorColor);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _TabIndicatorPainter extends BoxPainter {
  final Paint _paint;
  final Color indicatorColor;

  _TabIndicatorPainter(this.indicatorColor)
      : _paint = Paint()
          ..color = indicatorColor
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final double xPos = offset.dx + cfg.size!.width / 2;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(xPos - 68, 71, xPos + 68, 74),
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
      ),
      _paint,
    );
  }
}