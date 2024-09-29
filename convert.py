import os
from PIL import Image

# Quick and dirty converter from TIFF to JPG

input_dir = "data/images"
output_dir = "data/images_jpg"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

for filename in os.listdir(input_dir):
    if filename.endswith(".tiff") or filename.endswith(".tif"):
        img_path = os.path.join(input_dir, filename)
        img = Image.open(img_path)
        
        # Save the image as JPG
        jpg_filename = os.path.splitext(filename)[0] + ".jpg"
        output_path = os.path.join(output_dir, jpg_filename)
        
        img.convert("RGB").save(output_path, "JPEG")
        print(f"Converted {filename} to {jpg_filename}")

print("Conversion complete!")
