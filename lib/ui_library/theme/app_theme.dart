import 'package:flutter/material.dart';

import 'neutral_colors.dart';

class AppTheme {
  static ThemeData buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final neutralColors = isDark ? NeutralColors.dark : NeutralColors.light;

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        surface: neutralColors.neutral100,
        primary: neutralColors.neutral950,
        onPrimary: neutralColors.neutral50,
        secondary: neutralColors.neutral950,
        onSecondary: neutralColors.neutral50,
        error: Colors.red.shade400,
        onError: neutralColors.neutral50,
        onSurface: neutralColors.neutral950,
        surfaceTint: neutralColors.neutral100,
      ),
      scaffoldBackgroundColor: neutralColors.neutral50,
      appBarTheme: AppBarTheme(
        backgroundColor: neutralColors.neutral100,
        foregroundColor: neutralColors.neutral950,
        elevation: 1,
      ),
      dividerTheme: DividerThemeData(
        color: neutralColors.neutral200,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: neutralColors.neutral950),
        bodyMedium: TextStyle(color: neutralColors.neutral950),
        titleMedium: TextStyle(color: neutralColors.neutral600),
      ),
      iconTheme: IconThemeData(
        color: neutralColors.neutral600,
      ),
      extensions: [
        neutralColors,
      ],
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.white.withOpacity(0.1),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: neutralColors.neutral950),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(neutralColors.neutral100),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: neutralColors.neutral100,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: neutralColors.neutral200),
            borderRadius: BorderRadius.circular(4),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: neutralColors.neutral200),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: neutralColors.neutral300),
            borderRadius: BorderRadius.circular(4),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: neutralColors.neutral100,
        textStyle: TextStyle(color: neutralColors.neutral950),
      ),
    );
  }
}
