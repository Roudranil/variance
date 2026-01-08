import 'package:flutter/material.dart';

/// A Material 3 filled card container for grouping related list items.
///
/// This is a reusable pattern for displaying grouped content with a header,
/// optional leading icon, and list of children. Used in Settings, Account
/// Management, and Category Management screens.
class GroupedListCard extends StatelessWidget {
  /// Creates a new instance of [GroupedListCard].
  ///
  /// Parameters:
  /// - [title]: The header text displayed above the card content.
  /// - [children]: The list of widgets (typically ListTiles) to display.
  /// - [leadingIcon]: Optional icon displayed beside the title.
  const GroupedListCard({
    required this.title,
    required this.children,
    this.leadingIcon,
    super.key,
  });

  /// The header text displayed above the card content.
  final String title;

  /// The list of child widgets displayed within the card.
  final List<Widget> children;

  /// Optional icon displayed beside the title.
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section header with optional icon
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // filled card container
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withAlpha(128),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: IconTheme(
              data: IconThemeData(color: colorScheme.primary),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}
