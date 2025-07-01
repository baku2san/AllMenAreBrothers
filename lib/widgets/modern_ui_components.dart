/// モダンUIコンポーネント集
/// 統一感のある再利用可能なUIコンポーネント
library;

import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';

/// モダンなステータスカード
class ModernStatusCard extends StatelessWidget {
  const ModernStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ModernRadius.mdRadius,
        child: Container(
          padding: ModernSpacing.paddingMD,
          decoration: ModernDecorations.card(colorScheme),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: ModernSpacing.paddingXS,
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: ModernRadius.smRadius,
                    ),
                    child: Icon(
                      icon,
                      color: effectiveColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// モダンなプログレスバー
class ModernProgressBar extends StatelessWidget {
  const ModernProgressBar({
    super.key,
    required this.progress,
    required this.label,
    this.color,
    this.backgroundColor,
    this.height = 8.0,
  });

  final double progress; // 0.0 - 1.0
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: ModernShadows.coloredShadow(effectiveColor, opacity: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// モダンなアクションボタン
class ModernActionButton extends StatelessWidget {
  const ModernActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isExpanded = false,
    this.cost,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool isExpanded;
  final String? cost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget button = OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (cost != null)
            Text(
              cost!,
              style: AppTextStyles.labelSmall.copyWith(
                color: onPressed != null
                    ? colorScheme.onSurface.withValues(alpha: 0.7)
                    : colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: onPressed == null
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : (isPrimary
                ? colorScheme.primary
                : isDestructive
                    ? colorScheme.errorContainer
                    : colorScheme.surface),
        foregroundColor: onPressed == null
            ? colorScheme.onSurface.withValues(alpha: 0.38)
            : (isPrimary
                ? colorScheme.onPrimary
                : isDestructive
                    ? colorScheme.onErrorContainer
                    : colorScheme.onSurface),
        side: BorderSide(
          color: onPressed == null
              ? colorScheme.outline.withValues(alpha: 0.3)
              : (isPrimary
                  ? colorScheme.primary
                  : isDestructive
                      ? colorScheme.error
                      : colorScheme.outline),
          width: isPrimary ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: ModernRadius.mdRadius,
        ),
        padding: ModernSpacing.paddingMD,
      ),
    );

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// モダンなセクションヘッダー
class ModernSectionHeader extends StatelessWidget {
  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: ModernSpacing.paddingMD,
      decoration: ModernDecorations.primaryContainer(colorScheme),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: ModernSpacing.paddingXS,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: ModernRadius.smRadius,
              ),
              child: Icon(
                icon!,
                color: colorScheme.onPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// モダンなリストタイル
class ModernListTile extends StatelessWidget {
  const ModernListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ModernRadius.mdRadius,
        child: Container(
          padding: ModernSpacing.paddingMD,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
            borderRadius: ModernRadius.mdRadius,
            border: isSelected ? Border.all(color: colorScheme.primary.withValues(alpha: 0.5)) : null,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
