import 'package:flutter/material.dart';

const Color mainColor = Color(0xFF1A2A80) ;
const secondaryColor = 0xFF50E3C2;
const textColor = 0xFF4A4A4A;
const greenColor = Colors.green;
const redColor = Colors.red;
const whiteColor =Colors.white;
const blackColor = Colors.black;
final grayColor = Colors.grey[700];
const whitwColor = Colors.white;
const colors = Color(0xFFF9FAFB);               
 



 Color? convertColorsFromStringToHex(String? hex){
  if(hex!=null&& hex.isNotEmpty){
  hex = hex.replaceAll("#", ""); 
return Color(int.parse("0xFF$hex"));}
return null;
 }