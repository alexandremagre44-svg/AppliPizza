// lib/src/models/subscriber.dart
// Modèle pour les abonnés au mailing

class Subscriber {
  final String id;
  final String email;
  final String status; // 'active', 'unsubscribed'
  final List<String> tags;
  final bool consent;
  final DateTime dateInscription;
  final String? unsubscribeToken;

  Subscriber({
    required this.id,
    required this.email,
    this.status = 'active',
    this.tags = const ['client'],
    this.consent = true,
    required this.dateInscription,
    this.unsubscribeToken,
  });

  // Conversion vers Map pour stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'status': status,
      'tags': tags,
      'consent': consent,
      'dateInscription': dateInscription.toIso8601String(),
      'unsubscribeToken': unsubscribeToken,
    };
  }

  // Création depuis Map
  factory Subscriber.fromJson(Map<String, dynamic> json) {
    return Subscriber(
      id: json['id'] as String,
      email: json['email'] as String,
      status: json['status'] as String? ?? 'active',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? ['client'],
      consent: json['consent'] as bool? ?? true,
      dateInscription: DateTime.parse(json['dateInscription'] as String),
      unsubscribeToken: json['unsubscribeToken'] as String?,
    );
  }

  // Copie avec modifications
  Subscriber copyWith({
    String? id,
    String? email,
    String? status,
    List<String>? tags,
    bool? consent,
    DateTime? dateInscription,
    String? unsubscribeToken,
  }) {
    return Subscriber(
      id: id ?? this.id,
      email: email ?? this.email,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      consent: consent ?? this.consent,
      dateInscription: dateInscription ?? this.dateInscription,
      unsubscribeToken: unsubscribeToken ?? this.unsubscribeToken,
    );
  }
}
