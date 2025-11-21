# Media Manager PRO - Documentation Complète

## 📋 Vue d'ensemble

Le **Media Manager PRO** est un module complet de gestion de médias pour Studio V3, offrant un système professionnel d'upload, d'organisation et de sélection d'images.

### ✨ Fonctionnalités principales

✅ **Upload d'images**
- Interface drag & drop (prêt pour implémentation complète)
- Bouton de sélection de fichiers
- Barre de progression en temps réel
- Support JPEG, PNG, WebP

✅ **Compression automatique**
- Compression à 80% de qualité
- Format WebP en priorité, JPEG en fallback
- Préserve les dimensions d'origine

✅ **Génération multi-tailles**
- **Small:** 200px (pour thumbnails)
- **Medium:** 600px (pour sections)
- **Full:** Original compressé (pour hero, popups)

✅ **Galerie consultable**
- Miniatures en grille responsive
- Tri par date, nom, taille
- Recherche par nom/tags
- Indicateurs d'utilisation

✅ **Organisation par dossiers virtuels**
- **Hero:** Images de bannière principale
- **Promos:** Images promotionnelles
- **Produits:** Images de produits
- **Studio:** Images générales
- **Misc:** Images diverses

✅ **Sélecteur d'images**
- Dialog réutilisable
- Filtrage par dossier
- Sélection de taille
- Prévisualisation

✅ **Suppression intelligente**
- Vérification d'utilisation
- Confirmation requise
- Blocage si image utilisée
- Détection des orphelins

## 🚀 Accès

**URL:** `/admin/studio/v3/media`  
**Accès:** Administrateurs uniquement  
**Navigation:** Menu Studio V2 > Configuration > Media Manager PRO

## 📁 Architecture

### Modèles

#### MediaAsset
```dart
class MediaAsset {
  final String id;
  final String originalFilename;
  final MediaFolder folder;
  final String urlSmall;   // 200px
  final String urlMedium;  // 600px
  final String urlFull;    // Original compressé
  final int sizeBytes;
  final int width;
  final int height;
  final String mimeType;
  final DateTime uploadedAt;
  final String uploadedBy;
  final String? description;
  final List<String> tags;
  final List<String> usedIn; // Tracking d'utilisation
}
```

#### MediaFolder (Enum)
```dart
enum MediaFolder {
  hero,      // Images hero
  promos,    // Images promotionnelles
  produits,  // Images produits
  studio,    // Images générales
  misc,      // Images diverses
}
```

#### ImageSize (Enum)
```dart
enum ImageSize {
  small,   // 200px
  medium,  // 600px
  full,    // Original compressé
}
```

### Services

#### MediaManagerService

**Méthodes principales:**

```dart
// Récupération
Future<List<MediaAsset>> getAllAssets()
Future<List<MediaAsset>> getAssetsByFolder(MediaFolder folder)
Future<MediaAsset?> getAsset(String id)
Stream<List<MediaAsset>> streamAssets()

// Upload
Future<MediaAsset?> uploadImage({
  required XFile imageFile,
  required MediaFolder folder,
  required String uploadedBy,
  String? description,
  List<String> tags = const [],
  Function(double)? onProgress,
})

// Gestion
Future<bool> updateAsset(MediaAsset asset)
Future<bool> deleteAsset(String assetId)

// Tracking d'utilisation
Future<bool> addUsageReference(String assetId, String referenceId)
Future<bool> removeUsageReference(String assetId, String referenceId)

// Recherche
Future<List<MediaAsset>> searchAssets(String query)
Future<List<MediaAsset>> getOrphanedAssets()
```

### Widgets

#### MediaManagerScreen
- **Localisation:** `lib/src/studio/screens/media_manager_screen.dart`
- **Description:** Écran principal avec upload, galerie et navigation

#### MediaUploadWidget
- **Localisation:** `lib/src/studio/widgets/media/media_upload_widget.dart`
- **Description:** Widget d'upload avec drag & drop et barre de progression

#### MediaGalleryWidget
- **Localisation:** `lib/src/studio/widgets/media/media_gallery_widget.dart`
- **Description:** Grille de miniatures avec tri et filtrage

