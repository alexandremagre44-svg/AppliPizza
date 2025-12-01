// lib/builder/models/builder_block.dart
// Base block model for Builder B3 system

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'builder_enums.dart';
import '../utils/firestore_parsing_helpers.dart';
import '../../white_label/core/module_id.dart';

/// Base block class for all content blocks
/// 
/// This is the foundation for the modular block system.
/// Each block represents a distinct piece of content on a page.
/// 
/// Blocks are:
/// - Modular: Can be added, removed, and reordered
/// - Configurable: Each has specific settings via config map
/// - Reusable: Same block type can be used multiple times
/// - Multi-resto: Supports different configurations per restaurant
class BuilderBlock {
  /// Unique identifier for this block instance
  final String id;

  /// Type of block (hero, banner, text, etc.)
  final BlockType type;

  /// Position order on the page (0 = first, 1 = second, etc.)
  final int order;

  /// Configuration data specific to this block type
  /// 
  /// Examples:
  /// - Hero: {title, subtitle, imageUrl, buttonLabel, tapAction, tapActionTarget}
  /// - Banner: {text, backgroundColor, textColor}
  /// - Text: {content, fontSize, color, alignment}
  /// - ProductList: {mode, layout, limit, columns}
  final Map<String, dynamic> config;

  /// Whether this block is currently active/visible
  final bool isActive;

  /// Visibility setting (always, mobile-only, desktop-only, hidden)
  final BlockVisibility visibility;

  /// Optional custom CSS/styling
  final String? customStyles;

  /// Timestamp when block was created
  final DateTime createdAt;

  /// Timestamp when block was last updated
  final DateTime updatedAt;

  /// Optional module ID required for this block to be visible
  /// If set, the block will only render when the module is enabled
  final ModuleId? requiredModule;

