// lib/builder/runtime/modules/rewards_module_widget.dart
import '../../white_label/theme/theme_extensions.dart';
// Runtime widget for rewards_module
// 
// Displays available rewards for the user

import 'package:flutter/material.dart';

/// Rewards Module Widget
/// 
/// Displays a card showing available rewards
class RewardsModuleWidget extends StatelessWidget {
  const RewardsModuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: Colors.orange.shade700,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Mes récompenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Aucune récompense disponible',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