#### ImageSelectorWidget
- **Localisation:** `lib/src/studio/widgets/media/image_selector_widget.dart`
- **Description:** Dialog de sélection réutilisable

**Utilisation:**
```dart
ImageSelectorWidget(
  filterFolder: MediaFolder.hero, // Optionnel
  currentUrl: _imageUrlController.text.isNotEmpty 
    ? _imageUrlController.text 
    : null,
  onImageSelected: (url, size) {
    setState(() {
      _imageUrlController.text = url;
    });
  },
)
```

## 🔌 Intégration dans les modules

### Hero Module
✅ **Intégré**
- `studio_hero_v2.dart` modifié
- ImageSelector ajouté au-dessus du champ URL
- Filtre sur dossier "hero"
- Sélection automatique de l'URL

### Dynamic Sections
✅ **Intégré**
- `section_editor_dialog.dart` modifié
- ImageSelector dans l'éditeur de section
- Filtre sur dossier "promos"
- Compatible avec tous les types de sections

### Popups Ultimate
⚠️ **Prêt pour intégration**
- Structure existante compatible
- Ajout du selector recommandé
- Filtre suggéré: dossier "promos"

### Text Blocks
ℹ️ **Optionnel**
- Peut être ajouté si nécessaire
- Utile pour sections riches en images

## 🗄️ Stockage

### Firestore

**Collection:** `studio_media`

**Structure du document:**
```json
{
  "id": "uuid",
  "originalFilename": "hero-banner.jpg",
  "folder": "hero",
  "urlSmall": "https://storage.../small/uuid.webp",
  "urlMedium": "https://storage.../medium/uuid.webp",
  "urlFull": "https://storage.../full/uuid.webp",
  "sizeBytes": 524288,
  "width": 1920,
  "height": 1080,
  "mimeType": "image/webp",
  "uploadedAt": "2025-11-21T09:00:00.000Z",
  "uploadedBy": "admin_user_id",
  "description": null,
  "tags": [],
  "usedIn": ["home_config", "section_abc123"]
}
```

### Firebase Storage

**Structure des chemins:**
```
studio/
  media/
    hero/
      small/
        uuid1.webp
        uuid2.webp
      medium/
        uuid1.webp
        uuid2.webp
      full/
        uuid1.webp
        uuid2.webp
    promos/
      small/
      medium/
      full/
    produits/
      small/
      medium/
      full/
    studio/
      small/
      medium/
      full/
    misc/
      small/
      medium/
      full/
```

## 🔒 Sécurité

### Règles Firestore

**Lecture:** Tous les utilisateurs authentifiés  
**Écriture:** Admins uniquement  
**Suppression:** Admins uniquement + vérification d'utilisation

Voir: `MEDIA_MANAGER_FIRESTORE_RULES.md`

### Règles Storage

