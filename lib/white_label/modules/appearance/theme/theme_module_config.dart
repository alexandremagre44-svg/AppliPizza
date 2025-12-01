/// Configuration spécifique au module Thème.
///
/// Cette classe contient les paramètres configurables pour le module
/// thème. Elle peut être utilisée à la place de la configuration
/// générique ModuleConfig pour typer les settings.
///
/// Phase 4: Cette classe est utilisée par le ThemeAdapter pour générer
/// des ThemeData Material 3 personnalisés.
class ThemeModuleConfig {
  /// Indique si le module est activé.
  final bool enabled;

  /// Paramètres spécifiques au module.
  final Map<String, dynamic> settings;

  /// Constructeur.
  const ThemeModuleConfig({
    this.enabled = false,
    this.settings = const {},
  });

  // ========== Typed Accessors (Phase 4) ==========
  // Ces getters fournissent un accès typé aux settings pour le ThemeAdapter

  /// Couleur principale (format hex: "#RRGGBB" ou "RRGGBB")
  String? get primaryColor => settings['primaryColor'] as String?;

  /// Couleur secondaire (format hex: "#RRGGBB" ou "RRGGBB")
  String? get secondaryColor => settings['secondaryColor'] as String?;

  /// Couleur d'accent (format hex: "#RRGGBB" ou "RRGGBB")
  String? get accentColor => settings['accentColor'] as String?;

  /// Couleur de fond (format hex: "#RRGGBB" ou "RRGGBB")
  String? get backgroundColor => settings['backgroundColor'] as String?;

  /// Couleur de surface (format hex: "#RRGGBB" ou "RRGGBB")
  String? get surfaceColor => settings['surfaceColor'] as String?;

  /// Couleur d'erreur (format hex: "#RRGGBB" ou "RRGGBB")
  String? get errorColor => settings['errorColor'] as String?;

  /// Police de caractères (ex: "Inter", "Roboto", "Montserrat")
  String? get fontFamily => settings['fontFamily'] as String?;

  /// Rayon des bordures en pixels
  double? get borderRadius => (settings['borderRadius'] as num?)?.toDouble();

  /// Mode sombre activé (non implémenté dans Phase 4)
  bool get useDarkMode => settings['useDarkMode'] as bool? ?? false;

  /// Crée une copie de cette configuration avec les champs modifiés.
  ThemeModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? settings,
  }) {
    return ThemeModuleConfig(
      enabled: enabled ?? this.enabled,
      settings: settings ?? this.settings,
    );
  }

  /// Sérialise la configuration en JSON.
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'settings': settings,
    };
  }

  /// Désérialise une configuration depuis un JSON.
  factory ThemeModuleConfig.fromJson(Map<String, dynamic> json) {
    return ThemeModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'ThemeModuleConfig(enabled: $enabled, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeModuleConfig &&
        other.enabled == enabled &&
        _mapEquals(other.settings, settings);
  }

  @override
  int get hashCode => enabled.hashCode ^ settings.hashCode;

  /// Helper pour comparer deux maps de manière profonde.
  /// 
  /// Note: Cette implémentation effectue une comparaison superficielle
  /// des valeurs (a[key] != b[key]). Pour des objets complexes imbriqués,
  /// elle pourrait ne pas détecter toutes les différences. Dans le contexte
  /// de ThemeModuleConfig, les valeurs sont généralement des types simples
  /// (String, num, bool), donc cette approche est suffisante.
  static bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
