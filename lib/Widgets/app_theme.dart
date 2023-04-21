import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messanger_app/Class%20Files/color.dart';

mixin AppThemeMixin {
  ThemeData appTheme(BuildContext context) => ThemeData(
        scaffoldBackgroundColor: const Color(0xfff2f2f2),
        // scaffoldBackgroundColor: gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [Color(0xFF5b8bdf), Color(0xFF07c8e5)],
        primaryColor: AColor.black,
        accentColor: AColor.black,
        appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            color: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light),
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900)),
        // primarySwatch: ,
        fontFamily: GoogleFonts.poppins().fontFamily,
      );
}
