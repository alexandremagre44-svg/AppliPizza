/// lib/src/screens/delivery/delivery_area_selector_screen.dart
///
/// Écran de sélection de la zone de livraison.
///
/// Cet écran affiche:
/// - La liste des zones de livraison actives
/// - Les frais de livraison par zone
/// - Le montant minimum par zone
/// - Le délai estimé par zone

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/buttons.dart';
import '../../design_system/cards.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/restaurant_plan_provider.dart';
import '../../../white_label/core/module_id.dart';
import '../../../white_label/modules/core/delivery/delivery_area.dart';
import '../../../white_label/modules/core/delivery/delivery_settings.dart';
import 'delivery_not_available_widget.dart';

/// Écran de sélection de la zone de livraison.
class DeliveryAreaSelectorScreen extends ConsumerStatefulWidget {
  const DeliveryAreaSelectorScreen({super.key});

  @override
  ConsumerState<DeliveryAreaSelectorScreen> createState() =>
      _DeliveryAreaSelectorScreenState();
}

class _DeliveryAreaSelectorScreenState
    extends ConsumerState<DeliveryAreaSelectorScreen> {
  DeliveryArea? _selectedArea;

  @override
  void initState() {
    super.initState();
    // Pré-sélectionner la zone existante si disponible
    final deliveryState = ref.read(deliveryProvider);
    _selectedArea = deliveryState.selectedArea;
  }

  void _onAreaSelected(DeliveryArea area) {
    setState(() {
      _selectedArea = area;
    });
  }

  void _onConfirm() {
    if (_selectedArea != null) {
      // Sauvegarder la zone sélectionnée
      ref.read(deliveryProvider.notifier).setArea(_selectedArea!);

      // Retourner au checkout avec les informations de livraison
      context.go('/checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    final flags = ref.watch(restaurantFeatureFlagsProvider);
    final deliverySettings = ref.watch(deliverySettingsProvider);
    final deliveryState = ref.watch(deliveryProvider);

    // Guard: Vérifier si le module livraison est activé
    if (!(flags?.has(ModuleId.delivery) ?? false)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Zone de livraison'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Le module livraison n\'est pas disponible'),
        ),
      );
    }

    // Vérifier si l'adresse a été saisie
    if (deliveryState.selectedAddress == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Zone de livraison'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: AppColors.neutral400),
              const SizedBox(height: AppSpacing.md),
              const Text('Veuillez d\'abord saisir votre adresse'),
              const SizedBox(height: AppSpacing.md),
              AppButton.primary(
                text: 'Saisir mon adresse',
                onPressed: () => context.go('/delivery/address'),
              ),
            ],
          ),
        ),
      );
    }

    // Récupérer les zones actives
    final activeAreas = deliverySettings?.activeAreas ?? [];

    // Chercher une zone correspondant au code postal
    final postalCode = deliveryState.selectedAddress!.postalCode;
    final matchingArea = deliverySettings?.findAreaByPostalCode(postalCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Zone de livraison',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: activeAreas.isEmpty
          ? _buildNoAreasAvailable(context)
          : _buildAreasList(context, activeAreas, matchingArea, deliverySettings),
    );
  }

  Widget _buildNoAreasAvailable(BuildContext context) {
    return Center(
      child: DeliveryNotAvailableWidget(
        reason: DeliveryUnavailableReason.noZones,
        onRetry: () => context.pop(),
      ),
    );
  }

  Widget _buildAreasList(
    BuildContext context,
    List<DeliveryArea> areas,
    DeliveryArea? matchingArea,
    DeliverySettings? settings,
  ) {
    final deliveryState = ref.watch(deliveryProvider);

    return Column(
      children: [
        // Header avec l'adresse
        _buildAddressHeader(context, deliveryState),

        // Message si zone trouvée automatiquement
        if (matchingArea != null) _buildMatchingAreaBanner(context, matchingArea),

        // Liste des zones
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélectionnez votre zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Les frais et délais varient selon la zone',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Cartes des zones
                ...areas.map((area) => _buildAreaCard(context, area, settings)),
              ],
            ),
          ),
        ),

        // Bouton de confirmation
        _buildConfirmButton(context),
      ],
    );
  }

  Widget _buildAddressHeader(BuildContext context, DeliveryState deliveryState) {
    return Container(
      padding: AppSpacing.paddingMD,
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Livraison à',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  deliveryState.selectedAddress?.formattedAddress ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingAreaBanner(BuildContext context, DeliveryArea area) {
    return Container(
      padding: AppSpacing.paddingMD,
      color: AppColors.successContainer,
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Bonne nouvelle ! Vous êtes dans la zone "${area.name}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.successDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(
    BuildContext context,
    DeliveryArea area,
    DeliverySettings? settings,
  ) {
    final isSelected = _selectedArea?.id == area.id;
    final deliveryState = ref.watch(deliveryProvider);
    final postalCode = deliveryState.selectedAddress?.postalCode ?? '';
    final isInZone = area.postalCodes.contains(postalCode);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppInteractiveCard(
        selected: isSelected,
        onTap: () => _onAreaSelected(area),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la zone
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: isSelected ? AppColors.primary : AppColors.neutral600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isInZone)
                        Text(
                          'Votre code postal est dans cette zone',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                              ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Détails de la zone
            Row(
              children: [
                // Frais de livraison
                _buildDetailChip(
                  context,
                  Icons.delivery_dining,
                  area.deliveryFee > 0
                      ? '${area.deliveryFee.toStringAsFixed(2)} €'
                      : 'Gratuit',
                  'Frais',
                ),
                const SizedBox(width: AppSpacing.sm),
                // Minimum de commande
                _buildDetailChip(
                  context,
                  Icons.shopping_cart,
                  '${area.minimumOrderAmount.toStringAsFixed(0)} € min',
                  'Minimum',
                ),
                const SizedBox(width: AppSpacing.sm),
                // Délai estimé
                _buildDetailChip(
                  context,
                  Icons.access_time,
                  '${area.estimatedMinutes} min',
                  'Délai',
                ),
              ],
            ),

            // Info livraison gratuite
            if (settings?.freeDeliveryThreshold != null && area.deliveryFee > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'Livraison gratuite dès ${settings!.freeDeliveryThreshold!.toStringAsFixed(0)} €',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AppFullWidthButton(
          text: _selectedArea != null
              ? 'Confirmer - ${_selectedArea!.name}'
              : 'Sélectionnez une zone',
          onPressed: _selectedArea != null ? _onConfirm : null,
          size: ButtonSize.large,
          icon: Icons.check,
        ),
      ),
    );
  }
}
