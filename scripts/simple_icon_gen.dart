import 'dart:io';

/// シンプルな水滸伝ゲーム用アイコンジェネレーター
void main() {
  print('🎨 水滸伝ゲーム用アイコンを生成中...');
  
  // アイコンディレクトリを作成
  final iconDir = Directory('assets/icons');
  if (!iconDir.existsSync()) {
    iconDir.createSync(recursive: true);
  }

  // 512x512のアイコンを生成
  final icon512 = generateIconSVG(512);
  File('assets/icons/icon-512.svg').writeAsStringSync(icon512);
  print('✨ 生成: assets/icons/icon-512.svg');

  // 192x192のアイコンを生成
  final icon192 = generateIconSVG(192);
  File('assets/icons/icon-192.svg').writeAsStringSync(icon192);
  print('✨ 生成: assets/icons/icon-192.svg');

  // フォアグラウンド用アイコンを生成（Android Adaptive Icon用）
  final iconForeground = generateForegroundSVG(432);
  File('assets/icons/icon-foreground.svg').writeAsStringSync(iconForeground);
  print('✨ 生成: assets/icons/icon-foreground.svg');
  
  print('✅ アイコン生成完了!');
}

String generateIconSVG(int size) {
  return '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 $size $size">
  <defs>
    <radialGradient id="bg" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#4CAF50"/>
      <stop offset="100%" stop-color="#2E7D32"/>
    </radialGradient>
    <linearGradient id="mountain" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#8D6E63"/>
      <stop offset="100%" stop-color="#5D4037"/>
    </linearGradient>
  </defs>
  
  <!-- 背景円 -->
  <circle cx="${size ~/ 2}" cy="${size ~/ 2}" r="${size ~/ 2 - 4}" fill="url(#bg)" stroke="#1B5E20" stroke-width="4"/>
  
  <!-- 梁山（山） -->
  <path d="M${size * 0.15} ${size * 0.75} L${size * 0.3} ${size * 0.4} L${size * 0.5} ${size * 0.5} L${size * 0.7} ${size * 0.4} L${size * 0.85} ${size * 0.75} Z" 
        fill="url(#mountain)" stroke="#3E2723" stroke-width="2"/>
  
  <!-- 湖水 -->
  <ellipse cx="${size * 0.5}" cy="${size * 0.78}" rx="${size * 0.3}" ry="${size * 0.1}" 
           fill="#1976D2" stroke="#0D47A1" stroke-width="2"/>
  
  <!-- 城塞 -->
  <rect x="${size * 0.45}" y="${size * 0.4}" width="${size * 0.1}" height="${size * 0.2}" 
        fill="#8D6E63" stroke="#3E2723" stroke-width="2"/>
  
  <!-- 旗 -->
  <line x1="${size * 0.55}" y1="${size * 0.25}" x2="${size * 0.55}" y2="${size * 0.45}" 
        stroke="#3E2723" stroke-width="3"/>
  <path d="M${size * 0.55} ${size * 0.25} L${size * 0.75} ${size * 0.3} L${size * 0.55} ${size * 0.38} Z" 
        fill="#F44336" stroke="#B71C1C" stroke-width="1"/>
  
  <!-- 中央のシンボル -->
  <circle cx="${size * 0.5}" cy="${size * 0.5}" r="${size * 0.06}" 
          fill="#FFD700" stroke="#FF8F00" stroke-width="2"/>
  <text x="${size * 0.5}" y="${size * 0.52}" text-anchor="middle" 
        font-family="serif" font-size="${size * 0.05}" font-weight="bold" fill="#8D6E63">忠</text>
</svg>''';
}

String generateForegroundSVG(int size) {
  return '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 $size $size">
  <defs>
    <linearGradient id="mountain" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#8D6E63"/>
      <stop offset="100%" stop-color="#5D4037"/>
    </linearGradient>
  </defs>
  
  <!-- 梁山（山） - 中央配置 -->
  <path d="M${size * 0.25} ${size * 0.7} L${size * 0.35} ${size * 0.45} L${size * 0.5} ${size * 0.55} L${size * 0.65} ${size * 0.45} L${size * 0.75} ${size * 0.7} Z" 
        fill="url(#mountain)" stroke="#3E2723" stroke-width="3"/>
  
  <!-- 城塞 -->
  <rect x="${size * 0.47}" y="${size * 0.45}" width="${size * 0.06}" height="${size * 0.15}" 
        fill="#8D6E63" stroke="#3E2723" stroke-width="2"/>
  
  <!-- 旗 -->
  <line x1="${size * 0.53}" y1="${size * 0.35}" x2="${size * 0.53}" y2="${size * 0.5}" 
        stroke="#3E2723" stroke-width="3"/>
  <path d="M${size * 0.53} ${size * 0.35} L${size * 0.68} ${size * 0.4} L${size * 0.53} ${size * 0.47} Z" 
        fill="#F44336" stroke="#B71C1C" stroke-width="1"/>
  
  <!-- シンボル -->
  <circle cx="${size * 0.5}" cy="${size * 0.52}" r="${size * 0.05}" 
          fill="#FFD700" stroke="#FF8F00" stroke-width="2"/>
  <text x="${size * 0.5}" y="${size * 0.545}" text-anchor="middle" 
        font-family="serif" font-size="${size * 0.04}" font-weight="bold" fill="#8D6E63">忠</text>
</svg>''';
}
