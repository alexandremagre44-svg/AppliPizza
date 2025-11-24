// lib/builder/blocks/info_block_runtime.dart
// Runtime version of InfoBlock - practical information display

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/builder_block.dart';
import '../../src/theme/app_theme.dart';

/// Enhanced InfoBlockRuntime for practical information
/// 
/// Configuration options:
/// - icon: Icon type ('info', 'warning', 'success', 'error', 'time', 'phone', 'location', 'email')
/// - title: Info title/heading
/// - content: Main information text
/// - highlight: Set to true for emphasized display
/// - actionType: 'none', 'call', 'email', 'navigate' (for interactive info)
/// - actionValue: Phone number, email, or URL for action
class InfoBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const InfoBlockRuntime({
    super.key,
    required this.block,
  });

  // Helper getters for configuration
  String get _iconName => block.getConfig<String>('icon') ?? 'info';
  String get _title => block.getConfig<String>('title') ?? '';
  String get _content => block.getConfig<String>('content') ?? '';
  bool get _highlight => block.getConfig<bool>('highlight') ?? false;
  String? get _actionType => block.getConfig<String>('actionType');
  String? get _actionValue => block.getConfig<String>('actionValue');

  IconData get _icon {
    switch (_iconName) {
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      case 'time':
        return Icons.access_time_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'location':
        return Icons.location_on_outlined;
      case 'email':
        return Icons.email_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color get _color {
    if (_highlight) {
      return AppColors.primaryRed;
    }
    
    switch (_iconName) {
      case 'warning':
        return Colors.orange;
      case 'error':
        return AppColors.errorRed;
      case 'success':
        return Colors.green;
      case 'phone':
      case 'location':
      case 'email':
        return AppColors.primaryRed;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_title.isEmpty && _content.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasAction = _actionType != null && 
                      _actionType != 'none' && 
                      _actionValue != null && 
                      _actionValue!.isNotEmpty;

    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: GestureDetector(
        onTap: hasAction ? () => _handleAction(context) : null,
        child: Container(
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            color: _highlight 
                ? _color.withOpacity(0.15) 
                : _color.withOpacity(0.1),
            border: Border.all(
              color: _color.withOpacity(_highlight ? 0.5 : 0.3),
              width: _highlight ? 2 : 1,
            ),
            borderRadius: AppRadius.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _color, size: 24),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_title.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _title,
                              style: _highlight 
                                  ? AppTextStyles.titleLarge.copyWith(
                                      color: _color,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : AppTextStyles.titleMedium.copyWith(color: _color),
                            ),
                          ),
                          if (hasAction)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: _color,
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                    ],
                    if (_content.isNotEmpty)
                      Text(
                        _content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context) async {
    if (_actionType == null || _actionValue == null) return;

    try {
      Uri? uri;
      
      switch (_actionType) {
        case 'call':
          uri = Uri.parse('tel:$_actionValue');
          break;
        case 'email':
          uri = Uri.parse('mailto:$_actionValue');
          break;
        case 'navigate':
          uri = Uri.parse(_actionValue!);
          break;
      }

      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching action: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'effectuer cette action'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}
