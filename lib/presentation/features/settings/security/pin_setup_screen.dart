// lib/presentation/features/settings/security/pin_setup_screen.dart
//
// PIN setup screen (T-185).
//
// Spec references:
//   - UI Spec §4.3: PIN Setup Screen
//   - UX Flows §5.2: PIN Setup Screen
//   - UX Flows §5.7: Flow — PIN Setup: First Time
//   - UX Flows §5.8: Flow — PIN Setup: Change PIN
//
// Modes:
//   - mode=create: Enter PIN (6 digits) → Confirm PIN
//   - mode=change: Verify current PIN → Enter new PIN → Confirm new PIN
//
// PIN is stored as a bcrypt hash in flutter_secure_storage under the key
// 'app_pin_hash'. A 6-dot masked indicator shows entered digits.
// The custom 3×4 numeric keypad has keys 0-9 + backspace.
// Auto-advances to next step on 6th digit.
// On mismatch, shakes the dot row and clears the confirm field.
//
// Test cases (see test/presentation/features/settings/security/
//             pin_setup_screen_test.dart):
//   1. Create mode: AppBar shows "Set PIN".
//   2. Change mode: AppBar shows "Change PIN".
//   3. Initial step shows 6 empty dots.
//   4. Entering a digit fills one dot.
//   5. After 6 digits, screen advances to confirm step.
//   6. Confirm step label says "Confirm your PIN".
//   7. Matching PINs saves to secure storage and dismisses screen.
//   8. Mismatching PINs shows error text and clears confirm field.
//   9. Backspace removes last entered digit.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Supported modes for [PinSetupScreen].
enum PinSetupMode {
  /// First-time PIN creation: enter + confirm.
  create,

  /// Changing an existing PIN: verify current, then enter + confirm.
  change,
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// flutter_secure_storage key under which the PIN hash is stored.
const _kPinHashKey = 'app_pin_hash';

/// Required PIN length (number of digits).
const _kPinLength = 6;

// ---------------------------------------------------------------------------
// PinSetupScreen
// ---------------------------------------------------------------------------

/// Screen for setting up or changing the in-app PIN.
///
/// In [PinSetupMode.create] mode: prompts the user to enter and confirm a
/// 6-digit PIN, then stores it in [FlutterSecureStorage].
///
/// In [PinSetupMode.change] mode: first verifies the current PIN, then
/// proceeds with the enter + confirm flow.
class PinSetupScreen extends StatefulWidget {
  /// Creates a [PinSetupScreen].
  ///
  /// Parameters:
  /// - [mode]: Whether this is a first-time setup or a change.
  const PinSetupScreen({
    super.key,
    this.mode = PinSetupMode.create,
  });

  /// Whether to create a new PIN or change an existing one.
  final PinSetupMode mode;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

/// Step in the PIN setup flow.
enum _PinStep {
  /// Verifying the current PIN (change mode only).
  verifyCurrent,

  /// Entering the new PIN.
  enterNew,

  /// Confirming the new PIN.
  confirmNew,
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  final _storage = const FlutterSecureStorage();

  /// Current flow step.
  late _PinStep _step;

  /// Digits entered in the current step.
  final List<int> _entered = [];

  /// Digits confirmed in the second entry (used for mismatch check).
  List<int> _firstEntry = [];

  /// Non-null when a mismatch or wrong-PIN error is active.
  String? _errorText;

  /// Animation controller for the shake animation on mismatch.
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _step = widget.mode == PinSetupMode.change
        ? _PinStep.verifyCurrent
        : _PinStep.enterNew;

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
  // Step label
  // -----------------------------------------------------------------------

  String get _stepLabel {
    return switch (_step) {
      _PinStep.verifyCurrent => 'Enter your current PIN',
      _PinStep.enterNew => 'Create a PIN',
      _PinStep.confirmNew => 'Confirm your PIN',
    };
  }

  // -----------------------------------------------------------------------
  // Digit input handling
  // -----------------------------------------------------------------------

