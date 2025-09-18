import 'package:ecommerce_app/constants/text_styles.dart';
import 'package:flutter/material.dart';

class BasicInput extends StatelessWidget {
  final String? label, hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Widget? prefixIcon, suffixIcon;
  final int? maxLines;
  final bool readOnly;
  final bool? isBorder;
  final double? radius;
  const BasicInput({
    super.key,
    this.label,
    this.hintText,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.isBorder = true,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? true : false,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelStyle: AppTextStyles.caption(context),
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: isBorder == true
            ? OutlineInputBorder(borderRadius: BorderRadius.circular(radius!))
            : InputBorder.none,
      ),
    );
  }
}
