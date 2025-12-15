// lib/src/screens/admin/pos/widgets/pos_session_close_modal.dart
/// 
/// Modal for closing a cashier session with variance report
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/cashier_session.dart';
import '../design/pos_theme.dart';
import '../design/pos_components.dart';

/// Session closing modal
class PosSessionCloseModal extends ConsumerStatefulWidget {
  final CashierSession session;
  final Function(double closingCash, String? notes) onConfirm;
  
  const PosSessionCloseModal({
    Key? key,
    required this.session,
    required this.onConfirm,
  }) : super(key: key);
  
  @override
  ConsumerState<PosSessionCloseModal> createState() => _PosSessionCloseModalState();
}

class _PosSessionCloseModalState extends ConsumerState<PosSessionCloseModal> {
  final _cashController = TextEditingController();
  final _notesController = TextEditingController();
  double? _closingCash;
  
  @override
  void dispose() {
    _cashController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _updateCash(String value) {
    setState(() {
      _closingCash = double.tryParse(value);
    });
  }
  
  double get _expectedCash => widget.session.calculatedExpectedCash;
  
  double? get _variance {
    if (_closingCash == null) return null;
    return _closingCash! - _expectedCash;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PosRadii.lg)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: EdgeInsets.all(PosSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.store_mall_directory,
                      color: Colors.orange[700],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Fermeture de caisse',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Session summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé de session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Durée',
                      value: _formatDuration(widget.session.duration),
                    ),
                    _SummaryRow(
                      label: 'Commandes',
                      value: '${widget.session.orderCount}',
                    ),
                    _SummaryRow(
                      label: 'Total encaissé',
                      value: '${widget.session.totalCollected.toStringAsFixed(2)} €',
                    ),
                    _SummaryRow(
                      label: 'Fond de caisse initial',
                      value: '${widget.session.openingCash.toStringAsFixed(2)} €',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Espèces attendues',
                      value: '${_expectedCash.toStringAsFixed(2)} €',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Closing cash input
              TextField(
                controller: _cashController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: _updateCash,
                decoration: InputDecoration(
                  labelText: 'Montant compté en caisse',
                  suffixText: '€',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.euro),
                  helperText: 'Comptez les espèces présentes dans la caisse',
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Variance display
              if (_variance != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _variance!.abs() < 0.01
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _variance!.abs() < 0.01
                          ? Colors.green
                          : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _variance!.abs() < 0.01
                            ? Icons.check_circle
                            : Icons.warning,
                        color: _variance!.abs() < 0.01
                            ? Colors.green[700]
                            : Colors.orange[700],
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _variance!.abs() < 0.01
                                  ? 'Caisse équilibrée'
                                  : 'Écart détecté',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _variance!.abs() < 0.01
                                    ? Colors.green[900]
                                    : Colors.orange[900],
                              ),
                            ),
                            if (_variance!.abs() >= 0.01)
                              Text(
                                _variance! > 0
                                    ? 'Excédent: ${_variance!.toStringAsFixed(2)} €'
                                    : 'Manque: ${_variance!.abs().toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange[800],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              
              // Notes input
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes de fermeture (optionnel)',
                  hintText: 'Ex: Explication de l\'écart, remarques',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: PosButton(
                      label: 'Annuler',
                      variant: PosButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: PosSpacing.sm),
                  Expanded(
                    child: PosButton(
                      label: 'Fermer la caisse',
                      variant: PosButtonVariant.primary,
                      onPressed: _closingCash != null
                          ? () {
                              widget.onConfirm(
                                _closingCash!,
                                _notesController.text.trim().isEmpty
                                    ? null
                                    : _notesController.text.trim(),
                              );
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}
