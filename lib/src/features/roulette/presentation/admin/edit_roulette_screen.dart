// lib/src/screens/admin/studio/edit_roulette_screen.dart
// Advanced roulette editor with visual preview and probability validation

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import '../../data/models/roulette_config.dart';
import 'package:pizza_delizza/src/features/roulette/data/repositories/roulette_repository.dart';
import '../../shared/design_system/app_theme.dart';

class EditRouletteScreen extends StatefulWidget {
  final RouletteConfig config;
  
  const EditRouletteScreen({super.key, required this.config});

  @override
  State<EditRouletteScreen> createState() => _EditRouletteScreenState();
}

class _EditRouletteScreenState extends State<EditRouletteScreen> {
  final RouletteRepository _rouletteRepository = RouletteRepository();
  
  late bool _isEnabled;
  late List<RouletteSegment> _segments;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _isEnabled = widget.config.isActive;
    _segments = List.from(widget.config.segments);
  }

  double get _totalProbability {
    return _segments.fold(0.0, (sum, segment) => sum + segment.probability);
  }

  bool get _isProbabilityValid {
    final total = _totalProbability;
    return (total - 100.0).abs() < 0.01; // Allow tiny floating point difference
  }

  Future<void> _saveConfig() async {
    if (!_isProbabilityValid) {
      _showSnackBar('La somme des probabilités doit être égale à 100%', isError: true);
      return;
    }
    
    if (_segments.isEmpty) {
      _showSnackBar('Ajoutez au moins un segment', isError: true);
      return;
    }
    
    setState(() => _isSaving = true);
    
    final config = widget.config.copyWith(
      isActive: _isEnabled,
      segments: _segments,
      updatedAt: DateTime.now(),
    );
    
    final success = await _rouletteRepository.saveRouletteConfig(config);
    
    setState(() => _isSaving = false);
    
    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      _showSnackBar('Erreur lors de l\'enregistrement', isError: true);
    }
  }

  void _addSegment() {
    showDialog(
      context: context,
      builder: (context) => _SegmentEditorDialog(
        onSave: (segment) {
          setState(() {
            _segments.add(segment);
          });
        },
      ),
    );
  }

  void _editSegment(int index) {
    showDialog(
      context: context,
      builder: (context) => _SegmentEditorDialog(
        segment: _segments[index],
        onSave: (segment) {
          setState(() {
            _segments[index] = segment;
          });
        },
      ),
    );
  }

  void _deleteSegment(int index) {
    setState(() {
      _segments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration de la Roulette'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          if (!_isSaving)
            IconButton(
              icon: Icon(
                Icons.save,
                color: _isProbabilityValid ? Colors.white : Colors.white.withOpacity(0.3),
              ),
              onPressed: _isProbabilityValid ? _saveConfig : null,
              tooltip: _isProbabilityValid 
                  ? 'Enregistrer' 
                  : 'La somme des probabilités doit être égale à 100%',
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          
          if (isWideScreen) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildConfigSection(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 1,
                  child: _buildPreviewSection(),
                ),
              ],
            );
          } else {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.primaryRed,
                    unselectedLabelColor: AppColors.textMedium,
                    indicatorColor: AppColors.primaryRed,
                    tabs: const [
                      Tab(text: 'Configuration', icon: Icon(Icons.settings, size: 20)),
                      Tab(text: 'Aperçu', icon: Icon(Icons.casino, size: 20)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildConfigSection(),
                        _buildPreviewSection(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSegment,
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un segment'),
      ),
    );
  }

  Widget _buildConfigSection() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
            child: Padding(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('État de la roulette', style: AppTextStyles.titleLarge),
                  SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    title: const Text('Activer la roulette'),
                    subtitle: const Text('Les clients pourront faire tourner la roue'),
                    value: _isEnabled,
                    activeColor: AppColors.primaryRed,
                    onChanged: (value) => setState(() => _isEnabled = value),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
            child: Padding(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Probabilités', style: AppTextStyles.titleLarge),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: _isProbabilityValid 
                              ? AppColors.successGreen.withOpacity(0.1)
                              : AppColors.errorRed.withOpacity(0.1),
                          borderRadius: AppRadius.button,
                          border: Border.all(
                            color: _isProbabilityValid 
                                ? AppColors.successGreen
                                : AppColors.errorRed,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isProbabilityValid ? Icons.check_circle : Icons.warning,
                              size: 16,
                              color: _isProbabilityValid 
                                  ? AppColors.successGreen
                                  : AppColors.errorRed,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              '${_totalProbability.toStringAsFixed(1)}%',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _isProbabilityValid 
                                    ? AppColors.successGreen
                                    : AppColors.errorRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!_isProbabilityValid) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'La somme doit être égale à 100%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          Text('Segments (${_segments.length})', style: AppTextStyles.titleLarge),
          SizedBox(height: AppSpacing.md),
          
          if (_segments.isEmpty)
            Center(
              child: Padding(
                padding: AppSpacing.paddingXXL,
                child: Column(
                  children: [
                    Icon(
                      Icons.casino,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Aucun segment',
                      style: AppTextStyles.titleLarge,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Ajoutez des segments pour configurer la roue',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _segments.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final segment = _segments.removeAt(oldIndex);
                  _segments.insert(newIndex, segment);
                });
              },
              itemBuilder: (context, index) {
                final segment = _segments[index];
                return _buildSegmentCard(segment, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentCard(RouletteSegment segment, int index) {
    return Card(
      key: ValueKey(segment.id),
      elevation: 1,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textLight),
          ),
        ),
        title: Text(segment.label, style: AppTextStyles.titleMedium),
        subtitle: Text(
          '${segment.probability.toStringAsFixed(1)}% • ${segment.rewardId}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editSegment(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: AppColors.errorRed,
              onPressed: () => _deleteSegment(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      color: AppColors.backgroundLight,
      child: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingXL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Aperçu de la roue',
                style: AppTextStyles.titleLarge,
              ),
              SizedBox(height: AppSpacing.xl),
              _buildWheelPreview(),
              SizedBox(height: AppSpacing.xl),
              if (!_isProbabilityValid)
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.errorRed),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: AppColors.errorRed),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Probabilités invalides',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.errorRed,
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

  Widget _buildWheelPreview() {
    if (_segments.isEmpty) {
      return Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundLight,
          border: Border.all(color: AppColors.textLight, width: 2),
        ),
        child: Center(
          child: Text(
            'Ajoutez des segments',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    }

    return CustomPaint(
      size: const Size(300, 300),
      painter: _WheelPainter(segments: _segments),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}

class _SegmentEditorDialog extends StatefulWidget {
  final RouletteSegment? segment;
  final Function(RouletteSegment) onSave;
  
  const _SegmentEditorDialog({
    this.segment,
    required this.onSave,
  });

  @override
  State<_SegmentEditorDialog> createState() => _SegmentEditorDialogState();
}

class _SegmentEditorDialogState extends State<_SegmentEditorDialog> {
  late TextEditingController _labelController;
  late TextEditingController _rewardIdController;
  late TextEditingController _probabilityController;
  late Color _selectedColor;
  
  @override
  void initState() {
    super.initState();
    final segment = widget.segment;
    _labelController = TextEditingController(text: segment?.label ?? '');
    _rewardIdController = TextEditingController(text: segment?.rewardId ?? '');
    _probabilityController = TextEditingController(
      text: segment?.probability.toStringAsFixed(1) ?? '10.0',
    );
    _selectedColor = segment?.color ?? Colors.blue;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _rewardIdController.dispose();
    _probabilityController.dispose();
    super.dispose();
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le libellé est requis')),
      );
      return;
    }
    
    if (_rewardIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\'identifiant de récompense est requis')),
      );
      return;
    }
    
    final probability = double.tryParse(_probabilityController.text);
    if (probability == null || probability <= 0 || probability > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Probabilité invalide (0-100)')),
      );
      return;
    }
    
    final segment = RouletteSegment(
      id: widget.segment?.id ?? const Uuid().v4(),
      label: _labelController.text.trim(),
      rewardId: _rewardIdController.text.trim(),
      probability: probability,
      color: _selectedColor,
    );
    
    widget.onSave(segment);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.segment == null ? 'Nouveau segment' : 'Modifier le segment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Libellé*',
                hintText: 'Pizza offerte',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: _rewardIdController,
              decoration: const InputDecoration(
                labelText: 'ID de récompense*',
                hintText: 'free_pizza',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: _probabilityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Probabilité (%)*',
                hintText: '10.0',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
            ),
            SizedBox(height: AppSpacing.md),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textLight),
                ),
              ),
              title: const Text('Couleur'),
              trailing: const Icon(Icons.edit),
              onTap: _pickColor,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
          ),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<RouletteSegment> segments;
  
  _WheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    if (segments.isEmpty) return;
    
    double startAngle = -math.pi / 2; // Start from top
    
    for (final segment in segments) {
      final sweepAngle = (segment.probability / 100) * 2 * math.pi;
      
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );
      
      // Draw text
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: segment.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
      
      startAngle += sweepAngle;
    }
    
    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 30, centerPaint);
    
    // Draw arrow at top
    final arrowPaint = Paint()
      ..color = AppColors.primaryRed
      ..style = PaintingStyle.fill;
    
    final arrowPath = Path()
      ..moveTo(center.dx, 10)
      ..lineTo(center.dx - 15, 30)
      ..lineTo(center.dx + 15, 30)
      ..close();
    
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
