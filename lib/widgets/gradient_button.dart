import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final Gradient? gradient;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.gradient,
    this.height = 54,
    this.width,
    this.borderRadius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : (gradient ?? AppColors.primaryGradient),
        color: onPressed == null ? Colors.grey.shade400 : null,
        borderRadius: effectiveRadius,
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : child ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        if (text != null)
                          Text(
                            text!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
