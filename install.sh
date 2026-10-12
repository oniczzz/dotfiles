#!/usr/bin/env bash
set -euo pipefail

RICE="${1:-ember}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
R="$DIR/rices/$RICE"

if [ ! -d "$R" ]; then
  echo "Нет такого райса: $RICE. Доступные:"; ls "$DIR/rices"; exit 1
fi

echo ">> Пакеты"
sudo pacman -S --needed --noconfirm base-devel git niri kitty xwayland-satellite \
  xdg-desktop-portal-gnome noctalia upower fastfetch cava python \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra \
  pipewire pipewire-pulse wireplumber sddm qt6-svg qt6-virtualkeyboard \
  qt6-multimedia-ffmpeg adwaita-icon-theme

if ! command -v yay >/dev/null; then
  echo ">> yay"
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
fi
yay -S --needed --noconfirm bibata-cursor-theme-bin

echo ">> Конфиги"
cd "$R/home"
while IFS= read -r -d '' f; do
  f="${f#./}"
  dest="$HOME/$f"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then mv "$dest" "$dest.bak"; fi
  ln -sfn "$R/home/$f" "$dest"
done < <(find . -type f -print0)
cd "$DIR"

[ -f "$HOME/.config/fastfetch/gen_logo.py" ] && python3 "$HOME/.config/fastfetch/gen_logo.py"

if [ -d "$R/sddm" ]; then
  echo ">> SDDM"
  T=/usr/share/sddm/themes/sddm-astronaut-theme
  if [ ! -f "$T/Main.qml" ]; then
    sudo rm -rf "$T"
    sudo git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git "$T"
  fi
  sudo cp -r "$T/Fonts/"* /usr/share/fonts/ && fc-cache -f
  sudo cp "$R/sddm/theme.conf" "$T/Themes/$RICE.conf"
  sudo cp "$R/sddm/background.png" "$T/Backgrounds/$RICE.png"
  sudo sed -i "s|^Background *=.*|Background=\"Backgrounds/$RICE.png\"|" "$T/Themes/$RICE.conf"
  sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/$RICE.conf|" "$T/metadata.desktop"
  sudo cp "$R/sddm/sddm.conf" /etc/sddm.conf
  sudo mkdir -p /etc/sddm.conf.d
  printf '[General]\nInputMethod=qtvirtualkeyboard\n' | sudo tee /etc/sddm.conf.d/virtualkbd.conf >/dev/null
  sudo systemctl enable sddm
fi

echo "Готово: райс '$RICE'. Выйди из niri и зайди заново."
