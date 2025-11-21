// lib/src/studio/preview/admin_home_preview_advanced.dart
// Advanced preview widget for Studio Admin - displays real HomeScreen with draft data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/home/home_screen.dart';
import '../../models/home_layout_config.dart';
import '../../models/banner_config.dart';
import '../../models/theme_config.dart';
import '../models/popup_v2_model.dart';
import 'simulation_state.dart';
import 'simulation_panel.dart';
import 'preview_phone_frame.dart';
import 'preview_state_overrides.dart';

/// Advanced preview widget for Studio Admin
/// Displays the real HomeScreen with draft configuration and simulation controls
class AdminHomePreviewAdvanced extends StatefulWidget {
  /// Draft home layout configuration (if being edited)
  final HomeLayoutConfig? draftHomeLayout;
  
  /// Draft banners (if being edited)
  final List<BannerConfig>? draftBanners;
  
  /// Draft popups (if being edited)
  final List<PopupV2Model>? draftPopups;
  
  /// Draft theme (if being edited)
  final ThemeConfig? draftTheme;

  const AdminHomePreviewAdvanced({
    super.key,
    this.draftHomeLayout,
    this.draftBanners,
    this.draftPopups,
    this.draftTheme,
  });

  @override
  State<AdminHomePreviewAdvanced> createState() => _AdminHomePreviewAdvancedState();
}

class _AdminHomePreviewAdvancedState extends State<AdminHomePreviewAdvanced> {
  SimulationState _simulationState = const SimulationState();

  void _updateSimulation(SimulationState newState) {
    setState(() {
      _simulationState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Row(
        children: [
          // Simulation panel (left side)
          SimulationPanel(
            state: _simulationState,
            onStateChanged: _updateSimulation,
          ),
          
          const SizedBox(width: 24),
          
          // Preview area (center/right)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildPreview(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    // Create provider overrides based on simulation state and draft data
    final overrides = PreviewStateOverrides.createOverrides(
      simulation: _simulationState,
      draftHomeLayout: widget.draftHomeLayout,
      draftBanners: widget.draftBanners,
      draftPopups: widget.draftPopups,
      draftTheme: widget.draftTheme,
    );

    return Column(
      children: [
        // Preview header
        _buildPreviewHeader(),
        
        const SizedBox(height: 16),
        
        // Phone frame with real HomeScreen
        PreviewPhoneFrame(
          child: ProviderScope(
            overrides: overrides,
            child: const HomeScreen(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Preview footer with simulation info
        _buildPreviewFooter(),
      ],
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
            'Preview Studio - Rendu 1:1',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 16),
          if (widget.draftHomeLayout != null ||
              widget.draftBanners != null ||
              widget.draftPopups != null ||
              widget.draftTheme != null)
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
      ),
    );
  }

  Widget _buildPreviewFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
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
          _buildInfoChip(
            icon: Icons.person,
            label: _simulationState.userDisplayName,
          ),
          const SizedBox(width: 8),
          _buildInfoChip(
            icon: Icons.access_time,
            label: '${_simulationState.dayName} ${_simulationState.simulatedHour}h',
          ),
          const SizedBox(width: 8),
          _buildInfoChip(
            icon: Icons.shopping_cart,
            label: '${_simulationState.cartItemCount} item(s)',
          ),
          const SizedBox(width: 8),
          _buildInfoChip(
            icon: Icons.history,
            label: '${_simulationState.previousOrdersCount} commande(s)',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
