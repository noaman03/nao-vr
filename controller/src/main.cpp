#include <WiFi.h>
#include <WiFiUdp.h>
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include "secrets.h"

// --- NETWORK CONFIGURATION ---
const IPAddress PC_IP = UNITY_PC_IP;
const uint16_t UDP_PORT = 5006;

// --- PIN DEFINITIONS ---
const int JOYSTICK_X_PIN = 32; 
const int JOYSTICK_Y_PIN = 35; 
const int JOYSTICK_SW_PIN = 25;

// I2C Pins (default for most ESP32 boards)
const int SDA_PIN = 21;
const int SCL_PIN = 22;

// --- OBJECTS ---
WiFiUDP udp;
Adafruit_MPU6050 mpu;

// --- TIMING/DATA ---
unsigned long lastSend = 0;
const int DATA_RATE_MS = 10; // Send data every 10ms (100 Hz)

// --- IMU DATA ---
float pitch = 0.0;
float roll = 0.0;
float yaw = 0.0;

// Complementary filter variables
float dt = 0.01; // 10ms = 0.01s
float alpha = 0.96; // Complementary filter coefficient
unsigned long lastTime = 0;

//===================================================================
// SETUP FUNCTION
//===================================================================
void setup() {
    Serial.begin(115200); 
    Serial.println("Starting Joystick + IMU Controller...");
    
    // 1. Initialize Joystick Button Pin
    pinMode(JOYSTICK_SW_PIN, INPUT_PULLUP);

    // 2. Initialize I2C for MPU6050
    Wire.begin(SDA_PIN, SCL_PIN);
    
    // 3. Initialize MPU6050
    if (!mpu.begin()) {
        Serial.println("Failed to find MPU6050 chip!");
        while (1) {
            delay(10);
        }
    }
    Serial.println("MPU6050 Found!");

    // Configure MPU6050
    mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
    mpu.setGyroRange(MPU6050_RANGE_500_DEG);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
    
    delay(100);

    // 4. Connect to WiFi
    Serial.print("Connecting to WiFi: ");
    Serial.println(WIFI_SSID);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    
    Serial.println("\nWiFi Connected.");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
    
    lastTime = millis();
}

//===================================================================
// CALCULATE PITCH, ROLL, YAW
//===================================================================
void updateIMU() {
    sensors_event_t accel, gyro, temp;
    mpu.getEvent(&accel, &gyro, &temp);
    
    // Calculate time delta
    unsigned long currentTime = millis();
    dt = (currentTime - lastTime) / 1000.0; // Convert to seconds
    lastTime = currentTime;
    
    // Calculate pitch and roll from accelerometer (in degrees)
    float accelPitch = atan2(accel.acceleration.y, 
                            sqrt(accel.acceleration.x * accel.acceleration.x + 
                                 accel.acceleration.z * accel.acceleration.z)) * 180.0 / PI;
    float accelRoll = atan2(-accel.acceleration.x, accel.acceleration.z) * 180.0 / PI;
    
    // Integrate gyroscope data
    pitch += gyro.gyro.x * dt * 180.0 / PI;
    roll += gyro.gyro.y * dt * 180.0 / PI;
    yaw += gyro.gyro.z * dt * 180.0 / PI;
    
    // Apply complementary filter (combine gyro and accel)
    pitch = alpha * pitch + (1.0 - alpha) * accelPitch;
    roll = alpha * roll + (1.0 - alpha) * accelRoll;
    
    // Yaw uses only gyroscope (no magnetometer for absolute heading)
    // Note: Yaw will drift over time without magnetometer correction
}

//===================================================================
// LOOP FUNCTION
//===================================================================
void loop() {
    if (millis() - lastSend >= DATA_RATE_MS) {
        
        // --- 1. Update IMU Data ---
        updateIMU();
        
        // --- 2. Joystick Data Acquisition ---
        int stickX = analogRead(JOYSTICK_X_PIN); // 0-4095
        int stickY = analogRead(JOYSTICK_Y_PIN); // 0-4095
        int buttonState = digitalRead(JOYSTICK_SW_PIN); // 1 (unpressed) or 0 (pressed)

        // --- 3. Format and Send UDP Packet (6 values) ---
        // Format: Pitch, Roll, Yaw, StickX, StickY, Button (matches Unity script)
        char buffer[128];
        snprintf(buffer, sizeof(buffer), 
                 "%.2f,%.2f,%.2f,%d,%d,%d", 
                 pitch, roll, yaw, stickX, stickY, buttonState); 

        udp.beginPacket(PC_IP, UDP_PORT);
        udp.print(buffer);
        udp.endPacket();
        
        // --- Debug Print ---
        Serial.println(buffer);

        lastSend = millis();
    }
}
