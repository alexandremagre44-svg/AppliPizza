// lib/src/staff_tablet/screens/staff_tablet_checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../services/firebase_order_service.dart';
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

      // Create order
      final orderService = FirebaseOrderService();
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
                Icon(Icons.check_circle, color: Colors.green[700], size: 32),
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
                    color: Colors.grey[100],
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
                              color: Colors.orange[700],
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
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
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
            backgroundColor: Colors.red[700],
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
    final cart = ref.watch(staffTabletCartProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Finaliser la commande',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Le panier est vide',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
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
                                activeColor: Colors.orange[700],
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
                                activeColor: Colors.orange[700],
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
                                      selectedColor: Colors.orange[700],
                                      labelStyle: TextStyle(
                                        color: _selectedTimeSlot == slot ? Colors.white : Colors.black,
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
                                activeColor: Colors.orange[700],
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
                                activeColor: Colors.orange[700],
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
                                activeColor: Colors.orange[700],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit button
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Valider la commande',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.orange[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Résumé de la commande',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.productName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    '${item.total.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${cart.total.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
