import 'package:flutter/material.dart';

/// 水滸伝戦略ゲーム用アイコン生成器
/// 梁山泊をモチーフにした中国古典風のアイコンを生成
class WaterMarginIconGenerator {
  /// アイコンのベースカラーパレット
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color white = Color(0xFFFFFFFF);

  /// SVG形式のアイコンを生成
  static String generateSVGIcon(int size) {
    final double iconSize = size.toDouble();
    final double centerX = iconSize / 2;
    final double centerY = iconSize / 2;
    final double radius = iconSize * 0.45;

    return '''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="$size" height="$size" viewBox="0 0 $size $size" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="bgGradient" cx="50%" cy="50%" r="50%">
      <stop offset="0%" style="stop-color:${_colorToHex(lightGreen)};stop-opacity:1" />
      <stop offset="100%" style="stop-color:${_colorToHex(primaryGreen)};stop-opacity:1" />
    </radialGradient>
    <linearGradient id="mountainGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:${_colorToHex(accentGold)};stop-opacity:1" />
      <stop offset="50%" style="stop-color:${_colorToHex(primaryGreen)};stop-opacity:1" />
      <stop offset="100%" style="stop-color:${_colorToHex(darkGreen)};stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- 背景円 -->
  <circle cx="$centerX" cy="$centerY" r="$radius" fill="url(#bgGradient)" stroke="${_colorToHex(darkGreen)}" stroke-width="${iconSize * 0.02}"/>
  
  <!-- 梁山泊の山々 -->
  <path d="M ${iconSize * 0.15} ${iconSize * 0.75} 
           L ${iconSize * 0.3} ${iconSize * 0.35}
           L ${iconSize * 0.45} ${iconSize * 0.55}
           L ${iconSize * 0.55} ${iconSize * 0.25}
           L ${iconSize * 0.7} ${iconSize * 0.45}
           L ${iconSize * 0.85} ${iconSize * 0.75}
           Z" 
           fill="url(#mountainGradient)" 
           stroke="${_colorToHex(darkGreen)}" 
           stroke-width="${iconSize * 0.01}"/>
  
  <!-- 水面（湖） -->
  <ellipse cx="$centerX" cy="${iconSize * 0.78}" rx="${iconSize * 0.25}" ry="${iconSize * 0.08}" 
           fill="${_colorToHex(Color(0xFF1976D2))}" 
           opacity="0.7"/>
  
  <!-- 城塞（要塞） -->
  <rect x="${iconSize * 0.47}" y="${iconSize * 0.4}" width="${iconSize * 0.06}" height="${iconSize * 0.2}" 
        fill="${_colorToHex(accentGold)}" 
        stroke="${_colorToHex(darkGreen)}" 
        stroke-width="${iconSize * 0.005}"/>
  
  <!-- 旗 -->
  <rect x="${iconSize * 0.505}" y="${iconSize * 0.3}" width="${iconSize * 0.03}" height="${iconSize * 0.15}" 
        fill="${_colorToHex(Color(0xFFD32F2F))}"/>
        
  <!-- 中国風装飾円 -->
  <circle cx="$centerX" cy="${iconSize * 0.2}" r="${iconSize * 0.04}" 
          fill="${_colorToHex(accentGold)}" 
          stroke="${_colorToHex(darkGreen)}" 
          stroke-width="${iconSize * 0.01}"/>
</svg>
''';
  }

  /// アダプティブアイコン用のフォアグラウンド
  static String generateForegroundSVG(int size) {
    final double iconSize = size.toDouble();
    final double padding = iconSize * 0.2; // アダプティブアイコン用のパディング

    return '''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="$size" height="$size" viewBox="0 0 $size $size" xmlns="http://www.w3.org/2000/svg">
  <g transform="translate($padding, $padding)">
    ${_generateIconElements(iconSize - padding * 2)}
  </g>
</svg>
''';
  }

  /// アダプティブアイコン用の背景
  static String generateBackgroundSVG(int size) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="$size" height="$size" viewBox="0 0 $size $size" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="adaptiveBg" cx="50%" cy="50%" r="70%">
      <stop offset="0%" style="stop-color:${_colorToHex(lightGreen)};stop-opacity:1" />
      <stop offset="100%" style="stop-color:${_colorToHex(primaryGreen)};stop-opacity:1" />
    </radialGradient>
  </defs>
  <rect width="$size" height="$size" fill="url(#adaptiveBg)"/>
</svg>
''';
  }

  static String _generateIconElements(double size) {
    return '''
    <!-- 梁山泊の山々 -->
    <path d="M ${size * 0.1} ${size * 0.8} 
             L ${size * 0.25} ${size * 0.3}
             L ${size * 0.4} ${size * 0.5}
             L ${size * 0.5} ${size * 0.2}
             L ${size * 0.6} ${size * 0.4}
             L ${size * 0.75} ${size * 0.5}
             L ${size * 0.9} ${size * 0.8}
             Z" 
             fill="${_colorToHex(accentGold)}" 
             stroke="${_colorToHex(darkGreen)}" 
             stroke-width="${size * 0.01}"/>
    
    <!-- 城塞 -->
    <rect x="${size * 0.47}" y="${size * 0.35}" width="${size * 0.06}" height="${size * 0.25}" 
          fill="${_colorToHex(Color(0xFFFF8F00))}" 
          stroke="${_colorToHex(darkGreen)}" 
          stroke-width="${size * 0.005}"/>
    
    <!-- 旗 -->
    <rect x="${size * 0.505}" y="${size * 0.25}" width="${size * 0.03}" height="${size * 0.15}" 
          fill="${_colorToHex(Color(0xFFD32F2F))}"/>
    ''';
  }

  /// Colorを16進数文字列に変換
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

/// アイコン生成の使用例
void main() {
  print('192pxアイコン:');
  print(WaterMarginIconGenerator.generateSVGIcon(192));
  
  print('\n512pxアイコン:');
  print(WaterMarginIconGenerator.generateSVGIcon(512));
  
  print('\nアダプティブフォアグラウンド:');
  print(WaterMarginIconGenerator.generateForegroundSVG(432));
  
  print('\nアダプティブ背景:');
  print(WaterMarginIconGenerator.generateBackgroundSVG(432));
}
