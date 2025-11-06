# 🗺️ Pizza Deli'Zza - Carte Visuelle de Navigation

## 📱 Flow de Navigation Principal

```
┌─────────────────┐
│  SplashScreen   │
│      (/)        │
└────────┬────────┘
         │
         ├─── Non connecté ───┐
         │                    ▼
         │            ┌──────────────┐
         │            │ LoginScreen  │
         │            │   (/login)   │
         │            └──────┬───────┘
         │                   │
         └─── Connecté ──────┤
                             ▼
                    ┌─────────────────────────────┐
                    │   Navigation Principale     │
                    │   (avec Bottom Bar)         │
                    └─────────────────────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
    ┌─────────┐        ┌──────────┐       ┌──────────┐
    │  Home   │        │   Menu   │       │   Cart   │
    │ (/home) │        │ (/menu)  │       │ (/cart)  │
    └────┬────┘        └─────┬────┘       └─────┬────┘
         │                   │                   │
         └───────────────────┼───────────────────┘
                             │
         ┌───────────────────┼───────────────────┬──────────────────┐
         │                   │                   │                  │
         ▼                   ▼                   ▼                  ▼
    ┌─────────┐      ┌──────────────┐     ┌──────────┐     ┌────────────┐
    │ Profile │      │ProductDetail │     │Checkout  │     │   Admin    │
    │(/profile)      │  (/details)  │     │(/checkout)     │  (/admin)  │
    └─────────┘      └──────────────┘     └──────────┘     └─────┬──────┘
         │                                                         │
         │                                      Admin seulement ──┤
         │                                                         │
         │                                      ┌──────────────────┼──────────────┐
         │                                      ▼                  ▼              ▼
         │                               ┌─────────────┐  ┌─────────────┐  ┌──────────┐
         │                               │AdminPizza   │  │ AdminMenu   │  │  Plus... │
         │                               │(/admin/pizza)  │(/admin/menu)│  │          │
         │                               └─────────────┘  └─────────────┘  └──────────┘
         │
         └─── Historique commandes
```

---

## 🎭 Rôles et Accès

### 👤 Client (client@delizza.com)
```
✅ Home Screen       - Voir pizzas populaires et menus
✅ Menu Screen       - Parcourir tout le catalogue
✅ Cart Screen       - Gérer le panier
✅ Checkout Screen   - Passer commande avec créneaux
✅ Profile Screen    - Voir profil et historique
✅ Product Detail    - Voir détails d'un produit
❌ Admin Screens     - Accès refusé
```

### 👨‍💼 Admin (admin@delizza.com)
```
✅ Toutes les fonctionnalités Client
✅ Admin Dashboard   - Tableau de bord
✅ Admin Pizza       - CRUD Pizzas
✅ Admin Menu        - CRUD Menus
⏳ Horaires          - À venir
⏳ Paramètres        - À venir
```

---

## 🔄 Flow Utilisateur Typique

### Scénario 1: Commande Simple
```
1. Login (LoginScreen)
   ↓
2. Parcourir home (HomeScreen)
   ↓
3. Voir menu complet (MenuScreen)
   ↓
4. Cliquer sur pizza → Voir détails (ProductDetailScreen)
   ↓
5. Ajouter au panier
   ↓
6. Aller au panier (CartScreen)
   ↓
7. Valider → Checkout (CheckoutScreen)
   ↓
8. Choisir date + créneau
   ↓
9. Confirmer
   ↓
10. Voir historique (ProfileScreen)
```

### Scénario 2: Menu Customisé
```
1. MenuScreen
   ↓
2. Sélectionner un menu (ex: Menu Duo)
   ↓
3. Modal de customisation s'ouvre
   ↓
4. Choisir 1 pizza parmi la liste
   ↓
5. Choisir 1 boisson parmi la liste
   ↓
6. Valider → Ajout au panier
   ↓
7. Continuer vers checkout
```

