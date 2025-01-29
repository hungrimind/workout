import 'package:flutter/material.dart';

@immutable
class NeutralColors extends ThemeExtension<NeutralColors> {
  final Color neutral50;
  final Color neutral100;
  final Color neutral200;
  final Color neutral300;
  final Color neutral400;
  final Color neutral500;
  final Color neutral600;
  final Color neutral700;
  final Color neutral800;
  final Color neutral900;
  final Color neutral950;

  const NeutralColors({
    required this.neutral50,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral400,
    required this.neutral500,
    required this.neutral600,
    required this.neutral700,
    required this.neutral800,
    required this.neutral900,
    required this.neutral950,
  });

  // Light theme values from Tailwind
  static const light = NeutralColors(
    neutral50: NeutralColorValues.neutral50,
    neutral100: NeutralColorValues.neutral100,
    neutral200: NeutralColorValues.neutral200,
    neutral300: NeutralColorValues.neutral300,
    neutral400: NeutralColorValues.neutral400,
    neutral500: NeutralColorValues.neutral500,
    neutral600: NeutralColorValues.neutral600,
    neutral700: NeutralColorValues.neutral700,
    neutral800: NeutralColorValues.neutral800,
    neutral900: NeutralColorValues.neutral900,
    neutral950: NeutralColorValues.neutral950,
  );

  // Dark theme values from Tailwind (inverted)
  static const dark = NeutralColors(
    neutral50: NeutralColorValues.neutral950,
    neutral100: NeutralColorValues.neutral900,
    neutral200: NeutralColorValues.neutral800,
    neutral300: NeutralColorValues.neutral700,
    neutral400: NeutralColorValues.neutral600,
    neutral500: NeutralColorValues.neutral500,
    neutral600: NeutralColorValues.neutral400,
    neutral700: NeutralColorValues.neutral300,
    neutral800: NeutralColorValues.neutral200,
    neutral900: NeutralColorValues.neutral100,
    neutral950: NeutralColorValues.neutral50,
  );

  @override
  ThemeExtension<NeutralColors> copyWith({
    Color? neutral50,
    Color? neutral100,
    Color? neutral200,
    Color? neutral300,
    Color? neutral400,
    Color? neutral500,
    Color? neutral600,
    Color? neutral700,
    Color? neutral800,
    Color? neutral900,
    Color? neutral950,
  }) {
    return NeutralColors(
      neutral50: neutral50 ?? this.neutral50,
      neutral100: neutral100 ?? this.neutral100,
      neutral200: neutral200 ?? this.neutral200,
      neutral300: neutral300 ?? this.neutral300,
      neutral400: neutral400 ?? this.neutral400,
      neutral500: neutral500 ?? this.neutral500,
      neutral600: neutral600 ?? this.neutral600,
      neutral700: neutral700 ?? this.neutral700,
      neutral800: neutral800 ?? this.neutral800,
      neutral900: neutral900 ?? this.neutral900,
      neutral950: neutral950 ?? this.neutral950,
    );
  }

  @override
  ThemeExtension<NeutralColors> lerp(
    covariant ThemeExtension<NeutralColors>? other,
    double t,
  ) {
    if (other is! NeutralColors) {
      return this;
    }
    return NeutralColors(
      neutral50: Color.lerp(neutral50, other.neutral50, t)!,
      neutral100: Color.lerp(neutral100, other.neutral100, t)!,
      neutral200: Color.lerp(neutral200, other.neutral200, t)!,
      neutral300: Color.lerp(neutral300, other.neutral300, t)!,
      neutral400: Color.lerp(neutral400, other.neutral400, t)!,
      neutral500: Color.lerp(neutral500, other.neutral500, t)!,
      neutral600: Color.lerp(neutral600, other.neutral600, t)!,
      neutral700: Color.lerp(neutral700, other.neutral700, t)!,
      neutral800: Color.lerp(neutral800, other.neutral800, t)!,
      neutral900: Color.lerp(neutral900, other.neutral900, t)!,
      neutral950: Color.lerp(neutral950, other.neutral950, t)!,
    );
  }
}

class NeutralColorValues {
  const NeutralColorValues();

  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral300 = Color(0xFFD4D4D4);
  static const neutral400 = Color(0xFFA3A3A3);
  static const neutral500 = Color(0xFF737373);
  static const neutral600 = Color(0xFF525252);
  static const neutral700 = Color(0xFF404040);
  static const neutral800 = Color(0xFF262626);
  static const neutral900 = Color(0xFF171717);
  static const neutral950 = Color(0xFF0A0A0A);
}
