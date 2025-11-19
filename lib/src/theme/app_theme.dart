// lib/src/theme/app_theme.dart
// Pizza Deli'Zza Visual Identity - Système de design centralisé
// MIGRATION: Ce fichier redirige maintenant vers le nouveau design system
// Pour rétrocompatibilité, tous les anciens noms sont conservés

// Export du nouveau design system complet
export '../design_system/app_theme.dart';

// Rétrocompatibilité: les anciennes classes sont maintenant des aliases
import '../design_system/app_theme.dart' as ds;

// Ancienne classe AppColors (alias vers le nouveau)
typedef AppColors = ds.AppColors;

// Ancienne classe AppTextStyles (alias vers le nouveau)
typedef AppTextStyles = ds.AppTextStyles;

// Ancienne classe AppSpacing (alias vers le nouveau)
typedef AppSpacing = ds.AppSpacing;

// Ancienne classe AppRadius (alias vers le nouveau)
typedef AppRadius = ds.AppRadius;

// Ancienne classe AppShadows (alias vers le nouveau)
typedef AppShadows = ds.AppShadows;

// Ancienne classe AppTheme (alias vers le nouveau)
typedef AppTheme = ds.AppTheme;
