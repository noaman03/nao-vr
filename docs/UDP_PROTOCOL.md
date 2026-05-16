# UDP Protocol

Unity receives all live hardware/tracking data over UDP.

## Head Tracker

- Sender: `head_tracking`
- Unity receiver: `IMU_HeadTracking.cs`
- Port: `5005`
- Packet: comma-separated floats or whole-number floats

```text
pitch,roll,yaw
```

Example:

```text
12,3,-45
```

## Controller

- Sender: `controller`
- Unity receiver: `JoystickController.cs`
- Port: `5006`
- Packet: pitch, roll, yaw, joystick X, joystick Y, button state

```text
pitch,roll,yaw,stickX,stickY,button
```

Example:

```text
1.20,-0.75,34.10,2048,1800,1
```

Button state uses ESP32 pull-up logic:

- `0`: pressed
- `1`: not pressed

## Camera Hand Tracking

- Sender: `stick_tracking.py`
- Unity receiver: `FreeHandController.cs`
- Port: `5007`
- Packet: normalized X, Y, Z

```text
x,y,z
```

Example:

```text
0.5123,0.4231,0.2000
```

When the tracked object is not detected, the Python tracker sends:

```text
-1.0000,-1.0000,-1.0000
```
