// lib/presentation/features/accounts/reconcile_screen.dart
//
// ReconcileScreen — balance reconciliation for a single account (T-43).
//
// Flow (ACC-06, PRD §5.1.3.1):
//   1. Display computed balance (reactive from accountBalanceProvider).
//   2. User enters actual (real-world) balance.
//   3. Compute discrepancy = actual − computed.
//   4. If zero: show "Balance is already correct" toast and pop.
//   5. If positive: post BAI (Balance Adjustment Income) via LedgerEngine.
//   6. If negative: post BAE (Balance Adjustment Expense) via LedgerEngine.
//   7. Navigate back on success.
//
// Widget tests:
//   1. positive delta → shows BAI info message
//   2. negative delta → shows BAE info message
//   3. zero delta → shows "already correct" message

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ignore: prefer_const_constructors — Uuid() must not be const
final _uuid = Uuid();

/// Screen that lets the user reconcile an account's balance.
///
/// Computes the discrepancy between the user-entered actual balance and the
/// system-computed balance, then posts the appropriate adjustment transaction.
class ReconcileScreen extends ConsumerStatefulWidget {
  /// Creates a [ReconcileScreen].
  const ReconcileScreen({super.key, required this.accountId});

  /// UUID of the account to reconcile.
  final String accountId;

  @override
  ConsumerState<ReconcileScreen> createState() => _ReconcileScreenState();
}

class _ReconcileScreenState extends ConsumerState<ReconcileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actualController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _actualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountAsync = ref.watch(accountByIdProvider(widget.accountId));
    final balanceAsync =
        ref.watch(accountBalanceProvider(widget.accountId, 'INR'));

    final account = accountAsync.value;
    final computedBalance = balanceAsync.value ?? 0;
    final currencyCode = account?.currencyCode ?? 'INR';

    return Scaffold(
      appBar: AppBar(title: const Text('Reconcile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Computed balance',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$currencyCode ${computedBalance / 100}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _actualController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Actual balance ($currencyCode)',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter the actual balance';
                  }
                  if (double.tryParse(v.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reconcile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final actualDouble = double.parse(_actualController.text.trim());
    // Convert to minor units (cents).
    final actualMinor = (actualDouble * 100).round();

    final balanceAsync =
        ref.read(accountBalanceProvider(widget.accountId, 'INR'));
    final computedMinor = balanceAsync.value ?? 0;
    final deltaMinor = actualMinor - computedMinor;

    if (deltaMinor == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Balance is already correct.')),
        );
        context.pop();
      }
      return;
    }

    // Determine adjustment type.
    final isPositive = deltaMinor > 0;
    // BAI protected category id and BAE protected category id are resolved
    // from the database at runtime. For now we use sentinel IDs that the
    // LedgerEngine recognises (seeded on onCreate).
    const baiCategoryId = 'bai-protected';
    const baeCategoryId = 'bae-protected';

    final categoryId = isPositive ? baiCategoryId : baeCategoryId;
    final adjustmentType =
        isPositive ? TransactionType.income : TransactionType.expense;
    final amountMinor = deltaMinor.abs();

    setState(() => _isSaving = true);

    try {
      final useCaseAsync =
          await ref.read(createTransactionUseCaseProvider.future);
      final accountAsync = ref.read(accountByIdProvider(widget.accountId));
      final account = accountAsync.value;
      if (account == null) return;

      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final draft = Transaction(
        id: _uuid.v4(),
        type: adjustmentType,
        status: TransactionStatus.posted,
        purpose: TransactionPurpose.system,
        dateTime: nowEpoch,
        amountMinor: amountMinor,
        currencyCode: account.currencyCode,
        categoryId: categoryId,
        accountSourceId:
            adjustmentType == TransactionType.expense ? account.id : null,
        accountDestinationId:
            adjustmentType == TransactionType.income ? account.id : null,
        createdAt: nowEpoch,
        updatedAt: nowEpoch,
      );

      final result = await useCaseAsync.call(draft);
      if (!mounted) return;

      switch (result) {
        case Ok():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPositive
                    ? 'Positive adjustment posted (BAI).'
                    : 'Negative adjustment posted (BAE).',
              ),
            ),
          );
          context.pop();
        case Err(:final failure):
          dev.log(
            'ReconcileScreen: reconcile failed — ${failure.message}',
            name: 'ReconcileScreen',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${failure.message}')),
          );
      }
    } on Exception catch (e) {
      dev.log('ReconcileScreen: unexpected error — $e', name: 'ReconcileScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
