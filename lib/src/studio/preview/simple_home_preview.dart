// lib/src/studio/preview/simple_home_preview.dart
// Simple preview that shows real HomeScreen with draft data (no simulation)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/home/home_screen.dart';
import '../../models/theme_config.dart';
import '../../providers/theme_providers.dart';
import 'preview_phone_frame.dart';

/// Simple preview widget that displays the real HomeScreen with optional draft theme
/// This is a minimal preview without any simulation controls - just shows what the user is editing
class SimpleHomePreview extends StatelessWidget {
  /// Optional draft theme configuration
  final ThemeConfig? draftTheme;

  const SimpleHomePreview({
    super.key,
    this.draftTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              // Preview header
              _buildPreviewHeader(),
              
              const SizedBox(height: 16),
              
              // Phone frame with real HomeScreen
              PreviewPhoneFrame(
                child: _buildPreviewContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.preview,
            color: Colors.grey.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Preview Live - Rendu 1:1',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          if (draftTheme != null) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Mode Brouillon',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    // If we have draft theme, override the theme provider
    if (draftTheme != null) {
      return ProviderScope(
        overrides: [
          themeConfigStreamProvider.overrideWith((ref) {
            return Stream.value(draftTheme!);
          }),
        ],
        child: const HomeScreen(),
      );
    }
    
    // Otherwise just show the real HomeScreen with current data
    return const HomeScreen();
  }
}
