// lib/src/widgets/popup_dialog.dart
// Animated popup dialog widget
// MIGRATED to WL V2 Theme - Uses theme colors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/popup_config.dart';
import '../design_system/app_theme.dart';
import '../../white_label/theme/theme_extensions.dart';

class PopupDialog extends StatefulWidget {
  final PopupConfig popup;
  final VoidCallback onDismiss;
  
  const PopupDialog({
    super.key,
    required this.popup,
    required this.onDismiss,
  });

  @override
  State<PopupDialog> createState() => _PopupDialogState();
}

class _PopupDialogState extends State<PopupDialog> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // MANDATORY 400ms animation as specified in requirements
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleDismiss() {
    widget.onDismiss();
    _close();
  }

  void _handleButtonTap() {
    if (widget.popup.buttonLink != null && widget.popup.buttonLink!.isNotEmpty) {
      context.go(widget.popup.buttonLink!);
    }
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardLarge,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: AppSpacing.paddingLG,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.popup.title,
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: context.textSecondary, // WL V2: Theme text
                        size: 20,
                      ),
                      onPressed: _close,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.md),
                
                // Image if available
                if (widget.popup.imageUrl != null && 
                    widget.popup.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: AppRadius.card,
                    child: Image.network(
                      widget.popup.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: context.backgroundColor, // WL V2: Theme background
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: context.textSecondary, // WL V2: Theme text
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                ],
                
                // Message
                Text(
                  widget.popup.message,
                  style: AppTextStyles.bodyLarge,
                ),
                
                // Button if available
                if (widget.popup.buttonText != null && 
                    widget.popup.buttonText!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleButtonTap,
                      // WL V2: Button inherits style from theme elevatedButtonTheme
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor, // WL V2: Theme primary
                        foregroundColor: context.onPrimary, // WL V2: Contrast color
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      child: Text(widget.popup.buttonText!),
                    ),
                  ),
                ],
                
                // Don't show again button
                SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: _handleDismiss,
                    child: Text(
                      'Ne plus afficher',
                      style: context.bodySmall?.copyWith( // WL V2: Theme text
                        color: context.textSecondary, // WL V2: Theme text color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
