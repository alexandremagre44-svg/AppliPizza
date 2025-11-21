// lib/src/studio/widgets/studio_navigation.dart
// Professional navigation sidebar for Studio V2

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../core/constants.dart';

class StudioNavigation extends StatelessWidget {
  final String selectedSection;
  final Function(String) onSectionChanged;
  final bool hasUnsavedChanges;
  final VoidCallback onPublish;
  final VoidCallback onCancel;
  final bool isSaving;
  final bool isMobile;

  const StudioNavigation({
    super.key,
    required this.selectedSection,
    required this.onSectionChanged,
    required this.hasUnsavedChanges,
    required this.onPublish,
    required this.onCancel,
    this.isSaving = false,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileNavigation(context);
    }
    return _buildDesktopNavigation(context);
  }

  Widget _buildDesktopNavigation(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Studio V2',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasUnsavedChanges) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Modifications non publiées',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildNavSection(context, 'MODULES', [
                  _NavItem(
                    id: 'overview',
                    icon: Icons.dashboard_outlined,
                    label: 'Vue d\'ensemble',
                  ),
                  _NavItem(
                    id: 'hero',
                    icon: Icons.image_outlined,
                    label: 'Hero',
                  ),
                  _NavItem(
                    id: 'banners',
                    icon: Icons.notifications_outlined,
                    label: 'Bandeaux',
                  ),
                  _NavItem(
                    id: 'popups',
                    icon: Icons.campaign_outlined,
                    label: 'Popups',
                  ),
                  _NavItem(
                    id: 'texts',
                    icon: Icons.text_fields_outlined,
                    label: 'Textes dynamiques',
                  ),
                  _NavItem(
                    id: 'content',
                    icon: Icons.home_outlined,
                    label: 'Contenu d\'accueil',
                  ),
                  _NavItem(
                    id: 'sections',
                    icon: Icons.view_module_outlined,
                    label: 'Sections V3',
                  ),
                ]),
                const SizedBox(height: 16),
                _buildNavSection(context, 'CONFIGURATION', [
                  _NavItem(
                    id: 'theme',
                    icon: Icons.palette_outlined,
                    label: 'Theme Manager PRO',
                  ),
                  _NavItem(
                    id: 'settings',
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                  ),
                ]),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Column(
              children: [
                if (hasUnsavedChanges) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isSaving ? null : onPublish,
                      icon: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.publish, size: 18),
                      label: Text(isSaving ? 'Publication...' : 'Publier'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isSaving ? null : onCancel,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Studio V2',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (hasUnsavedChanges) ...[
            IconButton(
              onPressed: isSaving ? null : onPublish,
              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.publish),
              tooltip: 'Publier',
            ),
            IconButton(
              onPressed: isSaving ? null : onCancel,
              icon: const Icon(Icons.close),
              tooltip: 'Annuler',
            ),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'theme') {
                context.go(AppRoutes.adminStudioV3Theme);
              } else {
                onSectionChanged(value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'overview',
                child: ListTile(
                  leading: Icon(Icons.dashboard_outlined),
                  title: Text('Vue d\'ensemble'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'hero',
                child: ListTile(
                  leading: Icon(Icons.image_outlined),
                  title: Text('Hero'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'banners',
                child: ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Bandeaux'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'popups',
                child: ListTile(
                  leading: Icon(Icons.campaign_outlined),
                  title: Text('Popups'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'texts',
                child: ListTile(
                  leading: Icon(Icons.text_fields_outlined),
                  title: Text('Textes dynamiques'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'sections',
                child: ListTile(
                  leading: Icon(Icons.view_module_outlined),
                  title: Text('Sections V3'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'theme',
                child: ListTile(
                  leading: Icon(Icons.palette_outlined),
                  title: Text('Theme Manager PRO'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Paramètres'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavSection(
    BuildContext context,
    String title,
    List<_NavItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map((item) => _buildNavItem(context, item)),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item) {
    final isSelected = selectedSection == item.id;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            // Handle theme navigation specially - it's a separate route
            if (item.id == 'theme') {
              context.go(AppRoutes.adminStudioV3Theme);
            } else {
              onSectionChanged(item.id);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : const Color(0xFF616161),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : const Color(0xFF212121),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String id;
  final IconData icon;
  final String label;

  _NavItem({
    required this.id,
    required this.icon,
    required this.label,
  });
}
