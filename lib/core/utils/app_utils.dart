import 'package:intl/intl.dart';

/// Provides utility methods and constants for the application.
class AppUtils {
  /// The currency format used throughout the application.
  ///
  /// This is configured for Indian Rupee (INR) with standard formatting.
  static final currencyFormat = NumberFormat.simpleCurrency(
    name: 'INR',
    locale: 'en_IN',
  );

  /// The date format used for display.
  ///
  /// Formats dates as "MMM dd, yyyy" (e.g., "Jan 01, 2024").
  static final dateFormat = DateFormat('MMM dd, yyyy');
}

/// Defines standard spacing constants used in the UI.
class AppSizes {
  /// A spacing of 4.0 logical pixels.
  static const double p4 = 4.0;

  /// A spacing of 8.0 logical pixels.
  static const double p8 = 8.0;

  /// A spacing of 16.0 logical pixels.
  static const double p16 = 16.0;

  /// A spacing of 24.0 logical pixels.
  static const double p24 = 24.0;

  /// A spacing of 32.0 logical pixels.
  static const double p32 = 32.0;
}
