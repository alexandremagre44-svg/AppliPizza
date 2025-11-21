// lib/src/studio/preview/simulation_panel.dart
// Simulation control panel for preview customization

import 'package:flutter/material.dart';
import 'simulation_state.dart';

/// Simulation control panel widget
class SimulationPanel extends StatelessWidget {
  final SimulationState state;
  final Function(SimulationState) onStateChanged;

  const SimulationPanel({
    super.key,
    required this.state,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('🎭 Simulation'),
            const SizedBox(height: 16),
            
            // User type simulator
            _buildUserTypeSimulator(),
            const SizedBox(height: 24),
            
            // Time simulator
            _buildTimeSimulator(),
            const SizedBox(height: 24),
            
            // Cart simulator
            _buildCartSimulator(),
            const SizedBox(height: 24),
            
            // Order history simulator
            _buildOrderHistorySimulator(),
            const SizedBox(height: 24),
            
            // Theme simulator
            _buildThemeSimulator(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1E1E),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF424242),
        ),
      ),
    );
  }

  /// User type simulator section
  Widget _buildUserTypeSimulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('👤 Type d\'utilisateur'),
        ...SimulatedUserType.values.map((type) {
          return RadioListTile<SimulatedUserType>(
            title: Text(
              _getUserTypeLabel(type),
              style: const TextStyle(fontSize: 13),
            ),
            value: type,
            groupValue: state.userType,
            onChanged: (value) {
              if (value != null) {
                onStateChanged(state.copyWith(userType: value));
              }
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  String _getUserTypeLabel(SimulatedUserType type) {
    switch (type) {
      case SimulatedUserType.newCustomer:
        return 'Nouveau client';
      case SimulatedUserType.returningCustomer:
        return 'Client habituel';
      case SimulatedUserType.cartFilled:
        return 'Client panier rempli';
      case SimulatedUserType.frequentBuyer:
        return 'Client 5 commandes';
      case SimulatedUserType.vipLoyalty:
        return 'Client VIP Fidélité';
    }
  }

  /// Time simulator section
  Widget _buildTimeSimulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('⏰ Temps simulé'),
        
        // Hour slider
        Row(
          children: [
            const Text('Heure:', style: TextStyle(fontSize: 13)),
            Expanded(
              child: Slider(
                value: state.simulatedHour.toDouble(),
                min: 0,
                max: 23,
                divisions: 23,
                label: '${state.simulatedHour}h',
                onChanged: (value) {
                  onStateChanged(state.copyWith(simulatedHour: value.toInt()));
                },
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                '${state.simulatedHour}h',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Day selector
        const Text('Jour:', style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (int day = 1; day <= 7; day++)
              _buildDayChip(day),
          ],
        ),
      ],
    );
  }

  Widget _buildDayChip(int day) {
    final isSelected = state.simulatedDay == day;
    final dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    
    return InkWell(
      onTap: () {
        onStateChanged(state.copyWith(simulatedDay: day));
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            dayLabels[day - 1],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  /// Cart simulator section
  Widget _buildCartSimulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('🛒 Panier'),
        
        // Preset options
        CheckboxListTile(
          title: const Text('Panier vide', style: TextStyle(fontSize: 13)),
          value: state.cartItemCount == 0,
          onChanged: (value) {
            if (value == true) {
              onStateChanged(state.copyWith(cartItemCount: 0));
            }
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('1 item', style: TextStyle(fontSize: 13)),
          value: state.cartItemCount == 1,
          onChanged: (value) {
            if (value == true) {
              onStateChanged(state.copyWith(cartItemCount: 1));
            }
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('2 items', style: TextStyle(fontSize: 13)),
          value: state.cartItemCount == 2,
          onChanged: (value) {
            if (value == true) {
              onStateChanged(state.copyWith(cartItemCount: 2));
            }
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Combo/Menu', style: TextStyle(fontSize: 13)),
          value: state.hasCombo,
          onChanged: (value) {
            onStateChanged(state.copyWith(
              hasCombo: value ?? false,
              cartItemCount: value == true ? 1 : state.cartItemCount,
            ));
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        
        // Manual item count
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Items:', style: TextStyle(fontSize: 13)),
            Expanded(
              child: Slider(
                value: state.cartItemCount.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: '${state.cartItemCount}',
                onChanged: (value) {
                  onStateChanged(state.copyWith(cartItemCount: value.toInt()));
                },
              ),
            ),
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                '${state.cartItemCount}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Order history simulator section
  Widget _buildOrderHistorySimulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('📦 Historique commandes'),
        Row(
          children: [
            const Text('Commandes:', style: TextStyle(fontSize: 13)),
            Expanded(
              child: Slider(
                value: state.previousOrdersCount.toDouble(),
                min: 0,
                max: 20,
                divisions: 20,
                label: '${state.previousOrdersCount}',
                onChanged: (value) {
                  onStateChanged(state.copyWith(previousOrdersCount: value.toInt()));
                },
              ),
            ),
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                '${state.previousOrdersCount}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Theme simulator section
  Widget _buildThemeSimulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('🎨 Thème'),
        RadioListTile<ThemeMode>(
          title: const Text('Light', style: TextStyle(fontSize: 13)),
          value: ThemeMode.light,
          groupValue: state.themeMode,
          onChanged: (value) {
            if (value != null) {
              onStateChanged(state.copyWith(themeMode: value));
            }
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark', style: TextStyle(fontSize: 13)),
          value: ThemeMode.dark,
          groupValue: state.themeMode,
          onChanged: (value) {
            if (value != null) {
              onStateChanged(state.copyWith(themeMode: value));
            }
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Auto', style: TextStyle(fontSize: 13)),
          value: ThemeMode.system,
          groupValue: state.themeMode,
          onChanged: (value) {
            if (value != null) {
              onStateChanged(state.copyWith(themeMode: value));
            }
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
