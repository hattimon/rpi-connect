#!/bin/bash
# setup-grass.sh - Grass Node autostart setup for Raspberry Pi OS Trixie (Debian 13)
# Usage: bash setup-grass.sh

set -e

CRX_URL="https://raw.githubusercontent.com/hattimon/rpi-connect/main/grass-node/grass-6.1.3.crx"
CRX_PATH="/home/pi/grass-node/grass-6.1.3.crx"

echo "================================================"
echo " Grass Node - Setup dla Raspberry Pi (Trixie)"
echo "================================================"
echo ""

# --- 1. Wayland W2 ---
echo "[1/4] Ustawiam Wayland (W2) jako backend graficzny..."
sudo raspi-config nonint do_wayland W2
echo "      OK"

# --- 2. Autologin lightdm ---
echo "[2/4] Ustawiam autologin na desktop (lightdm) dla uzytkownika pi..."
if [ -f /etc/lightdm/lightdm.conf ]; then
  sudo sed -i 's/^#*autologin-user=.*/autologin-user=pi/' /etc/lightdm/lightdm.conf
  sudo sed -i 's/^#*autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
else
  echo "      Ostrzezenie: /etc/lightdm/lightdm.conf nie istnieje (sprawdz jaki DM jest uzywany)"
fi
echo "      OK"

# --- 3. Pobierz wtyczke CRX (kopii zapasowa) ---
echo "[3/4] Pobieranie wtyczki Grass Node (CRX) do katalogu roboczego..."
mkdir -p /home/pi/grass-node
if [ ! -f "$CRX_PATH" ]; then
  curl -L --progress-bar -o "$CRX_PATH" "$CRX_URL"
  echo "      Pobrano: $CRX_PATH"
else
  echo "      Plik juz istnieje: $CRX_PATH (pomijam)"
fi
chown -R pi:pi /home/pi/grass-node

# --- 4. Autostart labwc (Wayland compositor) ---
echo "[4/4] Tworzenie autostartu labwc dla Chromium + Grass..."
mkdir -p /home/pi/.config/labwc
cat > /home/pi/.config/labwc/autostart << 'EOF'
/usr/bin/chromium --noerrdialogs --disable-infobars --start-maximized \
  --ozone-platform=wayland --password-store=basic \
  --disable-gpu --disable-software-rasterizer \
  https://app.getgrass.io &
EOF

echo "      OK"

# --- Weryfikacja ---
echo ""
echo "Weryfikacja konfiguracji:"
echo "  lightdm autologin:"
if [ -f /etc/lightdm/lightdm.conf ]; then
  grep -E '^autologin-user' /etc/lightdm/lightdm.conf || echo "  BLAD: brak autologin-user w lightdm.conf!"
else
  echo "  Brak /etc/lightdm/lightdm.conf (byc moze inny DM)."
fi

echo ""
echo "  labwc autostart:"
cat /home/pi/.config/labwc/autostart

echo ""
echo "  katalog z CRX:"
ls -lh /home/pi/grass-node || echo "  Brak katalogu /home/pi/grass-node"

echo ""
echo "================================================"
echo " GOTOWE!"
echo " 1) Najpierw recznie zainstaluj Grass (grass-6.1.3.crx) w Chromium"
echo "    w trybie Developer mode i zaloguj sie w rozszerzeniu."
echo " 2) Potem uruchom ten skrypt: bash setup-grass.sh"
echo " 3) Na koniec: sudo reboot"
echo " Po restarcie Chromium uruchomi sie automatycznie"
echo " z dashboardem app.getgrass.io, a node bedzie pracowal w tle."
echo "================================================"
