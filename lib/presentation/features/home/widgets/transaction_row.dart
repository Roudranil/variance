// lib/presentation/features/home/widgets/transaction_row.dart
//
// TransactionRow — 3-column transaction list row widget.
//
// Architecture (T-155, UI spec §5.1.2, UX flows §6.8.2):
//   Column layout:
//     C1 (Leading): category icon + parent name; subcategory name if present;
//       "Transfer" label for transfers (no icon). Badge overlay when pending.
//     C2 (Title/Account): Row 1 = title (bodyLarge); Row 2 = account info
//       (bodySmall). Account info: source for expense, dest for income,
//       "Src → Dest" for transfer.
//     C3 (Trailing): Row 1 = amount + symbol (numericMedium); Row 2 = FX
//       equivalent (numericSmall, onSurfaceVariant) only for foreign currency.
//       Income = green; Expense = red; Transfer = neutral.
//
// ISO 4217 disambiguation: when ≥2 currencies share a symbol, the ISO code
//   is shown instead of the symbol.
//
// Pending styling: entire row uses onSurfaceVariant; badge on C1 icon.
//
// Test cases (see test/.../transaction_row_test.dart):
//   1. Expense: category name + title + source account + red amount
//   2. Income: destination account visible
//   3. Transfer: "Transfer" label + "Src → Dst" account info
//   4. Foreign currency: FX equivalent row 2 shown
//   5. Pending badge visible when isPending = true
//   6. Subcategory name shown when parentCategory provided

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/features/settings/categories/category_icons.dart';
import 'package:variance/presentation/theme/variance_colors.dart';
import 'package:variance/presentation/theme/variance_typography.dart';

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

