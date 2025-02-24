#include <SoftwareSerial.h>
#include <EEPROM.h>
#include "bluetooth_handler.h"  // Include the external file
#include "controller.h"

SoftwareSerial mySerial(10, 11); // RX, TX
const int EEPROM_ADDRESS = 0; // EEPROM memory location for UserId

void setup() {
    Serial.begin(9600);
    while (!Serial) {
        ; // Wait for serial port to connect. Needed for native USB port only
    }

    Serial.println("HC-06 Ready! Waiting for message...");
    mySerial.begin(9600);

    initializeRelays();  //new

    // Read stored UserId from EEPROM on startup
    String storedUserId = readUserId();
    Serial.print("Stored UserId: ");
    Serial.println(storedUserId);
}

void loop() { 
    captureBluetoothData(); // Call function from external file

     if (mySerial.available()) {                                                      //-------
        String receivedMessage = "";  

        while (mySerial.available()) {  
            char receivedChar = mySerial.read();  
            receivedMessage += receivedChar;  
            delay(5);  
        }

        processBluetoothData(receivedMessage); // Now processing is inside controller.h
    }                                                                                 //-------- new

    if (mySerial.available()) {
        Serial.write(mySerial.read());
    }
    if (Serial.available()) {
        mySerial.write(Serial.read());
    }
}
