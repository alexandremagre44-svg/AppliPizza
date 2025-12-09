import 'package:flutter/material.dart';

/// Newsletter Subscription Screen
/// 
/// Allows customers to subscribe to the restaurant's newsletter.
/// This is a placeholder for future implementation.
class SubscribeNewsletterScreen extends StatelessWidget {
  const SubscribeNewsletterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsletter'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Inscription Newsletter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Restez informé de nos actualités et promotions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'À implémenter',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
