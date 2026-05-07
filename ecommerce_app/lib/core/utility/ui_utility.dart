import 'package:ecommerce_app/services/company_info/company_info_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared UI utilities — mix into any widget class:
///   class _MyWidgetState extends State<MyWidget> with UiUtility { ... }
///   class MyStatelessWidget extends StatelessWidget with UiUtility { ... }
mixin UiUtility {

  // ════════════════════════════════════════════════════════════════
  // COLOR HELPERS
  // ════════════════════════════════════════════════════════════════

  /// Parse a hex string like '#1D5D9B' → Color.
  /// Falls back to [fallback] if [hex] is null or malformed.
  Color hexColor(String? hex, [String fallback = '#1D5D9B']) {
    try {
      final raw = (hex?.isNotEmpty == true ? hex! : fallback)
          .replaceAll('#', '');
      return Color(int.parse('FF$raw', radix: 16));
    } catch (_) {
      final raw = fallback.replaceAll('#', '');
      return Color(int.parse('FF$raw', radix: 16));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // COMPANY INFO — extract a typed color bundle from any cubit state
  // ════════════════════════════════════════════════════════════════

  /// Returns a [CompanyColors] bundle from a [CompanyInfoState].
  /// Falls back to sensible defaults when state is not yet loaded.
  CompanyColors companyColors(CompanyInfoState state) {
    final company = state is CompanyInfoLoaded
        ? state.company.company
        : state is CompanyInfoUpdated
        ? state.company.company
        : null;

    return CompanyColors(
      main:        hexColor(company?.mainColor,       '#1D5D9B'),
      sub:         hexColor(company?.subColor,        '#1D5D9B'),
      button:      hexColor(company?.buttonColor,     '#1D5D9B'),
      buttonText:  hexColor(company?.buttonTextColor, '#FFFFFF'),
      text:        hexColor(company?.textColor,       '#1A1A2E'),
      hint:        hexColor(company?.hintColor,       '#9E9E9E'),
      card:        hexColor(company?.cardColor,       '#F5F5F5'),
      label:       hexColor(company?.labelColor,      '#1A1A2E'),
      textField:   hexColor(company?.textFiledColor,  '#F5F5F5'),
      icon:        hexColor(company?.iconColor,       '#1D5D9B'),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // THEME BUILDER
  // ════════════════════════════════════════════════════════════════

  /// Builds a full [ThemeData] from a [CompanyColors] bundle.
  ThemeData buildTheme(CompanyColors c, {Brightness brightness = Brightness.light}) {
    return ThemeData(
      useMaterial3: true,
      brightness:   brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor:  c.main,
        brightness: brightness,
        primary:    c.main,
        secondary:  c.sub,
        surface:    c.card,
      ),
      scaffoldBackgroundColor: c.card,
      appBarTheme: AppBarTheme(
        backgroundColor: c.main,
        foregroundColor: c.buttonText,
        iconTheme: IconThemeData(color: c.icon),
        titleTextStyle: TextStyle(
          color:      c.buttonText,
          fontSize:   18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.button,
          foregroundColor: c.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.button,
          side: BorderSide(color: c.button),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.button),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: c.textField,
        hintStyle:  TextStyle(color: c.hint),
        labelStyle: TextStyle(color: c.label),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.sub),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.sub),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.main, width: 2),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge:   TextStyle(color: c.text),
        bodyMedium:  TextStyle(color: c.text),
        bodySmall:   TextStyle(color: c.text),
        labelLarge:  TextStyle(color: c.label),
        labelMedium: TextStyle(color: c.label),
        titleLarge:  TextStyle(color: c.text),
        titleMedium: TextStyle(color: c.text),
      ),
      iconTheme: IconThemeData(color: c.icon),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ════════════════════════════════════════════════════════════════

  /// A small field label above form inputs.
  Widget fieldLabel(String text, Color color) =>
      _FieldLabel(text: text, color: color);

  /// A decorative blurred circle used as a background blob.
  Widget blob({required double size, required Color color}) =>
      _Blob(size: size, color: color);

  /// A full-width primary action button that shows a spinner while [loading].
  Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    bool loading = false,
    double height = 54,
    double radius = 14,
  }) =>
      _PrimaryButton(
        label:           label,
        onPressed:       onPressed,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        loading:         loading,
        height:          height,
        radius:          radius,
      );

  /// A branded form card container (white/surface rounded card).
  Widget formCard({
    required Widget child,
    required Color surfaceColor,
    required Color shadowColor,
    double padding = 24,
    double radius  = 24,
  }) =>
      _FormCard(
        child:        child,
        surfaceColor: surfaceColor,
        shadowColor:  shadowColor,
        padding:      padding,
        radius:       radius,
      );

  /// Decorative background blobs positioned in a [Stack].
  /// Returns a list of [Positioned] widgets — spread them into Stack.children.
  List<Widget> backgroundBlobs(Color primary) => [
    Positioned(
      top:   -80.r,
      right: -60.r,
      child: blob(size: 260.r, color: primary.withOpacity(0.12)),
    ),
    Positioned(
      top:   60.r,
      right: 40.r,
      child: blob(size: 100.r, color: primary.withOpacity(0.07)),
    ),
    Positioned(
      bottom: -100.r,
      left:   -80.r,
      child: blob(size: 300.r, color: primary.withOpacity(0.08)),
    ),
  ];
}


// ════════════════════════════════════════════════════════════════════════════
// DATA CLASS
// ════════════════════════════════════════════════════════════════════════════

/// Strongly-typed color bundle extracted from company info.
class CompanyColors {
  final Color main;
  final Color sub;
  final Color button;
  final Color buttonText;
  final Color text;
  final Color hint;
  final Color card;
  final Color label;
  final Color textField;
  final Color icon;

  const CompanyColors({
    required this.main,
    required this.sub,
    required this.button,
    required this.buttonText,
    required this.text,
    required this.hint,
    required this.card,
    required this.label,
    required this.textField,
    required this.icon,
  });
}


// ════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGET IMPLEMENTATIONS
// ════════════════════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color  color;
  const _FieldLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize:      13.sp,
        fontWeight:    FontWeight.w600,
        color:         color,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color  color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String        label;
  final VoidCallback? onPressed;
  final Color         backgroundColor;
  final Color         foregroundColor;
  final bool          loading;
  final double        height;
  final double        radius;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.loading,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: height.h,
      child: loading
          ? Center(
        child: CircularProgressIndicator(
          color:       backgroundColor,
          strokeWidth: 2.5,
        ),
      )
          : ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:      16.sp,
            fontWeight:    FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  final Color  surfaceColor;
  final Color  shadowColor;
  final double padding;
  final double radius;

  const _FormCard({
    required this.child,
    required this.surfaceColor,
    required this.shadowColor,
    required this.padding,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding.r),
      decoration: BoxDecoration(
        color:        surfaceColor,
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            color:      shadowColor.withOpacity(0.06),
            blurRadius: 32,
            offset:     const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}