// lib/src/screens/profile/widgets/roulette_card_widget.dart
// Roulette card for profile screen (Material 3)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../core/constants.dart';
import '../../../models/app_texts_config.dart';
import '../../../services/roulette_rules_service.dart';

/// Dedicated card for roulette access
/// Shows icon, configurable title/description, and CTA button
class RouletteCardWidget extends StatefulWidget {
  final RouletteTexts texts;
  final String userId;

  const RouletteCardWidget({
    super.key,
    required this.texts,
    required this.userId,
  });

  @override
  State<RouletteCardWidget> createState() => _RouletteCardWidgetState();
}

class _RouletteCardWidgetState extends State<RouletteCardWidget> {
  final RouletteRulesService _rulesService = RouletteRulesService();
  RouletteStatus? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    try {
      final status = await _rulesService.checkEligibility(widget.userId);
      if (mounted) {
        setState(() {
          _status = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = _status?.canSpin ?? false;
    final isLoading = _isLoading;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: canSpin && !isLoading
            ? () {
                context.go(AppRoutes.roulette);
              }
            : null,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: canSpin && !isLoading
                        ? [
                            Colors.amber,
                            Colors.amber.shade700,
                          ]
                        : [
                            Colors.grey.shade300,
                            Colors.grey.shade400,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: canSpin && !isLoading
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        canSpin ? Icons.casino : Icons.block,
                        size: 40,
                        color: Colors.white,
                      ),
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // Title
              Text(
                widget.texts.playTitle,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              // Description or status
              if (isLoading)
                Text(
                  'Vérification...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
              else if (!canSpin && _status?.reason != null)
                Column(
                  children: [
                    Text(
                      _status!.reason!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_status!.nextEligibleAt != null) ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatNextEligibleTime(_status!.nextEligibleAt!),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                )
              else
                Text(
                  widget.texts.playDescription,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              SizedBox(height: AppSpacing.lg),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canSpin && !isLoading
                      ? () {
                          context.go(AppRoutes.roulette);
                        }
                      : null,
                  icon: Icon(
                    canSpin ? Icons.casino : Icons.block,
                    size: 20,
                  ),
                  label: Text(
                    canSpin ? widget.texts.playButton : 'Non disponible',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSpin ? Colors.amber : AppColors.neutral300,
                    foregroundColor: canSpin ? Colors.black87 : AppColors.neutral600,
                    disabledBackgroundColor: AppColors.neutral300,
                    disabledForegroundColor: AppColors.neutral600,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNextEligibleTime(DateTime nextTime) {
    final now = DateTime.now();
    final difference = nextTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'Disponible dans ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Disponible dans ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Disponible dans ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Disponible maintenant';
    }
  }
}
