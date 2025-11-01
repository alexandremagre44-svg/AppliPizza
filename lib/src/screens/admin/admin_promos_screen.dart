// lib/src/screens/admin/admin_promos_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/promo_code.dart';
import '../../services/promo_service.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';

class AdminPromosScreen extends StatefulWidget {
  const AdminPromosScreen({super.key});

  @override
  State<AdminPromosScreen> createState() => _AdminPromosScreenState();
}

class _AdminPromosScreenState extends State<AdminPromosScreen> {
  final PromoService _promoService = PromoService();
  List<PromoCode> _promoCodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromoCodes();
  }

  Future<void> _loadPromoCodes() async {
    setState(() => _isLoading = true);
    final codes = await _promoService.loadPromoCodes();
    setState(() {
      _promoCodes = codes;
      _isLoading = false;
    });
  }

  Future<void> _showPromoDialog({PromoCode? promo}) async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: promo?.code ?? '');
    final discountController = TextEditingController(text: promo?.discount.toString() ?? '');
    final fixedDiscountController = TextEditingController(text: promo?.fixedDiscount?.toString() ?? '');
    final usageLimitController = TextEditingController(text: promo?.usageLimit?.toString() ?? '');
    DateTime? expiryDate = promo?.expiryDate;
    bool isActive = promo?.isActive ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(promo == null ? 'Nouveau Code Promo' : 'Modifier Code Promo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Code *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Code requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: discountController,
                    decoration: const InputDecoration(labelText: 'Réduction (%)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fixedDiscountController,
                    decoration: const InputDecoration(labelText: 'Réduction fixe (€)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: usageLimitController,
                    decoration: const InputDecoration(labelText: 'Limite d\'utilisation'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(expiryDate == null ? 'Pas d\'expiration' : 'Expire le: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => expiryDate = date);
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Actif'),
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newPromo = PromoCode(
                    id: promo?.id ?? const Uuid().v4(),
                    code: codeController.text.trim().toUpperCase(),
                    discount: double.tryParse(discountController.text) ?? 0,
                    fixedDiscount: double.tryParse(fixedDiscountController.text),
                    usageLimit: int.tryParse(usageLimitController.text),
                    expiryDate: expiryDate,
                    isActive: isActive,
                    usageCount: promo?.usageCount ?? 0,
                  );

                  bool success;
                  if (promo == null) {
                    success = await _promoService.addPromoCode(newPromo);
                  } else {
                    success = await _promoService.updatePromoCode(newPromo);
                  }

                  if (success && context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadPromoCodes();
    }
  }

  Future<void> _deletePromo(PromoCode promo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le code "${promo.code}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _promoService.deletePromoCode(promo.id);
      _loadPromoCodes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Codes Promo'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _promoCodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.discount, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Aucun code promo', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                  itemCount: _promoCodes.length,
                  itemBuilder: (context, index) {
                    final promo = _promoCodes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.discount,
                          color: promo.isValid ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        title: Text(
                          promo.code,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (promo.fixedDiscount != null)
                              Text('-${promo.fixedDiscount}€')
                            else
                              Text('-${promo.discount}%'),
                            if (promo.expiryDate != null)
                              Text('Expire: ${promo.expiryDate!.day}/${promo.expiryDate!.month}/${promo.expiryDate!.year}'),
                            Text('Utilisé: ${promo.usageCount}${promo.usageLimit != null ? '/${promo.usageLimit}' : ''}'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!promo.isValid)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('EXPIRÉ', style: TextStyle(color: Colors.red, fontSize: 10)),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showPromoDialog(promo: promo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePromo(promo),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPromoDialog(),
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
