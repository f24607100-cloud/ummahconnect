import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 15.0,
    this.color,
    this.borderColor,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final finalBgColor = color ?? (isDark 
        ? AppColors.glassBackgroundDark 
        : AppColors.glassBackgroundLight);
        
    final finalBorderColor = borderColor ?? (isDark 
        ? AppColors.glassBorderDark 
        : AppColors.glassBorderLight);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: finalBgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: finalBorderColor,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
