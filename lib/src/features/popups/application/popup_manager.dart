// lib/src/utils/popup_manager.dart
// Manager for displaying popups on the client side

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/popup_config.dart';
import '../services/popup_service.dart';
import '../widgets/popup_dialog.dart';

class PopupManager {
  final PopupService _popupService = PopupService();
  static const String _dismissedPopupsKey = 'dismissed_popups';
  
  // Session storage for oncePerSession popups
  static final Set<String> _shownThisSession = {};
  
  /// Show popups based on trigger
  Future<void> showPopupsForTrigger(
    BuildContext context,
    PopupTrigger trigger, {
    required String userId,
  }) async {
    final popups = await _popupService.getActivePopups();
    
    // Filter by trigger
    final triggeredPopups = popups.where((p) => p.trigger == trigger).toList();
    
    // Sort by priority
    triggeredPopups.sort((a, b) => b.priority.compareTo(a.priority));
    
    for (final popup in triggeredPopups) {
      final shouldShow = await _shouldShowPopup(popup, userId);
      if (shouldShow && context.mounted) {
        await _showPopup(context, popup, userId);
        // Only show one popup at a time
        break;
      }
    }
  }
  
  Future<bool> _shouldShowPopup(PopupConfig popup, String userId) async {
    // Check if user has dismissed this popup permanently
    final prefs = await SharedPreferences.getInstance();
    final dismissedPopups = prefs.getStringList(_dismissedPopupsKey) ?? [];
    if (dismissedPopups.contains(popup.id)) {
      return false;
    }
    
    // Check session-based display
    if (_shownThisSession.contains(popup.id)) {
      return false;
    }
    
    // Check Firestore-based display conditions
    return await _popupService.shouldShowPopup(popup, userId);
  }
  
  Future<void> _showPopup(
    BuildContext context,
    PopupConfig popup,
    String userId,
  ) async {
    // Mark as shown in session
    _shownThisSession.add(popup.id);
    
    // Record view in Firestore
    await _popupService.recordPopupView(userId, popup.id);
    
    if (!context.mounted) return;
    
    // Show the popup dialog
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PopupDialog(
        popup: popup,
        onDismiss: () => _dismissPopupPermanently(popup.id),
      ),
    );
  }
  
  Future<void> _dismissPopupPermanently(String popupId) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedPopups = prefs.getStringList(_dismissedPopupsKey) ?? [];
    if (!dismissedPopups.contains(popupId)) {
      dismissedPopups.add(popupId);
      await prefs.setStringList(_dismissedPopupsKey, dismissedPopups);
    }
  }
  
  /// Clear session storage (call when user logs out)
  static void clearSession() {
    _shownThisSession.clear();
  }
  
  /// Reset dismissed popups (useful for testing)
  static Future<void> resetDismissedPopups() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedPopupsKey);
    _shownThisSession.clear();
  }
}
