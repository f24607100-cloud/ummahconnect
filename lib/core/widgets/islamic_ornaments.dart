import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class IslamicDivider extends StatelessWidget {
  final double width;
  final Color? color;

  const IslamicDivider({
    Key? key,
    this.width = 120.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;
    return CustomPaint(
      size: Size(width, 24),
      painter: _IslamicDividerPainter(color: themeColor),
    );
  }
}

class _IslamicDividerPainter extends CustomPainter {
  final Color color;

  _IslamicDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 6.0;

    // Draw central star (8-pointed Islamic Star)
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle1 = i * math.pi / 4;
      final x1 = center.dx + radius * math.cos(angle1);
      final y1 = center.dy + radius * math.sin(angle1);

      final angle2 = (i * math.pi / 4) + (math.pi / 8);
      final x2 = center.dx + (radius / 1.7) * math.cos(angle2);
      final y2 = center.dy + (radius / 1.7) * math.sin(angle2);

      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();

    // Fill star with gold if primary is green
    final fillPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Draw lateral decorative lines
    final lineLength = (size.width - 24) / 2;
    
    // Left side
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(lineLength - 4, center.dy),
      paint,
    );
    canvas.drawCircle(Offset(lineLength, center.dy), 1.5, fillPaint);

    // Right side
    canvas.drawLine(
      Offset(size.width - lineLength + 4, center.dy),
      Offset(size.width, center.dy),
      paint,
    );
    canvas.drawCircle(Offset(size.width - lineLength, center.dy), 1.5, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IslamicArchPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  IslamicArchPainter({
    required this.color,
    this.isFilled = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    
    // Start bottom left
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.4);
    
    // Draw beautiful Mihrab arch curve
    // Left shoulder curve
    path.cubicTo(
      0, size.height * 0.2, 
      size.width * 0.15, size.height * 0.12, 
      size.width * 0.35, size.height * 0.08,
    );
    
    // Peak curve (pointed arch)
    path.cubicTo(
      size.width * 0.45, size.height * 0.06,
      size.width * 0.5, 0,
      size.width * 0.5, 0,
    );
    
    path.cubicTo(
      size.width * 0.5, 0,
      size.width * 0.55, size.height * 0.06,
      size.width * 0.65, size.height * 0.08,
    );
    
    // Right shoulder curve
    path.cubicTo(
      size.width * 0.85, size.height * 0.12,
      size.width, size.height * 0.2,
      size.width, size.height * 0.4,
    );
    
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicArchPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isFilled != isFilled;
  }
}

class IslamicPatternDecoration extends StatelessWidget {
  final Widget child;

  const IslamicPatternDecoration({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final archColor = isDark 
        ? AppColors.darkPrimary.withOpacity(0.04)
        : AppColors.lightPrimary.withOpacity(0.02);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicArchPainter(
              color: archColor,
              isFilled: true,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
