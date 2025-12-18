import 'package:flutter/material.dart';
import '../../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../src/providers/restaurant_provider.dart';
import '../../../src/providers/auth_provider.dart';

/// Newsletter subscription status provider
final newsletterSubscriptionProvider = StateProvider<bool>((ref) => false);

/// Newsletter Subscription Screen
/// 
/// Allows customers to subscribe to the restaurant's newsletter.
class SubscribeNewsletterScreen extends ConsumerStatefulWidget {
  const SubscribeNewsletterScreen({super.key});

  @override
  ConsumerState<SubscribeNewsletterScreen> createState() =>
      _SubscribeNewsletterScreenState();
}

class _SubscribeNewsletterScreenState
    extends ConsumerState<SubscribeNewsletterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _acceptPromotions = true;

  @override
  void initState() {
    super.initState();
    // Note: Using ref.read() in initState is intentional here
    // We only need the initial state, not reactive updates
    // The build method uses ref.watch() for reactive UI updates
    _checkSubscriptionStatus();
  }

  void _checkSubscriptionStatus() {
    // TODO: Check if user is already subscribed
    // Load from user profile or Firestore
    // Note: ref.read() is appropriate here as this is a one-time check
    // The UI will reactively update via ref.watch() in build()
    final isSubscribed = ref.read(newsletterSubscriptionProvider);
    if (isSubscribed) {
      // Pre-fill email if user is logged in
      // TODO: Uncomment when user provider is available
      // final user = ref.read(userProvider);
      // _emailController.text = user?.email ?? '';
    }
  }

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez accepter les conditions pour vous inscrire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get restaurant and user info
      final restaurantConfig = ref.read(currentRestaurantProvider);
      final restaurantId = restaurantConfig.id;
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      
      // Defensive check: ensure restaurant ID is valid
      if (restaurantId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: ID du restaurant non trouvé'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Save to Firestore newsletter_subscribers collection
      final email = _emailController.text;
      // Sanitize email for use as document ID (replace invalid characters)
      final docId = email.replaceAll(RegExp(r'[\/\s]'), '_');
      
      final subscriberData = {
        'email': email,
        'name': _nameController.text,
        'userId': userId,
        'acceptPromotions': _acceptPromotions,
        'subscribedAt': FieldValue.serverTimestamp(),
        'source': 'app',
        'isActive': true,
      };

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('newsletter_subscribers')
          .doc(docId)
          .set(subscriberData);

      // Update user profile if logged in
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'newsletterSubscribed': true,
          'newsletterRestaurants': FieldValue.arrayUnion([restaurantId]),
        });
      }

      // Update subscription status
      ref.read(newsletterSubscriptionProvider.notifier).state = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Vous recevrez bientôt nos actualités'),
            backgroundColor: Colors.green,
          ),
        );

        // Pop back after short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = ref.watch(newsletterSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsletter'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isSubscribed ? _buildAlreadySubscribed() : _buildSubscriptionForm(),
      ),
    );
  }

  Widget _buildAlreadySubscribed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Vous êtes déjà inscrit !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Vous recevez déjà nos actualités et promotions par email.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              // TODO: Unsubscribe
              ref.read(newsletterSubscriptionProvider.notifier).state = false;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vous êtes maintenant désinscrit de la newsletter'),
                ),
              );
            },
            icon: const Icon(Icons.unsubscribe),
            label: const Text('Se désinscrire'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Center(
            child: Icon(
              Icons.email,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Restez informé !',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Inscrivez-vous à notre newsletter pour recevoir nos actualités, '
            'promotions et offres exclusives.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Prénom et nom',
              hintText: 'Jean Dupont',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'exemple@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Benefits card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Avantages newsletter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBenefit('Promotions exclusives'),
                  _buildBenefit('Nouveautés en avant-première'),
                  _buildBenefit('Recettes et conseils'),
                  _buildBenefit('Jeux concours'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Checkboxes
          CheckboxListTile(
            value: _acceptPromotions,
            onChanged: (value) {
              setState(() => _acceptPromotions = value ?? false);
            },
            title: const Text(
              'J\'accepte de recevoir des promotions personnalisées',
              style: TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),

          CheckboxListTile(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() => _acceptTerms = value ?? false);
            },
            title: const Text(
              'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
              style: TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
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
                    'S\'inscrire à la newsletter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Privacy note
          Text(
            'Nous respectons votre vie privée. Vous pouvez vous désinscrire à tout moment.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
