import 'package:flutter/material.dart';

const MaterialColor primaryColorLight = Colors.blue;
const MaterialColor primaryColorDark = Colors.lightBlue;

ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
  return ThemeData(
  useMaterial3: true,
  colorScheme: dynamicColorScheme ?? ColorScheme.fromSwatch(primarySwatch: primaryColorLight),
  primaryColor: dynamicColorScheme != null ? dynamicColorScheme.primary : primaryColorLight,
  scaffoldBackgroundColor: dynamicColorScheme != null ? dynamicColorScheme.background : Colors.white,
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5)
    ),
    elevation: 4,
  ),
  brightness: Brightness.light,
  dialogBackgroundColor: dynamicColorScheme != null ? dynamicColorScheme.surface : Colors.white,
  textTheme: const TextTheme(
    bodyText1: TextStyle(
      color: Colors.black54
    ),
    bodyText2: TextStyle(
      color: Colors.black
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: dynamicColorScheme != null ? dynamicColorScheme.primary : primaryColorLight
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(
        dynamicColorScheme != null ? dynamicColorScheme.primary : primaryColorLight
      ),
      overlayColor: MaterialStateProperty.all(
        dynamicColorScheme != null ? dynamicColorScheme.primary.withOpacity(0.1) : primaryColorLight.withOpacity(0.1)
      ),
    ),
  ),
  dividerColor: Colors.black12,
  listTileTheme: const ListTileThemeData(
    tileColor: Colors.transparent
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: MaterialStateProperty.all(Colors.white),
    fillColor: MaterialStateProperty.all(
      dynamicColorScheme != null ? dynamicColorScheme.primary : primaryColorLight
    ),
  ),
  tabBarTheme: TabBarTheme(
    unselectedLabelColor: Colors.black,
    unselectedLabelStyle: const TextStyle(
      color: Colors.black
    ),
    labelColor: dynamicColorScheme != null ? dynamicColorScheme.primary : primaryColorLight,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: dynamicColorScheme != null ? dynamicColorScheme.primary : primaryColorLight,
        width: 2
      )
    )
  ),
  androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
);
}

ThemeData darkTheme(ColorScheme? dynamicColorScheme) => ThemeData(
  useMaterial3: true,
  colorScheme: dynamicColorScheme ?? ColorScheme.fromSwatch(primarySwatch: primaryColorDark).copyWith(
    brightness: Brightness.dark
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(18, 18, 18, 1),
  dialogBackgroundColor: const Color.fromRGBO(44, 44, 44, 1),
  navigationBarTheme: NavigationBarThemeData(
    indicatorColor: dynamicColorScheme != null ? dynamicColorScheme.primary : primaryColorLight,
  ),
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
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: dynamicColorScheme != null ? dynamicColorScheme.primary : primaryColorLight
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