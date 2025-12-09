import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Newsletter Subscription Screen
/// 
/// Allows customers to subscribe to the restaurant's newsletter.
/// Stores subscriptions in Firestore and provides feedback to users.
class SubscribeNewsletterScreen extends StatefulWidget {
  /// Restaurant ID for storing subscriptions
  final String? restaurantId;

  /// Callback when subscription is successful
  final VoidCallback? onSubscriptionSuccess;

  const SubscribeNewsletterScreen({
    super.key,
    this.restaurantId,
    this.onSubscriptionSuccess,
  });

  @override
  State<SubscribeNewsletterScreen> createState() =>
      _SubscribeNewsletterScreenState();
}

class _SubscribeNewsletterScreenState extends State<SubscribeNewsletterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _acceptsMarketing = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsletter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Inscription Newsletter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              const Text(
                'Restez informés de nos actualités, promotions exclusives et nouveautés.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Name field (optional)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom (optionnel)',
                  hintText: 'Votre nom',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Email field (required)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  hintText: 'votre.email@exemple.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  // More permissive email validation (RFC 5322 compatible)
                  // Accepts most valid email formats including + and subdomains
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _subscribe(),
              ),
              const SizedBox(height: 16),

              // Marketing consent checkbox
              CheckboxListTile(
                value: _acceptsMarketing,
                onChanged: (value) {
                  setState(() {
                    _acceptsMarketing = value ?? false;
                  });
                },
                title: const Text(
                  'J\'accepte de recevoir des emails marketing',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Vous pouvez vous désabonner à tout moment',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Subscribe button
              ElevatedButton(
                onPressed: _isLoading ? null : _subscribe,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'S\'inscrire',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Privacy note
              Text(
                'En vous inscrivant, vous acceptez notre politique de confidentialité. '
                'Vos données ne seront jamais partagées avec des tiers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptsMarketing) {
      _showSnackBar(
        'Veuillez accepter de recevoir des emails marketing',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();
      final restaurantId = widget.restaurantId ?? 'default';

      // Store subscription in Firestore
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('newsletter_subscribers')
          .doc(email) // Use email as document ID to prevent duplicates
          .set({
        'email': email,
        'name': name.isNotEmpty ? name : null,
        'acceptsMarketing': _acceptsMarketing,
        'subscribedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      }, SetOptions(merge: true)); // Merge to update if already exists

      _showSnackBar('Inscription réussie ! Merci de votre confiance 🎉');

      // Clear form
      _emailController.clear();
      _nameController.clear();
      setState(() {
        _acceptsMarketing = false;
      });

      // Call callback
      widget.onSubscriptionSuccess?.call();

      // Navigate back after delay (increased to 3s for better UX)
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar(
        'Erreur lors de l\'inscription. Veuillez réessayer.',
        isError: true,
      );
      debugPrint('Newsletter subscription error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
