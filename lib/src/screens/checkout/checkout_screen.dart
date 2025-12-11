// lib/src/screens/checkout/checkout_screen.dart
// P11 & P12: Flux commande complet avec créneaux

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_plan_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../services/loyalty_service.dart';
import '../../models/loyalty_reward.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';
import '../../../white_label/core/module_id.dart';
import '../delivery/delivery_summary_widget.dart';
import '../delivery/delivery_not_available_widget.dart';
import '../../../white_label/widgets/runtime/point_selector_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  
  // Récompenses sélectionnées pour utilisation
  String? _selectedFreePizzaRewardType;
  String? _selectedFreeDrinkRewardType;
  String? _selectedFreeDessertRewardType;
  
  // Click & Collect - Selected pickup point
  PickupPoint? _selectedPickupPoint;
  
  // Créneaux horaires disponibles
  final List<String> _timeSlots = [
    '11:00 - 11:30',
    '11:30 - 12:00',
    '12:00 - 12:30',
    '12:30 - 13:00',
    '13:00 - 13:30',
    '18:00 - 18:30',
    '18:30 - 19:00',
    '19:00 - 19:30',
    '19:30 - 20:00',
    '20:00 - 20:30',
    '20:30 - 21:00',
  ];

  @override
  void initState() {
    super.initState();
    // Sélectionner aujourd'hui par défaut
    _selectedDate = DateTime.now();
  }

  bool _isTimeSlotAvailable(String timeSlot) {
    if (_selectedDate == null) return false;
    
    final now = DateTime.now();
    final isToday = _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;
    
    if (!isToday) return true; // Demain et après = tout dispo
    
    // Aujourd'hui: vérifier heure passée
    final slotStartTime = timeSlot.split(' - ')[0];
    final parts = slotStartTime.split(':');
    final slotHour = int.parse(parts[0]);
    final slotMinute = int.parse(parts[1]);
    
    return now.hour < slotHour || (now.hour == slotHour && now.minute < slotMinute);
  }

  Future<void> _confirmOrder() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un créneau'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate Click & Collect if module is active
    final plan = ref.read(restaurantPlanUnifiedProvider).asData?.value;
    if (plan?.hasModule(ModuleId.clickAndCollect) == true && _selectedPickupPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un point de retrait'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate delivery state if delivery mode is selected
    final deliveryState = ref.read(deliveryProvider);
    final deliverySettings = ref.read(deliverySettingsProvider);
    final cartState = ref.read(cartProvider);
    
    if (deliveryState.isDeliverySelected) {
      // Check if delivery is fully configured
      if (deliveryState.selectedAddress == null || deliveryState.selectedArea == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez configurer votre adresse de livraison'),
            backgroundColor: Colors.red,
          ),
        );
        context.push('/delivery/address');
        return;
      }
      
      // Check minimum order amount
      final minimumOk = deliverySettings != null
          ? isMinimumReached(deliverySettings, deliveryState.selectedArea, cartState.total)
          : cartState.total >= (deliveryState.selectedArea?.minimumOrderAmount ?? 0);
      
      if (!minimumOk) {
        final minimumAmount = deliverySettings != null
            ? getMinimumOrderAmount(deliverySettings, deliveryState.selectedArea)
            : (deliveryState.selectedArea?.minimumOrderAmount ?? 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Minimum de commande pour la livraison : ${minimumAmount.toStringAsFixed(2)} €'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      // Marquer les récompenses comme utilisées
      final authState = ref.read(authProvider);
      final uid = authState.userId;
      final loyaltyService = ref.read(loyaltyServiceProvider);
      
      if (uid != null) {
        if (_selectedFreePizzaRewardType != null) {
          await loyaltyService.useReward(uid, RewardType.freePizza);
        }
        if (_selectedFreeDrinkRewardType != null) {
          await loyaltyService.useReward(uid, RewardType.freeDrink);
        }
        if (_selectedFreeDessertRewardType != null) {
          await loyaltyService.useReward(uid, RewardType.freeDessert);
        }
      }
      
      // Calculate delivery fee if applicable
      double? deliveryFee;
      if (deliveryState.isDeliverySelected && deliveryState.selectedArea != null) {
        if (deliverySettings != null) {
          deliveryFee = computeDeliveryFee(
            deliverySettings,
            deliveryState.selectedArea!,
            cartState.total,
          );
        } else {
          deliveryFee = deliveryState.selectedArea!.deliveryFee;
        }
      }

      // Créer la commande avec les informations de retrait et/ou livraison
      await ref.read(userProvider.notifier).addOrder(
        pickupDate: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
        pickupTimeSlot: _selectedTimeSlot,
        customerName: 'Client', // TODO: Récupérer depuis le profil utilisateur
        // Delivery data
        deliveryMode: deliveryState.isDeliverySelected ? 'delivery' : 'takeAway',
        deliveryAddress: deliveryState.selectedAddress?.toJson(),
        deliveryAreaId: deliveryState.selectedArea?.id,
        deliveryFee: deliveryFee,
      );
      
      // Reset delivery state after successful order
      ref.read(deliveryProvider.notifier).reset();
      
      if (!mounted) return;
      
      // Afficher confirmation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Commande confirmée !'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Votre commande a été enregistrée.'),
              const SizedBox(height: 12),
              if (deliveryState.isDeliverySelected) ...[
                const Text(
                  'Livraison prévue:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(deliveryState.selectedAddress?.formattedAddress ?? ''),
                const SizedBox(height: 8),
                Text(
                  'Délai estimé: ${deliveryState.selectedArea?.estimatedMinutes ?? 30} min',
                  style: const TextStyle(color: Colors.blue),
                ),
              ] else ...[
                const Text(
                  'Retrait prévu:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
                Text(_selectedTimeSlot!),
              ],
              const SizedBox(height: 12),
              Text(
                deliveryState.isDeliverySelected
                    ? 'Statut: En préparation 🛵'
                    : 'Statut: En préparation 🍕',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.go('/profile'); // Voir historique
              },
              child: const Text('Voir mes commandes'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la commande: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final loyaltyInfoAsync = ref.watch(loyaltyInfoProvider);
    final flags = ref.watch(restaurantFeatureFlagsProvider);
    final deliveryState = ref.watch(deliveryProvider);
    final deliverySettings = ref.watch(deliverySettingsProvider);
    final isDeliveryEnabled = ref.watch(isDeliveryEnabledProvider);
    
    const serviceFee = 5.00;
    double subtotal = cartState.total;
    
    // Apply VIP discount (only if loyalty module is enabled)
    String? vipTier;
    double vipDiscount = 0.0;
    
    if (flags?.has(ModuleId.loyalty) ?? false) {
      loyaltyInfoAsync.whenData((loyaltyInfo) {
        if (loyaltyInfo != null) {
          vipTier = loyaltyInfo['vipTier'] as String?;
          if (vipTier != null) {
            final discountRate = VipTier.getDiscount(vipTier!);
            vipDiscount = subtotal * discountRate;
            subtotal = subtotal - vipDiscount;
          }
        }
      });
    }
    
    // Calculate delivery fee if delivery mode is selected
    double deliveryFee = 0.0;
    if (deliveryState.isDeliverySelected && deliveryState.selectedArea != null) {
      if (deliverySettings != null) {
        deliveryFee = computeDeliveryFee(
          deliverySettings,
          deliveryState.selectedArea!,
          cartState.total,
        );
      } else {
        deliveryFee = deliveryState.selectedArea!.deliveryFee;
      }
    }
    
    final total = subtotal + serviceFee + deliveryFee;

    // Check minimum order for delivery
    final minimumOk = _isMinimumOrderMet(
      deliveryState, 
      deliverySettings, 
      cartState.total,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Finaliser la commande',
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
        padding: const EdgeInsets.all(VisualConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode de retrait section (only if delivery module is enabled)
            if (isDeliveryEnabled) ...[
              _buildDeliveryModeSection(context, deliveryState),
              const SizedBox(height: 24),
            ],
            
            // Delivery summary (if delivery is selected and configured)
            if (deliveryState.isDeliveryConfigured) ...[
              const DeliverySummaryWidget(),
              const SizedBox(height: 24),
            ],
            
            // Click & Collect point selector (if module is enabled)
            if (flags?.has(ModuleId.clickAndCollect) ?? false) ...[
              _buildClickAndCollectSection(),
              const SizedBox(height: 24),
            ],
            
            // Minimum not reached warning
            if (deliveryState.isDeliverySelected && !minimumOk)
              _buildMinimumWarning(context, deliverySettings, deliveryState, cartState.total),
            
            // Récapitulatif commande
            _buildOrderSummary(
              cartState, 
              serviceFee, 
              deliveryFee,
              total, 
              vipDiscount, 
              vipTier,
              deliveryState.isDeliverySelected,
            ),
            
            const SizedBox(height: 32),
            
            // Loyalty rewards section (module guard: requires loyalty module)
            if (flags?.has(ModuleId.loyalty) ?? false)
              loyaltyInfoAsync.when(
                data: (loyaltyInfo) {
                  if (loyaltyInfo == null) return const SizedBox.shrink();
                  return _buildRewardsSection(loyaltyInfo);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            
            const SizedBox(height: 32),
            
            // Enhanced Section: Sélection date
            _buildSectionHeader(context, 'Choisir une date', Icons.calendar_today),
            const SizedBox(height: 16),
            _buildDateSelector(),
            
            const SizedBox(height: 32),
            
            // Enhanced Section: Sélection créneau
            _buildSectionHeader(context, 'Choisir un créneau', Icons.access_time),
            const SizedBox(height: 16),
            _buildTimeSlotSelector(),
            
            const SizedBox(height: 40),
            
            // Enhanced Confirmation Button
            // Disable if delivery is selected and minimum not met
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: minimumOk ? _confirmOrder : null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      minimumOk ? Icons.check_circle_outline : Icons.warning_amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      minimumOk 
                          ? 'Confirmer - ${total.toStringAsFixed(2)} €'
                          : 'Minimum non atteint',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(
    CartState cartState, 
    double serviceFee, 
    double deliveryFee,
    double total, 
    double vipDiscount, 
    String? vipTier,
    bool isDelivery,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...cartState.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.productName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${item.total.toStringAsFixed(2)} €',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total'),
                Text('${cartState.total.toStringAsFixed(2)} €'),
              ],
            ),
            if (vipDiscount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Réduction VIP ${vipTier?.toUpperCase()}'),
                      const SizedBox(width: 4),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                  Text(
                    '-${vipDiscount.toStringAsFixed(2)} €',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Frais de service'),
                Text('${serviceFee.toStringAsFixed(2)} €'),
              ],
            ),
            // Delivery fee (only shown if delivery is selected)
            if (isDelivery) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Frais de livraison'),
                    ],
                  ),
                  Text(
                    deliveryFee > 0 
                        ? '${deliveryFee.toStringAsFixed(2)} €'
                        : 'Gratuit',
                    style: TextStyle(
                      color: deliveryFee == 0 ? Colors.green : null,
                      fontWeight: deliveryFee == 0 ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSection(Map<String, dynamic> loyaltyInfo) {
    final rewards = loyaltyInfo['rewards'] as List<LoyaltyReward>;
    final availableRewards = rewards.where((r) => !r.used).toList();
    
    if (availableRewards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Utiliser des récompenses', Icons.card_giftcard),
        const SizedBox(height: 16),
        
        ...availableRewards.map((reward) {
          String label;
          IconData icon;
          Color color;
          bool isSelected = false;

          switch (reward.type) {
            case RewardType.freePizza:
              label = 'Pizza Gratuite';
              icon = Icons.local_pizza;
              color = AppColors.primaryRed;
              isSelected = _selectedFreePizzaRewardType != null;
              break;
            case RewardType.freeDrink:
              label = 'Boisson Gratuite';
              icon = Icons.local_drink;
              color = Colors.blue;
              isSelected = _selectedFreeDrinkRewardType != null;
              break;
            case RewardType.freeDessert:
              label = 'Dessert Gratuit';
              icon = Icons.cake;
              color = Colors.pink;
              isSelected = _selectedFreeDessertRewardType != null;
              break;
            default:
              label = 'Récompense';
              icon = Icons.card_giftcard;
              color = Colors.grey;
          }

          return CheckboxListTile(
            title: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
            subtitle: Text('Utilisable sur cette commande'),
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (reward.type == RewardType.freePizza) {
                  _selectedFreePizzaRewardType = value == true ? reward.type : null;
                } else if (reward.type == RewardType.freeDrink) {
                  _selectedFreeDrinkRewardType = value == true ? reward.type : null;
                } else if (reward.type == RewardType.freeDessert) {
                  _selectedFreeDessertRewardType = value == true ? reward.type : null;
                }
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDateSelector() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    
    return Row(
      children: [
        Expanded(
          child: _buildDateCard(today, 'Aujourd\'hui'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateCard(tomorrow, 'Demain'),
        ),
      ],
    );
  }

  Widget _buildDateCard(DateTime date, String label) {
    final isSelected = _selectedDate?.day == date.day &&
        _selectedDate?.month == date.month &&
        _selectedDate?.year == date.year;
    
    return Card(
      color: isSelected ? Theme.of(context).colorScheme.primary : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDate = date;
            _selectedTimeSlot = null; // Reset créneau
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}/${date.month}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _timeSlots.map((slot) {
        final isAvailable = _isTimeSlotAvailable(slot);
        final isSelected = _selectedTimeSlot == slot;
        
        return FilterChip(
          label: Text(slot),
          selected: isSelected,
          onSelected: isAvailable
              ? (selected) {
                  setState(() {
                    _selectedTimeSlot = selected ? slot : null;
                  });
                }
              : null,
          backgroundColor: isAvailable ? null : Colors.grey[200],
          selectedColor: Theme.of(context).colorScheme.primary,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : isAvailable
                    ? Colors.black87
                    : Colors.grey,
          ),
        );
      }).toList(),
    );
  }

  /// Build delivery mode selection section
  Widget _buildDeliveryModeSection(BuildContext context, DeliveryState deliveryState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mode de retrait',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Takeaway option
            _buildDeliveryModeOption(
              context,
              icon: Icons.store,
              title: 'Retrait sur place',
              subtitle: 'Click & Collect',
              isSelected: deliveryState.isTakeAwaySelected || !deliveryState.hasSelectedMode,
              onTap: () {
                ref.read(deliveryProvider.notifier).setMode(DeliveryMode.takeAway);
                ref.read(deliveryProvider.notifier).resetDeliveryDetails();
              },
            ),
            
            const SizedBox(height: 12),
            
            // Delivery option
            _buildDeliveryModeOption(
              context,
              icon: Icons.delivery_dining,
              title: 'Livraison',
              subtitle: deliveryState.isDeliveryConfigured 
                  ? deliveryState.selectedAddress?.formattedAddress ?? 'Configurer l\'adresse'
                  : 'Configurer l\'adresse',
              isSelected: deliveryState.isDeliverySelected,
              onTap: () {
                ref.read(deliveryProvider.notifier).setMode(DeliveryMode.delivery);
                // Navigate to address screen if not configured
                if (!deliveryState.isDeliveryConfigured) {
                  context.push('/delivery/address');
                }
              },
              trailing: deliveryState.isDeliverySelected && !deliveryState.isDeliveryConfigured
                  ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryModeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              )
            else if (trailing != null)
              trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildMinimumWarning(
    BuildContext context,
    dynamic deliverySettings,
    DeliveryState deliveryState,
    double cartTotal,
  ) {
    final minimumAmount = deliverySettings != null
        ? getMinimumOrderAmount(deliverySettings, deliveryState.selectedArea)
        : (deliveryState.selectedArea?.minimumOrderAmount ?? 0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DeliveryMinimumWarning(
        minimumAmount: minimumAmount,
        currentAmount: cartTotal,
        onAddItems: () => context.go('/menu'),
      ),
    );
  }

  /// Check if minimum order amount is met for delivery.
  /// Returns true if not a delivery order or if minimum is met.
  bool _isMinimumOrderMet(
    DeliveryState deliveryState,
    dynamic deliverySettings,
    double cartTotal,
  ) {
    // Not a delivery order - no minimum required
    if (!deliveryState.isDeliverySelected) {
      return true;
    }
    
    // Use deliverySettings if available for more accurate check
    if (deliverySettings != null) {
      return isMinimumReached(deliverySettings, deliveryState.selectedArea, cartTotal);
    }
    
    // Fallback: check only area minimum
    if (deliveryState.selectedArea == null) {
      return true;
    }
    
    return cartTotal >= deliveryState.selectedArea!.minimumOrderAmount;
  }

  /// Build Click & Collect pickup point selection section
  Widget _buildClickAndCollectSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedPickupPoint != null
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: _selectedPickupPoint != null ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: _selectPickupPoint,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _selectedPickupPoint != null
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Point de retrait',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedPickupPoint != null
                              ? _selectedPickupPoint!.name
                              : 'Sélectionner un point',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedPickupPoint != null
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _selectedPickupPoint != null
                        ? Icons.check_circle
                        : Icons.chevron_right,
                    color: _selectedPickupPoint != null
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ],
              ),
              if (_selectedPickupPoint != null) ...[
                const Divider(height: 24),
                Text(
                  _selectedPickupPoint!.address,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                if (_selectedPickupPoint!.phone != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        _selectedPickupPoint!.phone!,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Open point selector screen and update selected point
  Future<void> _selectPickupPoint() async {
    final point = await Navigator.push<PickupPoint>(
      context,
      MaterialPageRoute(
        builder: (context) => const PointSelectorScreen(),
      ),
    );

    if (point != null) {
      setState(() {
        _selectedPickupPoint = point;
      });
      
      // Note: Cart provider integration for pickup point storage can be added later
      // when CartNotifier is extended with setPickupPoint method
    }
  }
}
