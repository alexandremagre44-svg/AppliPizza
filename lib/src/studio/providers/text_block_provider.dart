// lib/src/studio/providers/text_block_provider.dart
// Riverpod providers for text block management with draft support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/text_block_model.dart';
import '../services/text_block_service.dart';

/// Service provider for text blocks
final textBlockServiceProvider = Provider<TextBlockService>((ref) {
  return TextBlockService();
});

/// Stream provider for all text blocks
final textBlocksProvider = StreamProvider<List<TextBlockModel>>((ref) {
  final service = ref.watch(textBlockServiceProvider);
  return service.watchTextBlocks();
});

/// Stream provider for enabled text blocks only
final enabledTextBlocksProvider = StreamProvider<List<TextBlockModel>>((ref) {
  final blocksAsync = ref.watch(textBlocksProvider);
  return blocksAsync.when(
    data: (blocks) => Stream.value(
      blocks.where((block) => block.isEnabled).toList(),
    ),
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Future provider for one-time fetch
final textBlocksFutureProvider = FutureProvider<List<TextBlockModel>>((ref) {
  final service = ref.watch(textBlockServiceProvider);
  return service.getAllTextBlocks();
});

/// Future provider for text blocks by category
final textBlocksByCategoryProvider = FutureProvider.family<List<TextBlockModel>, String>(
  (ref, category) async {
    final service = ref.watch(textBlockServiceProvider);
    return await service.getTextBlocksByCategory(category);
  },
);

/// State provider for draft text blocks (local changes before publish)
final draftTextBlocksProvider = StateProvider<List<TextBlockModel>?>((ref) => null);

/// State provider for tracking unsaved text block changes
final hasUnsavedTextBlockChangesProvider = StateProvider<bool>((ref) => false);

/// Provider that returns draft text blocks if available, otherwise published text blocks
final effectiveTextBlocksProvider = Provider<AsyncValue<List<TextBlockModel>>>((ref) {
  final draftBlocks = ref.watch(draftTextBlocksProvider);
  
  if (draftBlocks != null) {
    // Return draft text blocks (wrapped in AsyncValue for consistency)
    return AsyncValue.data(draftBlocks);
  }
  
  // Return published text blocks from stream
  return ref.watch(textBlocksProvider);
});

/// Helper provider to get text content by name
final textContentByNameProvider = FutureProvider.family<String?, String>(
  (ref, name) async {
    final service = ref.watch(textBlockServiceProvider);
    return await service.getTextContentByName(name);
  },
);
