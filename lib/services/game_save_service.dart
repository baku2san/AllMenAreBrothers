/// ゲームデータのセーブ/ロード機能
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/water_margin_map.dart';
import '../models/water_margin_strategy_game.dart';

/// セーブ/ロード機能を提供するサービス
class GameSaveService {
  static const String _saveKeyPrefix = 'water_margin_save_';
  static const String _autoSaveKey = 'water_margin_autosave';
  static const String _saveListKey = 'water_margin_save_list';

  /// ゲーム状態を保存
  static Future<bool> saveGame(
    WaterMarginGameState gameState, {
    String? saveName,
    bool isAutoSave = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final saveData = GameSaveData(
        gameState: gameState,
        saveTime: DateTime.now(),
        saveName: saveName ?? _generateAutoSaveName(gameState),
        version: '1.0.0',
      );

      final jsonString = jsonEncode(saveData.toJson());

      if (isAutoSave) {
        await prefs.setString(_autoSaveKey, jsonString);
      } else {
        final saveKey = _saveKeyPrefix + saveData.saveName;
        await prefs.setString(saveKey, jsonString);
        await _updateSaveList(saveData.saveName);
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('セーブエラー: $e');
      }
      return false;
    }
  }

  /// ゲーム状態を読み込み
  static Future<WaterMarginGameState?> loadGame(String saveName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveKey = _saveKeyPrefix + saveName;
      final jsonString = prefs.getString(saveKey);

      if (jsonString == null) return null;

      final jsonData = jsonDecode(jsonString);
      final saveData = GameSaveData.fromJson(jsonData);

      return saveData.gameState;
    } catch (e) {
      if (kDebugMode) {
        print('ロードエラー: $e');
      }
      return null;
    }
  }

  /// オートセーブを読み込み
  static Future<WaterMarginGameState?> loadAutoSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_autoSaveKey);

      if (jsonString == null) return null;

      final jsonData = jsonDecode(jsonString);
      final saveData = GameSaveData.fromJson(jsonData);

      return saveData.gameState;
    } catch (e) {
      if (kDebugMode) {
        print('オートセーブロードエラー: $e');
      }
      return null;
    }
  }

  /// セーブファイル一覧を取得
  static Future<List<SaveFileInfo>> getSaveList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveNames = prefs.getStringList(_saveListKey) ?? [];

      final saveInfoList = <SaveFileInfo>[];

      for (final saveName in saveNames) {
        final saveKey = _saveKeyPrefix + saveName;
        final jsonString = prefs.getString(saveKey);

        if (jsonString != null) {
          final jsonData = jsonDecode(jsonString);
          final saveData = GameSaveData.fromJson(jsonData);

          saveInfoList.add(SaveFileInfo(
            saveName: saveData.saveName,
            saveTime: saveData.saveTime,
            turn: saveData.gameState.currentTurn,
            playerGold: saveData.gameState.playerGold,
            playerProvinces: saveData.gameState.provinces.values
                .where((p) => WaterMarginMap.initialProvinceFactions[p.name]?.name == Faction.liangshan.name)
                .length,
          ));
        }
      }

      // 保存時刻でソート（新しい順）
      saveInfoList.sort((a, b) => b.saveTime.compareTo(a.saveTime));

      return saveInfoList;
    } catch (e) {
      if (kDebugMode) {
        print('セーブ一覧取得エラー: $e');
      }
      return [];
    }
  }

  /// セーブファイルを削除
  static Future<bool> deleteSave(String saveName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveKey = _saveKeyPrefix + saveName;

      await prefs.remove(saveKey);
      await _removeSaveFromList(saveName);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('セーブ削除エラー: $e');
      }
      return false;
    }
  }

  /// オートセーブがあるかチェック
  static Future<bool> hasAutoSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_autoSaveKey);
  }

  /// セーブ一覧を更新
  static Future<void> _updateSaveList(String saveName) async {
    final prefs = await SharedPreferences.getInstance();
    final saveNames = prefs.getStringList(_saveListKey) ?? [];

    if (!saveNames.contains(saveName)) {
      saveNames.add(saveName);
      await prefs.setStringList(_saveListKey, saveNames);
    }
  }

  /// セーブ一覧から削除
  static Future<void> _removeSaveFromList(String saveName) async {
    final prefs = await SharedPreferences.getInstance();
    final saveNames = prefs.getStringList(_saveListKey) ?? [];

    saveNames.remove(saveName);
    await prefs.setStringList(_saveListKey, saveNames);
  }

  /// オートセーブ名を生成
  static String _generateAutoSaveName(WaterMarginGameState gameState) {
    final now = DateTime.now();
    return 'ターン${gameState.currentTurn}_${now.month}月${now.day}日_${now.hour}時${now.minute}分';
  }
}

/// セーブデータのモデル
class GameSaveData {
  const GameSaveData({
    required this.gameState,
    required this.saveTime,
    required this.saveName,
    required this.version,
  });

  final WaterMarginGameState gameState;
  final DateTime saveTime;
  final String saveName;
  final String version;

  Map<String, dynamic> toJson() {
    return {
      'gameState': gameState.toJson(),
      'saveTime': saveTime.toIso8601String(),
      'saveName': saveName,
      'version': version,
    };
  }

  factory GameSaveData.fromJson(Map<String, dynamic> json) {
    return GameSaveData(
      gameState: WaterMarginGameState.fromJson(json['gameState']),
      saveTime: DateTime.parse(json['saveTime']),
      saveName: json['saveName'],
      version: json['version'] ?? '1.0.0',
    );
  }
}

/// セーブファイル情報
class SaveFileInfo {
  const SaveFileInfo({
    required this.saveName,
    required this.saveTime,
    required this.turn,
    required this.playerGold,
    required this.playerProvinces,
  });

  final String saveName;
  final DateTime saveTime;
  final int turn;
  final int playerGold;
  final int playerProvinces;

  String get formattedTime {
    return '${saveTime.month}/${saveTime.day} ${saveTime.hour.toString().padLeft(2, '0')}:${saveTime.minute.toString().padLeft(2, '0')}';
  }
}
