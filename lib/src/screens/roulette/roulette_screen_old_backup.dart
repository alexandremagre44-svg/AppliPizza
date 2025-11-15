// lib/src/screens/roulette/roulette_screen.dart
// Client-side roulette wheel screen with sounds, haptics, and confetti

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../models/roulette_config.dart';
import '../../services/roulette_service.dart';
import '../../design_system/app_theme.dart';
import 'reward_celebration_screen.dart';

class RouletteScreen extends StatefulWidget {
  final String userId;
  
  const RouletteScreen({super.key, required this.userId});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> {
  final RouletteService _rouletteService = RouletteService();
  final StreamController<int> _selectedController = StreamController<int>();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  RouletteConfig? _config;
  bool _isLoading = true;
  bool _isSpinning = false;
  bool _canSpin = false;
  int? _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _selectedController.close();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    final config = await _rouletteService.getRouletteConfig();
    final canSpin = await _rouletteService.canUserSpinToday(widget.userId);
    
    setState(() {
      _config = config;
      _canSpin = canSpin;
      _isLoading = false;
    });
  }

  Future<void> _spin() async {
    if (!_canSpin || _isSpinning || _config == null || _config!.segments.isEmpty) {
      return;
    }
    
    setState(() => _isSpinning = true);
    
    // Initial haptic feedback on spin start
    HapticFeedback.mediumImpact();
    
    // Play tick sound in loop during rotation (when audio asset is available)
    // The tick sound should be short (~0.1s) and play repeatedly
    try {
      // await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // await _audioPlayer.play(AssetSource('sounds/tick.mp3'));
    } catch (e) {
      print('Audio not available: $e');
    }
    
    // Simulate click haptics during spin (lighter feedback every 200ms)
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isSpinning || !mounted) {
        timer.cancel();
        return;
      }
      HapticFeedback.selectionClick();
    });
    
    // Determine winning segment
    final winningSegment = _rouletteService.spinWheel(_config!.segments);
    final winningIndex = _config!.segments.indexWhere((s) => s.id == winningSegment.id);
    
    // Set the selected index to trigger the wheel spin
    _selectedController.add(winningIndex);
    
    // Wait for wheel to finish spinning (fortune wheel takes ~5 seconds)
    await Future.delayed(const Duration(seconds: 5));
    
    if (!mounted) return;
    
    // Stop tick sound
    try {
      // await _audioPlayer.stop();
    } catch (e) {
      print('Audio stop error: $e');
    }
    
    // Record the spin
    await _rouletteService.recordSpin(widget.userId, winningSegment);
    
    // Victory haptic feedback (stronger impact)
    HapticFeedback.heavyImpact();
    
    // Play victory sound and show confetti if not "nothing"
    if (winningSegment.rewardId != 'nothing') {
      try {
        // await _audioPlayer.play(AssetSource('sounds/win.mp3'));
      } catch (e) {
        print('Victory audio not available: $e');
      }
      _confettiController.play();
    }
    
    setState(() {
      _selectedIndex = winningIndex;
      _isSpinning = false;
      _canSpin = false;
    });
    
    // Show celebration screen
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RewardCelebrationScreen(
          segment: winningSegment,
          userId: widget.userId,
        ),
      ),
    );
    
    // Reload to check if user can spin again
    _loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Roue de la Chance'),
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_config == null || !_config!.isCurrentlyActive) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Roue de la Chance'),
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: AppSpacing.paddingXL,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.casino,
                  size: 80,
                  color: AppColors.textLight,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'La roue n\'est pas disponible',
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Revenez plus tard pour tenter votre chance !',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roue de la Chance'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryRed.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
          
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingXL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tentez votre chance !',
                    style: AppTextStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: AppSpacing.sm),
                  
                  if (!_canSpin)
                    Container(
                      padding: AppSpacing.paddingMD,
                      decoration: BoxDecoration(
                        color: AppColors.warningOrange.withOpacity(0.1),
                        borderRadius: AppRadius.card,
                        border: Border.all(color: AppColors.warningOrange),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info, color: AppColors.warningOrange),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Limite atteinte pour aujourd\'hui',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.warningOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(height: AppSpacing.xxl),
                  
                  // Fortune Wheel
                  SizedBox(
                    height: 400,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FortuneWheel(
                          selected: _selectedController.stream,
                          animateFirst: false,
                          duration: const Duration(seconds: 5),
                          indicators: const [
                            FortuneIndicator(
                              alignment: Alignment.topCenter,
                              child: TriangleIndicator(
                                color: Colors.red,
                              ),
                            ),
                          ],
                          items: _config!.segments.map((segment) {
                            return FortuneItem(
                              child: Text(
                                segment.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              style: FortuneItemStyle(
                                color: segment.color,
                                borderColor: Colors.white,
                                borderWidth: 2,
                              ),
                            );
                          }).toList(),
                        ),
                        
                        // Center button
                        if (!_isSpinning)
                          GestureDetector(
                            onTap: _canSpin ? _spin : null,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _canSpin 
                                    ? AppColors.primaryRed 
                                    : AppColors.textLight,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        
                        if (_isSpinning)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textLight,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.xxl),
                  
                  if (_canSpin)
                    ElevatedButton.icon(
                      onPressed: _isSpinning ? null : _spin,
                      icon: const Icon(Icons.casino),
                      label: const Text('Faire tourner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        textStyle: AppTextStyles.titleMedium,
                      ),
                    ),
                  
                  SizedBox(height: AppSpacing.lg),
                  
                  Text(
                    'Vous pouvez tourner ${_config!.maxUsesPerDay} fois par jour',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
