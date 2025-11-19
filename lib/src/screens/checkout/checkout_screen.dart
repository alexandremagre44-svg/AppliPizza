// lib/src/screens/checkout/checkout_screen.dart
// P11 & P12: Flux commande complet avec créneaux

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/loyalty_service.dart';
import '../../models/loyalty_reward.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';

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

    try {
      // Marquer les récompenses comme utilisées
      final authState = ref.read(authProvider);
      final uid = authState.userId;
      
      if (uid != null) {
        if (_selectedFreePizzaRewardType != null) {
          await LoyaltyService().useReward(uid, RewardType.freePizza);
        }
        if (_selectedFreeDrinkRewardType != null) {
          await LoyaltyService().useReward(uid, RewardType.freeDrink);
        }
        if (_selectedFreeDessertRewardType != null) {
          await LoyaltyService().useReward(uid, RewardType.freeDessert);
        }
      }

      // Créer la commande avec les informations de retrait
      await ref.read(userProvider.notifier).addOrder(
        pickupDate: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
        pickupTimeSlot: _selectedTimeSlot,
        customerName: 'Client', // TODO: Récupérer depuis le profil utilisateur
      );
      
      if (!mounted) return;
      
      // Afficher confirmation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
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
              Text('Votre commande a été enregistrée.'),
              const SizedBox(height: 12),
              Text(
                'Retrait prévu:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              Text(_selectedTimeSlot!),
              const SizedBox(height: 12),
              Text(
                'Statut: En préparation 🍕',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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
    
    const deliveryFee = 5.00;
    double subtotal = cartState.total;
    
    // Apply VIP discount
    String? vipTier;
    double vipDiscount = 0.0;
    
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
    
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finaliser la commande',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(VisualConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Récapitulatif commande
            _buildOrderSummary(cartState, deliveryFee, total, vipDiscount, vipTier),
            
            const SizedBox(height: 32),
            
            // Loyalty rewards section
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
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _confirmOrder,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Confirmer - ${total.toStringAsFixed(2)} €',
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

  Widget _buildOrderSummary(CartState cartState, double deliveryFee, double total, double vipDiscount, String? vipTier) {
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
                Text('${deliveryFee.toStringAsFixed(2)} €'),
              ],
            ),
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
}
