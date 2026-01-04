import 'package:flutter_test/flutter_test.dart';
import 'package:variance/core/utils/logger.dart';

void main() {
  test('VarianceLogger outputs colored logs', () {
    print('\n--- Logger Visual Verification Start ---');
    VarianceLogger.debug('This is a debug message');
    VarianceLogger.info('This is an info message');
    VarianceLogger.warning('This is a warning message');
    VarianceLogger.error('This is an error message');
    print('--- Logger Visual Verification End ---\n');
  });
}
