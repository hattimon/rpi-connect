Raspberry Pi Connect Scripts 

---
## Instalacja Grass Node na Raspberry Pi (jako node)

1. Pobierasz wtyczke z [grass-linux](https://app.grass.io/dashboard/download/item/extension)

![instalacja](grass-node/grass1.png)
![instalacja](grass-node/grass2.png)

2. Dodajesz wtyczke do chromium:

![instalacja](grass-node/grass1-rpi3.png)
![instalacja](grass-node/grass2-rpi3.png)   
 
![instalacja](grass-node/grass4-rpi3.png)   
![instalacja](grass-node/grass5-rpi3.png)   
![instalacja](grass-node/grass6-rpi3.png)   
![instalacja](grass-node/grass7-rpi3.png)   
![instalacja](grass-node/grass8-rpi3.png)   
...logujesz do panelu
![instalacja](grass-node/grass3-rpi3.png)

Pobierz i uruchom skrypt instalacyjny jednym poleceniem:

```bash
curl -L https://raw.githubusercontent.com/hattimon/rpi-connect/main/grass-node/setup-grass.sh | bash
```

Restartujesz urządzenie:
```bash
sudo reboot
```
![instalacja](grass-node/grass-rpi3.png)

GOTOWE!
Automatycznie przy starcie startuje chromium z wtyczką grass w tle.

