# 🔍 AUDIT DÉTAILLÉ DES VIOLATIONS - THÈME WL V2

**Généré le**: 2025-12-17 13:19:50

## 📊 STATISTIQUES GLOBALES

- **Colors.\* violations**: 3036 occurrences
- **Color(0x...) violations**: 253 occurrences
- **BorderRadius.circular violations**: 663 occurrences
- **TextStyle() violations**: 938 occurrences

---

## 🔴 TOP 20 FICHIERS - Colors.* Hardcodés

| Fichier | Violations |
|---------|-----------|
| `lib/src/design_system/app_theme.dart` | 116 |
| `lib/builder/editor/builder_page_editor_screen.dart` | 65 |
| `lib/src/staff_tablet/widgets/staff_menu_customization_modal.dart` | 63 |
| `lib/src/staff_tablet/screens/staff_tablet_checkout_screen.dart` | 58 |
| `lib/src/staff_tablet/screens/staff_tablet_history_screen.dart` | 54 |
| `lib/src/screens/home/elegant_pizza_customization_modal.dart` | 54 |
| `lib/src/staff_tablet/widgets/staff_tablet_cart_summary.dart` | 52 |
| `lib/superadmin/pages/restaurant_detail_page.dart` | 48 |
| `lib/src/design_system/badges.dart` | 47 |
| `lib/builder/blocks/system_block_runtime.dart` | 47 |
| `lib/superadmin/pages/restaurant_wizard/wizard_step_preview.dart` | 45 |
| `lib/src/staff_tablet/screens/staff_tablet_catalog_screen.dart` | 45 |
| `lib/superadmin/pages/restaurant_modules_page.dart` | 44 |
| `lib/src/design_system/pos_components.dart` | 44 |
| `lib/src/screens/menu/menu_customization_modal.dart` | 43 |
| `lib/src/screens/home/pizza_customization_modal.dart` | 43 |
| `lib/src/staff_tablet/widgets/staff_pizza_customization_modal.dart` | 42 |
| `lib/src/screens/admin/pos/widgets/pos_cart_panel_v2.dart` | 42 |
| `lib/src/screens/roulette/roulette_screen.dart` | 40 |
| `lib/src/screens/profile/profile_screen.dart` | 40 |

## 🟠 TOP 20 FICHIERS - Color(0x...) Hardcodés

| Fichier | Violations |
|---------|-----------|
| `lib/src/design_system/colors.dart` | 61 |
| `lib/src/design_system/pos_design_system.dart` | 21 |
| `lib/src/kitchen/widgets/kitchen_colors.dart` | 12 |
| `lib/src/screens/admin/studio/roulette_segment_editor_screen.dart` | 11 |
| `lib/builder/blocks/category_list_block_preview.dart` | 10 |
| `lib/archived/superadmin/restaurants_list_page.dart` | 10 |
| `lib/white_label/runtime/theme_adapter.dart` | 9 |
| `lib/src/kitchen/kitchen_constants.dart` | 9 |
| `lib/superadmin/pages/restaurant_wizard/wizard_step_brand.dart` | 8 |
| `lib/superadmin/pages/restaurant_wizard/wizard_entry_page.dart` | 8 |
| `lib/superadmin/pages/restaurant_detail_page.dart` | 8 |
| `lib/superadmin/superadmin_app.dart` | 7 |
| `lib/src/models/theme_config.dart` | 7 |
| `lib/src/services/roulette_segment_service.dart` | 6 |
| `lib/builder/theme/builder_theme_adapter.dart` | 6 |
| `lib/superadmin/pages/restaurant_wizard/wizard_step_template.dart` | 5 |
| `lib/superadmin/pages/restaurant_wizard/wizard_step_cashier_profile.dart` | 5 |
| `lib/superadmin/pages/restaurant_wizard/wizard_step_preview.dart` | 4 |
| `lib/superadmin/pages/restaurant_wizard/wizard_step_modules.dart` | 4 |
| `lib/superadmin/pages/settings_page.dart` | 3 |

## 🔵 TOP 20 FICHIERS - BorderRadius.circular Hardcodés

| Fichier | Violations |
|---------|-----------|
| `lib/builder/editor/builder_page_editor_screen.dart` | 32 |
| `lib/src/screens/home/elegant_pizza_customization_modal.dart` | 27 |
| `lib/src/staff_tablet/widgets/staff_pizza_customization_modal.dart` | 23 |
| `lib/src/staff_tablet/widgets/staff_menu_customization_modal.dart` | 20 |
| `lib/src/screens/profile/profile_screen.dart` | 18 |
| `lib/superadmin/pages/restaurant_wizard/wizard_step_preview.dart` | 14 |
| `lib/src/staff_tablet/screens/staff_tablet_checkout_screen.dart` | 13 |
| `lib/builder/editor/panels/theme_properties_panel.dart` | 13 |
| `lib/white_label/runtime/theme_adapter.dart` | 12 |
| `lib/superadmin/pages/restaurant_detail_page.dart` | 12 |
| `lib/src/staff_tablet/screens/staff_tablet_history_screen.dart` | 12 |
| `lib/src/providers/theme_providers.dart` | 12 |
| `lib/builder/theme/builder_theme_adapter.dart` | 12 |
| `lib/builder/editor/widgets/builder_properties_panel.dart` | 12 |
| `lib/builder/blocks/system_block_runtime.dart` | 12 |
| `lib/white_label/theme/unified_theme_adapter.dart` | 11 |
| `lib/src/staff_tablet/widgets/staff_tablet_cart_summary.dart` | 11 |
| `lib/superadmin/pages/restaurant_wizard/wizard_step_brand.dart` | 10 |
| `lib/src/widgets/ingredient_selector.dart` | 10 |
| `lib/src/screens/admin/pos/widgets/pos_actions_panel_v2.dart` | 10 |

---

## 🎯 FICHIERS PRIORITAIRES (Top 10 Worst Offenders)

Fichiers avec le plus de violations combinées (Colors + Color(0x + BorderRadius):

- `lib/src/design_system/app_theme.dart` - **116 violations**
- `lib/builder/editor/builder_page_editor_screen.dart` - **97 violations**
- `lib/src/staff_tablet/widgets/staff_menu_customization_modal.dart` - **83 violations**
- `lib/src/screens/home/elegant_pizza_customization_modal.dart` - **81 violations**
- `lib/src/design_system/colors.dart` - **73 violations**
- `lib/src/staff_tablet/screens/staff_tablet_checkout_screen.dart` - **71 violations**
- `lib/superadmin/pages/restaurant_detail_page.dart` - **68 violations**
- `lib/src/staff_tablet/screens/staff_tablet_history_screen.dart` - **66 violations**
- `lib/src/staff_tablet/widgets/staff_pizza_customization_modal.dart` - **65 violations**
- `lib/src/staff_tablet/widgets/staff_tablet_cart_summary.dart` - **64 violations**

---

## 📂 VIOLATIONS PAR MODULE

### screens
- Colors.*: 775
- Color(0x...): 11
- BorderRadius: 136
- **Total**: 922

### widgets
- Colors.*: 171
- Color(0x...): 4
- BorderRadius: 21
- **Total**: 196

### superadmin
- Colors.*: 488
- Color(0x...): 70
- BorderRadius: 115
- **Total**: 673

### builder
- Colors.*: 551
- Color(0x...): 26
- BorderRadius: 199
- **Total**: 776

### design_system
- Colors.*: 441
- Color(0x...): 82
- BorderRadius: 17
- **Total**: 540

### white_label
- Colors.*: 117
- Color(0x...): 11
- BorderRadius: 36
- **Total**: 164

