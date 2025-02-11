import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final Color? textColor;
  final Gradient? gradient;
  final Icon? icon;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isLoading; // Add isLoading parameter

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.textColor,
    this.gradient,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.isLoading = false, // Initialize isLoading to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ??
              const RadialGradient(
                center: Alignment(0.45, 0.22),
                radius: 0.77,
                colors: [Color(0xFF033B59), Color(0xFF012139)],
              ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
          onPressed:
              isLoading ? null : onPressed, // Disable button when loading
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.transparent, // Remove the default background color
            shadowColor: Colors.transparent, // Remove the default shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? Colors.white,
                    ),
                    strokeWidth: 2.0,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize ?? 18,
                        fontWeight: fontWeight ?? FontWeight.bold,
                        color: textColor ?? Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (icon != null) icon!,
                  ],
                ),
        ),
      ),
    );
  }
}
