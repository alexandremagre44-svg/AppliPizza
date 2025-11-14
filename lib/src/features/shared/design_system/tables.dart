// lib/src/design_system/tables.dart
// Composants tableaux - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'radius.dart';
import 'shadows.dart';

// ═══════════════════════════════════════════════════════════════
// TABLE STANDARD - AppTable
// ═══════════════════════════════════════════════════════════════

/// Table responsive avec design cohérent
class AppTable extends StatelessWidget {
  final List<AppTableColumn> columns;
  final List<List<Widget>> rows;
  final bool showBorder;
  final bool showDividers;
  final bool stickyHeader;
  final Widget? emptyState;

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showBorder = true,
    this.showDividers = true,
    this.stickyHeader = false,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty && emptyState != null) {
      return emptyState!;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
        border: showBorder
            ? Border.all(color: AppColors.borderSubtle, width: 1)
            : null,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 600),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                // Rows
                if (rows.isNotEmpty)
                  ...rows.asMap().entries.map((entry) {
                    final index = entry.key;
                    final row = entry.value;
                    return _buildRow(row, index);
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: columns.map((column) {
          return Expanded(
            flex: column.flex,
            child: Padding(
              padding: AppSpacing.tableCellPadding,
              child: Text(
                column.header,
                style: AppTextStyles.labelLarge,
                textAlign: column.alignment,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(List<Widget> row, int index) {
    return _TableRow(
      showDivider: showDividers && index < rows.length - 1,
      child: Row(
        children: List.generate(columns.length, (colIndex) {
          final column = columns[colIndex];
          final cell = row[colIndex];
          return Expanded(
            flex: column.flex,
            child: Padding(
              padding: AppSpacing.tableCellPadding,
              child: Align(
                alignment: _getAlignment(column.alignment),
                child: cell,
              ),
            ),
          );
        }),
      ),
    );
  }

  Alignment _getAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }
}

/// Configuration de colonne
class AppTableColumn {
  final String header;
  final int flex;
  final TextAlign alignment;

  const AppTableColumn({
    required this.header,
    this.flex = 1,
    this.alignment = TextAlign.left,
  });
}

/// Ligne de table avec hover
class _TableRow extends StatefulWidget {
  final Widget child;
  final bool showDivider;
  final VoidCallback? onTap;

  const _TableRow({
    required this.child,
    this.showDivider = false,
    this.onTap,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovering ? AppColors.neutral50 : Colors.transparent,
            border: widget.showDivider
                ? const Border(
                    bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
                  )
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TABLE ACTIONS - Actions pour les lignes de table
// ═══════════════════════════════════════════════════════════════

/// Widget d'actions pour ligne de table (typiquement en dernière colonne)
class AppTableActions extends StatelessWidget {
  final List<AppTableAction> actions;
  final MainAxisAlignment alignment;

  const AppTableActions({
    super.key,
    required this.actions,
    this.alignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: IconButton(
            icon: Icon(action.icon, size: 20),
            onPressed: action.onPressed,
            tooltip: action.tooltip,
            color: action.color ?? AppColors.neutral600,
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: const EdgeInsets.all(6),
          ),
        );
      }).toList(),
    );
  }
}

/// Action de table
class AppTableAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  const AppTableAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });
}

// ═══════════════════════════════════════════════════════════════
// DATA TABLE WRAPPER - Wrapper pour DataTable natif avec style
// ═══════════════════════════════════════════════════════════════

/// Wrapper stylisé pour DataTable Flutter natif
class AppDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckboxColumn;
  final bool sortAscending;
  final int? sortColumnIndex;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
    this.sortAscending = true,
    this.sortColumnIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Theme(
          data: Theme.of(context).copyWith(
            dataTableTheme: DataTableThemeData(
              headingRowColor: MaterialStateProperty.all(AppColors.neutral50),
              dataRowColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return AppColors.neutral50;
                }
                return null;
              }),
              dividerThickness: 1,
              headingTextStyle: AppTextStyles.labelLarge,
              dataTextStyle: AppTextStyles.bodyMedium,
            ),
          ),
          child: DataTable(
            columns: columns,
            rows: rows,
            showCheckboxColumn: showCheckboxColumn,
            sortAscending: sortAscending,
            sortColumnIndex: sortColumnIndex,
            headingRowHeight: 48,
            dataRowHeight: 56,
            horizontalMargin: AppSpacing.md,
            columnSpacing: AppSpacing.lg,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SIMPLE LIST TABLE - Table simplifiée pour listes
// ═══════════════════════════════════════════════════════════════

/// Table simplifiée sans header, juste des lignes
class AppSimpleList extends StatelessWidget {
  final List<Widget> items;
  final bool showDividers;
  final EdgeInsets? itemPadding;

  const AppSimpleList({
    super.key,
    required this.items,
    this.showDividers = true,
    this.itemPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) {
            return showDividers
                ? const Divider(height: 1, color: AppColors.borderSubtle)
                : const SizedBox.shrink();
          },
          itemBuilder: (context, index) {
            return _TableRow(
              showDivider: false,
              child: Padding(
                padding: itemPadding ?? AppSpacing.paddingMD,
                child: items[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
