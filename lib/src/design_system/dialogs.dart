// lib/src/design_system/dialogs.dart
// Composants dialogs et modales - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'radius.dart';
import 'shadows.dart';
import 'buttons.dart';

// ═══════════════════════════════════════════════════════════════
// DIALOG STANDARD - AppDialog
// ═══════════════════════════════════════════════════════════════

/// Dialog standard avec header, contenu et actions
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;
  final double? maxWidth;
  final bool showCloseButton;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.icon,
    this.iconColor,
    this.maxWidth = 500,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.dialog,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 500),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.dialog,
          boxShadow: AppShadows.dialog,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: AppSpacing.dialogPadding,
                child: content,
              ),
            ),
            // Actions
            if (actions != null && actions!.isNotEmpty) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.dialogHeaderPadding,
      decoration: BoxDecoration(
        color: iconColor ?? AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: AppRadius.radiusSmall,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Fermer',
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: AppSpacing.dialogFooterPadding,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _intersperse(
          actions!,
          const SizedBox(width: AppSpacing.sm),
        ),
      ),
    );
  }

  List<Widget> _intersperse(List<Widget> list, Widget separator) {
    if (list.isEmpty) return [];
    return list
        .expand((item) => [item, separator])
        .toList()
        ..removeLast();
  }
}

// ═══════════════════════════════════════════════════════════════
// DIALOG INFO - Dialog d'information
// ═══════════════════════════════════════════════════════════════

/// Dialog pour afficher une information
class AppInfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String? confirmText;

  const AppInfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info,
    this.iconColor = AppColors.info,
    this.confirmText,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.info,
    Color iconColor = AppColors.info,
    String? confirmText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppInfoDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        confirmText: confirmText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      icon: icon,
      iconColor: iconColor,
      content: Text(
        message,
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        AppButton.primary(
          text: confirmText ?? 'OK',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIALOG CONFIRMATION - Dialog de confirmation
// ═══════════════════════════════════════════════════════════════

/// Dialog de confirmation avec annuler/confirmer
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final IconData icon;
  final Color iconColor;
  final bool isDangerous;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.icon = Icons.help,
    this.iconColor = AppColors.warning,
    this.isDangerous = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData icon = Icons.help,
    Color iconColor = AppColors.warning,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        isDangerous: isDangerous,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      icon: icon,
      iconColor: iconColor,
      content: Text(
        message,
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        AppButton.ghost(
          text: cancelText ?? 'Annuler',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        isDangerous
            ? AppButton.danger(
                text: confirmText ?? 'Confirmer',
                onPressed: () => Navigator.of(context).pop(true),
              )
            : AppButton.primary(
                text: confirmText ?? 'Confirmer',
                onPressed: () => Navigator.of(context).pop(true),
              ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIALOG DANGER - Dialog de confirmation dangereuse (suppression)
// ═══════════════════════════════════════════════════════════════

/// Dialog pour actions dangereuses (suppression, etc.)
class AppDangerDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;

  const AppDangerDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppDangerDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AppConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText ?? 'Supprimer',
      cancelText: cancelText,
      icon: Icons.warning,
      iconColor: AppColors.danger,
      isDangerous: true,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIALOG LOADING - Dialog de chargement
// ═══════════════════════════════════════════════════════════════

/// Dialog de chargement avec spinner
class AppLoadingDialog extends StatelessWidget {
  final String? message;

  const AppLoadingDialog({
    super.key,
    this.message,
  });

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppLoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.dialog,
      ),
      backgroundColor: AppColors.white,
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIALOG SUCCESS - Dialog de succès
// ═══════════════════════════════════════════════════════════════

/// Dialog de succès avec animation
class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;

  const AppSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppSuccessDialog(
        title: title,
        message: message,
        confirmText: confirmText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppInfoDialog(
      title: title,
      message: message,
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      confirmText: confirmText,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIALOG ERROR - Dialog d'erreur
// ═══════════════════════════════════════════════════════════════

/// Dialog d'erreur
class AppErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;

  const AppErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppErrorDialog(
        title: title,
        message: message,
        confirmText: confirmText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppInfoDialog(
      title: title,
      message: message,
      icon: Icons.error,
      iconColor: AppColors.danger,
      confirmText: confirmText,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BOTTOM SHEET - Alternative modale en bas
// ═══════════════════════════════════════════════════════════════

/// Bottom sheet avec design cohérent
class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showHandle;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showHandle = true,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool showHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        child: child,
        actions: actions,
        showHandle: showHandle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
        boxShadow: AppShadows.dialog,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            if (showHandle)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            // Title
            Padding(
              padding: AppSpacing.paddingMD,
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: AppTextStyles.headlineMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingMD,
                child: child,
              ),
            ),
            // Actions
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: AppSpacing.paddingMD,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _intersperse(
                    actions!,
                    const SizedBox(width: AppSpacing.sm),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _intersperse(List<Widget> list, Widget separator) {
    if (list.isEmpty) return [];
    return list
        .expand((item) => [item, separator])
        .toList()
        ..removeLast();
  }
}
