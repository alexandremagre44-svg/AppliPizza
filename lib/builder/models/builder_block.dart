// lib/builder/models/builder_block.dart
// Base block model for Builder B3 system

import 'dart:convert';
import 'builder_enums.dart';
import '../utils/firestore_parsing_helpers.dart';

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

  BuilderBlock({
    required this.id,
    required this.type,
    required this.order,
    required this.config,
    this.isActive = true,
    this.visibility = BlockVisibility.visible,
    this.customStyles,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from Firestore JSON
  /// 
  /// This method is self-contained and crash-proof:
  /// - Handles Timestamp, String, int, or null for createdAt/updatedAt
  /// - Handles missing or null 'id' field (generates fallback ID)
  /// - Handles missing or null 'type' field (defaults to 'text')
  /// - Handles Config as Map, JSON-encoded String, or null
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
    } catch (e) {
      print('⚠️ Config parsing error: $e');
      // Do not throw, keep empty configMap
    }
    
    try {
      // Handle missing 'id' gracefully
      final String blockId = json['id'] as String? ?? 
          'block_${DateTime.now().millisecondsSinceEpoch}_${json.hashCode.abs()}';
      
      if (json['id'] == null) {
        print('⚠️ Warning: Block missing id field, generated fallback: $blockId');
      }
      
      return BuilderBlock(
        id: blockId,
        type: BlockType.fromJson(json['type'] as String? ?? 'text'),
        order: json['order'] as int? ?? 0,
        config: configMap,
        isActive: json['isActive'] as bool? ?? true,
        visibility: BlockVisibility.fromJson(
          json['visibility'] as String? ?? 'visible',
        ),
        customStyles: json['customStyles'] as String?,
        // Use safe DateTime parsing for Firestore types
        createdAt: safeParseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: safeParseDateTime(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e) {
      // Log warning but return a valid Block with empty config to prevent crashes
      print('⚠️ Warning: Error parsing block, returning fallback block: $e');
      final fallbackId = 'block_fallback_${DateTime.now().millisecondsSinceEpoch}';
      return BuilderBlock(
        id: fallbackId,
        type: BlockType.text,
        order: 0,
        config: configMap, // Use whatever config we managed to parse
      );
    }
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
      createdAt: block.createdAt,
      updatedAt: block.updatedAt,
    );
  }

  /// Available system module types
  static const List<String> availableModules = [
    'roulette',
    'loyalty',
    'rewards',
    'accountActivity',
  ];

  /// Get display label for a module type
  static String getModuleLabel(String moduleType) {
    switch (moduleType) {
      case 'roulette':
        return 'Roulette';
      case 'loyalty':
        return 'Fidélité';
      case 'rewards':
        return 'Récompenses';
      case 'accountActivity':
        return 'Activité du compte';
      default:
        return 'Module inconnu';
    }
  }

  /// Get icon for a module type
  static String getModuleIcon(String moduleType) {
    switch (moduleType) {
      case 'roulette':
        return '🎰';
      case 'loyalty':
        return '⭐';
      case 'rewards':
        return '🎁';
      case 'accountActivity':
        return '📊';
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
  /// This method is self-contained and crash-proof:
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
    } catch (e) {
      print('⚠️ Config parsing error: $e');
      // Do not throw, keep empty configMap
    }
    
    try {
      // Handle missing 'id' gracefully
      final String blockId = json['id'] as String? ?? 
          'sysblock_${DateTime.now().millisecondsSinceEpoch}_${json.hashCode.abs()}';
      
      if (json['id'] == null) {
        print('⚠️ Warning: SystemBlock missing id field, generated fallback: $blockId');
      }
      
      return SystemBlock(
        id: blockId,
        moduleType: configMap['moduleType'] as String? ?? 'unknown',
        order: json['order'] as int? ?? 0,
        config: configMap,
        isActive: json['isActive'] as bool? ?? true,
        visibility: BlockVisibility.fromJson(
          json['visibility'] as String? ?? 'visible',
        ),
        customStyles: json['customStyles'] as String?,
        // Use safe DateTime parsing for Firestore types
        createdAt: safeParseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: safeParseDateTime(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e) {
      // Log warning but return a valid SystemBlock with empty config to prevent crashes
      print('⚠️ Warning: Error parsing SystemBlock, returning fallback block: $e');
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
