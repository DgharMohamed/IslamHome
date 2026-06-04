import os
import glob
from PIL import Image, ImageDraw

folder = r"c:\Users\Batman\Desktop\Portfolio Projects\IslamicLibraryApp\islamic_library_flutter\Screenshots"
files = glob.glob(os.path.join(folder, "MuMu-*.png"))
files.sort()

cols = 6
rows = (len(files) + cols - 1) // cols
w, h = 400, 800

grid_img = Image.new('RGB', (cols * w, rows * h), color='white')

for i, f in enumerate(files):
    try:
        img = Image.open(f)
        img.thumbnail((w, h))
        x = (i % cols) * w
        y = (i // cols) * h
        grid_img.paste(img, (x, y))
        
        draw = ImageDraw.Draw(grid_img)
        basename = os.path.basename(f)
        draw.rectangle([x, y, x+w, y+30], fill="black")
        draw.text((x + 10, y + 10), basename, fill="white")
    except Exception as e:
        print(f"Error processing {f}: {e}")

out_path = os.path.join(folder, "grid_new.jpg")
grid_img.save(out_path, quality=85)
print(f"Grid saved to {out_path}")
