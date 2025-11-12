// lib/src/utils/order_export.dart
// Utilitaires pour exporter les commandes en CSV

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class OrderExport {
  /// Convertit une liste de commandes en CSV
  static String toCSV(List<Order> orders) {
    final List<List<dynamic>> rows = [];
    
    // En-tête
    rows.add([
      'N° Commande',
      'Date',
      'Heure',
      'Client',
      'Téléphone',
      'Email',
      'Statut',
      'Produits',
      'Quantité',
      'Total (€)',
      'Commentaire',
      'Date retrait',
      'Créneau retrait',
    ]);
    
    // Données
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    for (final order in orders) {
      final products = order.items.map((item) => 
        '${item.quantity}x ${item.productName}'
      ).join(', ');
      
      final totalQuantity = order.items.fold<int>(
        0, 
        (sum, item) => sum + item.quantity,
      );
      
      rows.add([
        order.id.substring(0, 8),
        dateFormat.format(order.date),
        timeFormat.format(order.date),
        order.customerName ?? 'N/A',
        order.customerPhone ?? 'N/A',
        order.customerEmail ?? 'N/A',
        order.status,
        products,
        totalQuantity,
        order.total.toStringAsFixed(2),
        order.comment ?? '',
        order.pickupDate ?? '',
        order.pickupTimeSlot ?? '',
      ]);
    }
    
    return const ListToCsvConverter().convert(rows);
  }
  
  /// Génère un nom de fichier avec timestamp
  static String generateFilename() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd_HH-mm');
    return 'commandes_${dateFormat.format(now)}.csv';
  }
}
