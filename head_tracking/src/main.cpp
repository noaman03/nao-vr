#include <Wire.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <MPU6050_tockn.h>
#include <MadgwickAHRS.h>
#include <USB.h>
#include <USBCDC.h>
#include "secrets.h"

// --- Configuration Constants ---
const IPAddress PC_IP = UNITY_PC_IP;
const uint16_t UDP_PORT = 5005;

// Timing Configuration - SLOWED DOWN for stability
const uint8_t UPDATE_INTERVAL_MS = 20;  // 20ms = 50Hz (was 8ms/125Hz)
const float SAMPLE_FREQUENCY = 1000.0f / UPDATE_INTERVAL_MS;
const uint32_t WIFI_TIMEOUT_MS = 10000;

// Dead zone threshold - ignore small changes
const float DEAD_ZONE = 0.5f;

// --- USB Serial ---
USBCDC SerialUSB;

// --- WiFi & UDP ---
WiFiUDP udp;

// --- MPU6050 + Madgwick ---
MPU6050 mpu(Wire);
Madgwick filter;
unsigned long lastSend = 0;

// Previous values for dead zone filtering
float lastPitch = 0;
float lastRoll = 0;
float lastYaw = 0;

// --- Helper Function to Check I2C Device Presence ---
bool I2C_Check(byte addr) {
  Wire.beginTransmission(addr);
  return Wire.endTransmission() == 0; 
}

void setup() {
    USB.begin();
    SerialUSB.begin(115200);
    delay(100); 
    
    SerialUSB.println("\n=== ESP32-S2 Head Tracking System ===");

    // --- I2C + MPU6050 Initialization ---
    Wire.begin(8, 7); 
    mpu.begin();
    
    SerialUSB.print("Initializing MPU6050...");
    const byte MPU_ADDR = 0x68;
    int attempts = 0;
    while(!I2C_Check(MPU_ADDR)){
        attempts++;
        SerialUSB.print(".");
        delay(500);
        if (attempts > 10) {
            SerialUSB.println("\nFailed to find MPU6050 after 10 attempts. Restarting...");
            ESP.restart();
        }
    }

    SerialUSB.println(" success!");
    SerialUSB.println("Calibrating gyro... DO NOT MOVE SENSOR!");
    
    mpu.calcGyroOffsets(true); 
    SerialUSB.println("Calibration complete.");

    // --- WiFi Connection ---
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    unsigned long wifiStart = millis();
    while (WiFi.status() != WL_CONNECTED) {
        if (millis() - wifiStart > WIFI_TIMEOUT_MS) {
            SerialUSB.println("\nWiFi timeout. Restarting...");
            ESP.restart();
        }
        delay(200);
        SerialUSB.print(".");
    }
    
    SerialUSB.println("\nWiFi Connected!");
    SerialUSB.print("IP: "); SerialUSB.println(WiFi.localIP());

    // --- Madgwick Filter Setup ---
    filter.begin(SAMPLE_FREQUENCY);
    SerialUSB.printf("Madgwick Filter running at %.2f Hz\n", SAMPLE_FREQUENCY);
    SerialUSB.println("\n--- START MOTION STREAMING ---\n");
}

void loop() {
    // Check WiFi connection and auto-reconnect
    if (WiFi.status() != WL_CONNECTED) {
        WiFi.disconnect();
        WiFi.reconnect();
        return;
    }

    unsigned long currentTime = millis();

    // Run at 50 Hz (every 20ms)
    if (currentTime - lastSend >= UPDATE_INTERVAL_MS) {
        lastSend = currentTime;

        // 1. Get new data from sensor
        mpu.update();
        
        // 2. Extract Data 
        float gx = mpu.getGyroX(); 
        float gy = mpu.getGyroY();
        float gz = mpu.getGyroZ();
        float ax = mpu.getAccX();
        float ay = mpu.getAccY();
        float az = mpu.getAccZ();

        // 3. Update Filter
        filter.updateIMU(gx, gy, gz, ax, ay, az);

        // 4. Get Orientation
        float pitch = filter.getPitch();
        float roll  = filter.getRoll();
        float yaw   = filter.getYaw();

        // 5. Apply dead zone filtering - only update if change is significant
        bool shouldSend = false;
        if (abs(pitch - lastPitch) > DEAD_ZONE) {
            lastPitch = pitch;
            shouldSend = true;
        }
        if (abs(roll - lastRoll) > DEAD_ZONE) {
            lastRoll = roll;
            shouldSend = true;
        }
        if (abs(yaw - lastYaw) > DEAD_ZONE) {
            lastYaw = yaw;
            shouldSend = true;
        }

        // Only send if there's meaningful change
        if (shouldSend) {
            // 6. Send as WHOLE NUMBERS with .0 format
            char buffer[64];
            snprintf(buffer, sizeof(buffer), "%.0f,%.0f,%.0f", 
                     round(lastPitch), round(lastRoll), round(lastYaw));

            udp.beginPacket(PC_IP, UDP_PORT);
            udp.print(buffer);
            udp.endPacket();

            SerialUSB.println(buffer); 
        }
    }
}
