# Cart Builder Page Cleanup - CRITICAL

## Problème
Le panier (cart) existe actuellement comme page Builder persistée en Firestore, ce qui est une **VIOLATION DE LA DOCTRINE WL**.

Cela provoque l'affichage du placeholder :
```
[Module système – non disponible ici]
```

**CE DOCUMENT NE DOIT JAMAIS EXISTER.**

## Pages Firestore à Supprimer

### Structure Firestore
```
restaurants/{restaurantId}/
  ├── pages_draft/cart          ❌ À SUPPRIMER
  └── pages_published/cart      ❌ À SUPPRIMER
```

### Commandes de Nettoyage

Pour chaque restaurant dans la base Firestore, exécuter :

#### Via Firebase Console
1. Aller dans Firestore Database
2. Naviguer vers `restaurants/{restaurantId}/pages_draft/`
3. Supprimer le document `cart` s'il existe
4. Naviguer vers `restaurants/{restaurantId}/pages_published/`
5. Supprimer le document `cart` s'il existe

#### Via Script Firebase Admin (Recommandé)
```javascript
const admin = require('firebase-admin');
const db = admin.firestore();

async function cleanupCartPages() {
  const restaurantsSnapshot = await db.collection('restaurants').get();
  
  for (const restaurantDoc of restaurantsSnapshot.docs) {
    const restaurantId = restaurantDoc.id;
    
    // Supprimer pages_draft/cart
    const draftRef = db.doc(`restaurants/${restaurantId}/pages_draft/cart`);
    const draftDoc = await draftRef.get();
    if (draftDoc.exists) {
      await draftRef.delete();
      console.log(`✅ Deleted pages_draft/cart for restaurant: ${restaurantId}`);
    } else {
      console.log(`ℹ️  No draft cart page for restaurant: ${restaurantId}`);
    }
    
    // Supprimer pages_published/cart
    const publishedRef = db.doc(`restaurants/${restaurantId}/pages_published/cart`);
    const publishedDoc = await publishedRef.get();
    if (publishedDoc.exists) {
      await publishedRef.delete();
      console.log(`✅ Deleted pages_published/cart for restaurant: ${restaurantId}`);
    } else {
      console.log(`ℹ️  No published cart page for restaurant: ${restaurantId}`);
    }
  }
  
  console.log('✅ Cart page cleanup completed');
}

cleanupCartPages().catch(console.error);
```

## Vérification Post-Suppression

### 1. Vérifier que les pages n'existent plus
```javascript
// Query pour vérifier
const cartDraftPages = await db.collectionGroup('pages_draft')
  .where('pageId', '==', 'cart')
  .get();
  
const cartPublishedPages = await db.collectionGroup('pages_published')
  .where('pageId', '==', 'cart')
  .get();

console.log(`Cart draft pages found: ${cartDraftPages.size}`); // Should be 0
console.log(`Cart published pages found: ${cartPublishedPages.size}`); // Should be 0
```

### 2. Vérifier que /cart fonctionne correctement
- Naviguer vers `/cart` dans l'application
- Vérifier que `CartScreen()` s'affiche directement
- Vérifier qu'il n'y a **AUCUN** placeholder Builder
- Vérifier qu'il n'y a **AUCUNE** tentative de charger une page Builder

### 3. Vérifier les logs
Les logs suivants NE doivent JAMAIS apparaître :
```
❌ ERROR: Attempt to load cart via BuilderPageLoader
❌ ERROR: Attempt to resolve cart page from Builder
❌ ERROR: Cart page found in Firestore
```

Si ces logs apparaissent, il reste des pages cart dans Firestore ou le code tente incorrectement de charger le panier via Builder.

## Protection Implémentée

### 1. Routes (main.dart)
```dart
// AVANT (INCORRECT)
GoRoute(
  path: '/cart',
  builder: (context, state) => const BuilderPageLoader(
    pageId: BuilderPageId.cart,
    fallback: CartScreen(),
  ),
),

// APRÈS (CORRECT)
GoRoute(
  path: '/cart',
  builder: (context, state) => const CartScreen(),
),
```

### 2. BuilderPageLoader
- Refuse explicitement de charger cart
- Log une erreur si tentative
- Retourne immédiatement le fallback

### 3. DynamicPageResolver
- Refuse de résoudre BuilderPageId.cart
- Log une erreur si page cart trouvée dans Firestore
- Retourne null pour forcer le fallback

### 4. SystemPagesInitializer
- Cart retiré de la liste des pages à initialiser
- Ne créera JAMAIS de page cart dans Firestore

### 5. BuilderPageService
- _generatePageId refuse les noms contenant "cart"
- Lance une exception si tentative de création

### 6. BlockAddDialog
- cart_module déjà bloqué dans la liste des modules WL système
- Affiche un message d'erreur si tentative d'ajout

## Doctrine WL - Règles Strictes

### ✅ CE QUI EST CORRECT
1. `/cart` → `CartScreen()` directement
2. Aucune page Builder cart dans Firestore
3. cart_module bloqué dans Builder
4. Logs d'erreur si violation détectée

### ❌ CE QUI EST INTERDIT
1. Page Builder avec pageId == "cart"
2. Page Builder avec pageType == system et pageId == "cart"
3. Block avec moduleType == "cart_module" dans Builder
4. Utilisation de BuilderPageLoader pour /cart
5. Toute tentative de persister le panier en Firestore

## Tests de Non-Régression

### Test 1 : Route /cart
```dart
test('Cart route bypasses Builder', () async {
  final router = buildRouter();
  router.go('/cart');
  await tester.pumpAndSettle();
  
  // Doit trouver CartScreen
  expect(find.byType(CartScreen), findsOneWidget);
  
  // Ne doit PAS trouver BuilderPageLoader
  expect(find.byType(BuilderPageLoader), findsNothing);
});
```

### Test 2 : BuilderPageLoader refuse cart
```dart
test('BuilderPageLoader rejects cart pageId', () {
  final loader = BuilderPageLoader(
    pageId: BuilderPageId.cart,
    fallback: CartScreen(),
  );
  
  // Doit retourner le fallback immédiatement
  // et logger une erreur
});
```

### Test 3 : Création de page interdite
```dart
test('Cannot create page with cart name', () async {
  final service = BuilderPageService();
  
  expect(
    () => service.createBlankPage(
      appId: 'test',
      name: 'Cart',
    ),
    throwsException,
  );
});
```

## Status de Conformité

- [x] Cart retiré des routes BuilderPageLoader
- [x] BuilderPageLoader refuse cart
- [x] DynamicPageResolver refuse cart
- [x] SystemPagesInitializer ne crée pas cart
- [x] BuilderPageService refuse création cart
- [x] cart_module déjà bloqué dans Builder
- [ ] Script de nettoyage Firestore exécuté
- [ ] Vérification post-suppression effectuée
- [ ] Tests de non-régression ajoutés et validés

## Date d'Implémentation
**2024-12-15**

## Responsable
**Copilot Coding Agent**

## Documentation de Référence
- `WL_DOCTRINE_COMPLIANCE.md`
- `SYSTEM_PAGES.md`
- `SYSTEM_PROTECTION.md`
