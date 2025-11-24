// lib/builder/utils/action_helper.dart
// Helper for handling block actions (navigation, URLs, scroll)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Types of actions supported by blocks
enum BlockActionType {
  none,
  openPage,
  openUrl,
  scrollToBlock,
}

/// Configuration for a block action
class BlockAction {
  final BlockActionType type;
  final String? value;
  
  const BlockAction({
    required this.type,
    this.value,
  });

  /// Parse action from config map
  factory BlockAction.fromConfig(Map<String, dynamic>? config) {
    if (config == null || config.isEmpty) {
      return const BlockAction(type: BlockActionType.none);
    }

    final typeStr = config['type'] as String?;
    final value = config['value'] as String?;

    switch (typeStr?.toLowerCase()) {
      case 'openpage':
      case 'navigate':
        return BlockAction(type: BlockActionType.openPage, value: value);
      case 'openurl':
      case 'url':
        return BlockAction(type: BlockActionType.openUrl, value: value);
      case 'scrolltoblock':
      case 'scroll':
        return BlockAction(type: BlockActionType.scrollToBlock, value: value);
      default:
        return const BlockAction(type: BlockActionType.none);
    }
  }

  /// Check if action is defined (not none)
  bool get isActive => type != BlockActionType.none && value != null && value!.isNotEmpty;
}

/// Helper class for executing block actions
class ActionHelper {
  /// Execute a block action
  static Future<void> execute(BuildContext context, BlockAction action) async {
    if (!action.isActive) return;

    switch (action.type) {
      case BlockActionType.openPage:
        await _openPage(context, action.value!);
        break;
      case BlockActionType.openUrl:
        await _openUrl(action.value!);
        break;
      case BlockActionType.scrollToBlock:
        await _scrollToBlock(context, action.value!);
        break;
      case BlockActionType.none:
        break;
    }
  }

  /// Navigate to a page (Builder page or app route)
  static Future<void> _openPage(BuildContext context, String route) async {
    try {
      // Ensure route starts with /
      final normalizedRoute = route.startsWith('/') ? route : '/$route';
      
      if (context.mounted) {
        context.go(normalizedRoute);
      }
    } catch (e) {
      debugPrint('Error navigating to page: $e');
    }
  }

  /// Open external URL
  static Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Cannot launch URL: $url');
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
    }
  }

  /// Scroll to a specific block (by ID)
  static Future<void> _scrollToBlock(BuildContext context, String blockId) async {
    // This would require a global key registry or scrollable context
    // For now, log the intent
    debugPrint('Scroll to block requested: $blockId (not yet implemented)');
    
    // TODO: Implement scroll to block functionality
    // Would need:
    // 1. Global registry of block keys
    // 2. Access to ScrollController
    // 3. Calculate block position and animate scroll
  }

  /// Create a tap handler for a block with action
  static VoidCallback? createTapHandler(
    BuildContext context,
    Map<String, dynamic>? actionConfig,
  ) {
    if (actionConfig == null || actionConfig.isEmpty) {
      return null;
    }

    final action = BlockAction.fromConfig(actionConfig);
    if (!action.isActive) {
      return null;
    }

    return () => execute(context, action);
  }

  /// Wrap a widget with GestureDetector if action is defined
  static Widget wrapWithAction(
    BuildContext context,
    Widget child,
    Map<String, dynamic>? actionConfig,
  ) {
    final tapHandler = createTapHandler(context, actionConfig);
    
    if (tapHandler == null) {
      return child;
    }

    return GestureDetector(
      onTap: tapHandler,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: child,
      ),
    );
  }
}
