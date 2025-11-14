// lib/src/models/campaign.dart
// Modèle pour les campagnes d'emailing

class Campaign {
  final String id;
  final String name;
  final String templateId;
  final String segment; // 'all', 'active', ou tags spécifiques
  final DateTime? scheduleAt; // null = envoi immédiat
  final String status; // 'draft', 'scheduled', 'sending', 'sent', 'failed'
  final DateTime createdAt;
  final DateTime? sentAt;
  final CampaignStats? stats;

  Campaign({
    required this.id,
    required this.name,
    required this.templateId,
    this.segment = 'all',
    this.scheduleAt,
    this.status = 'draft',
    required this.createdAt,
    this.sentAt,
    this.stats,
  });

  // Conversion vers Map pour stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'templateId': templateId,
      'segment': segment,
      'scheduleAt': scheduleAt?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'stats': stats?.toJson(),
    };
  }

  // Création depuis Map
  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      name: json['name'] as String,
      templateId: json['templateId'] as String,
      segment: json['segment'] as String? ?? 'all',
      scheduleAt: json['scheduleAt'] != null
          ? DateTime.parse(json['scheduleAt'] as String)
          : null,
      status: json['status'] as String? ?? 'draft',
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      stats: json['stats'] != null
          ? CampaignStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  // Copie avec modifications
  Campaign copyWith({
    String? id,
    String? name,
    String? templateId,
    String? segment,
    DateTime? scheduleAt,
    String? status,
    DateTime? createdAt,
    DateTime? sentAt,
    CampaignStats? stats,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      segment: segment ?? this.segment,
      scheduleAt: scheduleAt ?? this.scheduleAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      stats: stats ?? this.stats,
    );
  }
}

// Statistiques de campagne
class CampaignStats {
  final int totalRecipients;
  final int sent;
  final int failed;
  final int opened;
  final int clicked;

  CampaignStats({
    this.totalRecipients = 0,
    this.sent = 0,
    this.failed = 0,
    this.opened = 0,
    this.clicked = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalRecipients': totalRecipients,
      'sent': sent,
      'failed': failed,
      'opened': opened,
      'clicked': clicked,
    };
  }

  factory CampaignStats.fromJson(Map<String, dynamic> json) {
    return CampaignStats(
      totalRecipients: json['totalRecipients'] as int? ?? 0,
      sent: json['sent'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      opened: json['opened'] as int? ?? 0,
      clicked: json['clicked'] as int? ?? 0,
    );
  }

  CampaignStats copyWith({
    int? totalRecipients,
    int? sent,
    int? failed,
    int? opened,
    int? clicked,
  }) {
    return CampaignStats(
      totalRecipients: totalRecipients ?? this.totalRecipients,
      sent: sent ?? this.sent,
      failed: failed ?? this.failed,
      opened: opened ?? this.opened,
      clicked: clicked ?? this.clicked,
    );
  }
}
