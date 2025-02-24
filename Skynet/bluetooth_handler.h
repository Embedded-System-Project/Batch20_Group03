#ifndef BLUETOOTH_HANDLER_H
#define BLUETOOTH_HANDLER_H

#include <SoftwareSerial.h>
#include <EEPROM.h>

// External references from main file
extern SoftwareSerial mySerial;
extern const int EEPROM_ADDRESS;

// Function declarations (important for avoiding scope errors)
void saveUserId(String userId);
String readUserId();
void captureBluetoothData();

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
        int userIdIndex = receivedMessage.indexOf("\"userId\": \"");
        if (userIdIndex != -1) {
            int startIndex = userIdIndex + 11; // Start after "userId": "
            int endIndex = receivedMessage.indexOf("\"", startIndex); // Find closing "
            String extractedUserId = receivedMessage.substring(startIndex, endIndex);

            Serial.print("Extracted UserId: ");
            Serial.println(extractedUserId);

            // Check if UserId is "1jgre-1ref-tgwesfw-tfedw" and save it
            if (extractedUserId == "1jgre-1ref-tgwesfw-tfedw") {
                Serial.println("UserId Matched: Saving to EEPROM...");
                saveUserId(extractedUserId);  // No more scope issue!
            }
        }
    }
}

// Function to save UserId in EEPROM
void saveUserId(String userId) {
    for (int i = 0; i < userId.length(); i++) {
        EEPROM.write(EEPROM_ADDRESS + i, userId[i]); // Store each character
    }
    EEPROM.write(EEPROM_ADDRESS + userId.length(), '\0'); // Null-terminate string
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
