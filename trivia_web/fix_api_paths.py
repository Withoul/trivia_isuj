import os
import glob
import shutil

api_dir = r"C:\Users\User\Desktop\clon trivia\trivia_isuj\Server\api"
inner_api_dir = os.path.join(api_dir, "api")

# Get all php files in inner_api_dir
php_files = glob.glob(os.path.join(inner_api_dir, "*.php"))

for file_path in php_files:
    file_name = os.path.basename(file_path)
    dest_path = os.path.join(api_dir, file_name)
    
    # Read content
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Replace require_once __DIR__ . '/../config/database.php';
    # with require_once __DIR__ . '/config/database.php';
    content = content.replace("'/../config/", "'/config/")
    
    # Write to destination
    with open(dest_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print(f"Moved and updated {file_name}")

# Remove inner api folder
shutil.rmtree(inner_api_dir)
print("Removed inner api folder.")
