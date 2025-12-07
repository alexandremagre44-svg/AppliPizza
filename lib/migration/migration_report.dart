/// lib/migration/migration_report.dart
///
/// Modèle pour le rapport de migration Firestore.
/// Contient les résultats et statistiques de chaque migration exécutée.
library;

/// Rapport détaillé d'une exécution de migration.
///
/// Ce modèle contient toutes les informations sur les migrations exécutées,
/// incluant le nombre de documents modifiés et les erreurs rencontrées.
class MigrationReport {
  /// Nombre de documents plan/unified créés.
  final int restaurantPlansCreated;

  /// Nombre de restaurants normalisés (champs id, status).
  final int restaurantsNormalized;

  /// Nombre de configurations roulette migrées vers plan/unified.
  final int rouletteSettingsMigrated;

  /// Nombre d'utilisateurs normalisés (name/displayName, isAdmin).
  final int usersNormalized;

  /// Nombre de configurations loyalty_settings migrées vers builder_settings.
  final int loyaltySettingsMigrated;

  /// Nombre de segments de roulette migrés vers chaque restaurant.
  final int rouletteSegmentsMigrated;

  /// Liste des erreurs rencontrées pendant la migration.
  final List<String> errors;

  /// Durée totale de l'exécution de la migration.
  final Duration duration;

  /// Indique si la migration était en mode dry-run (simulation).
  final bool isDryRun;

  /// Timestamp de début de la migration.
  final DateTime startedAt;

  /// Timestamp de fin de la migration.
  final DateTime completedAt;

  /// Constructeur.
  const MigrationReport({
    required this.restaurantPlansCreated,
    required this.restaurantsNormalized,
    required this.rouletteSettingsMigrated,
    required this.usersNormalized,
    required this.loyaltySettingsMigrated,
    required this.rouletteSegmentsMigrated,
    required this.errors,
    required this.duration,
    required this.isDryRun,
    required this.startedAt,
    required this.completedAt,
  });

  /// Indique si la migration s'est terminée sans erreur.
  bool get isSuccess => errors.isEmpty;

  /// Nombre total de documents modifiés.
  int get totalDocumentsModified =>
      restaurantPlansCreated +
      restaurantsNormalized +
      rouletteSettingsMigrated +
      usersNormalized +
      loyaltySettingsMigrated +
      rouletteSegmentsMigrated;

  /// Retourne un résumé textuel du rapport.
  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('=== Migration Report ===');
    buffer.writeln('Mode: ${isDryRun ? "DRY-RUN (simulation)" : "LIVE"}');
    buffer.writeln('Started: ${startedAt.toIso8601String()}');
    buffer.writeln('Completed: ${completedAt.toIso8601String()}');
    buffer.writeln('Duration: ${duration.inSeconds}s');
    buffer.writeln('');
    buffer.writeln('Results:');
    buffer.writeln('  - Restaurant plans created: $restaurantPlansCreated');
    buffer.writeln('  - Restaurants normalized: $restaurantsNormalized');
    buffer.writeln('  - Roulette settings migrated: $rouletteSettingsMigrated');
    buffer.writeln('  - Users normalized: $usersNormalized');
    buffer.writeln('  - Loyalty settings migrated: $loyaltySettingsMigrated');
    buffer.writeln('  - Roulette segments migrated: $rouletteSegmentsMigrated');
    buffer.writeln('  - Total documents modified: $totalDocumentsModified');
    buffer.writeln('');

    if (errors.isEmpty) {
      buffer.writeln('Status: ✓ SUCCESS');
    } else {
      buffer.writeln('Status: ✗ ERRORS (${errors.length})');
      buffer.writeln('Errors:');
      for (var i = 0; i < errors.length; i++) {
        buffer.writeln('  ${i + 1}. ${errors[i]}');
      }
    }

    return buffer.toString();
  }

  /// Sérialise le rapport en JSON.
  Map<String, dynamic> toJson() {
    return {
      'restaurantPlansCreated': restaurantPlansCreated,
      'restaurantsNormalized': restaurantsNormalized,
      'rouletteSettingsMigrated': rouletteSettingsMigrated,
      'usersNormalized': usersNormalized,
      'loyaltySettingsMigrated': loyaltySettingsMigrated,
      'rouletteSegmentsMigrated': rouletteSegmentsMigrated,
      'errors': errors,
      'duration': duration.inMilliseconds,
      'isDryRun': isDryRun,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// Désérialise un rapport depuis un JSON.
  factory MigrationReport.fromJson(Map<String, dynamic> json) {
    return MigrationReport(
      restaurantPlansCreated: json['restaurantPlansCreated'] as int,
      restaurantsNormalized: json['restaurantsNormalized'] as int,
      rouletteSettingsMigrated: json['rouletteSettingsMigrated'] as int,
      usersNormalized: json['usersNormalized'] as int,
      loyaltySettingsMigrated: json['loyaltySettingsMigrated'] as int? ?? 0,
      rouletteSegmentsMigrated: json['rouletteSegmentsMigrated'] as int? ?? 0,
      errors: List<String>.from(json['errors'] as List),
      duration: Duration(milliseconds: json['duration'] as int),
      isDryRun: json['isDryRun'] as bool,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  @override
  String toString() => summary;
}
