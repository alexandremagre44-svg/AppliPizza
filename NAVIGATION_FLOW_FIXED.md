# 🗺️ Navigation Flow - Fixed

## Overview

This document shows the corrected navigation flow between Profile, Rewards, and Roulette screens.

## 📱 Navigation Map

```
┌──────────────────────────────────────────────────────────────────────┐
│                          PROFILE SCREEN                               │
│                     (/profile - ProfileScreen)                        │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 🏆 Carte Fidélité (LoyaltySectionWidget)                     │   │
│  │                                                                │   │
│  │ • 150 points de fidélité                                      │   │
│  │ • Barre de progression vers pizza gratuite                    │   │
│  │                                                                │   │
│  │  ┌──────────────────────────────────────────────┐            │   │
│  │  │ [Voir mes récompenses fidélité] ───────────┐ │            │   │
│  │  └──────────────────────────────────────────────┘ │            │   │
│  └────────────────────────────────────────────────────┼────────┘   │
│                                                        │             │
│                                                        │             │
│  ┌─────────────────────────────────────────────────────┼────────┐  │
│  │ 🎰 Roulette de la chance (RouletteCardWidget)      │        │  │
│  │                                                        ▼        │  │
│  │ • Vérification: RouletteRulesService.checkEligibility()     │  │
│  │ • Affiche: canSpin + reason + nextEligibleAt                 │  │
│  │                                                                │  │
│  │  ┌──────────────────────────────────────┐                    │  │
│  │  │ [Tourner la roue] ──────────────────┐│                    │  │
│  │  └──────────────────────────────────────┘│                    │  │
│  └────────────────────────────────────────────┼───────────────┘  │
│                                                │                   │
└────────────────────────────────────────────────┼───────────────────┘
                                                 │
                    ┌────────────────────────────┼───────────────────┐
                    │                            │                   │
                    ▼                            ▼                   │
┌──────────────────────────────────┐  ┌──────────────────────────────┴──┐
│     REWARDS SCREEN                │  │     ROULETTE SCREEN              │
│  (/rewards - RewardsScreen)       │  │  (/roulette - RouletteScreen)   │
├──────────────────────────────────┤  ├─────────────────────────────────┤
│                                   │  │                                  │
│  🎁 Récompenses disponibles       │  │  🎰 Roue de la chance            │
│  ┌─────────────────────────────┐ │  │                                  │
│  │ Ticket 1: Pizza gratuite    │ │  │  ┌────────────────────────────┐ │
│  │ Expire: 15/01/2025          │ │  │  │ État: Chargement règles... │ │
│  │ [Utiliser maintenant]       │ │  │  └────────────────────────────┘ │
│  └─────────────────────────────┘ │  │                                  │
│                                   │  │  Si rules == null:               │
│  ┌─────────────────────────────┐ │  │  ┌────────────────────────────┐ │
│  │ Ticket 2: -20% reduction    │ │  │  │ ⚠️  La roulette n'est pas   │ │
│  │ Expire: 20/01/2025          │ │  │  │    encore disponible.       │ │
│  │ [Utiliser maintenant]       │ │  │  │                              │ │
│  └─────────────────────────────┘ │  │  │    Veuillez réessayer       │ │
│                                   │  │  │    plus tard.               │ │
│  🎲 Tentez votre chance !        │  │  └────────────────────────────┘ │
│  ┌─────────────────────────────┐ │  │                                  │
│  │                              │ │  │  Si rules != null && canSpin:    │
│  │  [Tourner la roue] ─────────┼─┼──┤  ┌────────────────────────────┐ │
│  │                              │ │  │  │ Roue avec segments         │ │
│  └─────────────────────────────┘ │  │  │                              │ │
│                                   │  │  │ [Tourner la roue]  ←───────│ │
│  📜 Historique                   │  │  └────────────────────────────┘ │
│  • Ticket utilisé le...          │  │                                  │
│  • Ticket expiré le...           │  │  Après gain:                     │
│                                   │  │  ┌────────────────────────────┐ │
│                                   │  │  │ ✨ Félicitations !          │ │
│                                   │  │  │ Vous avez gagné:            │ │
│                                   │  │  │ • Pizza gratuite            │ │
└───────────────────────────────────┘  │  │                              │ │
                    ▲                   │  │ [Voir mes récompenses] ────┼─┤
                    │                   │  └────────────────────────────┘ │
                    │                   │              │                   │
                    │                   └──────────────┼───────────────────┘
                    │                                  │
                    └──────────────────────────────────┘
```

## 🔄 Navigation Methods Used

### ✅ Client Screens (Consistent)
- **Profile → Rewards**: `context.go(AppRoutes.rewards)` (via LoyaltySectionWidget)
- **Profile → Roulette**: `context.go(AppRoutes.roulette)` (via RouletteCardWidget)
- **Rewards → Roulette**: `context.go(AppRoutes.roulette)`
- **Roulette → Rewards**: `context.go(AppRoutes.rewards)`

