// lib/builder/runtime/modules/loyalty_module_widget.dart
import '../../white_label/theme/theme_extensions.dart';
// Runtime widget for loyalty_module
// 
// Displays loyalty program information with points, level, and progress

import 'package:flutter/material.dart';

/// Loyalty Module Widget
/// 
/// Displays a loyalty program card with points, level badge, and progress bar
class LoyaltyModuleWidget extends StatelessWidget {
  const LoyaltyModuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade300, Colors.amber.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber.shade700,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Programme Fidélité',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '350 points',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Bronze',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.35,
              minHeight: 8,
              backgroundColor: Colors.amber.shade50,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Encore 650 pts pour une pizza gratuite',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
