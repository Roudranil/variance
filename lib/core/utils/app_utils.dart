import 'package:intl/intl.dart';

class AppUtils {
  static final currencyFormat = NumberFormat.simpleCurrency(
    name: 'INR',
    locale: 'en_IN',
  );
  static final dateFormat = DateFormat('MMM dd, yyyy');
}

class AppSizes {
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p16 = 16.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
}