### ✅ Admin Screens (Consistent)
- **Admin Studio → All**: `Navigator.push(MaterialPageRoute(...))` (modal style)

## 📋 Route Definitions

### In `lib/src/core/constants.dart`
```dart
class AppRoutes {
  static const String rewards = '/rewards';    // ✅ Points to RewardsScreen
  static const String roulette = '/roulette';  // ✅ Points to RouletteScreen
  static const String profile = '/profile';    // ✅ Points to ProfileScreen
}
```

### In `lib/main.dart`
```dart
GoRoute(
  path: AppRoutes.rewards,
  builder: (context, state) => const RewardsScreen(), // ✅ Correct
),
GoRoute(
  path: AppRoutes.roulette,
  builder: (context, state) {
    final authState = ref.read(authProvider);
    final userId = authState.userEmail ?? 'guest';
    return RouletteScreen(userId: userId); // ✅ userId from auth
  },
),
```

## 🎯 Key Points

### 1. No Query Parameters
❌ **Before**: `context.push('${AppRoutes.roulette}?userId=${widget.userId}')`  
✅ **After**: `context.go(AppRoutes.roulette)` — userId obtained from auth provider

### 2. No Direct Screen Imports for Navigation
❌ **Before**: `Navigator.push(context, MaterialPageRoute(builder: (_) => RouletteScreen(...)))`  
✅ **After**: `context.go(AppRoutes.roulette)` — let router handle screen instantiation

### 3. Roulette Configuration Check
```dart
// RouletteRulesService.checkEligibility(userId)
if (rules == null) {
  return RouletteStatus.denied('La roulette n\'est pas encore configurée.');
}
// Then check: isEnabled, time slots, cooldown, daily limit...
```

### 4. No Auto-Redirects
- ✅ User must click button to navigate
- ✅ Winning creates ticket, shows dialog with button to view rewards
- ✅ No automatic screen changes

## 🧪 Test Scenarios

### Scenario 1: User Navigates from Profile to Rewards
1. User on Profile screen
2. Clicks "Voir mes récompenses fidélité" in loyalty card
3. ✅ Opens RewardsScreen at `/rewards`
4. ✅ Shows active tickets
5. ✅ Shows "Tourner la roue" button

### Scenario 2: User Navigates from Rewards to Roulette
1. User on Rewards screen
2. Clicks "Tourner la roue" button
3. ✅ Opens RouletteScreen at `/roulette`
4. ✅ Checks eligibility via RouletteRulesService
5. ✅ Shows appropriate message or wheel

### Scenario 3: Roulette Not Configured
1. User navigates to `/roulette`
2. RouletteScreen loads
3. Calls `checkEligibility(userId)`
4. `getRules()` returns `null` (document doesn't exist)
5. ✅ Shows: "La roulette n'est pas encore disponible."
6. ✅ Button disabled

### Scenario 4: User Wins on Roulette
1. User spins wheel
2. Lands on "Pizza gratuite"
3. `createTicketFromRouletteSegment()` creates ticket in Firestore
4. ✅ Dialog shows: "Félicitations ! Vous avez gagné: Pizza gratuite"
5. User clicks "Voir mes récompenses"
6. ✅ Navigates to RewardsScreen via `context.go(AppRoutes.rewards)`
7. ✅ Ticket appears in active tickets list

### Scenario 5: User on Cooldown
1. User navigates to `/roulette`
2. RouletteScreen checks eligibility
3. Last spin was 5 hours ago, minDelayHours = 24
4. ✅ Shows: "Prochain tirage disponible dans 19 heures"
5. ✅ Button disabled
6. ✅ Status banner at top shows reason + next eligible time

## 🛡️ Edge Cases Handled

1. **Missing Config** → Show "not configured" message
2. **Disabled Roulette** → Show "currently disabled" message
3. **Outside Time Slot** → Show "available from X to Y" message
4. **Cooldown Active** → Show "available in X hours" message
5. **Daily Limit Reached** → Show "already played today" message
6. **No Segments** → Show "wheel not available" message
7. **User Banned** → Show "account suspended" message

## ✅ Validation Checklist

- [x] Profile loyalty card button opens RewardsScreen
- [x] Profile roulette card button opens RouletteScreen
- [x] Rewards "Tourner la roue" button opens RouletteScreen
- [x] Roulette win dialog button opens RewardsScreen
- [x] No query parameters in routes
- [x] No Navigator.push in client screens
- [x] All use context.go() from go_router
- [x] RouletteScreen handles null rules gracefully
- [x] Admin screen can create rules from scratch
- [x] No auto-redirects anywhere
- [x] Back button works correctly (go_router handles it)
- [x] Deep links work (go_router handles it)