### Scénario 3: Admin - Ajouter Pizza
```
1. Login en tant qu'admin
   ↓
2. Onglet Admin (Bottom Bar)
   ↓
3. AdminDashboardScreen
   ↓
4. Cliquer sur "Pizzas"
   ↓
5. AdminPizzaScreen
   ↓
6. Bouton "Ajouter une pizza"
   ↓
7. Remplir formulaire (nom, prix, description, catégorie, ingrédients)
   ↓
8. Sauvegarder → SharedPreferences
   ↓
9. Liste mise à jour
```

---

## 📊 Architecture des Données

### Flow des Données (Riverpod)

```
┌──────────────────┐
│   UI (Screens)   │
└────────┬─────────┘
         │ watch / read
         ▼
┌──────────────────┐
│    Providers     │
│  (State Mgmt)    │
└────────┬─────────┘
         │
         ├──────────────────┬──────────────────┐
         ▼                  ▼                  ▼
┌────────────────┐  ┌────────────────┐  ┌────────────────┐
│   Services     │  │  Repositories  │  │  Local State   │
└────────┬───────┘  └────────┬───────┘  └────────────────┘
         │                   │
         ▼                   ▼
┌────────────────┐  ┌────────────────┐
│SharedPreferences  │  Mock Data     │
└────────────────┘  └────────────────┘
```

### Exemple: Ajout au Panier

```
1. User clique "Ajouter au panier"
   │
2. HomeScreen.handleAddToCart()
   │
3. ref.read(cartProvider.notifier).addItem(product)
   │
4. CartNotifier.addItem() vérifie si produit existe
   │
5. Si nouveau: Crée CartItem avec UUID
   │
6. state = CartState([...items, newItem])
   │
7. Riverpod notifie tous les listeners
   │
8. UI se met à jour automatiquement:
   - Badge panier (nombre d'articles)
   - CartScreen (liste mise à jour)
   - Total recalculé
```

---

## 🏗️ Architecture Technique

### Layers (Couches)

```
┌──────────────────────────────────────────┐
│           Presentation Layer             │
│  (Screens, Widgets, Theme)               │
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│          State Management Layer          │
│  (Providers - Riverpod)                  │
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│           Business Logic Layer           │
│  (Services, Repositories)                │
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│             Data Layer                   │
│  (Models, Mock Data, SharedPreferences)  │
└──────────────────────────────────────────┘
```

---

## 🎨 Structure des Widgets

### Hiérarchie Visuelle

```
MaterialApp.router
└── GoRouter
    └── ScaffoldWithNavBar (ShellRoute)
        ├── BottomNavigationBar
        │   ├── Home
        │   ├── Menu
        │   ├── Cart (avec Badge)
        │   ├── Profile
        │   └── Admin (si isAdmin)
        │
        └── child (écran actuel)
            ├── HomeScreen
            │   └── CustomScrollView
            │       ├── SliverAppBar
            │       ├── Section Pizzas (horizontal scroll)
            │       └── Section Menus (grid 2 col)
            │
            ├── MenuScreen
            │   ├── Tabs par catégorie
            │   └── GridView de ProductCard
            │
            ├── CartScreen
            │   ├── ListView de CartItem
            │   └── Total + Bouton Commander
            │
            └── ProfileScreen
                ├── Infos utilisateur
                ├── Historique commandes
                └── Bouton Déconnexion
```

---

## 🔐 Sécurité et Auth

### Flow d'Authentification

```
┌──────────────┐
│ App démarre  │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ AuthNotifier init    │
│ Lit SharedPrefs      │
└──────┬───────────────┘
       │
       ├─── isLoggedIn = true ───┐
       │                         ▼
       │                  ┌─────────────┐
       │                  │  /home      │
       │                  └─────────────┘
       │
       └─── isLoggedIn = false ──┐
                                 ▼
                          ┌─────────────┐
                          │  /login     │
                          └──────┬──────┘
                                 │
                          User entre credentials
                                 │
                                 ▼
                          ┌─────────────────────┐
                          │ AuthService.login() │
                          │ Valide credentials  │
                          └──────┬──────────────┘
                                 │
                ┌────────────────┼───────────────┐
                │                                │
         ✅ Valid                         ❌ Invalid
                │                                │
                ▼                                ▼
    ┌──────────────────────┐          ┌──────────────┐
    │ Sauve dans SharedPrefs│          │ Erreur       │
    │ role = admin/client   │          │ Message      │
    └──────┬────────────────┘          └──────────────┘
           │
           ▼
    ┌──────────────┐
    │ Redirect /home│
    └───────────────┘
```

