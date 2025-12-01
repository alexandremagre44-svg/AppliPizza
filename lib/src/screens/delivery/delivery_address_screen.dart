/// lib/src/screens/delivery/delivery_address_screen.dart
///
/// Écran de saisie de l'adresse de livraison.
///
/// Cet écran permet au client de saisir:
/// - Adresse complète
/// - Code postal
/// - Complément d'adresse (optionnel)
/// - Instructions pour le livreur (optionnel)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/buttons.dart';
import '../../design_system/cards.dart';
import '../../design_system/colors.dart';
import '../../design_system/inputs.dart';
import '../../design_system/spacing.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/restaurant_plan_provider.dart';
import '../../../white_label/core/module_id.dart';

/// Écran de saisie de l'adresse de livraison.
class DeliveryAddressScreen extends ConsumerStatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  ConsumerState<DeliveryAddressScreen> createState() =>
      _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends ConsumerState<DeliveryAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _complementController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    _complementController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'adresse est requise';
    }
    if (value.trim().length < 5) {
      return 'Adresse trop courte';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le code postal est requis';
    }
    // Validation basique du code postal français (5 chiffres)
    final postalCodeRegex = RegExp(r'^\d{5}$');
    if (!postalCodeRegex.hasMatch(value.trim())) {
      return 'Code postal invalide (5 chiffres)';
    }
    return null;
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Créer l'adresse
      final address = DeliveryAddress(
        address: _addressController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        complement: _complementController.text.trim().isNotEmpty
            ? _complementController.text.trim()
            : null,
        driverInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      );

      // Sauvegarder dans le provider
      ref.read(deliveryProvider.notifier).setAddress(address);

      // Naviguer vers la sélection de zone
      context.push('/delivery/area');
    }
  }

  @override
  Widget build(BuildContext context) {
    final flags = ref.watch(restaurantFeatureFlagsProvider);
    final deliveryState = ref.watch(deliveryProvider);

    // Initialize controllers with existing address (only once)
    if (!_initialized && deliveryState.selectedAddress != null) {
      _initialized = true;
      _addressController.text = deliveryState.selectedAddress!.address;
      _postalCodeController.text = deliveryState.selectedAddress!.postalCode;
      _complementController.text =
          deliveryState.selectedAddress!.complement ?? '';
      _instructionsController.text =
          deliveryState.selectedAddress!.driverInstructions ?? '';
    }

    // Guard: Vérifier si le module livraison est activé
    if (!(flags?.has(ModuleId.delivery) ?? false)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Livraison'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adresse de livraison',
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
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec icône
              _buildHeader(context),

              const SizedBox(height: AppSpacing.lg),

              // Card contenant le formulaire
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Adresse
                    AppTextField(
                      label: 'Adresse *',
                      hint: 'Numéro et nom de rue',
                      controller: _addressController,
                      prefixIcon: Icons.location_on,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateAddress,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Code postal
                    AppTextField(
                      label: 'Code postal *',
                      hint: '75001',
                      controller: _postalCodeController,
                      prefixIcon: Icons.local_post_office,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 5,
                      validator: _validatePostalCode,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Complément d'adresse
                    AppTextField(
                      label: 'Complément d\'adresse',
                      hint: 'Bâtiment, étage, digicode...',
                      controller: _complementController,
                      prefixIcon: Icons.apartment,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Instructions pour le livreur
                    AppTextArea(
                      label: 'Instructions pour le livreur',
                      hint: 'Ex: Sonner à l\'interphone, laisser devant la porte...',
                      controller: _instructionsController,
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Bouton Continuer
              AppFullWidthButton(
                text: 'Continuer',
                onPressed: _onContinue,
                size: ButtonSize.large,
                icon: Icons.arrow_forward,
              ),

              const SizedBox(height: AppSpacing.md),

              // Texte d'information
              Center(
                child: Text(
                  'Nous vérifierons si votre adresse est dans notre zone de livraison',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delivery_dining,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Où souhaitez-vous être livré ?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Entrez votre adresse de livraison',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
