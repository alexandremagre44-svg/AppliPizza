// lib/src/design_system/inputs.dart
// Composants de formulaire réutilisables - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'spacing.dart';
import 'radius.dart';

// ═══════════════════════════════════════════════════════════════
// INPUT STANDARD - AppTextField
// ═══════════════════════════════════════════════════════════════

/// Champ de texte standard avec design cohérent
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        filled: true,
        fillColor: enabled ? AppColors.white : AppColors.neutral100,
        contentPadding: AppSpacing.inputPadding,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.neutral600, size: 20)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: AppColors.neutral600, size: 20),
                onPressed: onSuffixIconTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.neutral200),
        ),
        labelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutral500,
        ),
        helperStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.danger,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INPUT AVEC ICÔNE - AppTextFieldWithIcon
// ═══════════════════════════════════════════════════════════════

/// Champ de texte avec icône (alias pour clarté)
class AppTextFieldWithIcon extends StatelessWidget {
  final String? label;
  final String? hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const AppTextFieldWithIcon({
    super.key,
    this.label,
    this.hint,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      prefixIcon: icon,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INPUT MULTILIGNES - AppTextArea
// ═══════════════════════════════════════════════════════════════

/// Zone de texte multiligne
class AppTextArea extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? errorText;

  const AppTextArea({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      errorText: errorText,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SELECT / DROPDOWN - AppDropdown
// ═══════════════════════════════════════════════════════════════

/// Menu déroulant avec design cohérent
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: enabled ? AppColors.white : AppColors.neutral100,
        contentPadding: AppSpacing.inputPadding,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.neutral600, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        labelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: AppTextStyles.bodyMedium,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.neutral600),
      dropdownColor: AppColors.white,
      borderRadius: AppRadius.input,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DATE TIME PICKER - AppDateTimePicker
// ═══════════════════════════════════════════════════════════════

/// Sélecteur de date/heure cohérent
class AppDateTimePicker extends StatelessWidget {
  final String? label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTimePickerMode mode;
  final String? errorText;

  const AppDateTimePicker({
    super.key,
    this.label,
    this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.mode = DateTimePickerMode.date,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = selectedDate != null
        ? _formatDate(selectedDate!, mode)
        : 'Sélectionner';

    return AppTextField(
      label: label,
      controller: TextEditingController(text: displayText),
      readOnly: true,
      suffixIcon: mode == DateTimePickerMode.date
          ? Icons.calendar_today
          : Icons.access_time,
      onTap: () => _selectDateTime(context),
      errorText: errorText,
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    if (mode == DateTimePickerMode.date || mode == DateTimePickerMode.dateTime) {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.white,
                surface: AppColors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        if (mode == DateTimePickerMode.dateTime) {
          if (!context.mounted) return;
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: AppColors.white,
                    surface: AppColors.white,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedTime != null) {
            final dateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            onDateSelected(dateTime);
          }
        } else {
          onDateSelected(pickedDate);
        }
      }
    } else if (mode == DateTimePickerMode.time) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        final now = DateTime.now();
        final dateTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDateSelected(dateTime);
      }
    }
  }

  String _formatDate(DateTime date, DateTimePickerMode mode) {
    switch (mode) {
      case DateTimePickerMode.date:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case DateTimePickerMode.time:
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      case DateTimePickerMode.dateTime:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Mode de sélection date/heure
enum DateTimePickerMode {
  date,
  time,
  dateTime,
}

// ═══════════════════════════════════════════════════════════════
// CHECKBOX - AppCheckbox
// ═══════════════════════════════════════════════════════════════

/// Checkbox avec label
class AppCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;

  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      borderRadius: AppRadius.button,
      child: Padding(
        padding: AppSpacing.paddingVerticalXS,
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: AppColors.primary,
              checkColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusXS,
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: enabled ? AppColors.textPrimary : AppColors.neutral500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RADIO - AppRadio
// ═══════════════════════════════════════════════════════════════

/// Radio button avec label
class AppRadio<T> extends StatelessWidget {
  final String label;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const AppRadio({
    super.key,
    required this.label,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled && onChanged != null ? () => onChanged!(value) : null,
      borderRadius: AppRadius.button,
      child: Padding(
        padding: AppSpacing.paddingVerticalXS,
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: enabled ? onChanged : null,
              activeColor: AppColors.primary,
            ),
            AppSpacing.horizontalSpaceXS,
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: enabled ? AppColors.textPrimary : AppColors.neutral500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
