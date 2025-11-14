// lib/src/features/content/presentation/admin/content_studio_screen.dart
// Admin interface for managing content strings with inline editing

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/content_provider.dart';
import '../../data/content_service.dart';
import 'debouncer.dart';
import '../../../../shared/theme/app_theme.dart';

/// Admin screen for managing content strings in the headless CMS
/// Features:
/// - Real-time updates via Firestore streams
/// - Inline editing with debounced saves
/// - Visual feedback for save states and errors
class ContentStudioScreen extends ConsumerStatefulWidget {
  const ContentStudioScreen({super.key});

  @override
  ConsumerState<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends ConsumerState<ContentStudioScreen> {
  // Track save states for each key
  final Map<String, bool> _savingStates = {};
  final Map<String, bool> _saveSuccessStates = {};
  final Map<String, String?> _errorStates = {};
  
  // Debouncers for each text field (250ms delay)
  final Map<String, Debouncer> _debouncers = {};

  @override
  void dispose() {
    // Clean up all debouncers
    for (final debouncer in _debouncers.values) {
      debouncer.dispose();
    }
    super.dispose();
  }

  Debouncer _getDebouncer(String key) {
    return _debouncers.putIfAbsent(
      key,
      () => Debouncer(duration: const Duration(milliseconds: 250)),
    );
  }

  Future<void> _saveString(String key, String value) async {
    setState(() {
      _savingStates[key] = true;
      _errorStates[key] = null;
    });

    try {
      final service = ref.read(contentServiceProvider);
      await service.updateString(key, 'fr', value);
      
      if (mounted) {
        setState(() {
          _savingStates[key] = false;
          _saveSuccessStates[key] = true;
          _errorStates[key] = null;
        });

        // Clear success indicator after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _saveSuccessStates[key] = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _savingStates[key] = false;
          _saveSuccessStates[key] = false;
          _errorStates[key] = e.toString();
        });

        // Show error in SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stringsAsync = ref.watch(allStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio de Contenu'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: stringsAsync.when(
        data: (strings) {
          if (strings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun contenu pour le moment',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les contenus apparaîtront ici une fois créés',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Sort strings by key for consistent display
          final sortedStrings = List.from(strings)
            ..sort((a, b) => a.key.compareTo(b.key));

          return ListView.builder(
            itemCount: sortedStrings.length,
            itemBuilder: (context, index) {
              final contentString = sortedStrings[index];
              final key = contentString.key;
              final currentValue = contentString.values['fr'] ?? '';
              
              final isSaving = _savingStates[key] ?? false;
              final saveSuccess = _saveSuccessStates[key] ?? false;
              final hasError = _errorStates[key] != null;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  // Display the key in gray italic (non-editable)
                  subtitle: Text(
                    key,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                  // Inline editable text field
                  title: TextFormField(
                    initialValue: currentValue,
                    decoration: InputDecoration(
                      border: hasError 
                          ? const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            )
                          : InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 8,
                      ),
                      suffixIcon: _buildSaveIndicator(
                        isSaving,
                        saveSuccess,
                        hasError,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    maxLines: null, // Allow multiline
                    onChanged: (value) {
                      // Debounce the save operation
                      final debouncer = _getDebouncer(key);
                      debouncer.call(() {
                        _saveString(key, value);
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(allStringsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddContentDialog(context);
        },
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget? _buildSaveIndicator(bool isSaving, bool saveSuccess, bool hasError) {
    if (isSaving) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    
    if (saveSuccess) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 20,
      );
    }
    
    if (hasError) {
      return const Icon(
        Icons.error,
        color: Colors.red,
        size: 20,
      );
    }
    
    return null;
  }

  void _showAddContentDialog(BuildContext context) {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un contenu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Clé',
                hintText: 'ex: home_welcome_title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Valeur (fr)',
                hintText: 'ex: Bienvenue chez PizzaDelizza',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = keyController.text.trim();
              final value = valueController.text.trim();
              
              if (key.isEmpty || value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La clé et la valeur sont requises'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                final service = ref.read(contentServiceProvider);
                await service.createString(key, 'fr', value);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contenu ajouté avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
