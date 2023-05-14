import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:label_app/models/ra_settings.dart';

TextStyle getFontStyle(double? fontSize, Color? color, FontWeight? fontWeight,
    RASettings general) {
  if (general.fontName == "Poppins") {
    return GoogleFonts.poppins(
        fontSize: fontSize, color: color, fontWeight: fontWeight);
  } else if (general.fontName == "Roboto") {
    return GoogleFonts.roboto(
        fontSize: fontSize, color: color, fontWeight: fontWeight);
  } else if (general.fontName == "Open Sans") {
    return GoogleFonts.openSans(
        fontSize: fontSize, color: color, fontWeight: fontWeight);
  } else if (general.fontName == "Lato") {
    return GoogleFonts.lato(
        fontSize: fontSize, color: color, fontWeight: fontWeight);
  } else if (general.fontName == "Oswald") {
    return GoogleFonts.oswald(
        fontSize: fontSize, color: color, fontWeight: fontWeight);
  } else if (general.fontName == "Montserrat") {
    return GoogleFonts.montserrat(
        fontSize: fontSize, color: color, fontWeight: fontWeight);
  } else {
    return GoogleFonts.roboto(
        fontSize: fontSize, color: color, fontWeight: fontWeight);
  }
}
