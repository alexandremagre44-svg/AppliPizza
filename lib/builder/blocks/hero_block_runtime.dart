// lib/builder/blocks/hero_block_runtime.dart
// Runtime version of HeroBlock - uses real widgets and styling

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/builder_block.dart';
import '../../src/widgets/home/hero_banner.dart';
import '../../src/core/constants.dart';

class HeroBlockRuntime extends ConsumerWidget {
  final BuilderBlock block;

  const HeroBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = block.getConfig<String>('title') ?? 'Bienvenue';
    final subtitle = block.getConfig<String>('subtitle') ?? '';
    final imageUrl = block.getConfig<String>('imageUrl') ?? '';
    final buttonLabel = block.getConfig<String>('buttonLabel');

    return HeroBanner(
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      title: title,
      subtitle: subtitle.isNotEmpty ? subtitle : null,
      onTap: () {
        // Navigate to menu when tapped
        context.go(AppRoutes.menu);
      },
    );
  }
}
