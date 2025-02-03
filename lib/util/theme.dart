import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

ThemeData theme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Nanum',
  scaffoldBackgroundColor: Colors.white,
  canvasColor: Colors.white,
  cardColor: odEvColor[100],
  dialogBackgroundColor: Colors.white,
  primaryColor: mainColor,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    extendedTextStyle: TextStyle(color: Colors.white),
    backgroundColor: mainColor[200],
    foregroundColor: Colors.white,
    focusColor: Colors.white,
    elevation: 1,
  ),
  textTheme: lightTextTheme,
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: odEvColor[300]!),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStatePropertyAll(
        TextStyle(color: mainColor[200]),
      ),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    shadowColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    unselectedIconTheme: IconThemeData(color: Colors.black, size: 24),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: mainColor[100],
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.black)),
      backgroundColor: WidgetStatePropertyAll(mainColor[100]),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.black)),
      iconColor: WidgetStatePropertyAll(Colors.black),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStatePropertyAll(TextStyle(color: mainColor)),
    ),
  ),
  listTileTheme: ListTileThemeData(
    textColor: Colors.black,
    iconColor: Colors.black,
  ),
  expansionTileTheme: ExpansionTileThemeData(
    textColor: Colors.black,
    iconColor: Colors.black,
    collapsedTextColor: Colors.black,
    collapsedIconColor: Colors.black,
  ),
  switchTheme: SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return mainColor;
        }
        return odEvColor[100];
      },
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return mainColor;
      }
      return odEvColor[300];
    }),
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return odEvColor[300];
    }),
  ),
  dividerColor: Colors.black,
  dividerTheme: DividerThemeData(color: Colors.black),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: mainColor)
      .copyWith(secondary: mainColor),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Nanum',
  scaffoldBackgroundColor: Colors.black,
  canvasColor: Colors.black,
  cardColor: dOdEvColor[100],
  dialogBackgroundColor: Colors.black,
  primaryColor: dMainColor,
  primaryTextTheme: darkTextTheme,
  textTheme: darkTextTheme,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    extendedTextStyle: TextStyle(color: Colors.black),
    backgroundColor: dMainColor[200],
    foregroundColor: Colors.black,
    focusColor: Colors.black,
    elevation: 1,
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: dOdEvColor[300]!),
    ),
  ),
  dialogTheme: DialogTheme(),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: dMainColor,
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.black,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStatePropertyAll(
        TextStyle(color: dMainColor[200]),
      ),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    shadowColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    unselectedIconTheme: IconThemeData(color: Colors.white, size: 24),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: dMainColor[100],
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
      backgroundColor: WidgetStatePropertyAll(dMainColor[100]),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
      iconColor: WidgetStatePropertyAll(Colors.white),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStatePropertyAll(TextStyle(color: dMainColor)),
    ),
  ),
  listTileTheme: ListTileThemeData(
    textColor: Colors.white,
    iconColor: Colors.white,
  ),
  expansionTileTheme: ExpansionTileThemeData(
    textColor: Colors.white,
    iconColor: Colors.white,
    collapsedTextColor: Colors.white,
    collapsedIconColor: Colors.white,
  ),
  switchTheme:
      SwitchThemeData(trackColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return dMainColor;
    }
    return dMainColor[400];
  })),
  dividerColor: Colors.white,
  dividerTheme: DividerThemeData(color: Colors.white),
  colorScheme: ColorScheme.fromSwatch(
          primarySwatch: dMainColor, brightness: Brightness.dark)
      .copyWith(secondary: dMainColor),
);

MaterialColor mainColor = const MaterialColor(
  0xff4CAF50,
  {
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(0xFF4CAF50),
    600: Color(0xFF43A047),
    700: Color(0xFF388E3C),
    800: Color(0xFF2E7D32),
    900: Color(0xFF1B5E20),
  },
);

MaterialColor dMainColor = const MaterialColor(
  0xff657b72,
  {
    100: Color(0xffbcd5cb),
    200: Color(0xff8fa79e),
    300: Color(0xff657b72),
    // 300: Color(0xffFF00cb),
    400: Color(0xff3d524a),
    500: Color(0xff182c25),
  },
);

TextTheme lightTextTheme = TextTheme().apply(
  bodyColor: Colors.black,
  displayColor: Colors.black,
);

TextTheme darkTextTheme = TextTheme().apply(
  bodyColor: Colors.white,
  displayColor: Colors.white,
);

SvgTheme svgTheme = const SvgTheme(currentColor: Colors.black);

SvgTheme darkSvgTheme = const SvgTheme(currentColor: Colors.white);

MaterialColor odEvColor = const MaterialColor(
  0xffffffff,
  {
    100: Color(0xFFF1F8E9),
    200: Colors.white,
    300: Color(0xFFC5E1A5),
  },
);

MaterialColor dOdEvColor = const MaterialColor(
  0xff000000,
  {
    100: Color(0xff182c25),
    200: Colors.black,
    300: Color(0xff657b72),
  },
);
