import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasicInput extends StatefulWidget {
  final String?                    label;
  final String?                    hintText;
  final bool                       isPassword;
  final TextEditingController?     controller;
  final TextInputType?             keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)?     onChanged;
  final void Function()?           onTap;
  final Widget?                    prefixIcon;
  final Widget?                    suffixIcon;
  final int?                       maxLines;
  final bool                       readOnly;
  final bool?                      isBorder;
  final double?                    radius;

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
    this.radius   = 14,
  });

  @override
  State<BasicInput> createState() => _BasicInputState();
}

class _BasicInputState extends State<BasicInput> {
  // FIX: was StatelessWidget — password toggle needs state
  bool _obscure = true;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final isDark     = theme.brightness == Brightness.dark;
    final primary    = theme.colorScheme.primary;
    final onSurface  = theme.colorScheme.onSurface;
    final fillColor  = isDark
        ? Colors.white.withOpacity(0.06)
        : primary.withOpacity(0.04);
    final borderColor = _isFocused
        ? primary
        : onSurface.withOpacity(0.15);

    // Effective suffix: custom OR password toggle OR nothing
    Widget? effectiveSuffix = widget.suffixIcon;
    if (widget.isPassword && widget.suffixIcon == null) {
      effectiveSuffix = GestureDetector(
        onTap: () => setState(() => _obscure = !_obscure),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            key:   ValueKey(_obscure),
            color: _isFocused ? primary : onSurface.withOpacity(0.4),
            size:  20.r,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize:        MainAxisSize.min,
      children: [
        // ── Optional label ─────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize:   12.sp,
              fontWeight: FontWeight.w600,
              color:      _isFocused
                  ? primary
                  : onSurface.withOpacity(0.6),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 6.h),
        ],

        // ── Input field ────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius!.r),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color:      primary.withOpacity(0.12),
                blurRadius: 12,
                offset:     const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: TextFormField(
            controller:    widget.controller,
            focusNode:     _focusNode,
            keyboardType:  widget.keyboardType,
            obscureText:   widget.isPassword ? _obscure : false,
            validator:     widget.validator,
            onChanged:     widget.onChanged,
            onTap:         widget.onTap,
            // FIX: password fields must be single line
            maxLines:      widget.isPassword ? 1 : widget.maxLines,
            readOnly:      widget.readOnly,
            style: TextStyle(
              fontSize:   14.sp,
              fontWeight: FontWeight.w500,
              color:      onSurface,
              height:     1.4,
            ),
            decoration: InputDecoration(
              hintText:    widget.hintText,
              hintStyle: TextStyle(
                fontSize:   13.sp,
                color:      onSurface.withOpacity(0.35),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon:        widget.prefixIcon,
              prefixIconColor:   _isFocused
                  ? primary
                  : onSurface.withOpacity(0.4),
              suffixIcon:        effectiveSuffix,
              filled:            true,
              fillColor:         fillColor,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 14.h),

              // No border
              border: widget.isBorder == false
                  ? OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(widget.radius!.r),
                borderSide: BorderSide.none,
              )
                  : OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(widget.radius!.r),
                borderSide: BorderSide(
                    color: borderColor, width: 1.5),
              ),

              enabledBorder: widget.isBorder == false
                  ? OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(widget.radius!.r),
                borderSide: BorderSide.none,
              )
                  : OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(widget.radius!.r),
                borderSide: BorderSide(
                    color: onSurface.withOpacity(0.15),
                    width: 1.5),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(widget.radius!.r),
                borderSide: BorderSide(color: primary, width: 2),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(widget.radius!.r),
                borderSide: BorderSide(
                    color: theme.colorScheme.error, width: 1.5),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(widget.radius!.r),
                borderSide: BorderSide(
                    color: theme.colorScheme.error, width: 2),
              ),

              errorStyle: TextStyle(
                fontSize:   11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}