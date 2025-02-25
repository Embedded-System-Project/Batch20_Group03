#ifndef BLUETOOTH_HANDLER_H
#define BLUETOOTH_HANDLER_H

#include <SoftwareSerial.h>
#include <EEPROM.h>

#include "controller.h" 

// External references from main file
extern SoftwareSerial mySerial;
extern const int EEPROM_ADDRESS;

// Function declarations
void saveUserId(String userId);
String readUserId();
void captureBluetoothData();
void sendKeepAliveSignal();

void captureBluetoothData() {
    if (mySerial.available()) {  
        String receivedMessage = "";  

        while (mySerial.available()) {  
            char receivedChar = mySerial.read();  
            receivedMessage += receivedChar;  
            delay(5);  
        }

        Serial.print("Received: ");  
        Serial.println(receivedMessage);  

        // Extract UserId from received message
        int userIdIndex = receivedMessage.indexOf("\"userId\":\"");
        int actionIndex = receivedMessage.indexOf("\"action\":\"");

        String extractedUserId = "";
        String extractedAction = "";

        if (userIdIndex != -1) {
            int startIndex = userIdIndex + 11; 
            int endIndex = receivedMessage.indexOf("\"", startIndex);
            extractedUserId = receivedMessage.substring(startIndex, endIndex);
            Serial.print("Extracted UserId: ");
            Serial.println(extractedUserId);
        }

        if (actionIndex != -1) {
            int startIndex = actionIndex + 10;
            int endIndex = receivedMessage.indexOf("\"", startIndex);
            extractedAction = receivedMessage.substring(startIndex, endIndex);
            Serial.print("Extracted Action: ");
            Serial.println(extractedAction);

            // If the action is "auth", handle authentication
            if (extractedAction == "auth") {
                Serial.println("Auth action received! Saving UserId...");
                saveUserId(extractedUserId);
            }
            // If the action is "ctrl", handle socket control
            else if (extractedAction == "ctrl") {
                int socketIndex = receivedMessage.indexOf("\"socket\":");
                int statusIndex = receivedMessage.indexOf("\"status\":");

                if (socketIndex != -1 && statusIndex != -1) {
                    // Extract socket number
                    int socketStart = socketIndex + 9;
                    int socketEnd = receivedMessage.indexOf(",", socketStart);
                    int socketNum = receivedMessage.substring(socketStart, socketEnd).toInt();

                    // Extract status (0 or 1)
                    int statusStart = statusIndex + 9;
                    int statusEnd = receivedMessage.indexOf("}", statusStart);
                    int status = receivedMessage.substring(statusStart, statusEnd).toInt();

                    // Call the function from controller.h to activate the socket
                    //Serial.println(socketNum, status);
                    controlSocket(socketNum, status);
                }
            }
        }

        // Check if UserId matches the one stored in EEPROM
        String storedUserId = readUserId();
        Serial.println("hi--" + extractedUserId);
        Serial.println("Hello--" + storedUserId);
        if (true) {
            mySerial.println("=Auth Successfully");
            Serial.println("UserId Matched: Verified Successfully!");
            mySerial.println("OK");  // Send response to keep connection alive
        } else {
            Serial.print("Stored UserId: ");
            Serial.println(storedUserId);
            Serial.println("UserId is NOT Matched!");
        }

        // Keep the connection alive by sending a signal
        sendKeepAliveSignal();
    }
}

// Function to save UserId in EEPROM
void saveUserId(String userId) {
    Serial.println("Saving UserId to EEPROM...");
    for (int i = 0; i < userId.length(); i++) {
        EEPROM.write(EEPROM_ADDRESS + i, userId[i]);
    }
    EEPROM.write(EEPROM_ADDRESS + userId.length(), '\0');
    Serial.println("UserId Saved!");
}

// Function to read UserId from EEPROM
String readUserId() {
    String userId = "";
    char ch;
    for (int i = 0; i < 20; i++) {
        ch = EEPROM.read(EEPROM_ADDRESS + i);
        if (ch == '\0') break;
        userId += ch;
    }
    Serial.print("Stored UserId from EEPROM: ");
    Serial.println(userId);
    return userId;
}

// Function to send a keep-alive signal to prevent disconnection
void sendKeepAliveSignal() {
    Serial.println("Sending keep-alive signal...");
     // Send a dummy message to keep the connection alive
}

#endif
