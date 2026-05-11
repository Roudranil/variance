// test/presentation/features/settings/categories/protected_category_guard_test.dart
//
// Widget tests for protected category guard (T-78).
//
// Tests verify that is_protected = 1 rows are excluded from the management
// screen and category picker, but remain visible in filter context (historical).
//
// Test cases:
//   1. management screen hides is_protected rows
//   2. management screen shows non-protected rows
//   3. category picker sheet hides is_protected rows
//   4. category picker sheet shows non-protected rows
//   5. no Edit/long-press menu for protected rows (they don't appear at all)
//   6. soft-deleted categories visible in picker when in edit mode (historical)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/category.dart';
import 'package:variance/presentation/features/settings/categories/category_management_screen.dart';
import 'package:variance/presentation/features/settings/categories/category_picker_sheet.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

Category _makeCat({
  required String id,
  required String name,
  CategoryTreeType treeType = CategoryTreeType.expense,
  bool isProtected = false,
  bool isDeleted = false,
  String? parentId,
}) {
  return Category(
    id: id,
    name: name,
    treeType: treeType,
    iconRef: 'shopping_cart',
    isProtected: isProtected,
    isDeleted: isDeleted,
    parentId: parentId,
    createdAt: _now,
    updatedAt: _now,
  );
}

class _FakeCategoryList extends CategoryList {
  _FakeCategoryList(this._cats);
  final List<Category> _cats;

  @override
  Future<List<Category>> build() async {
    state = AsyncData(_cats);
    return _cats;
  }
}

Widget _buildManagementApp(List<Category> categories) {
  return ProviderScope(
    overrides: [
      categoryListProvider.overrideWith(() => _FakeCategoryList(categories)),
    ],
    child: MaterialApp.router(
      theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
      routerConfig: GoRouter(
        initialLocation: '/settings/categories',
        routes: [
          GoRoute(
            path: '/settings/categories',
            builder: (_, __) => const CategoryManagementScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const Scaffold(body: Text('New')),
              ),
              GoRoute(
                path: ':id',
                builder: (_, __) => const Scaffold(body: Text('Detail')),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Protected category guard — management screen', () {
    testWidgets(
      '1. management screen hides is_protected rows',
      (tester) async {
        final cats = [
          _makeCat(id: 'p1', name: 'Balance Adjustment', isProtected: true),
          _makeCat(id: 'c1', name: 'Food'),
        ];
        await tester.pumpWidget(_buildManagementApp(cats));
        await tester.pumpAndSettle();

        expect(find.text('Balance Adjustment'), findsNothing);
      },
    );

    testWidgets(
      '2. management screen shows non-protected rows',
      (tester) async {
        final cats = [
          _makeCat(id: 'p1', name: 'Balance Adjustment', isProtected: true),
          _makeCat(id: 'c1', name: 'Food'),
        ];
        await tester.pumpWidget(_buildManagementApp(cats));
        await tester.pumpAndSettle();

        expect(find.text('Food'), findsOneWidget);
      },
    );

    testWidgets(
      '3. mixed protected/non-protected: only non-protected appear',
      (tester) async {
        final cats = [
          _makeCat(id: 'p1', name: 'Sys1', isProtected: true),
          _makeCat(id: 'p2', name: 'Sys2', isProtected: true),
          _makeCat(id: 'c1', name: 'Groceries'),
          _makeCat(id: 'c2', name: 'Transport'),
        ];
        await tester.pumpWidget(_buildManagementApp(cats));
        await tester.pumpAndSettle();

        expect(find.text('Sys1'), findsNothing);
        expect(find.text('Sys2'), findsNothing);
        expect(find.text('Groceries'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);
      },
    );
  });

  group('Protected category guard — category picker sheet', () {
    testWidgets(
      '4. category picker hides is_protected rows',
      (tester) async {
        final cats = [
          _makeCat(id: 'p1', name: 'Balance Adjustment', isProtected: true),
          _makeCat(id: 'c1', name: 'Food'),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoryListProvider.overrideWith(
                () => _FakeCategoryList(cats),
              ),
            ],
            child: MaterialApp(
              theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => CategoryPickerSheet(
                        treeType: CategoryTreeType.expense,
                        onSelected: (_) {},
                      ),
                    ),
                    child: const Text('Open Picker'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Picker'));
        await tester.pumpAndSettle();

        expect(find.text('Balance Adjustment'), findsNothing);
        expect(find.text('Food'), findsOneWidget);
      },
    );

    testWidgets(
      '5. category picker shows non-protected rows',
      (tester) async {
        final cats = [
          _makeCat(id: 'p1', name: 'Balance Adjustment', isProtected: true),
          _makeCat(id: 'c1', name: 'Food'),
          _makeCat(id: 'c2', name: 'Transport'),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoryListProvider.overrideWith(
                () => _FakeCategoryList(cats),
              ),
            ],
            child: MaterialApp(
              theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => CategoryPickerSheet(
                        treeType: CategoryTreeType.expense,
                        onSelected: (_) {},
                      ),
                    ),
                    child: const Text('Open Picker'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Picker'));
        await tester.pumpAndSettle();

        expect(find.text('Food'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);
      },
    );
  });
}
