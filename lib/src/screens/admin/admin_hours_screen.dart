// lib/src/screens/admin/admin_hours_screen.dart
// Écran de gestion des horaires (Admin)

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/business_hours.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';

class AdminHoursScreen extends StatefulWidget {
  const AdminHoursScreen({super.key});

  @override
  State<AdminHoursScreen> createState() => _AdminHoursScreenState();
}

class _AdminHoursScreenState extends State<AdminHoursScreen> {
  final SettingsService _settingsService = SettingsService();
  List<BusinessHours> _hours = [];
  List<ExceptionalClosure> _closures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final hours = await _settingsService.loadBusinessHours();
    final closures = await _settingsService.loadExceptionalClosures();
    setState(() {
      _hours = hours;
      _closures = closures;
      _isLoading = false;
    });
  }

  Future<void> _updateHour(int index, BusinessHours updatedHour) async {
    _hours[index] = updatedHour;
    await _settingsService.saveBusinessHours(_hours);
    _loadData();
  }

  Future<void> _addClosure() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fermeture exceptionnelle'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Raison'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true) {
      final closure = ExceptionalClosure(
        id: const Uuid().v4(),
        date: date,
        reason: reasonController.text.trim(),
      );
      _closures.add(closure);
      await _settingsService.saveExceptionalClosures(_closures);
      _loadData();
    }
  }

  Future<void> _deleteClosure(String id) async {
    _closures.removeWhere((c) => c.id == id);
    await _settingsService.saveExceptionalClosures(_closures);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Horaires'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(VisualConstants.paddingMedium),
              children: [
                Text(
                  'Horaires d\'ouverture',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ..._hours.asMap().entries.map((entry) {
                  final index = entry.key;
                  final hour = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(hour.dayOfWeek),
                      subtitle: hour.isClosed
                          ? const Text('Fermé')
                          : Text('${hour.openTime} - ${hour.closeTime}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(index, hour),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fermetures exceptionnelles',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _addClosure,
                      color: AppTheme.primaryRed,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_closures.isEmpty)
                  const Center(child: Text('Aucune fermeture prévue'))
                else
                  ..._closures.map((closure) {
                    final formattedDate = '${closure.date.day}/${closure.date.month}/${closure.date.year}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.event_busy, color: Colors.red),
                        title: Text(formattedDate),
                        subtitle: Text(closure.reason),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteClosure(closure.id),
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Future<void> _showEditDialog(int index, BusinessHours hour) async {
    String openTime = hour.openTime;
    String closeTime = hour.closeTime;
    bool isClosed = hour.isClosed;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(hour.dayOfWeek),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Fermé'),
                value: isClosed,
                onChanged: (value) => setState(() => isClosed = value!),
              ),
              if (!isClosed) ...[
                ListTile(
                  title: Text('Ouverture: $openTime'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(openTime.split(':')[0]),
                        minute: int.parse(openTime.split(':')[1]),
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        openTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('Fermeture: $closeTime'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(closeTime.split(':')[0]),
                        minute: int.parse(closeTime.split(':')[1]),
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        closeTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _updateHour(
        index,
        hour.copyWith(
          openTime: openTime,
          closeTime: closeTime,
          isClosed: isClosed,
        ),
      );
    }
  }
}
