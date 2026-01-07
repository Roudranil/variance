import 'package:flutter/material.dart';

/// A Material 3 filled card container for grouping related settings.
///
/// This widget provides a consistent visual style for settings sections,
/// using a filled card appearance with rounded corners and subtle background.
class SettingsCard extends StatelessWidget {
  /// Creates a new instance of [SettingsCard].
  ///
  /// Parameters:
  /// - [title]: The header text displayed above the card content.
  /// - [children]: The list of widgets (typically ListTiles) to display.
  const SettingsCard({required this.title, required this.children, super.key});

  /// The header text displayed above the card content.
  final String title;

  /// The list of child widgets displayed within the card.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section header
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
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
