#include <SoftwareSerial.h>
#include <EEPROM.h>
#include "auth_handler.h"  // Include the external file

SoftwareSerial mySerial(10, 11); // RX, TX
const int EEPROM_ADDRESS = 0; // EEPROM memory location for UserId

void setup() {
    Serial.begin(9600);
    while (!Serial) {
        ; // Wait for serial port to connect. Needed for native USB port only
    }

    Serial.println("HC-06 Ready! Waiting for message...");
    mySerial.begin(9600);

    // Read stored UserId from EEPROM on startup
    String storedUserId = readUserId();
    Serial.print("Stored UserId: ");
    Serial.println(storedUserId);
}

void loop() { 
    captureBluetoothData(); // Call function from external file

     if (Serial.available()) {
        String message = Serial.readString();  // Read full message from Serial Monitor
        Serial.print("Sending to Bluetooth: ");
        Serial.println(message);
//        mySerial.print(message);  // Send actual text, not ASCII
    }

    // If data is received from Bluetooth, send it to Serial Monitor
    if (mySerial.available()) {
        String receivedMessage = mySerial.readString();
        Serial.print("Received from Bluetooth: ");
        Serial.println(receivedMessage);
    }
}
