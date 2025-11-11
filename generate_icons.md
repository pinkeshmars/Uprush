# Generate Launcher Icons

## Steps to generate launcher icons:

1. **Add your icon image:**
   - Place a 1024x1024px PNG image at `assets/icon.png`
   - Follow the design guidelines in `assets/icon_instructions.md`

2. **Run the generator:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. **The generator will create:**
   - Android launcher icons in various sizes
   - iOS app icons in various sizes  
   - Web favicon and app icons
   - Windows app icon

## Current Configuration:
- Android: Custom launcher_icon name
- iOS: Default AppIcon
- Web: Generates favicon and PWA icons with theme colors
- Windows: 48x48px icon

## Image Requirements:
Your `assets/icon.png` should be:
- 1024x1024px PNG format
- Sharp, high-contrast design
- Follows UpRush brand colors (#6B73FF primary)
- No fine details (icons are displayed small)

## Troubleshooting:
- If you get permission errors on macOS, you may need to run with `sudo`
- Make sure your image is exactly 1024x1024px
- Ensure the image has good contrast for small sizes