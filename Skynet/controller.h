#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <Arduino.h>
#include <EEPROM.h>

// Define relay pins for 8 sockets (bulbs)
const int RELAY_PINS[8] = {2, 3, 4, 5, 6, 7, 8, 9};
const int EEPROM_ADDRESS = 0; // EEPROM memory location for UserId

// Function declarations
void initializeRelays();
void processBluetoothData(String receivedMessage);
void controlSocket(String socketId, bool status);
String extractJsonValue(String data, int startIndex);
String readUserId();

void initializeRelays() {
    for (int i = 0; i < 8; i++) {
        pinMode(RELAY_PINS[i], OUTPUT);
        digitalWrite(RELAY_PINS[i], LOW); // Ensure all sockets are OFF initially
    }
}

// Function to process Bluetooth data (extracts userId, socketId, and status)
void processBluetoothData(String receivedMessage) {
    Serial.print("Received: ");  
    Serial.println(receivedMessage);  

    // Extract UserId, SocketId, and Status
    int userIdIndex = receivedMessage.indexOf("\"userId\": \"");
    int socketIdIndex = receivedMessage.indexOf("\"socketId\": \"");
    int statusIndex = receivedMessage.indexOf("\"status\": ");

    if (userIdIndex != -1 && socketIdIndex != -1 && statusIndex != -1) {
        String extractedUserId = extractJsonValue(receivedMessage, userIdIndex + 11);
        String extractedSocketId = extractJsonValue(receivedMessage, socketIdIndex + 12);
        String statusStr = extractJsonValue(receivedMessage, statusIndex + 9);

        Serial.print("Extracted UserId: ");
        Serial.println(extractedUserId);
        Serial.print("Extracted SocketId: ");
        Serial.println(extractedSocketId);
        Serial.print("Extracted Status: ");
        Serial.println(statusStr);

        // Check if UserId matches stored UserId
        String storedUserId = readUserId();
        if (extractedUserId == storedUserId) {
            Serial.println("UserId Matched: Processing Socket Control...");

            // Convert status to boolean
            bool socketStatus = (statusStr == "true");

            // Control the corresponding socket
            controlSocket(extractedSocketId, socketStatus);
        } else {
            Serial.println("UserId does not match! Ignoring request.");
        }
    }
}

// Function to control the socket based on socketId and status
void controlSocket(String socketId, bool status) {
    int socketNumber = socketId.substring(6).toInt(); // Extract socket number (e.g., "socket1" -> 1)

    if (socketNumber >= 1 && socketNumber <= 8) {
        int relayPin = RELAY_PINS[socketNumber - 1]; // Get the corresponding relay pin

        if (status) {
            digitalWrite(relayPin, HIGH);
            Serial.print("Socket ");
            Serial.print(socketNumber);
            Serial.println(" ON");
        } else {
            digitalWrite(relayPin, LOW);
            Serial.print("Socket ");
            Serial.print(socketNumber);
            Serial.println(" OFF");
        }
    } else {
        Serial.println("Unknown socketId! No action taken.");
    }
}

// Function to extract a JSON value from the message
String extractJsonValue(String data, int startIndex) {
    int endIndex = data.indexOf("\"", startIndex);
    return data.substring(startIndex, endIndex);
}

// Function to read UserId from EEPROM
String readUserId() {
    String userId = "";
    char ch;
    for (int i = 0; i < 20; i++) { // Read up to 20 characters max
        ch = EEPROM.read(EEPROM_ADDRESS + i);
        if (ch == '\0') break; // Stop at null terminator
        userId += ch;
    }
    return userId;
}

#endif
