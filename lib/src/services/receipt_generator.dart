// lib/src/services/receipt_generator.dart
/// 
/// Receipt generator service for POS
/// Generates text-based receipts for printing or display
library;

import '../models/pos_order.dart';
import '../models/order_type.dart';
import '../models/payment_method.dart';
import '../services/selection_formatter.dart';

/// Receipt Generator Service
class ReceiptGenerator {
  /// Generate a text receipt for an order
  static String generateReceipt({
    required PosOrder order,
    required String restaurantName,
    String? restaurantAddress,
    String? restaurantPhone,
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('=' * 40);
    buffer.writeln(_center(restaurantName, 40));
    if (restaurantAddress != null) {
      buffer.writeln(_center(restaurantAddress, 40));
    }
    if (restaurantPhone != null) {
      buffer.writeln(_center(restaurantPhone, 40));
    }
    buffer.writeln('=' * 40);
    buffer.writeln();
    
    // Order info
    buffer.writeln('Commande: ${order.id.substring(0, 8)}');
    buffer.writeln('Date: ${_formatDateTime(order.date)}');
    buffer.writeln('Type: ${OrderType.getLabel(order.orderType)}');
    
    if (order.tableNumber != null) {
      buffer.writeln('Table: ${order.tableNumber}');
    }
    
    if (order.customerName != null) {
      buffer.writeln('Client: ${order.customerName}');
    }
    
    buffer.writeln('-' * 40);
    buffer.writeln();
    
    // Items
    buffer.writeln('ARTICLES:');
    buffer.writeln();
    
    for (final item in order.items) {
      // Item name and quantity
      buffer.writeln('${item.quantity}x ${item.productName}');
      
      // Price
      final itemTotal = item.price * item.quantity;
      buffer.writeln('   ${itemTotal.toStringAsFixed(2)} €');
      
      // Selections
      if (item.selections.isNotEmpty) {
        final description = formatSelections(item.selections);
        if (description != null) {
          final lines = description.split('\n');
          for (final line in lines) {
            buffer.writeln('   $line');
          }
        }
      }
      
      buffer.writeln();
    }
    
    buffer.writeln('-' * 40);
    buffer.writeln();
    
    // Totals
    buffer.writeln(_rightAlign('Sous-total:', order.total, 40));
    
    // Payment
    if (order.payment != null) {
      buffer.writeln();
      buffer.writeln('PAIEMENT:');
      buffer.writeln('Mode: ${PaymentMethod.getLabel(order.payment!.method)}');
      
      if (order.payment!.method == PaymentMethod.cash) {
        if (order.payment!.amountGiven != null) {
          buffer.writeln('Reçu: ${order.payment!.amountGiven!.toStringAsFixed(2)} €');
        }
        if (order.payment!.change != null) {
          buffer.writeln('Rendu: ${order.payment!.change!.toStringAsFixed(2)} €');
        }
      }
    }
    
    buffer.writeln();
    buffer.writeln('=' * 40);
    buffer.writeln(_center('TOTAL: ${order.total.toStringAsFixed(2)} €', 40));
    buffer.writeln('=' * 40);
    buffer.writeln();
    
    // Footer
    buffer.writeln(_center('Merci de votre visite !', 40));
    buffer.writeln(_center('À bientôt', 40));
    buffer.writeln();
    buffer.writeln('=' * 40);
    
    return buffer.toString();
  }
  
  /// Generate a kitchen ticket (for KDS)
  static String generateKitchenTicket({
    required PosOrder order,
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('=' * 40);
    buffer.writeln(_center('BON DE CUISINE', 40));
    buffer.writeln('=' * 40);
    buffer.writeln();
    
    // Order info
    buffer.writeln('Commande: ${order.id.substring(0, 8)}');
    buffer.writeln('Heure: ${_formatTime(order.date)}');
    buffer.writeln('Type: ${OrderType.getLabel(order.orderType)}');
    
    if (order.tableNumber != null) {
      buffer.writeln('Table: ${order.tableNumber}');
    }
    
    if (order.customerName != null) {
      buffer.writeln('Client: ${order.customerName}');
    }
    
    buffer.writeln('-' * 40);
    buffer.writeln();
    
    // Items - simplified for kitchen
    for (final item in order.items) {
      buffer.writeln('${item.quantity}x ${item.productName}');
      
      // Selections
      if (item.selections.isNotEmpty) {
        final description = formatSelections(item.selections);
        if (description != null) {
          final lines = description.split('\n');
          for (final line in lines) {
            buffer.writeln('   $line');
          }
        }
      }
      
      buffer.writeln();
    }
    
    // Notes
    if (order.staffNotes != null && order.staffNotes!.isNotEmpty) {
      buffer.writeln('-' * 40);
      buffer.writeln('NOTES:');
      buffer.writeln(order.staffNotes);
      buffer.writeln();
    }
    
    buffer.writeln('=' * 40);
    
    return buffer.toString();
  }
  
  /// Center text in a line
  static String _center(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }
  
  /// Right align with label and value
  static String _rightAlign(String label, double value, int width) {
    final valueStr = '${value.toStringAsFixed(2)} €';
    final combined = '$label $valueStr';
    if (combined.length >= width) return combined;
    final padding = width - combined.length;
    return label + ' ' * padding + valueStr;
  }
  
  /// Format date time
  static String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Format time only
  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
