// lib/builder/utils/builder_page_wrapper.dart
// Reusable wrapper for pages that support Builder B3 layouts
// MOBILE RESPONSIVE: Fixed scroll behavior for mobile

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../preview/preview.dart';

/// Wrapper widget that loads Builder B3 layout for a page
/// Falls back to default content if no published layout exists
class BuilderPageWrapper extends StatelessWidget {
  final BuilderPageId pageId;
  final String appId;
  final Widget Function() fallbackBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  const BuilderPageWrapper({
    super.key,
    required this.pageId,
    required this.appId,
    required this.fallbackBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final service = BuilderLayoutService();

    return FutureBuilder<BuilderPage?>(
      future: service.loadPublished(appId, pageId),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        // Error state - fallback to default
        if (snapshot.hasError) {
          debugPrint('Builder B3: Error loading page $pageId - ${snapshot.error}');
          return errorBuilder?.call(context, snapshot.error!) ?? fallbackBuilder();
        }

        final page = snapshot.data;

        // No published layout - use fallback
        if (page == null || page.blocks.isEmpty) {
          debugPrint('Builder B3: No published layout for $pageId, using fallback');
          return fallbackBuilder();
        }

        // Has published layout - render with Builder B3
        debugPrint('Builder B3: Rendering $pageId with ${page.blocks.length} blocks');
        return RefreshIndicator(
          onRefresh: () async {
            // Trigger rebuild to reload from Firestore
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: BuilderRuntimeRenderer(
              blocks: page.blocks,
              wrapInScrollView: false, // We handle scroll here
            ),
          ),
        );
      },
    );
  }
}
