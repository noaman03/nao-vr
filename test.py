import socket

try:
    from tracking_config import HEAD_TRACKING_LISTEN_IP, HEAD_TRACKING_UDP_PORT
except ImportError:
    HEAD_TRACKING_LISTEN_IP = "0.0.0.0"
    HEAD_TRACKING_UDP_PORT = 5005

# --- Configuration (Must match the ESP32 code) ---
# NOTE: The PC should listen on its own IP, or on all interfaces.
# We use '0.0.0.0' to listen on all available interfaces.
LISTEN_IP = HEAD_TRACKING_LISTEN_IP
LISTEN_PORT = HEAD_TRACKING_UDP_PORT
BUFFER_SIZE = 1024 # Standard buffer size

# Create a UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((LISTEN_IP, LISTEN_PORT))

print("--- UDP Head Tracking Listener ---")
print(f"Listening on port {LISTEN_PORT} for data from ESP32...")

try:
    while True:
        # Receive data packet
        data, addr = sock.recvfrom(BUFFER_SIZE) 
        
        # Decode the byte data into a string
        message = data.decode('utf-8').strip()
        
        try:
            # Parse the comma-separated values (Pitch, Roll, Yaw)
            pitch, roll, yaw = map(float, message.split(','))
            
            # Print the formatted output
            print(f"P: {pitch:7.2f} | R: {roll:7.2f} | Y: {yaw:7.2f} | Source: {addr[0]}")
            
        except ValueError:
            print(f"Error parsing data: {message}")
            
except KeyboardInterrupt:
    print("\nListener stopped.")
    
finally:
    sock.close()
