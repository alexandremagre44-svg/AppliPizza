# Système de Paramètres de la Roulette

## Vue d'ensemble

Ce système permet aux administrateurs de configurer toutes les règles d'activation de la "Roue de la chance" via le Studio Builder. Il complète le système de configuration des segments en ajoutant des règles de disponibilité, limites d'utilisation, et conditions d'éligibilité.

## Architecture

### Modèle de données

#### RouletteSettings

**Stockage Firestore**: 
- Collection: `marketing`
- Document: `roulette_settings`

**Champs principaux**:

| Champ | Type | Description | Valeurs possibles |
|-------|------|-------------|-------------------|
| `isEnabled` | bool | Activation globale de la roulette | true/false |
| `limitType` | String | Type de limite d'utilisation | 'none', 'per_day', 'per_week', 'per_month', 'total' |
| `limitValue` | int | Nombre maximum d'utilisations selon le type | 0-n |
| `cooldownHours` | int | Délai en heures entre deux utilisations | 0-n |
| `validFrom` | Timestamp? | Date de début de validité (optionnel) | - |
| `validTo` | Timestamp? | Date de fin de validité (optionnel) | - |
| `activeDays` | List<int> | Jours actifs de la semaine | [1-7] (1=lundi, 7=dimanche) |
| `activeStartHour` | int | Heure de début d'activation | 0-23 |
| `activeEndHour` | int | Heure de fin d'activation | 0-23 |
| `eligibilityType` | String | Type d'éligibilité utilisateur | 'all', 'new_users', 'loyal_users', 'min_orders', 'min_spent' |
| `minOrders` | int? | Nombre minimum de commandes requises | null ou valeur positive |
| `minSpent` | double? | Montant minimum dépensé requis | null ou valeur positive |

**Méthodes utilitaires**:
- `isActiveOnDay(int dayOfWeek)`: Vérifie si la roulette est active pour un jour donné
- `isActiveAtHour(int hour)`: Vérifie si la roulette est active à une heure donnée
- `isWithinValidityPeriod(DateTime now)`: Vérifie si la date actuelle est dans la période de validité

### Écran d'administration

#### RouletteSettingsScreen

**Chemin**: `lib/src/screens/admin/studio/roulette_settings_screen.dart`

**Navigation**: Via AdminStudioScreen → "Paramètres de la roulette"

**Sections de l'écran**:

1. **Activation globale**
   - Switch pour activer/désactiver la roulette
   - Texte explicatif

2. **Limites d'utilisation**
   - Dropdown pour sélectionner le type de limite
   - Champ numérique pour la valeur de la limite (si applicable)

3. **Cooldown**
   - Champ numérique pour définir le délai en heures

4. **Période de validité**
   - DatePicker pour la date de début (optionnel)
   - DatePicker pour la date de fin (optionnel)
   - Boutons pour effacer les dates

5. **Jours actifs**
   - 7 boutons circulaires pour les jours de la semaine (L M M J V S D)
   - Sélection multiple
   - Design interactif avec tooltip

6. **Horaires actifs**
   - Champ pour l'heure de début (0-23)
   - Champ pour l'heure de fin (0-23)
   - Support des plages traversant minuit

7. **Éligibilité utilisateur**
   - Dropdown pour le type d'éligibilité
   - Champs conditionnels selon le type:
     - `min_orders`: champ pour nombre de commandes
     - `min_spent`: champ pour montant dépensé

8. **Sauvegarde**
   - Bouton de sauvegarde avec validation
   - États de chargement et d'erreur
   - Feedback visuel (SnackBar)

## Design System

L'interface utilise 100% le Design System Pizza Deli'Zza Material 3:

- **Colors**: `AppColors` (primary, surface, outline, etc.)
- **Spacing**: `AppSpacing` (md, sm, lg)
- **Radius**: `AppRadius` (card, input, button)
- **Typography**: `AppTextStyles` (titleMedium, bodyMedium, labelLarge)

## Intégration dans le Studio

Le nouveau écran est accessible via le Studio Builder:

