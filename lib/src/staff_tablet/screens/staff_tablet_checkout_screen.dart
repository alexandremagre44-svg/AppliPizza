// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/staff_tablet/screens/staff_tablet_checkout_screen.dart

import 'package:flutter/material.dart';
import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../providers/staff_tablet_cart_provider.dart';

class StaffTabletCheckoutScreen extends ConsumerStatefulWidget {
  const StaffTabletCheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffTabletCheckoutScreen> createState() => _StaffTabletCheckoutScreenState();
}

class _StaffTabletCheckoutScreenState extends ConsumerState<StaffTabletCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  
  String _paymentMethod = 'cash';
  String _pickupTime = 'asap';
  String? _selectedTimeSlot;
  bool _isProcessing = false;

  final List<String> _timeSlots = [
    '11:30', '12:00', '12:30', '13:00', '13:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00'
  ];

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final cart = ref.read(staffTabletCartProvider);
      
      if (cart.items.isEmpty) {
        throw Exception('Le panier est vide');
      }

      // Determine pickup date and time
      String? pickupDate;
      String? pickupTimeSlot;
      
      if (_pickupTime == 'scheduled' && _selectedTimeSlot != null) {
        final now = DateTime.now();
        pickupDate = DateFormat('yyyy-MM-dd').format(now);
        pickupTimeSlot = _selectedTimeSlot;
      }

      // Create order using the provider for multi-tenant isolation
      final orderService = ref.read(firebaseOrderServiceProvider);
      final orderId = await orderService.createOrder(
        items: cart.items,
        total: cart.total,
        customerName: _customerNameController.text.trim().isNotEmpty 
            ? _customerNameController.text.trim() 
            : null,
        pickupDate: pickupDate,
        pickupTimeSlot: pickupTimeSlot,
        source: OrderSource.staffTablet,
        paymentMethod: _paymentMethod,
        comment: _pickupTime == 'asap' ? 'Dès que possible' : null,
      );

      // Clear cart
      ref.read(staffTabletCartProvider.notifier).clearCart();

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success[700], size: 32),
                const SizedBox(width: 12),
                const Text('Commande créée'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'La commande a été enregistrée avec succès.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${cart.total.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Paiement:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_getPaymentMethodLabel(_paymentMethod)),
                        ],
                      ),
                      if (_customerNameController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Client:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(_customerNameController.text.trim()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Retrait:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_pickupTime == 'asap' ? 'Dès que possible' : _selectedTimeSlot ?? ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/staff-tablet/catalog');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: context.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Nouvelle commande', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Espèces';
      case 'card':
        return 'Carte bancaire';
      case 'other':
        return 'Autre';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    // PROTECTION: Vérifier que l'utilisateur est admin
    final authState = ref.watch(authProvider);
    if (!authState.isAdmin) {
      return _buildUnauthorizedScreen(context);
    }
    
    final cart = ref.watch(staffTabletCartProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceVariant,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primarySwatch[600]!, AppColors.primaryDark!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: context.onPrimary, size: 26),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: context.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Finaliser la commande',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.onPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: context.colorScheme.surfaceVariant ),
                  const SizedBox(height: 16),
                  const Text(
                    'Le panier est vide',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: context.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Retour au catalogue', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Order summary card
                        _buildOrderSummaryCard(cart),
                        const SizedBox(height: 24),

                        // Customer name (optional)
                        _buildSectionCard(
                          title: 'Nom du client (optionnel)',
                          icon: Icons.person,
                          child: TextField(
                            controller: _customerNameController,
                            decoration: const InputDecoration(
                              hintText: 'Entrez le nom du client',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                            ),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Pickup time
                        _buildSectionCard(
                          title: 'Heure de retrait',
                          icon: Icons.access_time,
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: const Text('Dès que possible', style: TextStyle(fontSize: 18)),
                                value: 'asap',
                                groupValue: _pickupTime,
                                onChanged: (value) {
                                  setState(() {
                                    _pickupTime = value!;
                                    _selectedTimeSlot = null;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              RadioListTile<String>(
                                title: const Text('Créneau spécifique', style: TextStyle(fontSize: 18)),
                                value: 'scheduled',
                                groupValue: _pickupTime,
                                onChanged: (value) {
                                  setState(() {
                                    _pickupTime = value!;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              if (_pickupTime == 'scheduled') ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _timeSlots.map((slot) {
                                    return ChoiceChip(
                                      label: Text(slot, style: const TextStyle(fontSize: 16)),
                                      selected: _selectedTimeSlot == slot,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedTimeSlot = selected ? slot : null;
                                        });
                                      },
                                      selectedColor: AppColors.primary,
                                      labelStyle: TextStyle(
                                        color: _selectedTimeSlot == slot ? context.onPrimary : Colors.black,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Payment method
                        _buildSectionCard(
                          title: 'Mode de paiement',
                          icon: Icons.payment,
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: const Text('Espèces', style: TextStyle(fontSize: 18)),
                                value: 'cash',
                                groupValue: _paymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value!;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              RadioListTile<String>(
                                title: const Text('Carte bancaire', style: TextStyle(fontSize: 18)),
                                value: 'card',
                                groupValue: _paymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value!;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              RadioListTile<String>(
                                title: const Text('Autre', style: TextStyle(fontSize: 18)),
                                value: 'other',
                                groupValue: _paymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value!;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit button with enhanced design
                        Container(
                          decoration: BoxDecoration(
                            gradient: _isProcessing
                                ? null
                                : LinearGradient(
                                    colors: [AppColors.success[600]!, AppColors.success[800]!],
                                  ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isProcessing
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.success.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _submitOrder,
                            icon: _isProcessing
                                ? const SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(context.onPrimary),
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_rounded,
                                    size: 30,
                                  ),
                            label: Text(
                              _isProcessing ? 'Traitement...' : 'Valider la commande',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isProcessing ? AppColors.neutral400 : AppColors.primary,
                              foregroundColor: context.onPrimary,
                              minimumSize: const Size(double.infinity, 72),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSummaryCard(CartState cart) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.onPrimary,
              context.textSecondary,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primarySwatch[600]!, AppColors.primaryDark!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: context.onPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Résumé de la commande',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: context.colorScheme.surfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primarySwatch[300]!, Colors.transparent],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...cart.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.onPrimary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colorScheme.surfaceVariant ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDarker,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.surfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.total.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.surfaceVariant,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primarySwatch[300]!, Colors.transparent],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryLighter!, AppColors.primaryLighter!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primarySwatch[300]!, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calculate_rounded,
                          color: AppColors.primaryDark, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: context.colorScheme.surfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${cart.total.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.onPrimary,
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primarySwatch[200]!, width: 1.5),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.colorScheme.surfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primarySwatch[200]!, Colors.transparent],
                ),
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  /// Widget d'écran non autorisé pour les non-admins
  Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.error[900]!,
              AppColors.error[700]!,
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: EdgeInsets.all(AppSpacing.xl),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 80,
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Accès non autorisé',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Le module CAISSE est réservé aux administrateurs uniquement.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: () => context.go('/menu'),
                    icon: const Icon(Icons.home),
                    label: const Text('Retour à l\'accueil'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
