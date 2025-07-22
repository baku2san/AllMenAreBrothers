from PIL import Image

# 入力画像ファイル名（添付画像を保存したパスに変更してください）
INPUT_PATH = 'assets/map/china_outline_new.png'  # 新しい地図画像（添付画像）を保存したパス
OUTPUT_PATH = 'assets/map/china_outline_dot.bmp'

# ドット絵風の解像度（例：64x64）
DOT_SIZE = 64
PALETTE_COLORS = 16

# 画像読み込み
img = Image.open(INPUT_PATH)

# 低解像度化
img_small = img.resize((DOT_SIZE, DOT_SIZE), Image.NEAREST)

# 再拡大（元サイズに戻す）
img_pixel = img_small.resize(img.size, Image.NEAREST)

# 減色（パレット化）
img_palette = img_pixel.convert('P', palette=Image.ADAPTIVE, colors=PALETTE_COLORS)

# BMP形式で保存
img_palette.save(OUTPUT_PATH)

print(f"ドット絵風BMP画像を保存しました: {OUTPUT_PATH}")
