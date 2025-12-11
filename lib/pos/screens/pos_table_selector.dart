/// POS Table Selector - modal for selecting table number
/// 
/// This widget displays a grid of table numbers (1-40) for easy selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pos_context.dart';
import '../providers/pos_context_provider.dart';

/// Table selector modal
class PosTableSelector extends ConsumerWidget {
  const PosTableSelector({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.table_restaurant, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Sélectionner une table',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Table grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 40,
              itemBuilder: (context, index) {
                final tableNumber = index + 1;
                return _TableNumberButton(
                  tableNumber: tableNumber,
                  onTap: () {
                    ref.read(posContextProvider.notifier).setTableNumber(tableNumber);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TableNumberButton extends StatelessWidget {
  final int tableNumber;
  final VoidCallback onTap;
  
  const _TableNumberButton({
    required this.tableNumber,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.table_restaurant,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '$tableNumber',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Context selector modal - for choosing order type
class PosContextSelector extends ConsumerWidget {
  const PosContextSelector({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.restaurant, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Type de commande',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Order type buttons
          _ContextTypeButton(
            icon: Icons.table_restaurant,
            label: 'Table',
            description: 'Servir à une table',
            onTap: () {
              Navigator.pop(context);
              // Show table selector
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const PosTableSelector(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ContextTypeButton(
            icon: Icons.restaurant_menu,
            label: 'Sur place',
            description: 'Manger sur place (sans table)',
            onTap: () {
              ref.read(posContextProvider.notifier).setOrderType(PosOrderType.surPlace);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
          _ContextTypeButton(
            icon: Icons.shopping_bag,
            label: 'À emporter',
            description: 'Commande à emporter',
            onTap: () {
              ref.read(posContextProvider.notifier).setOrderType(PosOrderType.emporter);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _ContextTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  
  const _ContextTypeButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
