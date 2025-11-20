// lib/src/studio/models/text_block_model.dart
// Dynamic text block model for Studio V2 - CRUD-based text management

/// Type of text block for rendering and editing
enum TextBlockType {
  short,    // Single line text (titles, labels)
  long,     // Multi-line text (descriptions, paragraphs)
  markdown, // Markdown formatted text
  html,     // Limited HTML support
}

/// Dynamic text block model
/// Allows unlimited, customizable text blocks for white-label flexibility
class TextBlockModel {
  final String id;
  final String name;           // Internal identifier (e.g., "hero_title", "promo_text_1")
  final String displayName;    // Human-readable name for admin
  final String content;        // Actual text content
  final TextBlockType type;
  final int order;            // Display order in list
  final String category;      // Grouping (e.g., "home", "menu", "cart")
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  TextBlockModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.content,
    required this.type,
    required this.order,
    required this.category,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'content': content,
      'type': type.name,
      'order': order,
      'category': category,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  /// Create from Firestore document
  factory TextBlockModel.fromJson(Map<String, dynamic> json) {
    return TextBlockModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      content: json['content'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      order: json['order'] as int? ?? 0,
      category: json['category'] as String? ?? 'general',
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  static TextBlockType _parseType(String? value) {
    switch (value) {
      case 'long':
        return TextBlockType.long;
      case 'markdown':
        return TextBlockType.markdown;
      case 'html':
        return TextBlockType.html;
      default:
        return TextBlockType.short;
    }
  }

  /// Create a copy with modified fields
  TextBlockModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? content,
    TextBlockType? type,
    int? order,
    String? category,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return TextBlockModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      content: content ?? this.content,
      type: type ?? this.type,
      order: order ?? this.order,
      category: category ?? this.category,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// Create a default text block
  factory TextBlockModel.defaultBlock({
    required String category,
    int order = 0,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return TextBlockModel(
      id: 'text_block_$timestamp',
      name: 'text_block_$timestamp',
      displayName: 'Nouveau bloc de texte',
      content: '',
      type: TextBlockType.short,
      order: order,
      category: category,
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
