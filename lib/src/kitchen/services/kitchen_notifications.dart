// lib/src/kitchen/services/kitchen_notifications.dart

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../models/order.dart';
import '../../utils/logger.dart';
import '../kitchen_constants.dart';

/// Service de notifications pour le mode cuisine
/// Gère les alertes sonores et visuelles pour les nouvelles commandes
class KitchenNotificationService {
  static final KitchenNotificationService _instance = KitchenNotificationService._internal();
  factory KitchenNotificationService() => _instance;
  KitchenNotificationService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _repeatTimer;
  bool _isAlertActive = false;
  List<String> _unseenOrderIds = [];

  /// Callback pour notifier l'UI des nouvelles commandes
  void Function(List<String> orderIds)? onNewOrders;

  /// Démarrer les alertes pour les nouvelles commandes
  void startAlerts(List<Order> unseenOrders) {
    if (unseenOrders.isEmpty) {
      stopAlerts();
      return;
    }

    _unseenOrderIds = unseenOrders.map((o) => o.id).toList();
    
    if (!_isAlertActive) {
      _isAlertActive = true;
      _playNotificationSound();
      _startRepeatTimer();
      
      // Notifier l'UI
      onNewOrders?.call(_unseenOrderIds);
      
      AppLogger.info('Alertes démarrées pour ${unseenOrders.length} commandes non vues');
    }
  }

  /// Arrêter les alertes
  void stopAlerts() {
    _isAlertActive = false;
    _unseenOrderIds.clear();
    _repeatTimer?.cancel();
    _repeatTimer = null;
    
    AppLogger.info('Alertes arrêtées');
  }

  /// Marquer une commande comme vue et mettre à jour les alertes
  void markOrderAsSeen(String orderId) {
    _unseenOrderIds.remove(orderId);
    
    if (_unseenOrderIds.isEmpty) {
      stopAlerts();
    } else {
      // Notifier l'UI du changement
      onNewOrders?.call(_unseenOrderIds);
    }
  }

  /// Jouer le son de notification
  Future<void> _playNotificationSound() async {
    try {
      // Jouer un son court (bip)
      // Note: Comme il n'y a pas de fichier audio dans le projet,
      // nous utilisons un son système ou une fréquence courte
      
      // Pour l'instant, on simule juste le son
      // TODO: Ajouter un vrai fichier audio dans assets/sounds/notification.mp3
      
      AppLogger.debug('Son de notification joué');
      
      // Alternative: utiliser le son système si disponible
      // await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      AppLogger.error('Erreur lors de la lecture du son', e);
    }
  }

  /// Démarrer la répétition du son d'alerte
  void _startRepeatTimer() {
    _repeatTimer?.cancel();
    
    _repeatTimer = Timer.periodic(
      const Duration(seconds: KitchenConstants.notificationRepeatSeconds),
      (timer) {
        if (_isAlertActive && _unseenOrderIds.isNotEmpty) {
          _playNotificationSound();
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// Obtenir le nombre de commandes non vues
  int get unseenOrderCount => _unseenOrderIds.length;

  /// Vérifier si des alertes sont actives
  bool get hasActiveAlerts => _isAlertActive;

  /// Nettoyer les ressources
  void dispose() {
    stopAlerts();
    _audioPlayer.dispose();
  }
}
