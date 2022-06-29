import 'package:flutter/material.dart';

const Color primaryColorLight = Colors.blue;
const Color primaryColorDark = Colors.lightBlue;

ThemeData get lightTheme => ThemeData(
  primaryColor: primaryColorLight,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromRGBO(255, 255, 255, 1)
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5)
    ),
    elevation: 4,
  ),
  brightness: Brightness.light,
  dialogBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    bodyText1: TextStyle(
      color: Colors.black54
    ),
    bodyText2: TextStyle(
      color: Colors.black
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(primaryColorLight),
      overlayColor: MaterialStateProperty.all(primaryColorLight.withOpacity(0.1))
    ),
  ),
  dividerColor: Colors.black12,
  listTileTheme: const ListTileThemeData(
    tileColor: Colors.transparent
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: MaterialStateProperty.all(Colors.white),
    fillColor: MaterialStateProperty.all(primaryColorLight),
  ),
  tabBarTheme: const TabBarTheme(
    unselectedLabelColor: Colors.black,
    unselectedLabelStyle: TextStyle(
      color: Colors.black
    ),
    labelColor: primaryColorLight,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: primaryColorLight,
        width: 2
      )
    )
  ),
  androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
);

ThemeData get darkTheme => ThemeData(
  primaryColor: primaryColorDark,
  scaffoldBackgroundColor: const Color.fromRGBO(18, 18, 18, 1),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromRGBO(30, 30, 30, 1),
    selectedItemColor: primaryColorDark
  ),
  dialogBackgroundColor: const Color.fromRGBO(44, 44, 44, 1),
  snackBarTheme: SnackBarThemeData(
    contentTextStyle: const TextStyle(
      color: Colors.white
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5)
    ),
    elevation: 4,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    foregroundColor: Colors.white
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(primaryColorDark),
      overlayColor: MaterialStateProperty.all(primaryColorDark.withOpacity(0.1))
    ),
  ),
  brightness: Brightness.dark,
  textTheme: const TextTheme(
    bodyText1: TextStyle(
      color: Colors.white70
    ),
    bodyText2: TextStyle(
      color: Colors.white
    ),
  ),
  dividerColor: Colors.white12,
    listTileTheme: const ListTileThemeData(
    tileColor: Colors.transparent
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: MaterialStateProperty.all(Colors.white),
    fillColor: MaterialStateProperty.all(Colors.blue),
  ),
  tabBarTheme: const TabBarTheme(
    unselectedLabelColor: Colors.white,
    unselectedLabelStyle: TextStyle(
      color: Colors.white
    ),
    labelColor: primaryColorDark,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: primaryColorDark,
        width: 2
      )
    )
  ),
  androidOverscrollIndicator: AndroidOverscrollIndicator.stretch
);