```dart
AdminStudioScreen
  └─ Card "Paramètres de la roulette"
      ├─ Icône: Icons.settings_outlined
      ├─ Titre: "Paramètres de la roulette"
      ├─ Sous-titre: "Règles, limites et conditions d'utilisation"
      └─ Navigation → RouletteSettingsScreen()
```

## Utilisation

### Pour l'administrateur

1. Aller dans le **Studio** depuis le menu admin
2. Cliquer sur **"Paramètres de la roulette"**
3. Configurer les différentes sections selon les besoins
4. Cliquer sur **"Enregistrer"** pour sauvegarder dans Firestore

### Pour le développeur

#### Charger les paramètres

```dart
final doc = await FirebaseFirestore.instance
    .collection('marketing')
    .doc('roulette_settings')
    .get();

if (doc.exists && doc.data() != null) {
  final settings = RouletteSettings.fromMap(doc.data()!);
  
  // Vérifier si la roulette est active
  if (settings.isEnabled) {
    // Vérifier le jour
    final today = DateTime.now().weekday;
    if (settings.isActiveOnDay(today)) {
      // Vérifier l'heure
      final currentHour = DateTime.now().hour;
      if (settings.isActiveAtHour(currentHour)) {
        // Vérifier la période de validité
        if (settings.isWithinValidityPeriod(DateTime.now())) {
          // La roulette peut être affichée
        }
      }
    }
  }
}
```

#### Vérifier l'éligibilité d'un utilisateur

```dart
bool isUserEligible(RouletteSettings settings, UserProfile user) {
  switch (settings.eligibilityType) {
    case 'all':
      return true;
    case 'new_users':
      // Vérifier si l'utilisateur est nouveau
      return user.createdAt.isAfter(DateTime.now().subtract(Duration(days: 30)));
    case 'loyal_users':
      // Vérifier si l'utilisateur est fidèle
      return user.orderCount > 10;
    case 'min_orders':
      return user.orderCount >= (settings.minOrders ?? 0);
    case 'min_spent':
      return user.totalSpent >= (settings.minSpent ?? 0.0);
    default:
      return false;
  }
}
```

## Validation

L'écran implémente une validation complète:

- **Limites**: Valeur requise et positive si type != 'none'
- **Cooldown**: Valeur >= 0
- **Horaires**: Valeurs entre 0 et 23
- **Éligibilité**: Valeurs requises et positives pour min_orders/min_spent

## États et gestion des erreurs

- État de chargement pendant la récupération des données
- État de sauvegarde avec spinner sur le bouton
- Messages d'erreur via SnackBar (AppColors.error)
- Messages de succès via SnackBar (AppColors.success)

## Compatibilité

- Compatible avec les modules existants (1, 2, 3)
- Aucun impact sur les segments de la roulette
- Aucune modification de la roue (wheel)
- Stockage séparé dans Firestore (marketing/roulette_settings)

## Notes importantes

1. **Valeurs par défaut**: Si le document n'existe pas dans Firestore, l'écran utilise `RouletteSettings.defaultSettings()`
2. **Jours actifs**: Par défaut, tous les jours sont actifs [1,2,3,4,5,6,7]
3. **Horaires**: Par défaut, actif 24h/24 (0h-23h)
4. **Plage horaire traversant minuit**: La logique `isActiveAtHour()` gère correctement les cas comme 22h-2h

## Évolutions futures possibles

- Historique des modifications des paramètres
- Prévisualisation en temps réel de l'impact des règles
- Statistiques d'utilisation de la roulette
- Notifications aux utilisateurs lors des changements
- Support de règles multiples avec priorités
- Intégration avec le système de segments pour une configuration unifiée

## Ressources liées

- [ROULETTE_SEGMENTS_README.md](./ROULETTE_SEGMENTS_README.md) - Configuration des segments
- [PIZZA_ROULETTE_WHEEL_IMPLEMENTATION.md](./PIZZA_ROULETTE_WHEEL_IMPLEMENTATION.md) - Implémentation de la roue
- [PIZZA_ROULETTE_WHEEL_USAGE.md](./PIZZA_ROULETTE_WHEEL_USAGE.md) - Guide d'utilisation
