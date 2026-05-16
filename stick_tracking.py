import cv2
import numpy as np
import os
import socket
import time

try:
    from tracking_config import (
        HAND_TRACKING_UDP_IP,
        HAND_TRACKING_UDP_PORT,
        MOBILE_CAMERA_URL,
    )
except ImportError:
    HAND_TRACKING_UDP_IP = "127.0.0.1"
    HAND_TRACKING_UDP_PORT = 5007
    MOBILE_CAMERA_URL = "http://YOUR_PHONE_IP:4747/video"

# --- Configuration ---
# UDP Configuration
UDP_IP = os.getenv("HAND_TRACKING_UDP_IP", HAND_TRACKING_UDP_IP)
UDP_PORT = int(os.getenv("HAND_TRACKING_UDP_PORT", HAND_TRACKING_UDP_PORT))

# Mobile camera URL. Use tracking_config.py or MOBILE_CAMERA_URL to set this.
URL = os.getenv("MOBILE_CAMERA_URL", MOBILE_CAMERA_URL)
DISPLAY_WIDTH = 1280
DISPLAY_HEIGHT = 720
MIN_BALL_RADIUS = 10  # Increased min radius to reduce noise detection
MAX_Z_NORMALIZATION_FACTOR = 150.0  # Factor to control Z normalization (Z = radius / factor)

# Define color range for tennis ball (HSV)
# Ball 1: Tennis ball (yellow-green)
# Adjusted range slightly for robustness
COLOR_RANGES = {
    1: {'name': 'Tennis (Yellow-Green)', 'color_bgr': (0, 255, 255), 'hsv_ranges': [
        (np.array([25, 100, 100]), np.array([75, 255, 255]))
    ]}
}

# --- Initialization ---
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    print(f"UDP socket created successfully. Sending to {UDP_IP}:{UDP_PORT}")
except socket.error as e:
    print(f"Error creating socket: {e}")
    exit()

cap = cv2.VideoCapture(URL)
if not cap.isOpened():
    print(f"Error: Could not open video stream from {URL}")
    # Try opening default camera as fallback
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Could not open default camera either.")
        exit()
    else:
        print("Using default camera (index 0)")

# Pre-calculate kernel for morphological operations
kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))

