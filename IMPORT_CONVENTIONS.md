# Conventions d'Imports - Pizza Delizza

## Règle Absolue

**TOUS les imports vers `lib/domain/**` DOIVENT utiliser la syntaxe `package:`**

### ✅ Correct

```dart
import 'package:pizza_delizza/domain/module_exposure.dart';
import 'package:pizza_delizza/domain/fulfillment_config.dart';
```

### ❌ Interdit

```dart
// NE JAMAIS utiliser d'imports relatifs vers domain
import '../../../../domain/module_exposure.dart';
import '../../domain/fulfillment_config.dart';
import '../domain/module_exposure.dart';
```

## Pourquoi cette règle?

1. **Stabilité**: Les imports relatifs profonds (avec `../../../..`) sont fragiles et cassent facilement lors de restructurations
2. **Compilation Web**: Flutter Web a des problèmes avec les imports relatifs profonds
3. **Lisibilité**: Les imports package: sont plus clairs et explicites
4. **Maintenance**: Plus facile à rechercher et refactoriser

## Application

La règle de linting `always_use_package_imports` est activée dans `analysis_options.yaml` pour forcer cette convention sur TOUT le projet.

## Exemples d'Utilisation

### Dans un fichier UI distant (ex: lib/apps/superadmin/pages/tabs/modules_tab.dart)

```dart
// ✅ CORRECT
import 'package:pizza_delizza/domain/module_exposure.dart';
import 'package:pizza_delizza/domain/fulfillment_config.dart';
import 'package:flutter/material.dart';

class ModulesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Utilisation de ModuleExposure...
  }
}
```

### Dans un fichier proche (ex: lib/domain/autre_modele.dart)

```dart
// ✅ CORRECT - même pour les fichiers dans le même répertoire
import 'package:pizza_delizza/domain/module_exposure.dart';
import 'package:pizza_delizza/domain/fulfillment_config.dart';
```

## Vérification

Pour vérifier que tous les imports sont corrects:

```bash
# Analyse statique
flutter analyze

# Rechercher des imports relatifs incorrects (ne devrait rien retourner)
grep -r "import.*'\.\..*domain/" lib/
```

## Note

Le nom du package est `pizza_delizza` (défini dans `pubspec.yaml`), donc tous les imports doivent utiliser:
- `package:pizza_delizza/domain/...`
- `package:pizza_delizza/...` pour tout autre module

**NON** `package:wlhorizon/...` (ceci est incorrect pour ce projet)
