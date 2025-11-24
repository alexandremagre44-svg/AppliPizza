// lib/builder/blocks/category_list_block_runtime.dart
// Runtime version of CategoryListBlock - uses the existing CategoryShortcuts widget

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../../src/widgets/home/category_shortcuts.dart';

class CategoryListBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const CategoryListBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    // Use the existing CategoryShortcuts widget from the app
    return const CategoryShortcuts();
  }
}
