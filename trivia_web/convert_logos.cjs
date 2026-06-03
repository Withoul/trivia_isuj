const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const sourceDir = path.join(__dirname, '..', 'APP', 'trivia_app', 'assets', 'logotipos');
const targetDir = path.join(__dirname, 'public', 'assets', 'logotipos');

// 1. Ensure target directory exists
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

// 2. Ensure sharp is installed
try {
  require('sharp');
  console.log('sharp is already installed.');
} catch (e) {
  console.log('Installing sharp library for SVG to PNG conversion...');
  execSync('npm install --no-audit --no-fund sharp', { cwd: __dirname, stdio: 'inherit' });
}

const sharp = require('sharp');

// 3. Process files
const files = fs.readdirSync(sourceDir);

files.forEach(file => {
  if (path.extname(file).toLowerCase() === '.svg') {
    const srcPath = path.join(sourceDir, file);
    const destSvgPath = path.join(targetDir, file);
    const destPngName = path.basename(file, '.svg') + '.png';
    const destPngPath = path.join(targetDir, destPngName);

    // Copy original SVG
    fs.copyFileSync(srcPath, destSvgPath);
    console.log(`Copied SVG: ${file} -> public/assets/logotipos/`);

    // Convert SVG to PNG
    // Set width to 512 for high resolution PNG
    sharp(srcPath)
      .resize(512)
      .png()
      .toFile(destPngPath)
      .then(() => {
        console.log(`Converted to PNG: ${destPngName}`);
      })
      .catch(err => {
        console.error(`Error converting ${file}:`, err);
      });
  }
});
