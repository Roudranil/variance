// lib/presentation/features/settings/categories/category_icons.dart
//
// Curated icon set for category selection.
//
// Used by CategoryDetailScreen (icon picker modal) and CategoryPickerSheet.

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Curated ~40 Material Symbols icons available for category selection.
///
/// Keys are used as [Category.iconRef] values stored in the database.
/// Values are the corresponding Flutter [IconData] objects.
const Map<String, IconData> kCategoryIcons = {
  'shopping_cart': Symbols.shopping_cart,
  'restaurant': Symbols.restaurant,
  'directions_car': Symbols.directions_car,
  'home': Symbols.home,
  'local_hospital': Symbols.local_hospital,
  'school': Symbols.school,
  'sports_esports': Symbols.sports_esports,
  'flight': Symbols.flight,
  'work': Symbols.work,
  'coffee': Symbols.coffee,
  'local_grocery_store': Symbols.local_grocery_store,
  'fitness_center': Symbols.fitness_center,
  'movie': Symbols.movie,
  'music_note': Symbols.music_note,
  'pets': Symbols.pets,
  'phone': Symbols.phone,
  'laptop': Symbols.laptop,
  'local_pharmacy': Symbols.local_pharmacy,
  'savings': Symbols.savings,
  'payments': Symbols.payments,
  'credit_card': Symbols.credit_card,
  'attach_money': Symbols.attach_money,
  'trending_up': Symbols.trending_up,
  'business': Symbols.business,
  'category': Symbols.category,
  'label': Symbols.label,
  'receipt': Symbols.receipt,
  'local_taxi': Symbols.local_taxi,
  'two_wheeler': Symbols.two_wheeler,
  'electric_bolt': Symbols.electric_bolt,
  'water_drop': Symbols.water_drop,
  'wifi': Symbols.wifi,
  'tv': Symbols.tv,
  'book': Symbols.book,
  'sports': Symbols.sports,
  'beach_access': Symbols.beach_access,
  'park': Symbols.park,
  'child_care': Symbols.child_care,
  'cake': Symbols.cake,
  'nightlife': Symbols.nightlife,
};
