// lib/builder/blocks/image_block_runtime.dart
// Runtime version of ImageBlock

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../../src/theme/app_theme.dart';

class ImageBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const ImageBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = block.getConfig<String>('imageUrl') ?? '';
    final caption = block.getConfig<String>('caption') ?? '';
    final heightStr = block.getConfig<String>('height') ?? '200';
    final height = double.tryParse(heightStr) ?? 200.0;

    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: AppRadius.card,
            child: Image.network(
              imageUrl,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: height,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
          if (caption.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              caption,
              style: AppTextStyles.caption.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
