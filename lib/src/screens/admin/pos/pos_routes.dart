// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/admin/pos/pos_routes.dart
// Route constants and helpers for POS module

import '../../../core/constants.dart';

/// Routes pour le module POS (Caisse)
/// 
/// Note: La route principale est définie dans AppRoutes.pos pour éviter la duplication.
/// Cette classe contient les sous-routes spécifiques au module POS.
class PosRoutes {
  /// Route principale de la caisse (référence à AppRoutes.pos)
  static String get main => AppRoutes.pos;
  
  // Future routes for POS sub-sections (Phase 2+)
  // static const String history = '${AppRoutes.pos}/history';
  // static const String settings = '${AppRoutes.pos}/settings';
}
