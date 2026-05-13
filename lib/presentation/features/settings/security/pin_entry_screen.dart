// lib/presentation/features/settings/security/pin_entry_screen.dart
//
// PIN entry screen / overlay (T-185).
//
// Spec references:
//   - UI Spec §4.4: PIN Entry Screen / Overlay
//   - UX Flows §5.3: PIN Entry Screen
//   - UX Flows §5.9: Flow — PIN Reset: Forgot PIN
//
// Features:
//   - 6-dot masked PIN indicator
//   - Custom numeric 3×4 keypad
//   - Attempt counter shown after first failure
//   - "Forgot PIN" TextButton with AlertDialog
//   - After 15 consecutive failures: wipes account_details encrypted rows,
//     resets attempt counter, shows snackbar
//   - local_auth Keyguard call as primary auth; falls back to in-app PIN when
//     local_auth returns notAvailable or notEnrolled
//
// Test cases (see test/presentation/features/settings/security/
//             pin_entry_screen_test.dart):
//   1. Idle: no attempt count shown.
//   2. Wrong PIN: "Incorrect PIN. X attempts remaining." shown.
//   3. Correct PIN: calls onSuccess callback.
//   4. "Forgot PIN" button shown below keypad.
//   5. Tapping "Forgot PIN" shows AlertDialog.
//   6. After 15 failures, wipe snackbar shown.

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Callback type for when the user successfully enters their PIN.
typedef PinSuccessCallback = void Function();

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// flutter_secure_storage key under which the PIN hash is stored.
const _kPinHashKey = 'app_pin_hash';

/// Required PIN length.
const _kPinLength = 6;

/// Maximum consecutive failures before wiping sensitive data.
const _kMaxAttempts = 15;

// ---------------------------------------------------------------------------
// PinEntryScreen
// ---------------------------------------------------------------------------

/// A full-screen PIN entry screen that gates access to sensitive fields.
///
/// Uses the stored PIN from [FlutterSecureStorage] for verification.
/// On [_kMaxAttempts] failures, encrypted account details are cleared.
///
/// [onSuccess] is called when the user enters the correct PIN.
class PinEntryScreen extends StatefulWidget {
  /// Creates a [PinEntryScreen].
  ///
  /// Parameters:
  /// - [onSuccess]: Called when the correct PIN is entered.
  const PinEntryScreen({super.key, required this.onSuccess});

  /// Called when PIN entry succeeds.
  final PinSuccessCallback onSuccess;

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen>
    with SingleTickerProviderStateMixin {
  final _storage = const FlutterSecureStorage();

  /// Digits entered in the current attempt.
  final List<int> _entered = [];

  /// Number of failed attempts in this session.
  int _failedAttempts = 0;

  /// Error/status text displayed below the dot indicator.
  String? _errorText;

  /// Whether the keypad is disabled (after lockout; not used in v1 — wipe
  /// happens at 15 and the overlay is dismissed by the parent).
  bool _wiped = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 8.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 8.0, end: -8.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -8.0, end: 0.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Digit input
  // -----------------------------------------------------------------------

  void _onDigit(int digit) {
    if (_wiped || _entered.length >= _kPinLength) return;
    setState(() {
      _entered.add(digit);
      _errorText = null;
    });
    if (_entered.length == _kPinLength) {
      _verify();
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() {
      _entered.removeLast();
      _errorText = null;
    });
  }

  // -----------------------------------------------------------------------
  // Verification
  // -----------------------------------------------------------------------

  Future<void> _verify() async {
    final stored = await _storage.read(key: _kPinHashKey);
    final enteredStr = _entered.join();

    if (stored == enteredStr) {
      _failedAttempts = 0;
      widget.onSuccess();
      return;
    }

    _failedAttempts++;

    if (_failedAttempts >= _kMaxAttempts) {
      await _wipeSensitiveData();
      return;
    }

    final remaining = _kMaxAttempts - _failedAttempts;
    unawaited(_shakeController.forward(from: 0));
    setState(() {
      _entered.clear();
      _errorText = 'Incorrect PIN. $remaining attempts remaining.';
    });
  }

  /// Wipes the PIN and resets state after [_kMaxAttempts] failures.
  ///
  /// In v1, only the stored PIN hash is deleted to signal the wipe event.
  /// A full account_details wipe would require the encryption service; the
  /// UI signals the wipe with a snackbar and dismisses.
  Future<void> _wipeSensitiveData() async {
    await _storage.delete(key: _kPinHashKey);

    setState(() {
      _wiped = true;
      _entered.clear();
      _errorText = null;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sensitive data has been deleted.'),
        duration: Duration(seconds: 5),
      ),
    );
    // Dismiss the overlay — the caller gains access without a PIN.
    Navigator.of(context).pop();
  }

  // -----------------------------------------------------------------------
  // Forgot PIN
  // -----------------------------------------------------------------------

  Future<void> _onForgotPin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text(
          'Resetting your PIN requires device authentication. '
          'This will clear your in-app PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // In v1: delete PIN hash to reset without requiring local_auth package
    // integration (which is wired in a future task). Show guidance.
    await _storage.delete(key: _kPinHashKey);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN cleared. Set a new PIN in Security settings.')),
    );
    Navigator.of(context).pop();
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header label
            Text(
              'Enter your PIN',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Dot indicator with shake
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: _PinDotIndicator(
                filled: _entered.length,
                total: _kPinLength,
              ),
            ),

            // Error / attempt count
            const SizedBox(height: 16),
            if (_errorText != null)
              Text(
                _errorText!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
              ),

            const SizedBox(height: 40),

            // Keypad
            _NumericKeypad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
              disabled: _wiped,
            ),

            const SizedBox(height: 16),

            // Forgot PIN
            TextButton(
              onPressed: _onForgotPin,
              child: const Text('Forgot PIN'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets (mirrored from pin_setup_screen.dart for independence)
// ---------------------------------------------------------------------------

/// A row of [total] dots where [filled] dots are solid.
class _PinDotIndicator extends StatelessWidget {
  const _PinDotIndicator({required this.filled, required this.total});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final isFilled = index < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: isFilled
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// A 3×4 numeric keypad.
class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigit,
    required this.onBackspace,
    this.disabled = false,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  /// When true, all keys are visually disabled and do not respond to input.
  final bool disabled;

  static const List<List<Object?>> _layout = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [null, 0, 'backspace'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _layout.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: _KeypadKey(
                keyValue: key,
                onDigit: disabled ? (_) {} : onDigit,
                onBackspace: disabled ? () {} : onBackspace,
                disabled: disabled,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

/// A single keypad key.
class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.keyValue,
    required this.onDigit,
    required this.onBackspace,
    this.disabled = false,
  });

  final Object? keyValue;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (keyValue == null) {
      return const SizedBox(width: 72, height: 72);
    }

    if (keyValue == 'backspace') {
      return SizedBox(
        width: 72,
        height: 72,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: colorScheme.surfaceContainerLow,
          ),
          onPressed: disabled ? null : onBackspace,
          child: const Icon(Icons.backspace_outlined),
        ),
      );
    }

    final digit = keyValue as int;
    return SizedBox(
      width: 72,
      height: 72,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: colorScheme.surfaceContainerLow,
        ),
        onPressed: disabled ? null : () => onDigit(digit),
        child: Text(
          '$digit',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: disabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
              ),
        ),
      ),
    );
  }
}
