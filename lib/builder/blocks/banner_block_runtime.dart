// lib/builder/blocks/banner_block_runtime.dart
// Runtime version of BannerBlock - uses info banner widget

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../../src/widgets/home/info_banner.dart';

class BannerBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const BannerBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final text = block.getConfig<String>('text') ?? '';
    
    return InfoBanner(
      text: text,
      icon: Icons.info_outline,
    );
  }
}
