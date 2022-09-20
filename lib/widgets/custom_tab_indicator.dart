import 'package:flutter/material.dart';

class CustomTabIndicatorPortrait extends BoxDecoration {
  final BoxPainter _painter;

  CustomTabIndicatorPortrait({
    required Color indicatorColor,
    required int itemsTabBar,
  }) : _painter = _TabIndicatorPainterPortrait(indicatorColor, itemsTabBar);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _TabIndicatorPainterPortrait extends BoxPainter {
  final Paint _paint;
  final Color indicatorColor;
  final int itemsTabBar;

  _TabIndicatorPainterPortrait(this.indicatorColor, this.itemsTabBar)
      : _paint = Paint()
          ..color = indicatorColor
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final double xPos = offset.dx + cfg.size!.width / 2;

    Rect getRect(int nItems) {
      switch (nItems) {
        case 2:
          return Rect.fromLTRB(xPos - 102, 71, xPos + 102, 74);

        case 3:
        default:
          return Rect.fromLTRB(xPos - 68, 71, xPos + 68, 74);
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        getRect(itemsTabBar),
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
      ),
      _paint,
    );
  }
}


class CustomTabIndicatorLandscape extends BoxDecoration {
  final BoxPainter _painter;

  CustomTabIndicatorLandscape({
    required Color indicatorColor,
    required int itemsTabBar,
  }) : _painter = _TabIndicatorPainterLandscape(indicatorColor, itemsTabBar);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _TabIndicatorPainterLandscape extends BoxPainter {
  final Paint _paint;
  final Color indicatorColor;
  final int itemsTabBar;

  _TabIndicatorPainterLandscape(this.indicatorColor, this.itemsTabBar)
      : _paint = Paint()
          ..color = indicatorColor
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final double xPos = offset.dx + cfg.size!.width / 2;

    Rect getRect(int nItems) {
      switch (nItems) {
        case 2:
          return Rect.fromLTRB(xPos - 217, 48, xPos + 217, 45);

        case 3:
        default:
          return Rect.fromLTRB(xPos - 144, 48, xPos + 144, 45);
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        getRect(itemsTabBar),
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
      ),
      _paint,
    );
  }
}