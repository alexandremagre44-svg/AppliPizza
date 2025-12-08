// lib/builder/runtime/modules/newsletter_module_widget.dart
// Runtime widget for newsletter_module
// 
// Newsletter subscription module

import 'package:flutter/material.dart';

/// Newsletter Module Widget
/// 
/// Displays a newsletter subscription card
class NewsletterModuleWidget extends StatelessWidget {
  const NewsletterModuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.email,
                color: Colors.teal.shade700,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Newsletter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Recevez nos offres exclusives par email',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Newsletter subscription action
            },
            icon: const Icon(Icons.send, size: 18),
            label: const Text("S'inscrire"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
