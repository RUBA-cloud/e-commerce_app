import 'package:ecommerce_app/constants/colors.dart';
import 'package:flutter/material.dart';

BoxDecoration setBoxDecoration({
  required Color color,
  BoxShape boxShape = BoxShape.rectangle,
  double radius = 12,
  double opacity = 0.08,
  Border? border,  List<BoxShadow>? boxShadow,
}) {
  return BoxDecoration(
    // ignore: deprecated_member_use
    color: color.withOpacity(opacity),
    shape: boxShape,
    border: border,
    boxShadow: boxShadow,
    borderRadius: boxShape == BoxShape.circle
        ? null
        : BorderRadius.all(Radius.circular(radius)),
  );

  
}
IconData iconFromCodePoint(String? code, {IconData fallback = Icons.help_outline}) {
  if (code == null || code.trim().isEmpty) return fallback;

  var s = code.trim().toLowerCase();
  if (s.startsWith('0x')) s = s.substring(2);

  final cp = int.tryParse(s, radix: 16);
  if (cp == null) return fallback;

  return IconData(cp, fontFamily: 'MaterialIcons');
}

Color parseHexColor(
  String? hex, {
  Color fallback = const Color(0xFF9E9E9E),
}) {
  if (hex == null || hex.trim().isEmpty) return fallback;

  var value = hex.trim().toUpperCase();

  // إزالة البادئات
  if (value.startsWith('0X')) value = value.substring(2);
  if (value.startsWith('#')) value = value.substring(1);

  // لو RGB فقط → أضف Alpha
  if (value.length == 6) {
    value = 'FF$value';
  }

  // لازم يكون ARGB (8 chars)
  if (value.length != 8) return fallback;

  final intColor = int.tryParse(value, radix: 16);
  if (intColor == null) return fallback;

  return Color(intColor);
}
DecoratedBox setDecoratedBox(BoxDecoration boxDecoaration){
  return  DecoratedBox(decoration:boxDecoaration);
}
 ShapeBorder setShapeCard(Color color)=>RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    // ignore: deprecated_member_use
                    color: color
                  ));
 TextStyle setTextStyle({ required double fontSize, Color? color })=>TextStyle(color: color ?? mainColor,fontSize: fontSize,);

ButtonStyle setButtonStyle({required Color backgroundColor, required Color foregroundColor, required OutlinedBorder shape }){
 return ElevatedButton.styleFrom(
                            backgroundColor: backgroundColor,
                            foregroundColor: foregroundColor,
                            elevation: 0,
                            shape: shape
                            );
 }