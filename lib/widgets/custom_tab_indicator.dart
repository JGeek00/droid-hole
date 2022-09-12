import 'package:flutter/material.dart';

class CustomTabIndicatorPortrait extends BoxDecoration {
  final BoxPainter _painter;

  CustomTabIndicatorPortrait({required Color indicatorColor}) : _painter = _TabIndicatorPainterPortrait(indicatorColor);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _TabIndicatorPainterPortrait extends BoxPainter {
  final Paint _paint;
  final Color indicatorColor;

  _TabIndicatorPainterPortrait(this.indicatorColor)
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


class CustomTabIndicatorLandscape extends BoxDecoration {
  final BoxPainter _painter;

  CustomTabIndicatorLandscape({required Color indicatorColor}) : _painter = _TabIndicatorPainterLandscape(indicatorColor);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _TabIndicatorPainterLandscape extends BoxPainter {
  final Paint _paint;
  final Color indicatorColor;

  _TabIndicatorPainterLandscape(this.indicatorColor)
      : _paint = Paint()
          ..color = indicatorColor
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final double xPos = offset.dx + cfg.size!.width / 2;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(xPos - 144, 48, xPos + 144, 45),
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
      ),
      _paint,
    );
  }
}