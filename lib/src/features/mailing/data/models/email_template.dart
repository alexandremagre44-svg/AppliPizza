// lib/src/models/email_template.dart
// Modèle pour les templates d'emails marketing

class EmailTemplate {
  final String id;
  final String name;
  final String subject;
  final String htmlBody;
  final List<String> variables; // Liste des variables disponibles
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? bannerUrl;
  final String? ctaText;
  final String? ctaUrl;

  EmailTemplate({
    required this.id,
    required this.name,
    required this.subject,
    required this.htmlBody,
    this.variables = const [
      '{{product}}',
      '{{discount}}',
      '{{ctaUrl}}',
      '{{bannerUrl}}',
      '{{content}}',
      '{{unsubUrl}}',
      '{{appDownloadUrl}}'
    ],
    required this.createdAt,
    this.updatedAt,
    this.bannerUrl,
    this.ctaText,
    this.ctaUrl,
  });

  // Conversion vers Map pour stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'htmlBody': htmlBody,
      'variables': variables,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'bannerUrl': bannerUrl,
      'ctaText': ctaText,
      'ctaUrl': ctaUrl,
    };
  }

  // Création depuis Map
  factory EmailTemplate.fromJson(Map<String, dynamic> json) {
    return EmailTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      htmlBody: json['htmlBody'] as String,
      variables: (json['variables'] as List<dynamic>?)?.cast<String>() ??
          [
            '{{product}}',
            '{{discount}}',
            '{{ctaUrl}}',
            '{{bannerUrl}}',
            '{{content}}',
            '{{unsubUrl}}',
            '{{appDownloadUrl}}'
          ],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      bannerUrl: json['bannerUrl'] as String?,
      ctaText: json['ctaText'] as String?,
      ctaUrl: json['ctaUrl'] as String?,
    );
  }

  // Copie avec modifications
  EmailTemplate copyWith({
    String? id,
    String? name,
    String? subject,
    String? htmlBody,
    List<String>? variables,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bannerUrl,
    String? ctaText,
    String? ctaUrl,
  }) {
    return EmailTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      htmlBody: htmlBody ?? this.htmlBody,
      variables: variables ?? this.variables,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      ctaText: ctaText ?? this.ctaText,
      ctaUrl: ctaUrl ?? this.ctaUrl,
    );
  }

  // Remplacer les variables dans le template
  String compileWithVariables(Map<String, String> values) {
    String compiled = htmlBody;
    values.forEach((key, value) {
      compiled = compiled.replaceAll('{{$key}}', value);
    });
    return compiled;
  }
}
