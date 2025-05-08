import 'package:shadcn_flutter/shadcn_flutter.dart';

class GradientBorder extends ShapeBorder {
  final LinearGradient gradient;
  final double width;
  final BorderRadius borderRadius;

  const GradientBorder({
    required this.gradient,
    required this.width,
    required this.borderRadius,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect).deflate(width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..strokeWidth = width
          ..style = PaintingStyle.stroke;

    final outerRect = borderRadius.toRRect(rect);
    canvas.drawRRect(outerRect, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return GradientBorder(
      gradient: gradient,
      width: width * t,
      borderRadius: borderRadius * t,
    );
  }
}
