import socket

try:
    from tracking_config import CONTROLLER_LISTEN_IP, CONTROLLER_UDP_PORT
except ImportError:
    CONTROLLER_LISTEN_IP = "0.0.0.0"
    CONTROLLER_UDP_PORT = 5006

# --- Configuration (MUST MATCH ESP32) ---
# Use the same port your Unity script is using
UDP_IP = CONTROLLER_LISTEN_IP
UDP_PORT = CONTROLLER_UDP_PORT

def listen_for_udp():
    """
    Sets up a UDP socket to listen for data from the ESP32.
    """
    try:
        # Create a socket object, AF_INET for IPv4, SOCK_DGRAM for UDP
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        
        # Bind the socket to the IP and Port
        sock.bind((UDP_IP, UDP_PORT))
        
        print(f"[*] Listening for UDP packets on {UDP_IP}:{UDP_PORT}")
        print("Waiting for data... (Make sure ESP32 is powered on and connected to WiFi)")

        # Main receive loop
        while True:
            # Receive data and the sender's address
            data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
            
            # Decode the bytes to a string
            message = data.decode('utf-8').strip()
            
            # Print the received data
            print(f"[{addr[0]}:{addr[1]}] Data: {message}")

            # Example Data Format: P.RR,Y.YY,R.RR,X,Y,Button (e.g., -1.23,0.50,15.99,1819,1873,1)

    except Exception as e:
        print(f"[!] An error occurred: {e}")
    finally:
        # Close the socket when the script exits
        if 'sock' in locals():
            sock.close()
            print("[*] Socket closed.")

if __name__ == "__main__":
    listen_for_udp()
