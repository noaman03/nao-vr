import cv2
import mediapipe as mp
import os

try:
    from tracking_config import MOBILE_CAMERA_URL
except ImportError:
    MOBILE_CAMERA_URL = "http://YOUR_PHONE_IP:4747/video"

# Initialize MediaPipe Hands
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)
mp_draw = mp.solutions.drawing_utils

# Mobile camera URL (or 0 for webcam)
cap = cv2.VideoCapture(os.getenv("MOBILE_CAMERA_URL", MOBILE_CAMERA_URL))

# Finger tip indices in MediaPipe
FINGER_TIPS = [4, 8, 12, 16, 20]  # Thumb, Index, Middle, Ring, Pinky
FINGER_PIPS = [2, 6, 10, 14, 18]  # Lower joints

while True:
    ret, frame = cap.read()
    if not ret:
        break


    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    result = hands.process(frame_rgb)

    gesture = "No Hand"

    if result.multi_hand_landmarks:
        hand_landmarks = result.multi_hand_landmarks[0]
        mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)
        
        # Count how many fingers are extended
        fingers_up = 0
        for tip, pip in zip(FINGER_TIPS, FINGER_PIPS):
            if hand_landmarks.landmark[tip].y < hand_landmarks.landmark[pip].y:
                fingers_up += 1

        # Detect open or closed hand
        if fingers_up >= 4:  # 4 or 5 fingers up = open hand
            gesture = "Open Hand"
        elif fingers_up <= 1:  # 0 or 1 finger up = closed hand
            gesture = "Closed Hand"
        else:
            gesture = f"{fingers_up} Fingers"

    cv2.putText(frame, gesture, (10,50), cv2.FONT_HERSHEY_SIMPLEX,1,(0,255,0),2)
    cv2.imshow("Hand Gesture Detection", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
