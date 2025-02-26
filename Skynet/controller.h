#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <Arduino.h>
#include <EEPROM.h>
#include <ArduinoJson.h>

const int socketPins[8] = {2, 3, 4, 5, 6, 7, 8, 9};  // Pin numbers for each socket
int socketStates[8];  // Store socket states

void setupSockets() {
    for (int i = 0; i < 8; i++) {
        int storedState = EEPROM.read(i);
        if (storedState != 0 && storedState != 1) { // EEPROM may have junk data
            storedState = 0;
            EEPROM.write(i, 0);  // Initialize to 0
        }
        socketStates[i] = storedState;
        pinMode(socketPins[i], OUTPUT);
        digitalWrite(socketPins[i], socketStates[i]); // Restore state
    }
}

void controlSocket(int socket, int status) {
    if (socket >= 1 && socket <= 8) {  
        int index = socket - 1;
        int pin = socketPins[index];  
        digitalWrite(pin, status);
        socketStates[index] = status;

        // Update EEPROM with new state
        EEPROM.write(index, status);

        Serial.print("Socket ");
        Serial.print(socket);
        Serial.print(" turned ");
        Serial.println(status == 1 ? "ON" : "OFF");
        
        // Print updated states
        Serial.print("Updated States: ");
        for (int i = 0; i < 8; i++) {
            Serial.print(EEPROM.read(i));
            Serial.print(" ");
        }
        Serial.println();
    } else {
        Serial.println("Invalid socket number received!");
    }
}

// Function to process received JSON commands
void processCommand(String jsonString) {
    StaticJsonDocument<200> doc;  // Fix for deprecation warning
    DeserializationError error = deserializeJson(doc, jsonString);

    if (error) {
        Serial.println("JSON Parsing Failed!");
        return;
    }

    String action = doc["action"];
    int socket = doc["socket"];
    int status = doc["status"];

    if (action == "ctrl") {
        controlSocket(socket, status);
    } else {
        Serial.println("Unknown action received!");
    }
}

#endif
