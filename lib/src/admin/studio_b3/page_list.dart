// lib/src/admin/studio_b3/page_list.dart
// List of all B3 pages with management actions

import 'package:flutter/material.dart';
import '../../models/page_schema.dart';

/// Widget that displays a list of all B3 pages
class PageList extends StatelessWidget {
  final List<PageSchema> pages;
  final Function(PageSchema) onPageSelected;
  final Function(PageSchema, bool) onPageToggle;
  final VoidCallback onAddPage;
  final Function(PageSchema) onDeletePage;

  const PageList({
    Key? key,
    required this.pages,
    required this.onPageSelected,
    required this.onPageToggle,
    required this.onAddPage,
    required this.onDeletePage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: pages.isEmpty
              ? _buildEmptyState(context)
              : _buildPageGrid(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pages Dynamiques B3',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pages.length} page(s) configurée(s)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAddPage,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une page'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pages_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune page dynamique',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première page pour commencer',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddPage,
            icon: const Icon(Icons.add),
            label: const Text('Créer une page'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        return _buildPageCard(context, page);
      },
    );
  }

  Widget _buildPageCard(BuildContext context, PageSchema page) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onPageSelected(page),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      page.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Switch(
                    value: page.enabled,
                    onChanged: (value) => onPageToggle(page, value),
                    activeColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  page.route,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${page.blocks.length} bloc(s)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onPageSelected(page),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => onDeletePage(page),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
