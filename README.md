# NAO VR

NAO VR is a Unity VR game prototype built around custom hardware: an ESP32-based handle/controller, an ESP32-S2 head tracker, and optional camera-based hand tracking utilities.

The project is organized as a complete prototype repository: Unity gameplay, firmware, Python tracking tools, and a Flutter companion app live together so the game and hardware can be developed as one system.

## Project Layout

| Path | Purpose |
| --- | --- |
| `unity/nao vr/` | Main Unity project. Built with Unity `6000.2.14f1`, URP, Input System, and UDP tracking scripts. |
| `controller/` | PlatformIO firmware for the ESP32 handle/controller with joystick, button, and MPU6050 motion data. |
| `head_tracking/` | PlatformIO firmware for the ESP32-S2 head tracker using MPU6050 + Madgwick orientation filtering. |
| `stick_tracking.py` | OpenCV color tracker that sends hand/ball position data to Unity over UDP. |
| `hand_geastures.py` | MediaPipe hand gesture experiment. |
| `volume_hand _control.py` | MediaPipe hand-distance/gesture experiment. |
| `test.py`, `test2.py` | UDP listener utilities for testing head tracker and controller packets. |
| `nao_vr/` | Flutter companion/social app prototype for the VR project. |
| `docs/` | Setup, upload, and protocol notes. |

## System Overview

The hardware sends motion and input packets over Wi-Fi to the PC running Unity.

| Signal | Sender | Receiver | UDP Port | Format |
| --- | --- | --- | --- | --- |
| Head rotation | `head_tracking` ESP32-S2 | `IMU_HeadTracking.cs` | `5005` | `pitch,roll,yaw` |
| Handle movement/input | `controller` ESP32 | `JoystickController.cs` | `5006` | `pitch,roll,yaw,stickX,stickY,button` |
| Camera hand position | `stick_tracking.py` | `FreeHandController.cs` | `5007` | `x,y,z` normalized values |

## Quick Start

1. Open the Unity project from `unity/nao vr/` using Unity `6000.2.14f1`.
2. Copy `controller/include/secrets.example.h` to `controller/include/secrets.h` and set your Wi-Fi name, password, and Unity PC IP.
3. Copy `head_tracking/include/secrets.example.h` to `head_tracking/include/secrets.h` and set the same network values.
4. Copy `tracking_config.example.py` to `tracking_config.py` and update the phone camera URL if using the Python camera tracker.
5. Install Python dependencies:

```bash
pip install -r requirements.txt
```

6. Build or upload the firmware with PlatformIO:

```bash
pio run -d controller
pio run -d head_tracking
```

7. Start the Unity scene at `Assets/Scenes/SampleScene.unity`, then run any needed helper:

```bash
python stick_tracking.py
python test.py
python test2.py
```

## GitHub Readiness

This repository is prepared for GitHub:

- Unity `Library`, `Temp`, `Logs`, user settings, and generated IDE files are ignored.
- PlatformIO `.pio` build caches are ignored.
- Flutter build output and Dart tool caches are ignored.
- Local Wi-Fi credentials and camera URLs are kept in ignored local config files.
- Upload-blocking generated files larger than 100 MB are ignored.
- Large binary art/media files are configured for Git LFS.
- Unity text assets are configured for cleaner Git diffs and merges.

Before making a public repository, review `THIRD_PARTY_NOTICES.md` and confirm that every Unity asset can legally be redistributed publicly. If you are not sure, use a private GitHub repository.

## Development Notes

- Unity listens on the PC. Make sure Windows Firewall allows Unity to receive UDP packets on ports `5005`, `5006`, and `5007`.
- The ESP32 devices and PC should be on the same Wi-Fi network.
- The Unity scene expects the firmware packet formats documented in `docs/UDP_PROTOCOL.md`.
- `secrets.h` and `tracking_config.py` are intentionally ignored. Keep your real local values there.

## License

See `LICENSE`. Third-party Unity assets keep their original licenses and are not relicensed by this repository.
