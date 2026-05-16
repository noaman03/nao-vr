import cv2
import mediapipe as mp
import math
import numpy as np
import os

try:
    from tracking_config import MOBILE_CAMERA_URL
except ImportError:
    MOBILE_CAMERA_URL = "http://YOUR_PHONE_IP:4747/video"

# solution APIs
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands

# Initial bar values
volBar, volPer = 400, 0
saved_value = None
is_locked = False

# Mobile camera Setup
wCam, hCam = 640, 480
cam = cv2.VideoCapture(os.getenv("MOBILE_CAMERA_URL", MOBILE_CAMERA_URL))
cam.set(3,wCam)
cam.set(4,hCam)

# Mediapipe Hand Landmark Model
with mp_hands.Hands(
    model_complexity=0,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5) as hands:

  while cam.isOpened():
    success, image = cam.read()



    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = hands.process(image)
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
    if results.multi_hand_landmarks:
      for hand_landmarks in results.multi_hand_landmarks:
        mp_drawing.draw_landmarks(
            image,
            hand_landmarks,
            mp_hands.HAND_CONNECTIONS,
            mp_drawing_styles.get_default_hand_landmarks_style(),
            mp_drawing_styles.get_default_hand_connections_style()
            )

    # multi_hand_landmarks method for Finding postion of Hand landmarks      
    lmList = []
    if results.multi_hand_landmarks:
      myHand = results.multi_hand_landmarks[0]
      for id, lm in enumerate(myHand.landmark):
        h, w, c = image.shape
        cx, cy = int(lm.x * w), int(lm.y * h)
        lmList.append([id, cx, cy])          

    # Gesture detection (only when hand is present)
    if len(lmList) != 0:
      # Check for pinky (little finger) extended to save
      pinky_tip_y = lmList[20][2]
      pinky_pip_y = lmList[18][2]
      
      # Check for thumbs down to unlock
      thumb_tip_y = lmList[4][2]
      thumb_base_y = lmList[2][2]
      index_tip_y = lmList[8][2]
      index_pip_y = lmList[6][2]
      
      # Pinky up - save and lock
      if pinky_tip_y < pinky_pip_y:
        if not is_locked:
          saved_value = int(volPer)
          is_locked = True
          print(f"Pinky up - saved value: {saved_value}%")
      
      # Thumbs down - unlock (only check when locked)
      if is_locked and thumb_tip_y > thumb_base_y and index_tip_y > index_pip_y:
        is_locked = False
        saved_value = None
        print("Thumbs down - unlocked")
      
      x1, y1 = lmList[4][1], lmList[4][2]
      x2, y2 = lmList[8][1], lmList[8][2]

      # Marking Thumb and Index finger
      cv2.circle(image, (x1,y1),15,(255,255,255))  
      cv2.circle(image, (x2,y2),15,(255,255,255))   
      cv2.line(image,(x1,y1),(x2,y2),(0,255,0),3)
      length = math.hypot(x2-x1,y2-y1)
      if length < 50:
        cv2.line(image,(x1,y1),(x2,y2),(0,0,255),3)

      # Calculate bar position and percentage based on finger distance (only if not locked)
      if not is_locked:
        volBar = np.interp(length, [50, 220], [400, 150])
        volPer = np.interp(length, [50, 220], [0, 100])
      else:
        volPer = saved_value
        volBar = np.interp(saved_value, [0, 100], [400, 150])

      # Volume Bar
      cv2.rectangle(image, (50, 150), (85, 400), (0, 0, 0), 3)
      cv2.rectangle(image, (50, int(volBar)), (85, 400), (0, 0, 0), cv2.FILLED)
      cv2.putText(image, f'{int(volPer)} %', (40, 450), cv2.FONT_HERSHEY_COMPLEX,
                1, (0, 0, 0), 3)
    
    # Display status
    if is_locked and saved_value is not None:
      cv2.putText(image, f'LOCKED: {saved_value} %', (10, 50), cv2.FONT_HERSHEY_SIMPLEX,
                1, (0, 255, 0), 2)
      cv2.putText(image, 'Thumbs DOWN to unlock', (10, 90), cv2.FONT_HERSHEY_SIMPLEX,
                0.7, (0, 255, 255), 2)
    else:
      cv2.putText(image, 'Pinky UP to save', (10, 50), cv2.FONT_HERSHEY_SIMPLEX,
                0.7, (255, 255, 0), 2)
    
    cv2.putText(image, 'Press Q to quit', (10, image.shape[0] - 20), 
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
    
    cv2.imshow('handDetector', image) 
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
      break

cam.release()
cv2.destroyAllWindows()

if saved_value is not None:
  print(f"\nFinal saved value: {saved_value}%")
