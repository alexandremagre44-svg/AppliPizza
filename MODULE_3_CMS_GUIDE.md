# Module 3: Headless CMS I18N-Ready - Guide d'Utilisation

## Architecture Complète

### 1. Couche DATA (Source de Vérité)

#### Collection Firestore: `studio_content`
- **ID du document** = clé de la chaîne (ex: `home_welcome_title`)
- **Structure du document:**
```json
{
  "key": "home_welcome_title",
  "value": {
    "fr": "Bienvenue chez PizzaDeli'Zza"
  },
  "metadata": {
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  }
}
```

#### Modèle: `ContentString`
Fichier: `lib/src/features/content/data/models/content_string_model.dart`
- Classe immuable sans freezed
- Gestion robuste des données Firestore
- Conversion bidirectionnelle (fromFirestore / toFirestore)

#### Service: `ContentService`
Fichier: `lib/src/features/content/data/content_service.dart`
- `updateString(key, lang, value)` - Mise à jour atomique avec merge
- `watchAllStrings()` - Stream temps réel de tous les contenus
- `createString(key, lang, value)` - Création de nouveaux contenus
- `deleteString(key)` - Suppression de contenus

### 2. Couche DOMAINE (Logique Métier)

#### Providers Riverpod
Fichier: `lib/src/features/content/application/content_provider.dart`

**`allStringsProvider`** (StreamProvider)
- Source de données brute depuis Firestore
- Écoute en temps réel de la collection `studio_content`

**`localizationsProvider`** (Provider)
- Transforme `List<ContentString>` en `Map<String, String>`
- Clé = key du contenu
- Valeur = value['fr']
- Gestion des états: loading, data, error

#### Extension LocalizationExtension

L'extension sur `WidgetRef` fournit la méthode `tr()`:

```dart
extension LocalizationExtension on WidgetRef {
  String tr(String key, {Map<String, String>? params});
}
```

**Comportement:**
- ✅ Clé trouvée → Retourne la traduction
- ⏳ Chargement → Retourne "..."
- ❌ Erreur → Retourne "❌ Error"
- ⚠️ Clé non trouvée → Retourne "⚠️ key_name" (visuel DEV)

**Optimisation:**
- Utilise `select()` pour ne reconstruire que si la clé spécifique change
- Minimise les rebuilds inutiles

### 3. Couche PRÉSENTATION (UI)

#### Interface Admin: `ContentStudioScreen`
Fichier: `lib/src/features/content/presentation/admin/content_studio_screen.dart`

**Fonctionnalités:**
- ✅ Édition inline des contenus
- ✅ Debouncing (250ms) pour économiser les écritures Firestore
- ✅ Indicateurs visuels:
  - 🔄 Sauvegarde en cours (spinner)
  - ✅ Sauvegarde réussie (check vert, disparaît après 1.5s)
  - ❌ Erreur (bordure rouge + SnackBar)
- ✅ Ajout de nouveaux contenus via FAB
- ✅ Tri alphabétique des clés
- ✅ Mises à jour temps réel

**Route:** `/admin/studio/content` (`AppRoutes.studioContent`)

## Utilisation dans l'Application

### Exemple de Refactoring

#### ❌ AVANT (Texte statique)
```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizza Deli\'Zza'),
      ),
      body: Column(
        children: [
          Text('Bienvenue chez PizzaDeli\'Zza'),
          Text('Les meilleures pizzas artisanales'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Commander maintenant'),
          ),
        ],
      ),
    );
  }
}
```

#### ✅ APRÈS (Avec tr())
```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr('home_title')),
      ),
      body: Column(
        children: [
          Text(ref.tr('home_welcome_title')),
          Text(ref.tr('home_welcome_subtitle')),
          ElevatedButton(
            onPressed: () {},
            child: Text(ref.tr('home_order_now')),
          ),
        ],
      ),
    );
  }
}
```

### Interpolation de Paramètres

```dart
// Dans Firestore: "welcome_user" = "Bienvenue, {name}!"
Text(ref.tr('welcome_user', params: {'name': 'Alexandre'}))
// Affiche: "Bienvenue, Alexandre!"

// Dans Firestore: "order_total" = "Total: {amount}€"
Text(ref.tr('order_total', params: {'amount': '25.50'}))
// Affiche: "Total: 25.50€"
```

