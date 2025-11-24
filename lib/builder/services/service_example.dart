// lib/builder/services/service_example.dart
// Example usage of BuilderLayoutService

import 'builder_layout_service.dart';
import '../models/models.dart';

/// Example: Basic draft workflow
Future<void> exampleDraftWorkflow() async {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';
  final pageId = BuilderPageId.home;

  // 1. Create a new draft page
  print('Creating draft page...');
  final page = BuilderPage(
    pageId: pageId,
    appId: appId,
    name: 'Page d\'accueil',
    route: '/home',
    blocks: [],
    isDraft: true,
  );

  // 2. Add some blocks
  final heroBlock = BuilderBlock(
    id: 'hero_1',
    type: BlockType.hero,
    order: 0,
    config: {
      'title': 'Bienvenue chez Pizza Deli\'Zza',
      'imageUrl': 'https://...',
    },
  );

  final updatedPage = page.addBlock(heroBlock);

  // 3. Save draft
  await service.saveDraft(updatedPage);
  print('Draft saved!');

  // 4. Load draft later
  final loadedDraft = await service.loadDraft(appId, pageId);
  print('Draft loaded: ${loadedDraft?.blocks.length} blocks');

  // 5. Publish when ready
  await service.publishPage(
    loadedDraft!,
    userId: 'admin_123',
    shouldDeleteDraft: true,
  );
  print('Published!');
}

/// Example: Real-time updates with streams
void exampleRealTimeUpdates() {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';
  final pageId = BuilderPageId.home;

  // Watch draft changes
  service.watchDraft(appId, pageId).listen((draft) {
    if (draft != null) {
      print('Draft updated: v${draft.version}, ${draft.blocks.length} blocks');
    } else {
      print('No draft exists');
    }
  });

  // Watch published changes
  service.watchPublished(appId, pageId).listen((published) {
    if (published != null) {
      print('Published page updated: v${published.version}');
    } else {
      print('No published version');
    }
  });
}

/// Example: Editor workflow
Future<void> exampleEditorWorkflow() async {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';
  final pageId = BuilderPageId.home;

  // 1. Check if page exists
  final status = await service.getPageStatus(appId, pageId);
  print('Page status: $status');

  // 2. Load page for editing (prefers draft)
  var page = await service.loadPage(appId, pageId);

  // 3. If no page exists, create default
  if (page == null) {
    page = await service.createDefaultPage(appId, pageId);
    print('Created default page');
  }

  // 4. If editing published page, create draft first
  if (!page.isDraft && status.hasPublished) {
    page = await service.copyPublishedToDraft(appId, pageId);
    print('Created draft from published');
  }

  // 5. Make changes
  final newBlock = BuilderBlock(
    id: 'block_${DateTime.now().millisecondsSinceEpoch}',
    type: BlockType.text,
    order: page.blocks.length,
    config: {'content': 'New content'},
  );
  page = page!.addBlock(newBlock);

  // 6. Save draft
  await service.saveDraft(page);
  print('Changes saved to draft');
}

/// Example: Publishing workflow
Future<void> examplePublishingWorkflow() async {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';
  final pageId = BuilderPageId.home;

  // Load draft
  final draft = await service.loadDraft(appId, pageId);
  if (draft == null) {
    print('No draft to publish');
    return;
  }

  // Check published version
  final published = await service.loadPublished(appId, pageId);
  if (published != null) {
    print('Current published version: v${published.version}');
  }

  // Publish draft
  await service.publishPage(
    draft,
    userId: 'admin_123',
    shouldDeleteDraft: true, // Clean up draft after publishing
  );

  print('Published! New version: v${draft.version}');
}

/// Example: Multi-page management
Future<void> exampleMultiPage() async {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';

  // Load all published pages
  final allPages = await service.loadAllPublishedPages(appId);
  print('Published pages: ${allPages.keys.map((p) => p.value).join(", ")}');

  // Check which pages have drafts
  final allDrafts = await service.loadAllDraftPages(appId);
  print('Draft pages: ${allDrafts.keys.map((p) => p.value).join(", ")}');

  // Create missing pages
  for (final pageId in BuilderPageId.values) {
    if (!allPages.containsKey(pageId)) {
      print('Creating default page for ${pageId.label}...');
      await service.createDefaultPage(appId, pageId, isDraft: false);
    }
  }
}

/// Example: Multi-resto support
Future<void> exampleMultiResto() async {
  final service = BuilderLayoutService();

  // Restaurant 1
  final page1 = BuilderPage(
    pageId: BuilderPageId.home,
    appId: 'pizza_delizza',
    name: 'Accueil Pizza Deli\'Zza',
    route: '/home',
    blocks: [],
    isDraft: false,
  );
  await service.publishPage(page1, userId: 'admin');

  // Restaurant 2 - different content, same page type
  final page2 = BuilderPage(
    pageId: BuilderPageId.home,
    appId: 'pizza_express',
    name: 'Accueil Pizza Express',
    route: '/home',
    blocks: [],
    isDraft: false,
  );
  await service.publishPage(page2, userId: 'admin');

  // Load pages separately
  final page1Loaded = await service.loadPublished('pizza_delizza', BuilderPageId.home);
  final page2Loaded = await service.loadPublished('pizza_express', BuilderPageId.home);

  print('Restaurant 1: ${page1Loaded?.name}');
  print('Restaurant 2: ${page2Loaded?.name}');
}

/// Example: Unpublish/revert workflow
Future<void> exampleUnpublish() async {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';
  final pageId = BuilderPageId.home;

  // Unpublish a page (move back to draft)
  await service.unpublishPage(
    appId,
    pageId,
    deletePublished: true,
  );

  print('Page unpublished and moved to draft');
}

/// Example: Batch operations
Future<void> exampleBatchOperations() async {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';

  // Publish all drafts at once
  final published = await service.publishAllDrafts(
    appId,
    userId: 'admin_123',
    deleteDrafts: true,
  );

  print('Published ${published.length} pages:');
  for (final pageId in published) {
    print('  - ${pageId.label}');
  }
}

/// Example: Error handling
Future<void> exampleErrorHandling() async {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';
  final pageId = BuilderPageId.home;

  try {
    // Try to publish a non-draft page
    final page = BuilderPage(
      pageId: pageId,
      appId: appId,
      name: 'Test',
      route: '/test',
      blocks: [],
      isDraft: false, // Not a draft!
    );

    await service.saveDraft(page); // This will throw
  } on ArgumentError catch (e) {
    print('Error: $e');
  }

  try {
    // Try to unpublish non-existent page
    await service.unpublishPage(appId, BuilderPageId.contact);
  } on StateError catch (e) {
    print('Error: $e');
  }
}

/// Example: Page status checking
Future<void> examplePageStatus() async {
  final service = BuilderLayoutService();
  final appId = 'pizza_delizza';

  for (final pageId in BuilderPageId.values) {
    final status = await service.getPageStatus(appId, pageId);
    
    print('${pageId.label}:');
    print('  Has draft: ${status.hasDraft}');
    print('  Has published: ${status.hasPublished}');
    print('  Is new: ${status.isNew}');
    print('  Is clean: ${status.isClean}');
    print('  Has unpublished changes: ${status.hasUnpublishedChanges}');
    print('  Status: $status');
  }
}
