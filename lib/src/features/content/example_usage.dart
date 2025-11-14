// lib/src/features/content/example_usage.dart
// Example demonstrating how to use the CMS system in a Flutter widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/content_provider.dart';

/// Example widget demonstrating CMS usage
/// This can be referenced when refactoring existing screens
class ExampleCMSUsage extends ConsumerWidget {
  const ExampleCMSUsage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Basic usage - simple translation
    final welcomeTitle = ref.tr('home_welcome_title');
    
    // With parameter interpolation
    final userName = 'Alexandre';
    final personalizedGreeting = ref.tr(
      'welcome_user',
      params: {'name': userName},
    );

    return Scaffold(
      appBar: AppBar(
        // Use tr() for AppBar title
        title: Text(ref.tr('app_name')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple usage
            Text(
              welcomeTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // With parameters
            Text(
              personalizedGreeting,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            
            // Button text
            ElevatedButton(
              onPressed: () {},
              child: Text(ref.tr('home_order_now')),
            ),
            const SizedBox(height: 16),
            
            // Multiple translations in a Row
            Row(
              children: [
                Text(ref.tr('common_loading')),
                const SizedBox(width: 8),
                const CircularProgressIndicator(),
              ],
            ),
            const SizedBox(height: 32),
            
            // Demonstrating all states
            const Divider(),
            Text(
              'State Examples:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Loading state (if CMS not loaded yet)
            Text('Loading: ${ref.tr('some_key_loading')}'),
            
            // Missing key (development feedback)
            Text('Missing: ${ref.tr('nonexistent_key')}'),
            
            // Error state example
            Text('Error: (shown as ❌ Error if Firestore fails)'),
          ],
        ),
      ),
    );
  }
}

/// Example of a StatefulWidget using CMS
/// Shows that ConsumerStatefulWidget also works
class ExampleStatefulCMSUsage extends ConsumerStatefulWidget {
  const ExampleStatefulCMSUsage({super.key});

  @override
  ConsumerState<ExampleStatefulCMSUsage> createState() =>
      _ExampleStatefulCMSUsageState();
}

class _ExampleStatefulCMSUsageState
    extends ConsumerState<ExampleStatefulCMSUsage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr('example_counter_title')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ref.tr('counter_description')),
            const SizedBox(height: 16),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _counter++),
        tooltip: ref.tr('common_add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Example showing how to use CMS in a Dialog
void showExampleDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(ref.tr('dialog_title')),
      content: Text(ref.tr('dialog_message')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(ref.tr('common_cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle action
            Navigator.of(context).pop();
          },
          child: Text(ref.tr('common_save')),
        ),
      ],
    ),
  );
}

/// Example showing how to use CMS in SnackBar
void showExampleSnackBar(BuildContext context, WidgetRef ref) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ref.tr('order_success')),
      action: SnackBarAction(
        label: ref.tr('common_ok'),
        onPressed: () {},
      ),
    ),
  );
}

/// Example of building a list with CMS strings
class ExampleListWithCMS extends ConsumerWidget {
  const ExampleListWithCMS({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = [
      {'key': 'menu_pizzas', 'icon': Icons.local_pizza},
      {'key': 'menu_drinks', 'icon': Icons.local_drink},
      {'key': 'menu_desserts', 'icon': Icons.cake},
    ];

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: Icon(category['icon'] as IconData),
          title: Text(ref.tr(category['key'] as String)),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        );
      },
    );
  }
}
