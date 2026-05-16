# Setup

## Unity

1. Install Unity `6000.2.14f1`.
2. Open `unity/nao vr/` from Unity Hub.
3. Open `Assets/Scenes/SampleScene.unity`.
4. Allow Unity through Windows Firewall when prompted.

Unity receives:

- Head tracker rotation on UDP `5005`.
- Controller joystick/button/MPU data on UDP `5006`.
- Optional camera hand position data on UDP `5007`.

## Firmware

Both firmware projects use PlatformIO.

Create local secrets files:

```bash
copy controller\include\secrets.example.h controller\include\secrets.h
copy head_tracking\include\secrets.example.h head_tracking\include\secrets.h
```

Edit both `secrets.h` files:

```cpp
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
#define UNITY_PC_IP IPAddress(192, 168, 1, 100)
```

Build firmware:

```bash
pio run -d controller
pio run -d head_tracking
```

Upload firmware:

```bash
pio run -d controller -t upload
pio run -d head_tracking -t upload
```

If upload fails, check the board type and COM port in each `platformio.ini`.

## Python Tracking Tools

Create local camera/network config:

```bash
copy tracking_config.example.py tracking_config.py
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run tools:

```bash
python stick_tracking.py
python hand_geastures.py
python "volume_hand _control.py"
```

Use `test.py` to inspect head-tracker packets and `test2.py` to inspect controller packets.

## Flutter Companion App

```bash
cd nao_vr
flutter pub get
flutter analyze
flutter run
```