  BuilderBlock({
    required this.id,
    required this.type,
    required this.order,
    required this.config,
    this.isActive = true,
    this.visibility = BlockVisibility.visible,
    this.customStyles,
    this.requiredModule,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with modified fields
  BuilderBlock copyWith({
    String? id,
    BlockType? type,
    int? order,
    Map<String, dynamic>? config,
    bool? isActive,
    BlockVisibility? visibility,
    String? customStyles,
    ModuleId? requiredModule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BuilderBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      order: order ?? this.order,
      config: config ?? Map<String, dynamic>.from(this.config),
      isActive: isActive ?? this.isActive,
      visibility: visibility ?? this.visibility,
      customStyles: customStyles ?? this.customStyles,
      requiredModule: requiredModule ?? this.requiredModule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'order': order,
      'config': config,
      'isActive': isActive,
      'visibility': visibility.toJson(),
      'customStyles': customStyles,
      'requiredModule': requiredModule?.code,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from Firestore JSON
  /// 
  /// FIX B3-LAYOUT-PARSE: Enhanced with better logging and field validation
  /// - Handles Timestamp, String, int, or null for createdAt/updatedAt
  /// - Handles missing or null 'id' field (generates fallback ID)
  /// - Handles missing or null 'type' field (defaults to 'text')
  /// - Handles Config as Map, JSON-encoded String, or null
  /// - Validates required fields: id, type, config, isActive, order
  /// - Never throws - catches all parsing errors to prevent 'Ghost Block' crashes
  factory BuilderBlock.fromJson(Map<String, dynamic> json) {
    // Self-contained config parsing - bulletproof against nested maps
    Map<String, dynamic> configMap = {};
    try {
      final raw = json['config'];
      if (raw is Map) {
        configMap = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        configMap = Map<String, dynamic>.from(jsonDecode(raw));
      }
    } catch (e, stack) {
      debugPrint('❌ [BuilderBlock.fromJson] Config parsing FAILED: $e');
      debugPrint('$stack');
      // Do not throw, keep empty configMap
    }
    
    try {
      // FIX B3-LAYOUT-PARSE: Validate and log missing required fields
      final String? rawId = json['id'] as String?;
      final String? rawType = json['type'] as String?;
      final int? rawOrder = json['order'] as int?;
      final bool? rawIsActive = json['isActive'] as bool?;
      
      // Generate fallback ID if missing
      final String blockId = rawId ?? 
          'block_${DateTime.now().millisecondsSinceEpoch}_${json.hashCode.abs()}';
      
      // Log warnings for missing fields
      if (rawId == null) {
        debugPrint('⚠️ [BuilderBlock.fromJson] Block missing id field, generated fallback: $blockId');
      }
      if (rawType == null) {
        debugPrint('⚠️ [BuilderBlock.fromJson] Block $blockId missing type field, defaulting to "text"');
      }
      if (rawOrder == null) {
        debugPrint('⚠️ [BuilderBlock.fromJson] Block $blockId missing order field, defaulting to 0');
      }
      if (rawIsActive == null) {
        debugPrint('ℹ️ [BuilderBlock.fromJson] Block $blockId missing isActive field, defaulting to true');
      }
      if (configMap.isEmpty && json['config'] != null) {
        debugPrint('⚠️ [BuilderBlock.fromJson] Block $blockId has config but parsing returned empty');
      }
      
      return BuilderBlock(
        id: blockId,
        type: BlockType.fromJson(rawType ?? 'text'),
        order: rawOrder ?? 0,
        config: configMap,
        isActive: rawIsActive ?? true,
        visibility: BlockVisibility.fromJson(
          json['visibility'] as String? ?? 'visible',
        ),
        customStyles: json['customStyles'] as String?,
        requiredModule: _parseModuleId(json['requiredModule'] as String?),
        // Use safe DateTime parsing for Firestore types
        createdAt: safeParseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: safeParseDateTime(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e, stack) {
      // FIX B3-LAYOUT-PARSE: Log full stack trace, never swallow errors silently
      debugPrint('❌ [BuilderBlock.fromJson] Block parse FAILED: $e');
      debugPrint('$stack');
      
      // Return a valid Block with empty config to prevent crashes
      final fallbackId = 'block_fallback_${DateTime.now().millisecondsSinceEpoch}';
      return BuilderBlock(
        id: fallbackId,
        type: BlockType.text,
        order: 0,
        config: configMap, // Use whatever config we managed to parse
      );
    }
  }

  /// Helper to parse ModuleId from a string code
  static ModuleId? _parseModuleId(String? code) {
    if (code == null || code.isEmpty) return null;
    
    for (final moduleId in ModuleId.values) {
      if (moduleId.code == code) {
        return moduleId;
      }
    }
    return null;
  }

  /// Helper: Get a config value with type safety
  T? getConfig<T>(String key, [T? defaultValue]) {
    final value = config[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Helper: Update a config value
  BuilderBlock updateConfig(String key, dynamic value) {
    final newConfig = Map<String, dynamic>.from(config);
    newConfig[key] = value;
    return copyWith(
      config: newConfig,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'BuilderBlock(id: $id, type: ${type.value}, order: $order, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BuilderBlock && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// System Block - non-configurable but positionable system modules
/// 
/// These blocks represent existing application modules that can be
/// positioned in builder pages without additional configuration options.
/// 
/// Supported module types:
/// - roulette: Roulette wheel game
/// - loyalty: Loyalty points section
/// - rewards: Rewards tickets widget
/// - accountActivity: Account activity widget
class SystemBlock extends BuilderBlock {
  /// The system module type (roulette, loyalty, rewards, accountActivity)
  final String moduleType;

  SystemBlock({
    required super.id,
    required this.moduleType,
    required super.order,
    Map<String, dynamic>? config,
    super.isActive,
    super.visibility,
    super.customStyles,
    super.requiredModule,
    super.createdAt,
    super.updatedAt,
  }) : super(
          type: BlockType.system,
          config: config ?? {'moduleType': moduleType},
        );

  /// Create SystemBlock from a BuilderBlock
  factory SystemBlock.fromBlock(BuilderBlock block) {
    final moduleType = block.config['moduleType'] as String? ?? 'unknown';
    return SystemBlock(
      id: block.id,
      moduleType: moduleType,
      order: block.order,
      config: block.config,
      isActive: block.isActive,
      visibility: block.visibility,
      customStyles: block.customStyles,
      requiredModule: block.requiredModule,
      createdAt: block.createdAt,
      updatedAt: block.updatedAt,
    );
  }

  /// Available system module types
  /// 
  /// FIX M2/N2: Updated to be consistent with builder_modules.dart
  /// Includes all modules defined in the builderModules map:
  /// - roulette (same as roulette_module)
  /// - loyalty
  /// - rewards
  /// - accountActivity
  /// - menu_catalog (new)
  /// - cart_module (new)
  /// - profile_module (new)
  /// - roulette_module (alias for roulette)
  static const List<String> availableModules = [
    'roulette',
    'loyalty',
    'rewards',
    'accountActivity',
    // FIX M2/N2: Added modules that are defined in builder_modules.dart
    'menu_catalog',
    'cart_module',
    'profile_module',
    'roulette_module', // Alias for 'roulette' for consistency
  ];

  /// Get display label for a module type
  /// 
  /// FIX M2/N2: Added labels for new module types
  static String getModuleLabel(String moduleType) {
    switch (moduleType) {
      case 'roulette':
      case 'roulette_module':
        return 'Roulette';
      case 'loyalty':
        return 'Fidélité';
      case 'rewards':
        return 'Récompenses';
      case 'accountActivity':
        return 'Activité du compte';
      case 'menu_catalog':
        return 'Catalogue Menu';
      case 'cart_module':
        return 'Panier';
      case 'profile_module':
        return 'Profil';
      default:
        return 'Module inconnu';
    }
  }

  /// Get icon for a module type
  /// 
  /// FIX M2/N2: Added icons for new module types
  static String getModuleIcon(String moduleType) {
    switch (moduleType) {
      case 'roulette':
      case 'roulette_module':
        return '🎰';
      case 'loyalty':
        return '⭐';
      case 'rewards':
        return '🎁';
      case 'accountActivity':
        return '📊';
      case 'menu_catalog':
        return '🍕';
      case 'cart_module':
        return '🛒';
      case 'profile_module':
        return '👤';
      default:
        return '❓';
    }
  }

  @override
  SystemBlock copyWith({
    String? id,
    BlockType? type,
    int? order,
    Map<String, dynamic>? config,
    bool? isActive,
    BlockVisibility? visibility,
    String? customStyles,
    ModuleId? requiredModule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SystemBlock(
      id: id ?? this.id,
      moduleType: moduleType,
      order: order ?? this.order,
      config: config ?? Map<String, dynamic>.from(this.config),
      isActive: isActive ?? this.isActive,
      visibility: visibility ?? this.visibility,
      customStyles: customStyles ?? this.customStyles,
      requiredModule: requiredModule ?? this.requiredModule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['config'] = {...config, 'moduleType': moduleType};
    return json;
  }

  /// Create from Firestore JSON
  /// 
  /// FIX B3-LAYOUT-PARSE: Enhanced with better logging and field validation
  /// - Handles Timestamp, String, int, or null for createdAt/updatedAt
  /// - Handles missing or null 'id' field (generates fallback ID)
  /// - Handles Config as Map, JSON-encoded String, or null
  /// - Never throws - catches all parsing errors to prevent 'Ghost Block' crashes
  factory SystemBlock.fromJson(Map<String, dynamic> json) {
    // Self-contained config parsing - bulletproof against nested maps
    Map<String, dynamic> configMap = {};
    try {
      final raw = json['config'];
      if (raw is Map) {
        configMap = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        configMap = Map<String, dynamic>.from(jsonDecode(raw));
      }
    } catch (e, stack) {
      debugPrint('❌ [SystemBlock.fromJson] Config parsing FAILED: $e');
      debugPrint('$stack');
      // Do not throw, keep empty configMap
    }
    
    try {
      // Handle missing 'id' gracefully
      final String blockId = json['id'] as String? ?? 
          'sysblock_${DateTime.now().millisecondsSinceEpoch}_${json.hashCode.abs()}';
      
      if (json['id'] == null) {
        debugPrint('⚠️ [SystemBlock.fromJson] SystemBlock missing id field, generated fallback: $blockId');
      }
      
      final rawModuleType = configMap['moduleType'] as String?;
      final moduleType = rawModuleType ?? 'unknown';
      if (rawModuleType == null) {
        debugPrint('⚠️ [SystemBlock.fromJson] SystemBlock $blockId missing moduleType, defaulting to "unknown"');
      }
      
      return SystemBlock(
        id: blockId,
        moduleType: moduleType,
        order: json['order'] as int? ?? 0,
        config: configMap,
        isActive: json['isActive'] as bool? ?? true,
        visibility: BlockVisibility.fromJson(
          json['visibility'] as String? ?? 'visible',
        ),
        customStyles: json['customStyles'] as String?,
        requiredModule: BuilderBlock._parseModuleId(json['requiredModule'] as String?),
        // Use safe DateTime parsing for Firestore types
        createdAt: safeParseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: safeParseDateTime(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e, stack) {
      // FIX B3-LAYOUT-PARSE: Log full stack trace, never swallow errors silently
      debugPrint('❌ [SystemBlock.fromJson] Block parse FAILED: $e');
      debugPrint('$stack');
      
      final fallbackId = 'sysblock_fallback_${DateTime.now().millisecondsSinceEpoch}';
      return SystemBlock(
        id: fallbackId,
        moduleType: 'unknown',
        order: 0,
        config: configMap, // Use whatever config we managed to parse
      );
    }
  }

  @override
  String toString() {
    return 'SystemBlock(id: $id, moduleType: $moduleType, order: $order, active: $isActive)';
  }
}
