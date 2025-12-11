/// POS Module - Complete Point of Sale system
/// 
/// This module provides a full-featured POS (Point of Sale) system with:
/// - Desktop and mobile responsive layouts
/// - Order context management (Table, Sur place, À emporter)
/// - Payment method selection
/// - Cart management
/// - Kitchen integration preparation
/// 
/// ## Usage
/// 
/// The POS system is accessible to admin users only via the `/pos` route.
/// 
/// ### Desktop/Tablet Layout (>= 800px width)
/// - 3-column layout: Products | Cart | Actions
/// - Full catalog view with category tabs
/// - Real-time cart updates
/// - Payment method selector
/// 
/// ### Mobile Layout (< 800px width)
/// - Full-screen product grid
/// - Floating cart button with badge
/// - Modal bottom sheet for cart and checkout
/// - Optimized for one-handed operation
/// 
/// ### Order Context
/// - Table service (requires table number selection)
/// - Sur place (on-site without table)
/// - À emporter (takeaway)
/// 
/// ### Payment Methods
/// - Cash (Espèces)
/// - Card (Carte bancaire)
/// - Other (Autre)
/// 
/// ## Architecture
/// 
/// The POS module follows clean architecture principles:
/// 
/// - **Models**: Data structures (PosCartItem, PosOrder, PosContext, PosPaymentMethod)
/// - **Providers**: State management with Riverpod (cart, context, payment, order)
/// - **Screens**: UI layouts (desktop, mobile, checkout)
/// - **Widgets**: Reusable UI components (product grid, cart panel, etc.)
/// 
/// ## Module Protection
/// 
/// The POS is protected by a custom guard that:
/// - Allows ALL admin users to access POS (regardless of module status)
/// - Blocks ALL non-admin users from accessing POS
/// - Is associated with staff_tablet and paymentTerminal modules
/// 
library;

// Models
export 'models/pos_cart_item.dart';
export 'models/pos_context.dart';
export 'models/pos_order.dart';
export 'models/pos_payment_method.dart';

// Providers
export 'providers/pos_cart_provider.dart';
export 'providers/pos_context_provider.dart';
export 'providers/pos_order_provider.dart';
export 'providers/pos_payment_provider.dart';

// Screens
export 'screens/pos_screen.dart';
export 'screens/pos_screen_desktop.dart';
export 'screens/pos_screen_mobile.dart';
export 'screens/pos_checkout_sheet.dart';
export 'screens/pos_table_selector.dart';

// Widgets
export 'widgets/cart_item_row.dart';
export 'widgets/cart_panel.dart';
export 'widgets/payment_selector.dart';
export 'widgets/pos_actions_panel_new.dart';
export 'widgets/pos_context_bar.dart';
export 'widgets/product_card.dart';
export 'widgets/product_grid.dart';

// Routes
export 'pos_routes.dart';

// Guard
export 'pos_guard.dart';