### Import Nécessaire

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/content/application/content_provider.dart';
```

## Workflow de Développement

### 1. Ajouter un Nouveau Contenu

**Via l'Interface Admin:**
1. Aller sur `/admin/studio/content`
2. Cliquer sur le bouton "+"
3. Entrer la clé (ex: `product_add_to_cart`)
4. Entrer la valeur (ex: `Ajouter au panier`)
5. Cliquer "Ajouter"

**Via Code (si nécessaire):**
```dart
final service = ContentService();
await service.createString('new_key', 'fr', 'Nouvelle valeur');
```

### 2. Modifier un Contenu

**Via l'Interface Admin (Recommandé):**
- Éditer directement dans le champ texte
- Sauvegarde automatique après 250ms

**Via Code:**
```dart
final service = ContentService();
await service.updateString('existing_key', 'fr', 'Valeur modifiée');
```

### 3. Refactoring Systématique

Pour chaque écran:
1. Identifier tous les `Text(...)` avec des strings statiques
2. Créer une clé descriptive (convention: `screen_section_element`)
3. Ajouter le contenu dans l'admin CMS
4. Remplacer `Text('...')` par `Text(ref.tr('key'))`
5. Tester l'affichage

**Convention de Nommage:**
- `screen_element` - Ex: `home_title`
- `section_element` - Ex: `cart_checkout`
- `common_action` - Ex: `common_save`
- `error_type` - Ex: `error_network`

## Seed Initial des Données

Pour peupler la base avec des contenus initiaux:

```dart
import 'package:pizza_delizza/src/features/content/data/content_service.dart';
import 'package:pizza_delizza/src/features/content/data/initial_content_seeder.dart';

void seedContent() async {
  final service = ContentService();
  final seeder = InitialContentSeeder(service);
  await seeder.seedInitialContent();
}
```

## Performance & Optimisation

### Optimisation des Rebuilds

Le système utilise `select()` pour optimiser les rebuilds:

```dart
// ❌ BAD - Reconstruit pour TOUT changement
Text(ref.watch(localizationsProvider).value?['key'] ?? '')

// ✅ GOOD - Reconstruit UNIQUEMENT si cette clé change
Text(ref.tr('key'))
```

### Debouncing

Le debouncing de 250ms dans l'admin:
- Réduit les écritures Firestore
- Améliore l'UX (pas de latence perceptible)
- Économise les coûts Firestore

## Évolution Future (I18N)

Le système est **prêt pour l'internationalisation**:

### Ajouter une Nouvelle Langue

1. **Modifier le service:**
```dart
// Ajouter 'en' en plus de 'fr'
await service.updateString('home_title', 'en', 'Welcome to PizzaDeli\'Zza');
```

2. **Ajouter un sélecteur de langue:**
```dart
final currentLanguageProvider = StateProvider<String>((ref) => 'fr');
```

3. **Modifier localizationsProvider:**
```dart
final localizationsProvider = Provider<AsyncValue<Map<String, String>>>((ref) {
  final stringsAsync = ref.watch(allStringsProvider);
  final currentLang = ref.watch(currentLanguageProvider);
  
  return stringsAsync.when(
    data: (strings) {
      final map = <String, String>{};
      for (final contentString in strings) {
        final value = contentString.values[currentLang] ?? '';
        if (value.isNotEmpty) {
          map[contentString.key] = value;
        }
      }
      return AsyncValue.data(map);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
```

4. **Mise à jour de l'admin UI:**
Ajouter un sélecteur de langue dans le `ContentStudioScreen`.

## Tests

### Test du Service

```dart
test('ContentService updates string correctly', () async {
  final service = ContentService();
  await service.createString('test_key', 'fr', 'Test value');
  
  final strings = await service.getAllStrings();
  expect(strings.any((s) => s.key == 'test_key'), true);
});
```

### Test du Provider

```dart
testWidgets('tr() returns correct translation', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          return Text(ref.tr('test_key'));
        },
      ),
    ),
  );
  
  await tester.pump();
  expect(find.text('Test value'), findsOneWidget);
});
```

## Checklist de Migration

Pour chaque écran à migrer:

- [ ] Identifier tous les textes statiques
- [ ] Créer les clés de contenu dans l'admin
- [ ] Importer l'extension LocalizationExtension
- [ ] Remplacer `Text('...')` par `Text(ref.tr('...'))`
- [ ] Remplacer les textes dans AppBar
- [ ] Remplacer les textes dans les boutons
- [ ] Remplacer les textes dans les dialogues
- [ ] Remplacer les textes dans les SnackBars
- [ ] Tester l'écran
- [ ] Vérifier les états loading/error

## Résumé

✅ **Architecture Complète:** Data → Domain → Presentation
✅ **Performance:** Select() + Debouncing + Atomic updates
✅ **UX Admin:** Inline editing + Visual feedback + Real-time
✅ **Prêt I18N:** Structure extensible pour multi-langues
✅ **Type-Safe:** Pas de magic strings, tout typé
✅ **Maintenable:** Séparation claire des responsabilités

**Le système est opérationnel et prêt pour le refactoring systématique de l'application!**
