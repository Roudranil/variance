// lib/presentation/features/home/widgets/home_speed_dial.dart
//
// HomeSpeedDial — the floating action button with speed-dial expansion for the
// Home screen (T-165, T-166).
//
// Architecture:
//   - Collapsed: large FAB with Icons.add, primaryContainer colours.
//   - Expanded: scrim overlay (ColoredBox using scrim colour) that collapses
//     on tap; 3 SmallFABs stacked above anchor with right-aligned text labels.
//     Optionally a 4th "Drafts" action when back_button_behaviour = auto_save_draft.
//   - Local ValueNotifier<bool> tracks expanded/collapsed state.
//   - FAB is hidden (Visibility) while the search overlay is active.
//   - Navigates to /transaction/new?type=expense|income|transfer on each action.
//   - Navigates to /drafts when the Drafts action is tapped.
//
// M3 Spec (ui-spec §5.1.3):
//   - Expense:  Icons.arrow_upward,  errorContainer / onErrorContainer
//   - Income:   Icons.arrow_downward, secondaryContainer / onSecondaryContainer
//   - Transfer: Icons.swap_horiz,    tertiaryContainer / onTertiaryContainer
//   - Drafts:   Icons.drafts_outlined, surfaceContainerHigh / onSurface
//
// Test cases (see test/presentation/features/home/home_speed_dial_test.dart):
//   T-165.1  Three actions render when expanded
//   T-165.2  Scrim tap collapses the dial
//   T-165.3  Each action navigates with correct type param
//   T-165.4  FAB hidden while search is active
//   T-166.1  Drafts action present when back_button_behaviour = auto_save_draft
//   T-166.2  Drafts action absent when back_button_behaviour != auto_save_draft

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/search_providers.dart';

// ---------------------------------------------------------------------------
// HomeSpeedDial
// ---------------------------------------------------------------------------

/// Speed-dial FAB for the Home screen with Expense, Income, Transfer (and
/// optional Drafts) actions.
///
/// The FAB is automatically hidden while the search overlay is active.
/// Expansion state is managed by a local [ValueNotifier]; the scrim and
/// the anchor FAB both collapse the dial.
///
/// Navigation callbacks must be provided by the caller (typically the
/// containing [HomeScreen]) to avoid direct navigation coupling.
class HomeSpeedDial extends ConsumerStatefulWidget {
  /// Creates a [HomeSpeedDial].
  ///
  /// Parameters:
  /// - [onExpense]: Called when the Expense action is tapped.
  /// - [onIncome]: Called when the Income action is tapped.
  /// - [onTransfer]: Called when the Transfer action is tapped.
  /// - [onDrafts]: Called when the Drafts action is tapped.
  const HomeSpeedDial({
    required this.onExpense,
    required this.onIncome,
    required this.onTransfer,
    required this.onDrafts,
    super.key,
  });

  /// Callback invoked when the Expense action is tapped.
  final VoidCallback onExpense;

  /// Callback invoked when the Income action is tapped.
  final VoidCallback onIncome;

  /// Callback invoked when the Transfer action is tapped.
  final VoidCallback onTransfer;

  /// Callback invoked when the Drafts action is tapped.
  final VoidCallback onDrafts;

  @override
  ConsumerState<HomeSpeedDial> createState() => _HomeSpeedDialState();
}

class _HomeSpeedDialState extends ConsumerState<HomeSpeedDial> {
  // Local notifier tracks expanded/collapsed without rebuilding the whole tree.
  final ValueNotifier<bool> _expanded = ValueNotifier(false);

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch search state — FAB is hidden while search overlay is open.
    final isSearchActive = ref.watch(
      searchProvider.select((SearchState s) => s.isActive),
    );

    // Watch settings to determine whether to show Drafts action (T-166).
    final backBehaviour = ref.watch(
      appSettingsProvider.select(
        (AsyncValue<AppSettings> s) =>
            s.value?.backButtonBehaviour ?? BackButtonBehaviour.ask,
      ),
    );
    final showDrafts = backBehaviour == BackButtonBehaviour.autoSaveDraft;