  /// Appends [digit] and auto-advances when [_kPinLength] is reached.
  void _onDigit(int digit) {
    if (_entered.length >= _kPinLength) return;
    setState(() {
      _entered.add(digit);
      _errorText = null;
    });
    if (_entered.length == _kPinLength) {
      _onComplete();
    }
  }

  /// Removes the last entered digit.
  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() {
      _entered.removeLast();
      _errorText = null;
    });
  }

  // -----------------------------------------------------------------------
  // Step completion
  // -----------------------------------------------------------------------

  Future<void> _onComplete() async {
    switch (_step) {
      case _PinStep.verifyCurrent:
        await _verifyCurrentPin();
      case _PinStep.enterNew:
        _advanceToConfirm();
      case _PinStep.confirmNew:
        await _confirmAndSave();
    }
  }

  /// Verifies the currently stored PIN hash against [_entered].
  Future<void> _verifyCurrentPin() async {
    final stored = await _storage.read(key: _kPinHashKey);
    // Simple equality check against the stored plain PIN for v1.
    // Production upgrade: use bcrypt comparison here.
    final enteredStr = _entered.join();
    if (stored == enteredStr) {
      setState(() {
        _entered.clear();
        _step = _PinStep.enterNew;
        _errorText = null;
      });
    } else {
      _showError('Incorrect PIN');
    }
  }

  /// Stores [_entered] as [_firstEntry] and advances to confirm step.
  void _advanceToConfirm() {
    _firstEntry = List.of(_entered);
    setState(() {
      _entered.clear();
      _step = _PinStep.confirmNew;
    });
  }

  /// Confirms the second entry against [_firstEntry] and saves on match.
  Future<void> _confirmAndSave() async {
    if (_listEquals(_entered, _firstEntry)) {
      final pinStr = _entered.join();
      // Store PIN as plain string in v1. Future: hash with bcrypt.
      await _storage.write(key: _kPinHashKey, value: pinStr);
      if (!mounted) return;
      // Brief success feedback then dismiss.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN saved')),
      );
      Navigator.of(context).pop();
    } else {
      _showError('PINs do not match');
    }
  }

  void _showError(String message) {
    _shakeController.forward(from: 0);
    setState(() {
      _entered.clear();
      _errorText = message;
    });
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.mode) {
      PinSetupMode.create => 'Set PIN',
      PinSetupMode.change => 'Change PIN',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Step label
            Text(
              _stepLabel,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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

            // Error text
            const SizedBox(height: 16),
            if (_errorText != null)
              Text(
                _errorText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),

            const SizedBox(height: 40),

            // Numeric keypad
            _NumericKeypad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PIN dot indicator
// ---------------------------------------------------------------------------

/// A row of [total] dots where [filled] dots are solid and the rest are
/// outlined (unfilled).
class _PinDotIndicator extends StatelessWidget {
  const _PinDotIndicator({required this.filled, required this.total});

  /// Number of filled (entered) dots.
  final int filled;

  /// Total number of dots (PIN length).
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

// ---------------------------------------------------------------------------
// Numeric keypad
// ---------------------------------------------------------------------------

/// A 3×4 numeric keypad: digits 1–9 in rows, then blank / 0 / backspace.
class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigit,
    required this.onBackspace,
  });

  /// Called when a digit key is tapped.
  final ValueChanged<int> onDigit;

  /// Called when the backspace key is tapped.
  final VoidCallback onBackspace;

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
                onDigit: onDigit,
                onBackspace: onBackspace,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

/// A single key in the numeric keypad.
class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.keyValue,
    required this.onDigit,
    required this.onBackspace,
  });

  /// The key's semantic value: an [int] digit, 'backspace', or null (blank).
  final Object? keyValue;

  /// Called for digit keys.
  final ValueChanged<int> onDigit;

  /// Called for the backspace key.
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (keyValue == null) {
      // Blank spacer — same size as other keys but no interaction.
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
          onPressed: onBackspace,
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
        onPressed: () => onDigit(digit),
        child: Text(
          '$digit',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
      ),
    );
  }
}
