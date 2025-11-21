// lib/src/studio/screens/theme_manager_screen.dart
// Theme Manager PRO - Complete visual customization interface

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../models/theme_config.dart';
import '../../providers/theme_providers.dart';
import '../../services/theme_service.dart';
import '../widgets/theme/theme_editor_panel.dart';
import '../widgets/theme/theme_preview_panel.dart';

/// Theme Manager PRO Screen
/// 
/// Route: /admin/studio/v3/theme
/// 
/// Features:
/// - Color pickers (palette + picker)
/// - Real-time phone preview
/// - Font selection (Google Fonts with fallback)
/// - Sliders for text sizes, radius, shadows, padding
/// - Dark mode toggle
/// - Reset to defaults
class ThemeManagerScreen extends ConsumerStatefulWidget {
  const ThemeManagerScreen({super.key});

  @override
  ConsumerState<ThemeManagerScreen> createState() => _ThemeManagerScreenState();
}

class _ThemeManagerScreenState extends ConsumerState<ThemeManagerScreen> {
  final ThemeService _themeService = ThemeService();
  
  ThemeConfig? _publishedConfig;
  ThemeConfig? _draftConfig;
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadThemeConfig();
  }

  Future<void> _loadThemeConfig() async {
    setState(() => _isLoading = true);
    
    try {
      await _themeService.initIfMissing();
      final config = await _themeService.getThemeConfig();
      
      setState(() {
        _publishedConfig = config;
        _draftConfig = config.copyWith();
        _isLoading = false;
      });
      
      // Update providers
      ref.read(draftThemeConfigProvider.notifier).state = _draftConfig;
      ref.read(hasUnsavedThemeChangesProvider.notifier).state = false;
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading theme: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _publishChanges() async {
    if (_draftConfig == null) return;
    
    setState(() => _isSaving = true);
    
    try {
      await _themeService.updateThemeConfig(_draftConfig!);
      
      setState(() {
        _publishedConfig = _draftConfig;
        _isSaving = false;
      });
      
      ref.read(hasUnsavedThemeChangesProvider.notifier).state = false;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme published successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error publishing theme: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelChanges() {
    setState(() {
      _draftConfig = _publishedConfig?.copyWith();
    });
    
    ref.read(draftThemeConfigProvider.notifier).state = _draftConfig;
    ref.read(hasUnsavedThemeChangesProvider.notifier).state = false;
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'Are you sure you want to reset all theme settings to their default values? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() {
        _draftConfig = ThemeConfig.defaultConfig();
      });
      
      ref.read(draftThemeConfigProvider.notifier).state = _draftConfig;
      ref.read(hasUnsavedThemeChangesProvider.notifier).state = true;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme reset to defaults (not published yet)'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _updateDraftConfig(ThemeConfig config) {
    setState(() {
      _draftConfig = config;
    });
    
    ref.read(draftThemeConfigProvider.notifier).state = config;
    ref.read(hasUnsavedThemeChangesProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final hasUnsavedChanges = ref.watch(hasUnsavedThemeChangesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.palette_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Theme Manager PRO'),
            if (hasUnsavedChanges) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 8, color: Colors.orange),
                    SizedBox(width: 6),
                    Text(
                      'Unsaved changes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (hasUnsavedChanges) ...[
            TextButton.icon(
              onPressed: _isSaving ? null : _cancelChanges,
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _publishChanges,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.publish),
              label: Text(_isSaving ? 'Publishing...' : 'Publish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _draftConfig == null
              ? const Center(child: Text('Failed to load theme configuration'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 900;
                    
                    if (isMobile) {
                      return _buildMobileLayout();
                    } else {
                      return _buildDesktopLayout();
                    }
                  },
                ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Editor panel
        Expanded(
          flex: 2,
          child: ThemeEditorPanel(
            config: _draftConfig!,
            onConfigChanged: _updateDraftConfig,
            onResetToDefaults: _resetToDefaults,
          ),
        ),
        
        // Divider
        Container(
          width: 1,
          color: AppColors.outline,
        ),
        
        // Preview panel
        Expanded(
          flex: 1,
          child: ThemePreviewPanel(
            config: _draftConfig!,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ThemeEditorPanel(
            config: _draftConfig!,
            onConfigChanged: _updateDraftConfig,
            onResetToDefaults: _resetToDefaults,
          ),
        ],
      ),
    );
  }
}
