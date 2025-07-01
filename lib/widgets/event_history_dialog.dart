/// イベント履歴ダイアログ
/// 過去のゲームイベントを一覧表示するダイアログ
library;

import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';

/// イベント履歴ダイアログ
class EventHistoryDialog extends StatefulWidget {
  const EventHistoryDialog({
    super.key,
    required this.eventHistory,
  });

  final List<String> eventHistory;

  @override
  State<EventHistoryDialog> createState() => _EventHistoryDialogState();
}

class _EventHistoryDialogState extends State<EventHistoryDialog> {
  String _searchText = '';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredEvents = _getFilteredEvents();

    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: ModernSpacing.paddingLG,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: ModernSpacing.paddingMD,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: ModernRadius.smRadius,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'イベント履歴',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '全${widget.eventHistory.length}件のイベント',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // 検索・フィルタ部分
            Container(
              padding: ModernSpacing.paddingMD,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // 検索バー
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'イベントを検索...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // フィルタチップ
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'すべて', Icons.list_rounded, colorScheme),
                        const SizedBox(width: 8),
                        _buildFilterChip('turn', 'ターン', Icons.calendar_today_rounded, colorScheme),
                        const SizedBox(width: 8),
                        _buildFilterChip('development', '開発', Icons.build_rounded, colorScheme),
                        const SizedBox(width: 8),
                        _buildFilterChip('military', '軍事', Icons.shield_rounded, colorScheme),
                        const SizedBox(width: 8),
                        _buildFilterChip('diplomacy', '外交', Icons.handshake_rounded, colorScheme),
                        const SizedBox(width: 8),
                        _buildFilterChip('hero', '英雄', Icons.person_rounded, colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // イベントリスト
            Expanded(
              child: filteredEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: ModernSpacing.paddingXL,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '該当するイベントがありません',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '検索条件やフィルタを変更してください',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: ModernSpacing.paddingMD,
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        final eventIndex = widget.eventHistory.indexOf(event);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                                : colorScheme.surface,
                            borderRadius: ModernRadius.smRadius,
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _getEventTypeColor(event, colorScheme).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                _getEventIcon(event),
                                size: 16,
                                color: _getEventTypeColor(event, colorScheme),
                              ),
                            ),
                            title: Text(
                              event,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.outline.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#${eventIndex + 1}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // フッター
            Container(
              padding: ModernSpacing.paddingMD,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '表示中: ${filteredEvents.length}件 / 全${widget.eventHistory.length}件',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '閉じる',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// フィルタチップを構築
  Widget _buildFilterChip(String type, String label, IconData icon, ColorScheme colorScheme) {
    final isSelected = _filterType == type;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = selected ? type : 'all';
        });
      },
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
      ),
      label: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.secondaryContainer,
      side: BorderSide(
        color: isSelected ? colorScheme.secondary : colorScheme.outline.withValues(alpha: 0.2),
      ),
    );
  }

  /// フィルタされたイベントリストを取得
  List<String> _getFilteredEvents() {
    var events = widget.eventHistory.reversed.toList();

    // 検索フィルタ
    if (_searchText.isNotEmpty) {
      events = events.where((event) => event.toLowerCase().contains(_searchText.toLowerCase())).toList();
    }

    // カテゴリフィルタ
    if (_filterType != 'all') {
      events = events.where((event) => _matchesFilter(event, _filterType)).toList();
    }

    return events;
  }

  /// イベントがフィルタに合致するかチェック
  bool _matchesFilter(String event, String filterType) {
    switch (filterType) {
      case 'turn':
        return event.contains('ターン') || event.contains('開始') || event.contains('収入');
      case 'development':
        return event.contains('発展') ||
            event.contains('開発') ||
            event.contains('農業') ||
            event.contains('商業') ||
            event.contains('治安') ||
            event.contains('改善');
      case 'military':
        return event.contains('軍事') ||
            event.contains('徴兵') ||
            event.contains('兵士') ||
            event.contains('強化') ||
            event.contains('攻撃');
      case 'diplomacy':
        return event.contains('外交') || event.contains('同盟') || event.contains('交渉');
      case 'hero':
        return event.contains('派遣') || event.contains('仲間') || event.contains('英雄');
      default:
        return true;
    }
  }

  /// イベントタイプに応じた色を取得
  Color _getEventTypeColor(String event, ColorScheme colorScheme) {
    if (event.contains('発展') || event.contains('開発') || event.contains('改善')) {
      return colorScheme.primary;
    } else if (event.contains('軍事') || event.contains('徴兵') || event.contains('攻撃')) {
      return colorScheme.error;
    } else if (event.contains('外交') || event.contains('同盟')) {
      return colorScheme.tertiary;
    } else if (event.contains('派遣') || event.contains('英雄')) {
      return colorScheme.secondary;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }

  /// イベントタイプに応じたアイコンを取得
  IconData _getEventIcon(String event) {
    if (event.contains('発展') || event.contains('開発') || event.contains('改善')) {
      return Icons.build_rounded;
    } else if (event.contains('軍事') || event.contains('徴兵') || event.contains('攻撃')) {
      return Icons.shield_rounded;
    } else if (event.contains('外交') || event.contains('同盟')) {
      return Icons.handshake_rounded;
    } else if (event.contains('派遣') || event.contains('英雄')) {
      return Icons.person_rounded;
    } else if (event.contains('ターン') || event.contains('収入')) {
      return Icons.calendar_today_rounded;
    } else {
      return Icons.info_rounded;
    }
  }
}
