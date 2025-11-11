// lib/src/widgets/newsletter_subscription_widget.dart
// Widget pour permettre aux utilisateurs de s'abonner à la newsletter

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subscriber.dart';
import '../services/mailing_service.dart';
import '../theme/app_theme.dart';

class NewsletterSubscriptionWidget extends StatefulWidget {
  final String? userEmail;

  const NewsletterSubscriptionWidget({
    super.key,
    this.userEmail,
  });

  @override
  State<NewsletterSubscriptionWidget> createState() =>
      _NewsletterSubscriptionWidgetState();
}

class _NewsletterSubscriptionWidgetState
    extends State<NewsletterSubscriptionWidget> {
  final MailingService _mailingService = MailingService();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _consentGiven = false;
  bool _isLoading = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    if (widget.userEmail != null) {
      _emailController.text = widget.userEmail!;
      _checkSubscriptionStatus();
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    if (widget.userEmail == null) return;

    final subscribers = await _mailingService.loadSubscribers();
    final existing = subscribers.firstWhere(
      (sub) => sub.email == widget.userEmail && sub.status == 'active',
      orElse: () => Subscriber(
        id: '',
        email: '',
        dateInscription: DateTime.now(),
      ),
    );

    setState(() {
      _isSubscribed = existing.id.isNotEmpty;
      if (_isSubscribed) {
        _consentGiven = existing.consent;
      }
    });
  }

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter de recevoir des promotions'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subscriber = Subscriber(
        id: const Uuid().v4(),
        email: _emailController.text.trim(),
        status: 'active',
        tags: ['client'],
        consent: _consentGiven,
        dateInscription: DateTime.now(),
        unsubscribeToken: _mailingService.generateUnsubscribeToken(),
      );

      final success = await _mailingService.addSubscriber(subscriber);

      if (success && mounted) {
        setState(() {
          _isSubscribed = true;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Inscription réussie ! 🎉'),
                ),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (!success && mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cet email est déjà inscrit'),
            backgroundColor: AppTheme.warningOrange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _unsubscribe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se désinscrire'),
        content: const Text(
          'Êtes-vous sûr de vouloir vous désinscrire de la newsletter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Se désinscrire'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      final success = await _mailingService.unsubscribe(_emailController.text.trim());

      if (success && mounted) {
        setState(() {
          _isSubscribed = false;
          _consentGiven = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Désinscription réussie'),
            backgroundColor: AppTheme.textMedium,
          ),
        );
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubscribed) {
      return _buildSubscribedWidget();
    }

    return _buildSubscriptionForm();
  }

  Widget _buildSubscriptionForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.primaryRed.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.email,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Newsletter',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Restez informé de nos offres',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'votre@email.com',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryRed),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email requis';
                }
                if (!value.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Consent checkbox
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _consentGiven
                      ? AppTheme.primaryRed
                      : Colors.grey.shade300,
                  width: _consentGiven ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _consentGiven,
                    onChanged: (value) {
                      setState(() => _consentGiven = value ?? false);
                    },
                    activeColor: AppTheme.primaryRed,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _consentGiven = !_consentGiven);
                      },
                      child: Text(
                        'J\'accepte de recevoir des emails promotionnels et offres spéciales de Pizza Deli\'Zza',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 13,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // RGPD notice
            Text(
              'Conformément au RGPD, vous pouvez vous désinscrire à tout moment via le lien dans chaque email.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 11,
                    color: AppTheme.textLight,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 20),
            
            // Subscribe button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _subscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'S\'inscrire à la newsletter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribedWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.successGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Success icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.successGreen, Colors.teal.shade700],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Vous êtes inscrit !',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.successGreen,
                ),
          ),
          const SizedBox(height: 8),
          
          Text(
            _emailController.text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          
          Text(
            'Vous recevrez nos offres spéciales et nouveautés',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Unsubscribe button
          TextButton.icon(
            onPressed: _isLoading ? null : _unsubscribe,
            icon: Icon(Icons.unsubscribe, size: 18),
            label: Text('Se désinscrire'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