# --- Ball Detection Function ---
def track_ball(hsv_frame, hsv_ranges):
    """Generates the combined mask, finds the largest contour, and calculates ball properties."""
    combined_mask = None
    
    # Create and combine masks for all ranges of this color (e.g., Red)
    for lower, upper in hsv_ranges:
        mask = cv2.inRange(hsv_frame, lower, upper)
        if combined_mask is None:
            combined_mask = mask
        else:
            combined_mask = cv2.bitwise_or(combined_mask, mask)
            
    if combined_mask is None:
        return None, None  # Should not happen if COLOR_RANGES is structured correctly

    # Pre-processing for noise reduction and smoother shapes
    # 1. Opening (Erosion followed by Dilation) to remove small spots/noise
    mask_open = cv2.morphologyEx(combined_mask, cv2.MORPH_OPEN, kernel)
    # 2. Closing (Dilation followed by Erosion) to fill small holes
    mask_close = cv2.morphologyEx(mask_open, cv2.MORPH_CLOSE, kernel)
    
    # Find contours
    contours, _ = cv2.findContours(mask_close, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if contours:
        # Find the largest contour (most likely the ball)
        largest_contour = max(contours, key=cv2.contourArea)
        # Check if the area is large enough to be a ball
        if cv2.contourArea(largest_contour) > 100:
            ((x, y), radius) = cv2.minEnclosingCircle(largest_contour)
            
            # Simple check to ensure a meaningful detection
            if radius > MIN_BALL_RADIUS:
                return (x, y, radius), mask_close  # Return the mask for debugging/visual
    
    return None, None

# --- Main Loop ---
print(f"Starting hand tracking. Sending UDP position data to {UDP_IP}:{UDP_PORT}...")
print("Make sure Unity is listening on this port for camera position data.")
print("Press 'q' to quit.")

frame_count = 0
last_print_time = time.time()

while True:
    ret, frame = cap.read()
    if not ret:
        print("Error reading frame or end of stream.")
        # Attempt to restart stream if it's the mobile URL and not just the end of a file
        if URL:
            cap.release()
            cap = cv2.VideoCapture(URL)
            time.sleep(1)  # Wait before retrying
            continue
        break

    # Get frame dimensions for normalization
    frame_height, frame_width = frame.shape[:2]

    # Convert to HSV once
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    
    # Apply Gaussian blur for smoother color transitions and noise reduction
    hsv_blurred = cv2.GaussianBlur(hsv, (11, 11), 0)

    ball_data = {}  # Reset each frame
    display_y_offset = 30  # For text placement

    # Process all configured balls
    for ball_id, config in COLOR_RANGES.items():
        # Get ball position and the final mask
        ball_pos_radius, mask = track_ball(hsv_blurred, config['hsv_ranges'])

        if ball_pos_radius:
            x, y, radius = ball_pos_radius
            
            # 1. Normalize coordinates (0 to 1)
            norm_x = x / frame_width
            norm_y = y / frame_height
            # 2. Normalize Z (depth/size) based on radius (clamped at 1.0)
            norm_z = min(radius / MAX_Z_NORMALIZATION_FACTOR, 1.0)
            
            ball_data[ball_id] = (norm_x, norm_y, norm_z)
            
            # --- Visualization ---
            ball_name = config['name']
            ball_color = config['color_bgr']
            
            # Draw the circle and centroid
            cv2.circle(frame, (int(x), int(y)), int(radius), ball_color, 2)
            cv2.circle(frame, (int(x), int(y)), 5, ball_color, -1)
            
            # Display tracking data
            text_str = f"Ball {ball_id} ({ball_name}): X:{norm_x:.2f} Y:{norm_y:.2f} Z:{norm_z:.2f}"
            cv2.putText(frame, text_str, (10, display_y_offset),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, ball_color, 2)
            display_y_offset += 30  # Move down for the next ball

    # --- Send Data via UDP ---
    # Default values for undetected ball
    x1, y1, z1 = ball_data.get(1, (-1.0, -1.0, -1.0))
    
    # Format message string (X, Y, Z position)
    msg = f"{x1:.4f},{y1:.4f},{z1:.4f}"
    
    try:
        sock.sendto(msg.encode(), (UDP_IP, UDP_PORT))
        frame_count += 1
        
        # Print status every 2 seconds
        if time.time() - last_print_time > 2.0:
            detected_str = "DETECTED" if x1 >= 0 else "NOT DETECTED"
            print(f"Frames sent: {frame_count} | Ball status: {detected_str} | Last data: {msg}")
            last_print_time = time.time()
            
    except socket.error as e:
        print(f"Error sending UDP message: {e}")
        time.sleep(0.1)  # Avoid spamming errors

    # --- Display Frame ---
    try:
        # Add connection status
        status_color = (0, 255, 0) if x1 >= 0 else (0, 0, 255)  # Green if detected, red if not
        status_text = f"UDP: {UDP_IP}:{UDP_PORT} | Status: {'TRACKING' if x1 >= 0 else 'SEARCHING'}"
        cv2.putText(frame, status_text, (10, frame_height - 10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, status_color, 2)
        
        # Resize frame for larger display
        display_frame = cv2.resize(frame, (DISPLAY_WIDTH, DISPLAY_HEIGHT))
        cv2.imshow("Hand Tracking (Ball Detection)", display_frame)
    except cv2.error as e:
        print(f"Error displaying frame: {e}")

    # Exit on 'q' press
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# --- Cleanup ---
print("Stopping tracking and cleaning up...")
cap.release()
cv2.destroyAllWindows()
sock.close()
print(f"Total frames processed: {frame_count}")