---

## 📦 État du Stockage

### SharedPreferences Keys

```
StorageKeys {
  isLoggedIn      → bool      (true/false)
  userEmail       → String    (email de l'utilisateur)
  userRole        → String    ('admin' ou 'client')
  pizzas_list     → JSON      (liste des pizzas admin)
  menus_list      → JSON      (liste des menus admin)
}
```

### Données en Mémoire

```
Providers:
├── authProvider
│   └── AuthState {isLoggedIn, userEmail, userRole, isLoading, error}
│
├── cartProvider
│   └── CartState {items: List<CartItem>}
│
├── productListProvider
│   └── List<Product> (depuis mock_data)
│
├── userProvider
│   └── UserProfile {name, email, orders, favorites}
│
└── favoritesProvider
    └── List<String> (productIds)
```

---

## 🚦 États de l'Application

### Cycle de Vie d'une Commande

```
┌──────────────────┐
│  Panier Vide     │
└────────┬─────────┘
         │ Ajout produit
         ▼
┌──────────────────┐
│  Panier Actif    │ ← Modification quantités
└────────┬─────────┘
         │ Clic "Commander"
         ▼
┌──────────────────┐
│  Checkout        │
│  Sélection date  │
│  Sélection slot  │
└────────┬─────────┘
         │ Confirmation
         ▼
┌──────────────────┐
│  Commande Créée  │
│  Status: "En     │
│  préparation"    │
└────────┬─────────┘
         │ Ajout à l'historique
         ▼
┌──────────────────┐
│  Panier Vidé     │
│  Order dans      │
│  Profile         │
└──────────────────┘
```

---

## 🎯 Points d'Entrée Importants

### Pour le Développement

```
Démarrer l'app:
main.dart → MyApp → GoRouter → SplashScreen

Ajouter une fonctionnalité:
1. Créer modèle (models/)
2. Créer provider si état global (providers/)
3. Créer service si logique métier (services/)
4. Créer écran (screens/)
5. Ajouter route (main.dart)
6. Ajouter navigation (bottom bar ou bouton)

Modifier le thème:
theme/app_theme.dart

Ajouter une constante:
core/constants.dart

Ajouter un produit mocké:
data/mock_data.dart
```

---

## 🔍 Debugging Tips

### Où chercher selon le problème

```
Auth ne fonctionne pas:
→ providers/auth_provider.dart
→ services/auth_service.dart
→ main.dart (redirect logic)

Panier bugué:
→ providers/cart_provider.dart
→ screens/cart/cart_screen.dart

Navigation cassée:
→ main.dart (GoRouter config)
→ widgets/scaffold_with_nav_bar.dart

Produits ne s'affichent pas:
→ providers/product_provider.dart
→ repositories/product_repository.dart
→ data/mock_data.dart

Admin CRUD ne sauvegarde pas:
→ services/product_crud_service.dart
→ screens/admin/*_screen.dart
```

---

## 📈 Métriques du Projet

### Statistique du Code

```
Screens:        13 fichiers
Widgets:         4 fichiers
Providers:       5 fichiers
Services:        3 fichiers
Models:          4 fichiers
Total Dart:     ~30 fichiers

Produits mockés: 14 (6 pizzas + 3 boissons + 2 desserts + 3 menus)
Ingrédients:      8
Routes:          12
Bottom Bar:       5 items (4 client + 1 admin)
```

---

*Carte visuelle générée le 6 novembre 2025*
*Pour l'application Pizza Deli'Zza v1.0.0*
