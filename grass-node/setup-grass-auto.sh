#!/bin/bash
# setup-grass.sh - Grass Community Node autostart for Raspberry Pi OS Trixie
# Usage: bash setup-grass.sh

set -e

ZIP_URL="https://files.grass.io/file/grass-extension-upgrades/extension-latest/grass-community-node-linux-6.1.3.zip"
WORK_DIR="/home/pi/grass-node"
ZIP_PATH="${WORK_DIR}/grass-community-node-linux-6.1.3.zip"
CRX_PATH="${WORK_DIR}/grass-6.1.3.crx"

CHROMIUM_EXT_DIR="/home/pi/.config/chromium/External Extensions"
EXT_ID="ilehaonighjijnmpnagapkhpcdbhclfg"
EXT_VERSION="6.1.3"

echo "================================================"
echo " Grass Node - Setup dla Raspberry Pi (Trixie)"
echo "================================================"
echo ""

# --- 1. Wayland W2 ---
echo "[1/6] Ustawiam Wayland (W2) jako backend graficzny..."
sudo raspi-config nonint do_wayland W2
echo "      OK"

# --- 2. Autologin lightdm ---
echo "[2/6] Ustawiam autologin na desktop (lightdm) dla użytkownika pi..."
if [ -f /etc/lightdm/lightdm.conf ]; then
  sudo sed -i 's/^#*autologin-user=.*/autologin-user=pi/' /etc/lightdm/lightdm.conf
  sudo sed -i 's/^#*autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
else
  echo "      Ostrzeżenie: /etc/lightdm/lightdm.conf nie istnieje (sprawdź, jaki DM jest używany)"
fi
echo "      OK"

# --- 3. Pobierz i rozpakuj ZIP ---
echo "[3/6] Pobieranie Grass Community Node (ZIP)..."
mkdir -p "$WORK_DIR"
if [ ! -f "$ZIP_PATH" ]; then
  curl -L --progress-bar -o "$ZIP_PATH" "$ZIP_URL"
else
  echo "      ZIP już istnieje: $ZIP_PATH (pomijam pobieranie)"
fi

echo "      Rozpakowywanie ZIP..."
unzip -o "$ZIP_PATH" -d "$WORK_DIR" >/dev/null

if [ ! -f "$CRX_PATH" ]; then
  echo "BŁĄD: nie znaleziono pliku CRX pod: $CRX_PATH"
  ls -l "$WORK_DIR"
  exit 1
fi

chown -R pi:pi "$WORK_DIR"
echo "      OK - mam CRX: $CRX_PATH"

# --- 4. External extension dla Chromium ---
echo "[4/6] Konfiguruję Chromium external extension..."
mkdir -p "$CHROMIUM_EXT_DIR"

cat > "$CHROMIUM_EXT_DIR/${EXT_ID}.json" << EOF
{
  "external_crx": "$CRX_PATH",
  "external_version": "$EXT_VERSION"
}
EOF

chown -R pi:pi /home/pi/.config/chromium
echo "      OK - Grass będzie proponowany do instalacji przy starcie Chromium"

# --- 5. Autostart labwc + Chromium + Grass ---
echo "[5/6] Tworzę autostart labwc dla Chromium + Grass..."
mkdir -p /home/pi/.config/labwc
cat > /home/pi/.config/labwc/autostart << 'EOF'
/usr/bin/chromium \
  --noerrdialogs \
  --disable-infobars \
  --start-maximized \
  --ozone-platform=wayland \
  --password-store=basic \
  --disable-gpu \
  --disable-software-rasterizer \
  https://app.getgrass.io &
EOF

chown -R pi:pi /home/pi/.config/labwc
echo "      OK"

# --- 6. Weryfikacja ---
echo "[6/6] Weryfikacja konfiguracji..."
echo ""
echo "  lightdm autologin:"
if [ -f /etc/lightdm/lightdm.conf ]; then
  grep -E '^autologin-user' /etc/lightdm/lightdm.conf || echo "  Brak autologin-user w lightdm.conf!"
else
  echo "  Brak pliku /etc/lightdm/lightdm.conf (może być inny DM)."
fi

echo ""
echo "  labwc autostart:"
cat /home/pi/.config/labwc/autostart

echo ""
echo "  Grass CRX:"
ls -lh "$CRX_PATH"

echo ""
echo "  External extension JSON:"
cat "$CHROMIUM_EXT_DIR/${EXT_ID}.json"

echo ""
echo "================================================"
echo " GOTOWE."
echo " 1) Zrób: sudo reboot"
echo " 2) Po restarcie automatycznie wystartuje labwc + Chromium"
echo " 3) Chromium pokaże okno z pytaniem o instalację rozszerzenia Grass"
echo "    -> kliknij 'Dodaj rozszerzenie'"
echo " 4) Zaloguj się w rozszerzeniu do Grass dashboard"
echo " 5) Potem możesz ponownie zrobić reboot - node będzie startował sam"
echo "================================================"
