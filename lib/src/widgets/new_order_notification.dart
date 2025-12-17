// lib/src/widgets/new_order_notification.dart
// Notification popup et son pour nouvelles commandes
// MIGRATED to WL V2 Theme - Uses theme colors

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import '../../white_label/theme/theme_extensions.dart';

class NewOrderNotification extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback onViewOrder;
  final int orderCount;
  
  const NewOrderNotification({
    super.key,
    required this.onDismiss,
    required this.onViewOrder,
    this.orderCount = 1,
  });
  
  @override
  State<NewOrderNotification> createState() => _NewOrderNotificationState();
}

class _NewOrderNotificationState extends State<NewOrderNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  final _audioPlayer = AudioPlayer();
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
    _playNotificationSound();
  }
  
  Future<void> _playNotificationSound() async {
    try {
      // Jouer un son de notification
      // Note: Pour production, ajouter un fichier audio dans assets
      // await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
      
      // Alternative: utiliser le son système
      // Pour l'instant, on simule juste
      print('🔔 Son de notification joué');
    } catch (e) {
      print('Erreur lors de la lecture du son: $e');
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          elevation: 8,
          borderRadius: AppRadius.radiusLG,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primaryColor,
                  context.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.radiusLG,
              boxShadow: AppShadows.floating,
            ),
            child: Row(
              children: [
                // Icône animée
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.onPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: context.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.orderCount > 1
                            ? 'Nouvelles commandes !'
                            : 'Nouvelle commande !',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: context.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.orderCount > 1
                            ? '${widget.orderCount} commandes en attente'
                            : 'Une commande vient d\'arriver',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Boutons d'action
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: context.onPrimary),
                      onPressed: widget.onViewOrder,
                      tooltip: 'Voir',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: context.onPrimary),
                      onPressed: widget.onDismiss,
                      tooltip: 'Fermer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay pour afficher la notification par-dessus l'UI
class OrderNotificationOverlay {
  static OverlayEntry? _currentEntry;
  
  static void show(
    BuildContext context, {
    required VoidCallback onViewOrder,
    int orderCount = 1,
  }) {
    // Fermer la notification précédente si elle existe
    hide();
    
    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: NewOrderNotification(
          orderCount: orderCount,
          onDismiss: () => hide(),
          onViewOrder: () {
            hide();
            onViewOrder();
          },
        ),
      ),
    );
    
    Overlay.of(context).insert(_currentEntry!);
    
    // Auto-dismiss après 10 secondes
    Future.delayed(const Duration(seconds: 10), () {
      hide();
    });
  }
  
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
