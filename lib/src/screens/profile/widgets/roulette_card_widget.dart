// lib/src/screens/profile/widgets/roulette_card_widget.dart
// Roulette card for profile screen (Material 3)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../core/constants.dart';
import '../../../models/app_texts_config.dart';
import '../../../models/roulette_config.dart';
import '../../../services/roulette_rules_service.dart';
import '../../../services/roulette_segment_service.dart';
import '../../../screens/roulette/roulette_screen.dart';

/// State of the roulette widget
enum RouletteWidgetState {
  loading,
  disabled,
  unavailable,
  cooldown,
  timeRestricted,
  ready,
}

/// Dedicated card for roulette access
/// Shows icon, configurable title/description, and CTA button
class RouletteCardWidget extends ConsumerStatefulWidget {
  final RouletteTexts texts;
  final String userId;

  const RouletteCardWidget({
    super.key,
    required this.texts,
    required this.userId,
  });

  @override
  ConsumerState<RouletteCardWidget> createState() => _RouletteCardWidgetState();
}

class _RouletteCardWidgetState extends ConsumerState<RouletteCardWidget> {
  // Use getters to access services via providers
  RouletteRulesService get _rulesService => ref.read(rouletteRulesServiceProvider);
  RouletteSegmentService get _segmentService => ref.read(rouletteSegmentServiceProvider);
  
  RouletteWidgetState _state = RouletteWidgetState.loading;
  String _statusMessage = '';
  DateTime? _nextEligibleAt;
  RouletteRules? _rules;
  List<RouletteSegment> _segments = [];

  @override
  void initState() {
    super.initState();
    _checkRouletteAvailability();
  }

  Future<void> _checkRouletteAvailability() async {
    setState(() {
      _state = RouletteWidgetState.loading;
    });

    try {
      // 1. Load segments first
      final segments = await _segmentService.getActiveSegments();
      
      // 2. Load rules
      final rules = await _rulesService.getRules();
      
      if (!mounted) return;
      
      setState(() {
        _segments = segments;
        _rules = rules;
      });
      
      // 3. Determine state based on loaded data
      _determineState();
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = RouletteWidgetState.unavailable;
          _statusMessage = 'Erreur lors du chargement';
        });
      }
    }
  }

  void _determineState() {
    // Check if rules exist
    if (_rules == null) {
      setState(() {
        _state = RouletteWidgetState.unavailable;
        _statusMessage = 'La roulette n\'est pas configurée';
      });
      return;
    }
    
    // Check if roulette is enabled
    if (!_rules!.isEnabled) {
      setState(() {
        _state = RouletteWidgetState.disabled;
        _statusMessage = _rules!.messageDisabled;
      });
      return;
    }
    
    // Check if there are active segments
    if (_segments.isEmpty) {
      setState(() {
        _state = RouletteWidgetState.unavailable;
        _statusMessage = _rules!.messageUnavailable;
      });
      return;
    }
    
    // Check time restrictions
    final now = DateTime.now();
    final currentHour = now.hour;
    
    if (!_isWithinAllowedHours(currentHour)) {
      setState(() {
        _state = RouletteWidgetState.timeRestricted;
        _statusMessage = 'Disponible de ${_rules!.allowedStartHour}h à ${_rules!.allowedEndHour}h';
        _nextEligibleAt = _getNextAllowedTime(now);
      });
      return;
    }
    
    // Check cooldown via eligibility
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    try {
      final status = await _rulesService.checkEligibility(widget.userId);
      
      if (!mounted) return;
      
      if (status.canSpin) {
        setState(() {
          _state = RouletteWidgetState.ready;
          _statusMessage = widget.texts.playDescription;
        });
      } else {
        setState(() {
          _state = RouletteWidgetState.cooldown;
          _statusMessage = status.reason ?? 'Revenez demain !';
          _nextEligibleAt = status.nextEligibleAt;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = RouletteWidgetState.unavailable;
          _statusMessage = 'Erreur lors de la vérification';
        });
      }
    }
  }

  bool _isWithinAllowedHours(int currentHour) {
    if (_rules == null) return false;
    
    if (_rules!.allowedStartHour <= _rules!.allowedEndHour) {
      // Normal case: 9h - 22h
      return currentHour >= _rules!.allowedStartHour && 
             currentHour <= _rules!.allowedEndHour;
    } else {
      // Crosses midnight: 22h - 2h
      return currentHour >= _rules!.allowedStartHour || 
             currentHour <= _rules!.allowedEndHour;
    }
  }

  DateTime _getNextAllowedTime(DateTime now) {
    if (_rules == null) return now;
    
    final currentHour = now.hour;
    
    if (_rules!.allowedStartHour <= _rules!.allowedEndHour) {
      // Normal case
      if (currentHour < _rules!.allowedStartHour) {
        // Same day
        return DateTime(now.year, now.month, now.day, _rules!.allowedStartHour);
      } else {
        // Next day
        final tomorrow = now.add(const Duration(days: 1));
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, _rules!.allowedStartHour);
      }
    } else {
      // Crosses midnight
      if (currentHour <= _rules!.allowedEndHour) {
        // We're in the early morning allowed period, next is tonight
        return DateTime(now.year, now.month, now.day, _rules!.allowedStartHour);
      } else if (currentHour < _rules!.allowedStartHour) {
        // We're in the forbidden middle period, next is tonight
        return DateTime(now.year, now.month, now.day, _rules!.allowedStartHour);
      } else {
        // We're in the late night allowed period, next is early morning
        final tomorrow = now.add(const Duration(days: 1));
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _state == RouletteWidgetState.loading;
    final isReady = _state == RouletteWidgetState.ready;
    
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
        onTap: isReady
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RouletteScreen(userId: widget.userId),
                  ),
                );
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
                    colors: isReady
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
                  boxShadow: isReady
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
                        Icons.casino,
                        size: 40,
                        color: Colors.white,
                      ),
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // Title
              Text(
                'Roulette de la chance',
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
              else
                Column(
                  children: [
                    Text(
                      _statusMessage,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isReady ? AppColors.textSecondary : AppColors.warning,
                        fontWeight: isReady ? FontWeight.normal : FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_nextEligibleAt != null) ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatNextEligibleTime(_nextEligibleAt!),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              
              SizedBox(height: AppSpacing.lg),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isReady && !isLoading
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RouletteScreen(userId: widget.userId),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(
                    isReady ? Icons.casino : Icons.block,
                    size: 20,
                  ),
                  label: Text(
                    isReady ? 'Tourner la roue' : 'Non disponible',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isReady ? Colors.amber : AppColors.neutral300,
                    foregroundColor: isReady ? Colors.black87 : AppColors.neutral600,
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