/// A single 3-column transaction row for the Home screen list.
///
/// Does not wrap itself in a [GestureDetector]; callers (HomeScreen sliver
/// builder) wrap it in [Dismissible] for swipe actions and add a long-press
/// gesture for the contextual menu.
class TransactionRow extends StatelessWidget {
  /// Creates a [TransactionRow].
  ///
  /// Parameters:
  /// - [transaction]: The domain transaction to render.
  /// - [category]: The resolved category (may be null for transfers).
  /// - [parentCategory]: The parent category when [category] is a subcategory.
  ///   Null when [category] is a root category.
  /// - [sourceAccount]: Resolved source account (expense/transfer).
  /// - [destinationAccount]: Resolved destination account (income/transfer).
  /// - [homeCurrency]: ISO 4217 code of the home currency; used to detect
  ///   foreign-currency rows.
  /// - [usedCurrencySymbols]: Map of symbol → count of currencies sharing that
  ///   symbol; when count > 1, the ISO code is used instead of the symbol.
  /// - [isPending]: True when the transaction is in a future month (pending).
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.category,
    required this.parentCategory,
    required this.sourceAccount,
    required this.destinationAccount,
    required this.homeCurrency,
    required this.usedCurrencySymbols,
    required this.isPending,
  });

  /// The domain transaction to render.
  final Transaction transaction;

  /// Resolved category; null for transfers.
  final Category? category;

  /// Parent category; non-null when [category] is a subcategory.
  final Category? parentCategory;

  /// Resolved source account (expense / transfer source).
  final Account? sourceAccount;

  /// Resolved destination account (income / transfer destination).
  final Account? destinationAccount;

  /// Home currency ISO 4217 code (used to determine foreign-currency rows).
  final String homeCurrency;

  /// Maps currency symbols to the number of currencies sharing that symbol.
  ///
  /// When a symbol is shared by ≥2 currencies, the ISO code is shown instead.
  final Map<String, int> usedCurrencySymbols;

  /// True when the transaction is in a future month (pending styling).
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typo = Theme.of(context).extension<VarianceTypography>()!;
    final colors = Theme.of(context).extension<VarianceColors>()!;

    // Pending rows use muted styling.
    final textColor =
        isPending ? colorScheme.onSurfaceVariant : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // C1: Leading — category icon / transfer label
          _TransactionLeading(
            transaction: transaction,
            category: category,
            parentCategory: parentCategory,
            isPending: isPending,
            typo: typo,
            colorScheme: colorScheme,
          ),

          const SizedBox(width: 12),

          // C2: Title / account info (expands)
          Expanded(
            child: _TransactionMiddle(
              transaction: transaction,
              sourceAccount: sourceAccount,
              destinationAccount: destinationAccount,
              textColor: textColor,
              typo: typo,
              colorScheme: colorScheme,
            ),
          ),

          const SizedBox(width: 8),

          // C3: Amount + optional FX row
          _TransactionTrailing(
            transaction: transaction,
            homeCurrency: homeCurrency,
            usedCurrencySymbols: usedCurrencySymbols,
            isPending: isPending,
            typo: typo,
            colors: colors,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// C1: Leading — category icon + names / "Transfer" label
// ---------------------------------------------------------------------------

/// C1 column: category icon + parent/sub names, or "Transfer" label.
///
/// Shows a [Badge] overlay labelled "Pending" when [isPending] is true.
class _TransactionLeading extends StatelessWidget {
  const _TransactionLeading({
    required this.transaction,
    required this.category,
    required this.parentCategory,
    required this.isPending,
    required this.typo,
    required this.colorScheme,
  });

  final Transaction transaction;
  final Category? category;
  final Category? parentCategory;
  final bool isPending;
  final VarianceTypography typo;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (transaction.type == TransactionType.transfer) {
      return _TransferLabel(typo: typo, colorScheme: colorScheme);
    }

    // Resolve icon from category.
    final iconData = category != null
        ? kCategoryIcons[category!.iconRef] ?? Symbols.category
        : Symbols.category;

    // When [parentCategory] is non-null, [category] is a subcategory.
    // Display parent name on row 1, subcategory name on row 2.
    final displayName =
        parentCategory != null ? parentCategory!.name : (category?.name ?? '');
    final subName = parentCategory != null ? category?.name : null;

    return SizedBox(
      width: 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon with optional pending badge overlay.
          if (isPending)
            Badge(
              key: const Key('tx_row_pending_badge'),
              backgroundColor: colorScheme.tertiary,
              textColor: colorScheme.onTertiary,
              label: const Text('•'),
              child: Icon(
                iconData,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            Icon(
              iconData,
              size: 24,
              color: colorScheme.onSurfaceVariant,
            ),

          const SizedBox(height: 2),

          // Parent category name (or root name).
          Text(
            displayName,
            style: TextStyle(
              fontSize: typo.bodySmall,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          // Subcategory name (row 2) — only if present.
          if (subName != null) ...[
            Text(
              subName,
              style: TextStyle(
                fontSize: typo.bodySmall,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Label widget for transfer rows in C1 (no icon).
class _TransferLabel extends StatelessWidget {
  const _TransferLabel({
    required this.typo,
    required this.colorScheme,
  });

  final VarianceTypography typo;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 24,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 2),
          Text(
            'Transfer',
            style: TextStyle(
              fontSize: typo.bodySmall,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// C2: Middle — title + account info
// ---------------------------------------------------------------------------

/// C2 column: transaction title and account information.
class _TransactionMiddle extends StatelessWidget {
  const _TransactionMiddle({
    required this.transaction,
    required this.sourceAccount,
    required this.destinationAccount,
    required this.textColor,
    required this.typo,
    required this.colorScheme,
  });

  final Transaction transaction;
  final Account? sourceAccount;
  final Account? destinationAccount;
  final Color textColor;
  final VarianceTypography typo;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final title = transaction.title ?? '';
    final accountInfo = _resolveAccountInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: title (bodyLarge, onSurface)
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              fontSize: typo.bodyLarge,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

        // Row 2: account info (bodySmall, onSurfaceVariant)
        if (accountInfo.isNotEmpty)
          Text(
            accountInfo,
            style: TextStyle(
              fontSize: typo.bodySmall,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// Resolves the account info string based on transaction type.
  ///
  /// - Expense: source account name.
  /// - Income: destination account name.
  /// - Transfer: "Source → Destination".
  String _resolveAccountInfo() {
    switch (transaction.type) {
      case TransactionType.expense:
        return sourceAccount?.name ?? '';
      case TransactionType.income:
        return destinationAccount?.name ?? '';
      case TransactionType.transfer:
        final src = sourceAccount?.name ?? '';
        final dst = destinationAccount?.name ?? '';
        if (src.isEmpty && dst.isEmpty) return '';
        if (src.isEmpty) return dst;
        if (dst.isEmpty) return src;
        return '$src → $dst';
    }
  }
}

// ---------------------------------------------------------------------------
// C3: Trailing — amount + optional FX equivalent
// ---------------------------------------------------------------------------

/// C3 column: amount with currency symbol and optional FX equivalent row.
class _TransactionTrailing extends StatelessWidget {
  const _TransactionTrailing({
    required this.transaction,
    required this.homeCurrency,
    required this.usedCurrencySymbols,
    required this.isPending,
    required this.typo,
    required this.colors,
    required this.colorScheme,
  });

  final Transaction transaction;
  final String homeCurrency;
  final Map<String, int> usedCurrencySymbols;
  final bool isPending;
  final VarianceTypography typo;
  final VarianceColors colors;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final amountColor = _resolveAmountColor();
    final amountStr = _formatAmount();
    final isForeignCurrency = transaction.currencyCode != homeCurrency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Row 1: amount + currency symbol
        Text(
          amountStr,
          style: TextStyle(
            fontSize: typo.numericMedium,
            color: amountColor,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Row 2: FX equivalent (only for foreign-currency accounts)
        if (isForeignCurrency && transaction.exchangeRateMicro != null)
          _FxEquivalentText(
            transaction: transaction,
            homeCurrency: homeCurrency,
            typo: typo,
            colorScheme: colorScheme,
          ),
      ],
    );
  }

  /// Resolves the amount display color based on transaction type.
  Color _resolveAmountColor() {
    if (isPending) return colorScheme.onSurfaceVariant;
    return switch (transaction.type) {
      TransactionType.income => colors.incomeAmount,
      TransactionType.expense => colors.expenseAmount,
      TransactionType.transfer => colorScheme.onSurface,
    };
  }

  /// Formats the transaction amount with currency symbol or ISO code.
  ///
  /// Uses the ISO code when ≥2 currencies share the same symbol
  /// (disambiguation per UX flows §6.8.2).
  String _formatAmount() {
    final minor = transaction.amountMinor;
    final major = minor / 100.0;
    // Determine whether to show ISO code or symbol.
    final currencyCode = transaction.currencyCode;
    final symbol = _getCurrencySymbol(currencyCode);
    return '$symbol${major.toStringAsFixed(2)}';
  }

  /// Returns the currency symbol or ISO code for [code].
  String _getCurrencySymbol(String code) {
    // Map of ISO codes to symbols (minimal set; extend as needed).
    const symbolMap = {
      'INR': '₹',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'KRW': '₩',
      'RUB': '₽',
      'BRL': 'R\$',
      'MXN': '\$',
      'CAD': 'CA\$',
      'AUD': 'A\$',
      'SGD': 'S\$',
      'HKD': 'HK\$',
      'CHF': 'Fr.',
    };

    final symbol = symbolMap[code];
    if (symbol == null) return '$code ';

    // Disambiguation: use ISO code when ≥2 currencies share a symbol.
    final count = usedCurrencySymbols[symbol] ?? 1;
    if (count > 1) return '$code ';

    return symbol;
  }
}

/// Inline FX equivalent text shown on row 2 of C3 for foreign-currency rows.
class _FxEquivalentText extends StatelessWidget {
  const _FxEquivalentText({
    required this.transaction,
    required this.homeCurrency,
    required this.typo,
    required this.colorScheme,
  });

  final Transaction transaction;
  final String homeCurrency;
  final VarianceTypography typo;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final rateMicro = transaction.exchangeRateMicro;
    if (rateMicro == null) return const SizedBox.shrink();

    // Convert: (amountMinor / 100) * (rateMicro / 1_000_000)
    final foreignMajor = transaction.amountMinor / 100.0;
    final rate = rateMicro / 1000000.0;
    final homeAmount = foreignMajor * rate;

    final capture = transaction.homeCurrencyAtCapture ?? homeCurrency;

    return Text(
      key: const Key('tx_row_fx_equivalent'),
      '$capture ${homeAmount.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: typo.numericSmall,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
