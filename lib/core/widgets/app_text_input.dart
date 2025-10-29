import 'package:flutter/material.dart';

/// A reusable text input that matches the requested style:
/// - A label above the field
/// - An underline style (customizable color/width)
/// - Optional prefix/suffix widgets and validators
class AppTextInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLines;
  final TextStyle? labelStyle;
  final Color underlineColor;
  final double underlineWidth;

  const AppTextInput({
    Key? key,
    required this.label,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.labelStyle,
    this.underlineColor = Colors.black87,
    this.underlineWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveLabelStyle = labelStyle ??
        const TextStyle(
          color: Color(0xFF9CA3AF), // grey label like in the screenshot
          fontSize: 16,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: effectiveLabelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: underlineColor, width: underlineWidth),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: underlineWidth),
            ),
            border: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: underlineColor, width: underlineWidth),
            ),
          ),
        ),
      ],
    );
  }
}