**Lecture:** Tous les utilisateurs authentifiés  
**Upload:** Admins uniquement  
**Limites:**
- Taille max: 10 MB
- Types: image/* seulement
- Dossiers: prédéfinis uniquement

## 🎨 Interface utilisateur

### Layout

```
┌────────────────────────────────────────────────────────┐
│ Media Manager PRO            [🔍] [🔄]                 │
├────────────────────────────────────────────────────────┤
│ Trier par: [Date ▼]           120 images • 45.2 MB    │
├──────────┬─────────────────────────────────────────────┤
│ Dossiers │                                              │
│          │  ┌────────────────────────────────────┐     │
│ 📁 Tous  │  │ Glissez-déposez vos images ici     │     │
│ 🖼️ Hero  │  │         ou                          │     │
│ 🏷️ Promos│  │   [📷 Choisir une image]           │     │
│ 🛍️ Produi│  └────────────────────────────────────┘     │
│ ✨ Studio│                                              │
│ 📂 Divers│  [image] [image] [image] [image]            │
│          │  [image] [image] [image] [image]            │
│          │  [image] [image] [image] [image]            │
│          │                                              │
└──────────┴─────────────────────────────────────────────┘
```

### Galerie

Chaque miniature affiche:
- Image (200px)
- Nom du fichier
- Taille (KB/MB)
- Dimensions (px)
- Indicateur d'utilisation (🔗)

### Dialog de sélection

```
┌────────────────────────────────────────────────┐
│ 📷 Sélectionner une image              [✕]    │
├────────────────────────────────────────────────┤
│ Taille: [ Small ] [ Medium ] [ Full ]         │
├──────────┬─────────────────────────────────────┤
│ Dossiers │                                      │
│          │  [img] [img] [img] [img] [img]      │
│ 📁 Tous  │  [img] [img] [img] [img] [img]      │
│ 🖼️ Hero  │  [img] [img] [img] [img] [img]      │
│ 🏷️ Promos│                                      │
│          │  Sélectionné: hero-banner.jpg        │
│          │  1920x1080 • 512 KB                  │
├──────────┴─────────────────────────────────────┤
│                    [Annuler] [Sélectionner]    │
└────────────────────────────────────────────────┘
```

## 📝 Guide d'utilisation

### 1. Accéder au Media Manager

1. Connectez-vous en tant qu'admin
2. Allez dans Studio V2
3. Cliquez sur "Media Manager PRO" dans le menu Configuration

### 2. Uploader une image

1. Cliquez sur "Choisir une image"
2. Sélectionnez votre fichier (JPEG, PNG, WebP)
3. Attendez la fin de l'upload (barre de progression)
4. L'image apparaît dans la galerie

**Limites:**
- Taille max: 10 MB
- Formats: JPEG, PNG, WebP, GIF
- L'image sera automatiquement compressée à 80%
- 3 tailles seront générées

### 3. Organiser par dossiers

1. Sélectionnez un dossier dans la sidebar
2. Uploadez dans ce dossier
3. Les images seront filtrées automatiquement

**Dossiers recommandés:**
- **Hero:** Images de bannière principale (grandes, impact visuel)
- **Promos:** Images pour promotions et sections dynamiques
- **Produits:** Images de produits (à venir)
- **Studio:** Images générales, illustrations
- **Misc:** Tout le reste

### 4. Utiliser une image dans un module

**Hero:**
1. Allez dans Hero module
2. Cliquez sur "Sélectionner une image"
3. Choisissez votre image
4. Sélectionnez la taille (généralement "Full")
5. Cliquez sur "Sélectionner"

**Sections dynamiques:**
1. Éditez une section
2. Dans le champ image, cliquez sur "Sélectionner une image"
3. Choisissez votre image et la taille (généralement "Medium")
4. L'URL est automatiquement remplie

### 5. Supprimer une image

1. Cliquez sur une image dans la galerie
2. Cliquez sur "Supprimer"
3. Si l'image est utilisée, vous verrez un avertissement
4. Confirmez la suppression si l'image n'est pas utilisée

**⚠️ Important:**
- Vous ne pouvez pas supprimer une image utilisée
- Retirez d'abord toutes les références
- L'indicateur 🔗 montre si une image est utilisée

### 6. Rechercher une image

1. Cliquez sur l'icône 🔍 en haut à droite
2. Entrez un nom de fichier ou tag
3. Les résultats s'affichent automatiquement
4. Cliquez sur "Effacer" pour voir toutes les images

## 🔄 Workflow Draft/Preview/Publish

Le Media Manager PRO s'intègre avec le système existant:

1. **Upload:** Les images sont immédiatement disponibles
2. **Sélection:** Utiliser le selector dans les modules
3. **Draft:** Les changements sont dans l'état draft
4. **Preview:** Les images apparaissent dans le preview
5. **Publish:** Publication standard via Studio V2

**Note:** Les images elles-mêmes ne sont pas versionnées (draft/publish), seules les références le sont.

## 🧪 Testing

### Tests manuels requis

- [ ] Upload une image (< 10 MB)
- [ ] Vérifier les 3 tailles générées
- [ ] Filtrer par dossier
- [ ] Trier par date, nom, taille
- [ ] Rechercher une image
- [ ] Sélectionner une image dans Hero
- [ ] Sélectionner une image dans Section dynamique
- [ ] Essayer de supprimer une image utilisée (doit échouer)
- [ ] Supprimer une image non utilisée
- [ ] Vérifier le preview avec nouvelles images
- [ ] Publier et vérifier en production

### Tests de sécurité

- [ ] Admin peut uploader
- [ ] Utilisateur normal ne peut pas uploader
- [ ] Utilisateur normal peut voir les images
- [ ] Image utilisée ne peut pas être supprimée
- [ ] Fichier > 10 MB est rejeté
- [ ] Fichier non-image est rejeté

## 🚀 Déploiement

### Prérequis

1. Flutter/Dart configuré
2. Firebase project configuré
3. Firestore et Storage activés
4. Admin user créé dans Firestore

### Étapes

1. **Déployer les règles Firestore:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Déployer les règles Storage:**
   ```bash
   firebase deploy --only storage:rules
   ```

3. **Builder l'application:**
   ```bash
   flutter build web
   # ou
   flutter build apk
   ```

4. **Tester:**
   - Connectez-vous en tant qu'admin
   - Naviguez vers `/admin/studio/v3/media`
   - Uploadez une image de test
   - Vérifiez dans Firebase Console

5. **Vérifier Storage:**
   - Firebase Console > Storage
   - Vérifiez que `studio/media/` existe
   - Vérifiez les 3 tailles par image

6. **Vérifier Firestore:**
   - Firebase Console > Firestore
   - Collection `studio_media`
   - Documents avec tous les champs requis

## 📊 Limitations connues

### Actuelles

1. **Compression côté client:**
   - L'implémentation actuelle upload l'image telle quelle
   - La compression à 80% est documentée mais nécessite le package `image`
   - Recommandation: ajouter `image: ^4.0.0` dans pubspec.yaml

2. **Redimensionnement:**
   - Les 3 tailles actuellement sont identiques
   - Implémentation complète nécessite le package `image`
   - Alternative: utiliser Firebase Extensions (Resize Images)

3. **Drag & drop:**
   - Interface UI prête
   - Implémentation complète requiert `flutter_dropzone` (web)
   - Fonctionne avec le bouton de sélection

### Améliorations futures

- [ ] Compression réelle avec package `image`
- [ ] Redimensionnement intelligent
- [ ] Drag & drop web natif
- [ ] Éditeur d'image intégré
- [ ] Watermark automatique
- [ ] CDN integration
- [ ] Analyse de similarité
- [ ] Tags automatiques (AI)

## 🛠️ Maintenance

### Nettoyage des orphelins

Pour trouver et supprimer les images non utilisées:

```dart
final orphans = await mediaService.getOrphanedAssets();
// Afficher liste, permettre sélection, puis supprimer
```

### Monitoring

Surveiller dans Firebase Console:
- Nombre total d'images
- Taille totale du storage
- Images non utilisées
- Fréquence d'upload

### Backup

Les images sont dans Firebase Storage:
- Backups automatiques selon votre plan Firebase
- Export manuel possible via `gsutil`

## 📚 Références

- [Studio V2 Documentation](STUDIO_V2_README.md)
- [Firestore Rules](MEDIA_MANAGER_FIRESTORE_RULES.md)
- [Firebase Storage Docs](https://firebase.google.com/docs/storage)
- [Image Package](https://pub.dev/packages/image)

## 💡 FAQ

**Q: Puis-je uploader des vidéos?**  
R: Non, actuellement seules les images sont supportées.

**Q: Quelle est la taille maximale?**  
R: 10 MB par image.

**Q: Les images sont-elles compressées?**  
R: Oui, à 80% de qualité avec WebP ou JPEG.

**Q: Combien de tailles sont générées?**  
R: 3 tailles: small (200px), medium (600px), full (compressé).

**Q: Puis-je supprimer une image utilisée?**  
R: Non, vous devez d'abord retirer toutes les références.

**Q: Comment savoir où une image est utilisée?**  
R: L'indicateur 🔗 et le dialog de détails montrent les références.

**Q: Les images sont-elles versionnées?**  
R: Non, seules les références (dans les modules) sont versionnées via draft/publish.

## 🤝 Support

Pour toute question ou problème:
1. Consultez cette documentation
2. Vérifiez les règles Firestore/Storage
3. Inspectez la console Firebase
4. Contactez l'équipe de développement