    return Visibility(
      visible: !isSearchActive,
      child: ValueListenableBuilder<bool>(
        valueListenable: _expanded,
        builder: (context, expanded, _) {
          if (!expanded) {
            // Collapsed state: single large FAB.
            return _CollapsedFab(
              onTap: () => _expanded.value = true,
            );
          }

          // Expanded state: scrim + stacked small FABs above anchor.
          return _ExpandedDial(
            showDrafts: showDrafts,
            onCollapse: () => _expanded.value = false,
            onExpense: () {
              _expanded.value = false;
              widget.onExpense();
            },
            onIncome: () {
              _expanded.value = false;
              widget.onIncome();
            },
            onTransfer: () {
              _expanded.value = false;
              widget.onTransfer();
            },
            onDrafts: () {
              _expanded.value = false;
              widget.onDrafts();
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Collapsed FAB
// ---------------------------------------------------------------------------

/// Large [FloatingActionButton] in the collapsed SpeedDial state.
class _CollapsedFab extends StatelessWidget {
  const _CollapsedFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton(
      key: const Key('fab_collapsed'),
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      onPressed: onTap,
      child: const Icon(Icons.add),
    );
  }
}

// ---------------------------------------------------------------------------
// Expanded dial
// ---------------------------------------------------------------------------

/// Expanded speed-dial: scrim overlay + small FABs stacked above the anchor.
///
/// The scrim spans the full screen and collapses the dial when tapped.
/// Each action renders as a [_SpeedDialAction] with a right-aligned label.
class _ExpandedDial extends StatelessWidget {
  const _ExpandedDial({
    required this.showDrafts,
    required this.onCollapse,
    required this.onExpense,
    required this.onIncome,
    required this.onTransfer,
    required this.onDrafts,
  });

  /// Whether to show the Drafts entry point (T-166).
  final bool showDrafts;

  final VoidCallback onCollapse;
  final VoidCallback onExpense;
  final VoidCallback onIncome;
  final VoidCallback onTransfer;
  final VoidCallback onDrafts;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Full-screen scrim — tap to collapse.
        Positioned.fill(
          child: GestureDetector(
            key: const Key('speed_dial_scrim'),
            onTap: onCollapse,
            behavior: HitTestBehavior.opaque,
            child: ColoredBox(
              color: cs.scrim.withValues(alpha: 0.32),
            ),
          ),
        ),

        // Actions stacked above the anchor FAB.
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Drafts (optional — only when auto_save_draft enabled).
            if (showDrafts) ...[
              _SpeedDialAction(
                fabKey: const Key('fab_drafts'),
                icon: Icons.drafts_outlined,
                label: 'Drafts',
                backgroundColor: cs.surfaceContainerHigh,
                foregroundColor: cs.onSurface,
                onTap: onDrafts,
              ),
              const SizedBox(height: 8),
            ],

            // Transfer action.
            _SpeedDialAction(
              fabKey: const Key('fab_transfer'),
              icon: Icons.swap_horiz,
              label: 'Transfer',
              backgroundColor: cs.tertiaryContainer,
              foregroundColor: cs.onTertiaryContainer,
              onTap: onTransfer,
            ),
            const SizedBox(height: 8),

            // Income action.
            _SpeedDialAction(
              fabKey: const Key('fab_income'),
              icon: Icons.arrow_downward,
              label: 'Income',
              backgroundColor: cs.secondaryContainer,
              foregroundColor: cs.onSecondaryContainer,
              onTap: onIncome,
            ),
            const SizedBox(height: 8),

            // Expense action.
            _SpeedDialAction(
              fabKey: const Key('fab_expense'),
              icon: Icons.arrow_upward,
              label: 'Expense',
              backgroundColor: cs.errorContainer,
              foregroundColor: cs.onErrorContainer,
              onTap: onExpense,
            ),
            const SizedBox(height: 8),

            // Collapse FAB (tapping the anchor FAB again collapses the dial).
            FloatingActionButton(
              key: const Key('fab_collapse'),
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              onPressed: onCollapse,
              child: const Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Speed-dial action row
// ---------------------------------------------------------------------------

/// A single speed-dial action: right-aligned label + small FAB.
///
/// The [fabKey] is forwarded directly to the inner [FloatingActionButton.small]
/// so that tests can tap the FAB by key without hitting the label area.
class _SpeedDialAction extends StatelessWidget {
  const _SpeedDialAction({
    this.fabKey,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  /// Optional key forwarded to the inner [FloatingActionButton.small].
  final Key? fabKey;

  /// Icon displayed inside the small FAB.
  final IconData icon;

  /// Right-aligned text label shown beside the FAB.
  final String label;

  /// Background colour of the small FAB.
  final Color backgroundColor;

  /// Foreground (icon) colour of the small FAB.
  final Color foregroundColor;

  /// Callback invoked when the action is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label card for readability against dark scrim.
        Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // The fabKey is placed directly on the FAB so tests can tap it.
        FloatingActionButton.small(
          key: fabKey,
          heroTag: 'speed_dial_$label',
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          onPressed: onTap,
          child: Icon(icon),
        ),
      ],
    );
  }
}
