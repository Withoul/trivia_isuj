import os
import shutil
import glob

brain_dir = r"C:\Users\User\.gemini\antigravity-ide\brain\6718ddf4-7e82-4bf6-a714-d81d77d24c9e"
dest_dir = r"C:\Users\User\Desktop\clon trivia\trivia_isuj\trivia_web\public\assets\avatars"
os.makedirs(dest_dir, exist_ok=True)

mapping = {
    'ai_ball': 'ball.png',
    'ai_gloves': 'gloves.png',
    'ai_trophy': 'trophy.png',
    'ai_boot': 'boot.png'
}

for prefix, dest_name in mapping.items():
    pattern = os.path.join(brain_dir, f"{prefix}_*.png")
    matches = glob.glob(pattern)
    if matches:
        latest = max(matches, key=os.path.getctime)
        shutil.copy2(latest, os.path.join(dest_dir, dest_name))
        print(f"Copied {latest} to {dest_name}")
