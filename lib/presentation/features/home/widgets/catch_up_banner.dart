// lib/presentation/features/home/widgets/catch_up_banner.dart
//
// CatchUpBanner — displays the count of recurring transactions auto-posted
// during the current app-launch sweep (T-171).
//
// Behaviour (UX Flows §6.6):
//   - Visible when GetCatchUpBannerUseCase returns a non-empty list.
//   - Renders SizedBox.shrink() when result is empty.
//   - Message: "[N] recurring transaction(s) were auto-posted while you were away."
//   - "View details" TextButton calls FilterNotifier to scope the transaction
//     list to auto-posted entries. Uses a date-based filter (today) since the
//     DB has no per-session auto_post_timestamp.
//   - Banner uses FilledCard with surfaceContainerHigh background (M3 spec).
//   - Session-dismissable: close button hides banner without persisting state.
//
// Test cases (see test/presentation/features/home/catch_up_banner_test.dart):
//   T-171.1  Banner absent when use case returns empty list
//   T-171.2  Banner shown when use case returns non-empty list
//   T-171.3  Correct N appears in the banner message
//   T-171.4  "View details" tap calls FilterNotifier with correct date range
//   T-171.5  Dismiss hides the banner without rebuilding provider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/usecases/home/get_catch_up_banner_use_case.dart';
import 'package:variance/presentation/providers/filter_providers.dart'
    show filterProvider;
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// CatchUpBanner
// ---------------------------------------------------------------------------

/// Session-dismissable banner shown when recurring transactions were
/// auto-posted during the app-launch sweep (T-171).
///
/// Renders [SizedBox.shrink] when the use case returns an empty list.
/// Internally manages dismiss state with a local [StatefulWidget].
class CatchUpBanner extends ConsumerStatefulWidget {
  /// Creates a [CatchUpBanner].
  const CatchUpBanner({super.key});

  @override
  ConsumerState<CatchUpBanner> createState() => _CatchUpBannerState();
}

class _CatchUpBannerState extends ConsumerState<CatchUpBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final useCaseAsync = ref.watch(getCatchUpBannerUseCaseProvider);

    return useCaseAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (useCase) => _CatchUpBannerContent(
        useCase: useCase,
        onDismiss: () {
          if (mounted) setState(() => _dismissed = true);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content widget
// ---------------------------------------------------------------------------

/// Loads and renders the catch-up banner content.
///
/// Calls [useCase] and renders nothing when the result is empty.
class _CatchUpBannerContent extends StatefulWidget {
  const _CatchUpBannerContent({
    required this.useCase,
    required this.onDismiss,
  });

  final GetCatchUpBannerUseCase useCase;
  final VoidCallback onDismiss;

  @override
  State<_CatchUpBannerContent> createState() => _CatchUpBannerContentState();
}

class _CatchUpBannerContentState extends State<_CatchUpBannerContent> {
  List<RecurringTemplate>? _templates = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.useCase.call();
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        setState(() {
          _templates = value;
          _loaded = true;
        });
      case Err():
        setState(() {
          _templates = [];
          _loaded = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final templates = _templates;
    if (templates == null || templates.isEmpty) return const SizedBox.shrink();

    return _CatchUpBannerCard(
      count: templates.length,
      onDismiss: widget.onDismiss,
    );
  }
}

// ---------------------------------------------------------------------------
// Card widget
// ---------------------------------------------------------------------------

/// The visible banner card with the auto-posted count and "View details" CTA.
///
/// Uses [FilledCard] with [colorScheme.surfaceContainerHigh] as per M3 spec
/// (ui-spec §5.1.1 Components).
class _CatchUpBannerCard extends ConsumerWidget {
  const _CatchUpBannerCard({
    required this.count,
    required this.onDismiss,
  });

  /// Number of auto-posted transactions to display in the banner message.
  final int count;

  /// Called when the user taps the dismiss button.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final txWord = count == 1 ? 'transaction' : 'transactions';
    final message =
        '$count recurring $txWord were auto-posted while you were away.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        key: const Key('catch_up_banner_card'),
        color: cs.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.autorenew_rounded,
                size: 18,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message.
                    Text(
                      message,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // "View details" CTA.
                    TextButton(
                      key: const Key('catch_up_view_details'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 28),
                      ),
                      onPressed: () => _onViewDetails(context, ref),
                      child: Text(
                        'View details',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Dismiss button.
              IconButton(
                key: const Key('catch_up_dismiss'),
                icon: const Icon(Icons.close),
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Dismiss',
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Applies a date-range filter scoped to today so the transaction list
  /// shows only the auto-posted entries from this session.
  void _onViewDetails(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    ref.read(filterProvider.notifier).setDateRange(
          DateTimeRange(start: startOfDay, end: endOfDay),
        );
  }
}
