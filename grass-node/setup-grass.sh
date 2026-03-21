#!/bin/bash
# setup-grass.sh - Grass Node autostart setup for Raspberry Pi OS Trixie (Debian 13)
# Repo: https://github.com/hattimon/rpi-connect/tree/main/grass-node
# Usage: bash setup-grass.sh

set -e

CRX_URL="https://raw.githubusercontent.com/hattimon/rpi-connect/main/grass-node/grass-6.1.3.crx"
CRX_PATH="/home/pi/grass-node/grass-6.1.3.crx"
CHROMIUM_EXT_DIR="/home/pi/.config/chromium/External Extensions"
EXT_ID="ilehaonighjijnmpnagapkhpcdbhclfg"

echo "================================================"
echo " Grass Node - Setup dla Raspberry Pi (Trixie)"
echo "================================================"
echo ""

# --- 1. Wayland W2 ---
echo "[1/6] Ustawiam Wayland (W2) jako backend graficzny..."
sudo raspi-config nonint do_wayland W2
echo "      OK"

# --- 2. Autologin lightdm ---
echo "[2/6] Ustawiam autologin na desktop (lightdm) dla uzytkownika pi..."
sudo sed -i 's/^#*autologin-user=.*/autologin-user=pi/' /etc/lightdm/lightdm.conf
sudo sed -i 's/^#*autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
echo "      OK"

# --- 3. Pobierz wtyczke CRX ---
echo "[3/6] Pobieranie wtyczki Grass Node (CRX)..."
mkdir -p /home/pi/grass-node
if [ ! -f "$CRX_PATH" ]; then
  curl -L --progress-bar -o "$CRX_PATH" "$CRX_URL"
  echo "      Pobrano: $CRX_PATH"
else
  echo "      Plik juz istnieje: $CRX_PATH (pomijam)"
fi

# --- 4. Zainstaluj wtyczke CRX do Chromium ---
echo "[4/6] Instalowanie wtyczki Grass do Chromium..."
mkdir -p "$CHROMIUM_EXT_DIR"
cat > "$CHROMIUM_EXT_DIR/${EXT_ID}.json" << EOF
{
  "external_crx": "$CRX_PATH",
  "external_version": "6.1.3"
}
EOF
echo "      OK - wtyczka zostanie zaladowana przy pierwszym starcie Chromium"

# --- 5. Autostart labwc (Wayland compositor) ---
echo "[5/6] Tworzenie autostartu labwc dla Chromium + Grass..."
mkdir -p /home/pi/.config/labwc
cat > /home/pi/.config/labwc/autostart << 'EOF'
/usr/bin/chromium --noerrdialogs --disable-infobars --start-maximized --ozone-platform=wayland --password-store=basic --disable-gpu --disable-software-rasterizer https://app.getgrass.io &
EOF
# Usun stare autostary LXDE jesli istnieja
rm -f /home/pi/.config/lxsession/LXDE-pi/autostart
rm -f /home/pi/.config/lxsession/rpd-x/autostart
echo "      OK"

# --- 6. Weryfikacja ---
echo "[6/6] Weryfikacja konfiguracji..."
echo ""
echo "  lightdm autologin:"
grep -E '^autologin-user' /etc/lightdm/lightdm.conf || echo "  BLAD: brak autologin w lightdm.conf!"
echo ""
echo "  labwc autostart:"
cat /home/pi/.config/labwc/autostart
echo ""
echo "  wtyczka Grass:"
ls -lh "$CRX_PATH" 2>/dev/null && echo "  JSON: $(cat \"$CHROMIUM_EXT_DIR/${EXT_ID}.json\")" || echo "  BLAD: brak pliku CRX!"

echo ""
echo "================================================"
echo " GOTOWE! Wykonaj: sudo reboot"
echo " Po restarcie Chromium uruchomi sie automatycznie"
echo " z wtyczka Grass Node i polaczem z app.getgrass.io"
echo "================================================"
