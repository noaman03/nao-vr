# Contributing

This repository contains Unity gameplay, ESP32 firmware, Python tracking tools, and a Flutter companion app. Keep changes focused to the part of the system you are working on.

## Before Committing

- Do not commit Unity `Library`, `Temp`, `Logs`, or user settings.
- Do not commit PlatformIO `.pio` folders.
- Do not commit Flutter build output.
- Do not commit `secrets.h`, `tracking_config.py`, or `.env` files.
- Test packet compatibility when changing firmware or Unity UDP scripts.

## Useful Checks

```bash
pio run -d controller
pio run -d head_tracking
python -m py_compile stick_tracking.py hand_geastures.py test.py test2.py
flutter analyze
```

Run the Flutter command from `nao_vr/`.
