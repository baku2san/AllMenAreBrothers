/// トースト型通知ウィジェット
/// ゲームイベントを数秒間表示して自動的に消える通知システム
library;

import 'package:flutter/material.dart';
import '../core/app_config.dart';

/// トースト通知マネージャー
class ToastNotificationManager {
  static final List<ToastNotification> _activeNotifications = [];
  static OverlayEntry? _overlayEntry;

  /// 通知を表示
  static void showNotification(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final notification = ToastNotification(
      message: message,
      type: type,
      duration: duration,
      icon: icon,
      onDismiss: _removeNotification,
    );

    _activeNotifications.add(notification);
    _updateOverlay(context);

    // 自動削除のタイマー
    Future.delayed(duration, () {
      _removeNotification(notification);
      _updateOverlay(context);
    });
  }

  /// 通知を削除
  static void _removeNotification(ToastNotification notification) {
    _activeNotifications.remove(notification);
  }

  /// オーバーレイを更新
  static void _updateOverlay(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (_activeNotifications.isNotEmpty) {
      _overlayEntry = OverlayEntry(
        builder: (context) => ToastNotificationStack(
          notifications: List.from(_activeNotifications),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  /// 全ての通知をクリア
  static void clearAll(BuildContext context) {
    _activeNotifications.clear();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// トースト通知の種類
enum ToastType {
  info,
  success,
  warning,
  error,
}

/// トースト通知データ
class ToastNotification {
  const ToastNotification({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.icon,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final IconData? icon;
  final void Function(ToastNotification) onDismiss;
}

/// トースト通知スタック
class ToastNotificationStack extends StatelessWidget {
  const ToastNotificationStack({
    super.key,
    required this.notifications,
  });

  final List<ToastNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80, // ヘッダーの下
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: notifications.map((notification) {
          return ToastNotificationWidget(notification: notification);
        }).toList(),
      ),
    );
  }
}

/// 個別のトースト通知ウィジェット
class ToastNotificationWidget extends StatefulWidget {
  const ToastNotificationWidget({
    super.key,
    required this.notification,
  });

  final ToastNotification notification;

  @override
  State<ToastNotificationWidget> createState() => _ToastNotificationWidgetState();
}

class _ToastNotificationWidgetState extends State<ToastNotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 300.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(maxWidth: 300),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(colorScheme),
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    border: Border.all(
                      color: _getBorderColor(colorScheme),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // アイコン
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(colorScheme),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          widget.notification.icon ?? _getDefaultIcon(),
                          size: 16,
                          color: _getIconColor(colorScheme),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // メッセージ
                      Expanded(
                        child: Text(
                          widget.notification.message,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _getTextColor(colorScheme),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 閉じるボタン
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _animationController.reverse().then((_) {
                            widget.notification.onDismiss(widget.notification);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 通知タイプに応じた背景色を取得
  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (widget.notification.type) {
      case ToastType.success:
        return colorScheme.primaryContainer;
      case ToastType.warning:
        return colorScheme.tertiaryContainer;
      case ToastType.error:
        return colorScheme.errorContainer;
      case ToastType.info:
        return colorScheme.surfaceContainerHighest;
    }
  }

  /// 通知タイプに応じたボーダー色を取得
  Color _getBorderColor(ColorScheme colorScheme) {
    switch (widget.notification.type) {
      case ToastType.success:
        return colorScheme.primary.withValues(alpha: 0.3);
      case ToastType.warning:
        return colorScheme.tertiary.withValues(alpha: 0.3);
      case ToastType.error:
        return colorScheme.error.withValues(alpha: 0.3);
      case ToastType.info:
        return colorScheme.outline.withValues(alpha: 0.2);
    }
  }

  /// 通知タイプに応じたアイコン背景色を取得
  Color _getIconBackgroundColor(ColorScheme colorScheme) {
    switch (widget.notification.type) {
      case ToastType.success:
        return colorScheme.primary.withValues(alpha: 0.2);
      case ToastType.warning:
        return colorScheme.tertiary.withValues(alpha: 0.2);
      case ToastType.error:
        return colorScheme.error.withValues(alpha: 0.2);
      case ToastType.info:
        return colorScheme.secondary.withValues(alpha: 0.2);
    }
  }

  /// 通知タイプに応じたアイコン色を取得
  Color _getIconColor(ColorScheme colorScheme) {
    switch (widget.notification.type) {
      case ToastType.success:
        return colorScheme.primary;
      case ToastType.warning:
        return colorScheme.tertiary;
      case ToastType.error:
        return colorScheme.error;
      case ToastType.info:
        return colorScheme.secondary;
    }
  }

  /// 通知タイプに応じたテキスト色を取得
  Color _getTextColor(ColorScheme colorScheme) {
    switch (widget.notification.type) {
      case ToastType.success:
        return colorScheme.onPrimaryContainer;
      case ToastType.warning:
        return colorScheme.onTertiaryContainer;
      case ToastType.error:
        return colorScheme.onErrorContainer;
      case ToastType.info:
        return colorScheme.onSurface;
    }
  }

  /// デフォルトアイコンを取得
  IconData _getDefaultIcon() {
    switch (widget.notification.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }
}
