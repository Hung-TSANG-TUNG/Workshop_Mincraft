#!/bin/bash
set -Eeuo pipefail
cd "$(dirname "$(readlink -f "$0")")"

appimage_file="./AZ-Launcher_x86_64.AppImage"
appicon_file="./icon.png"
app_dir="${HOME}/.local/bin"

# Pre-conditions checks
if [ ! -f "$appimage_file" ]; then
  echo "Error: AppImage is missing ${appimage_file}" >&2
  exit 1
fi

# Copy the AppImage
[ ! -d "$app_dir" ] && echo "Creating app directory... (${app_dir})" && mkdir -p "$app_dir"
bin_file="${app_dir}/$(basename "$appimage_file")"
echo "Copying app image... (${appimage_file} -> ${bin_file})"
cp "$appimage_file" "$bin_file"
chmod 755 "$bin_file"

# Copy icon(s)
if [ -f "$appicon_file" ]; then
  icons_dir="${HOME}/.local/share/icons/hicolor/256x256/apps"
  [ ! -d "$icons_dir" ] && echo "Creating icons directory... (${icons_dir})" && mkdir -p "$icons_dir"
  echo "Copying 256x256 icon... (${icons_dir}/az-launcher.png)"
  cp "$appicon_file" "${icons_dir}/az-launcher.png"
else
  echo "Warn: Icon is missing ${appicon_file}"
fi

# Create desktop file
desktop_apps_dir="${HOME}/.local/share/applications"
[ ! -d "$app_dir" ] && echo "Creating desktop applications directory... (${desktop_apps_dir})" && \
  mkdir -p "$desktop_apps_dir"
desktop_file="${desktop_apps_dir}/az-launcher.desktop"
desktop_exec="\"$(printf %q "$bin_file")\""
if [ -n "${AZ_CLIENT_UPDATE_SOURCE:-}" ]; then
  echo "Add the current AZ_CLIENT_UPDATE_SOURCE to the desktop file!"
  desktop_exec="env AZ_CLIENT_UPDATE_SOURCE=\"$(printf %q "$AZ_CLIENT_UPDATE_SOURCE")\" ${desktop_exec}"
fi
echo "Creating desktop file... ($desktop_file)"
cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=AZ Launcher - Minecraft
Icon=az-launcher
Exec=${desktop_exec}
Comment=A Minecraft Modpack
Categories=Game;
Terminal=false
EOF

if [ -f "${desktop_apps_dir}/pactify-launcher.desktop" ]; then
  echo "Deleting old desktop file... (${desktop_apps_dir}/pactify-launcher.desktop)"
  rm -f "${desktop_apps_dir}/pactify-launcher.desktop" || true
fi

xdg-desktop-menu forceupdate --mode user >/dev/null 2>&1 || true

# Finish message
echo
echo
echo "AZ Launcher installed successfully!"
echo "- The application image has been copied to:"
echo "  \"$(printf %q "${bin_file}")\""
echo "- A desktop file has been created too, so you can start the launcher from your"
echo "  menu."
echo
echo "Have fun!"
exit 0
