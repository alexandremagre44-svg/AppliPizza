/// lib/src/navigation/module_route_guards.dart
///
/// Guards de navigation pour protéger les routes selon les modules activés.
///
/// Ces widgets wrapper vérifient si un module est actif avant d'afficher
/// le contenu. Si le module est inactif, ils redirigent ou affichent un fallback.
///
/// IMPORTANT: Ces guards ne modifient PAS les écrans existants.
/// Ils servent de couche de protection autour des routes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../white_label/core/module_id.dart';
import '../providers/restaurant_plan_provider.dart';
import '../core/constants.dart';

/// Page fallback affichée quand un module est désactivé.
class ModuleDisabledScreen extends StatelessWidget {
  final String moduleName;
  final String? redirectRoute;

  const ModuleDisabledScreen({
    required this.moduleName,
    this.redirectRoute,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-redirect si une route est spécifiée
    if (redirectRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(redirectRoute!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Module non disponible'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                'Module "$moduleName" désactivé',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ce module n\'est pas activé pour ce restaurant.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                icon: const Icon(Icons.home),
                label: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Guard générique pour protéger une route selon un module.
class ModuleRouteGuard extends ConsumerWidget {
  final ModuleId requiredModule;
  final Widget child;
  final String? fallbackRoute;
  final bool silentRedirect;

  const ModuleRouteGuard({
    required this.requiredModule,
    required this.child,
    this.fallbackRoute,
    this.silentRedirect = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);

    return planAsync.when(
      data: (plan) {
        if (plan == null) {
          // Pas de plan chargé, afficher fallback
          if (silentRedirect && fallbackRoute != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(fallbackRoute!);
            });
            return const SizedBox.shrink();
          }
          return ModuleDisabledScreen(
            moduleName: requiredModule.label,
            redirectRoute: fallbackRoute,
          );
        }

        final isActive = plan.hasModule(requiredModule);
        
        if (isActive) {
          return child;
        } else {
          // Module inactif
          if (silentRedirect && fallbackRoute != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(fallbackRoute!);
            });
            return const SizedBox.shrink();
          }
          return ModuleDisabledScreen(
            moduleName: requiredModule.label,
            redirectRoute: fallbackRoute,
          );
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) {
        // En cas d'erreur, rediriger ou afficher fallback
        if (fallbackRoute != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(fallbackRoute!);
          });
          return const SizedBox.shrink();
        }
        return ModuleDisabledScreen(
          moduleName: requiredModule.label,
          redirectRoute: AppRoutes.home,
        );
      },
    );
  }
}

/// Guard pour le module de livraison.
Widget deliveryRouteGuard(Widget child, {String? fallbackRoute}) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.delivery,
    fallbackRoute: fallbackRoute ?? AppRoutes.home,
    child: child,
  );
}

/// Guard pour le module de fidélité.
Widget loyaltyRouteGuard(Widget child, {String? fallbackRoute}) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.loyalty,
    fallbackRoute: fallbackRoute ?? AppRoutes.home,
    child: child,
  );
}

/// Guard pour le module roulette.
Widget rouletteRouteGuard(Widget child, {String? fallbackRoute}) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.roulette,
    fallbackRoute: fallbackRoute ?? AppRoutes.home,
    child: child,
  );
}

/// Guard pour le module promotions.
Widget promotionsRouteGuard(Widget child, {String? fallbackRoute}) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.promotions,
    fallbackRoute: fallbackRoute ?? AppRoutes.home,
    child: child,
  );
}

/// Guard pour le module Click & Collect.
Widget clickAndCollectRouteGuard(Widget child, {String? fallbackRoute}) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.clickAndCollect,
    fallbackRoute: fallbackRoute ?? AppRoutes.home,
    child: child,
  );
}

/// Guard pour le module newsletter.
Widget newsletterRouteGuard(Widget child, {String? fallbackRoute}) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.newsletter,
    fallbackRoute: fallbackRoute ?? AppRoutes.home,
    child: child,
  );
}

/// Guard pour le module tablette cuisine.
Widget kitchenRouteGuard(Widget child, {String? fallbackRoute}) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.kitchen_tablet,
    fallbackRoute: fallbackRoute ?? AppRoutes.home,
    child: child,
  );
}

/// Guard pour le module tablette staff.
Widget staffTabletRouteGuard(Widget child, {String? fallbackRoute}) {
  return ModuleRouteGuard(
    requiredModule: ModuleId.staff_tablet,
    fallbackRoute: fallbackRoute ?? AppRoutes.home,
    child: child,
  );
}
