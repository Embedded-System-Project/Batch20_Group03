#include <SoftwareSerial.h>
#include <EEPROM.h>
#include "auth_handler.h"  // Include the external file
//#include "resetter.h" // Include the external file

#define BUTTON_PIN 12  // Push button connected to pin 12
#define BLUE_TOOTH_POWER_PIN 13

SoftwareSerial mySerial(10, 11); // RX, TX
const int EEPROM_ADDRESS = 0; // EEPROM memory location for UserId
bool systemRunning = false;  // Initial state: OFF

void setup() {
    Serial.begin(9600);
    pinMode(BUTTON_PIN, INPUT_PULLUP);  // Configure button as input with pull-up resistor
    mySerial.begin(9600);
    pinMode(BLUE_TOOTH_POWER_PIN, OUTPUT);  // Set pin 7 as output
    Serial.println("HC-06 Ready! Waiting for message...");
    
    // Read stored UserId from EEPROM on startup
    String storedUserId = readUserId();
    Serial.print("Stored UserId: ");
    Serial.println(storedUserId);
}

void loop() { 
    toggleSystemState();  // Check button press to toggle state

    if (systemRunning) {
        digitalWrite(BLUE_TOOTH_POWER_PIN, HIGH);
        Serial.println("System is ON: Running loop functions...");
        captureBluetoothData(); // Call function from external file

        if (Serial.available()) {
            String message = Serial.readString();  
            Serial.print("Sending to Bluetooth: ");
            Serial.println(message);
        }

        if (mySerial.available()) {
            String receivedMessage = mySerial.readString();
            Serial.print("Received from Bluetooth: ");
            Serial.println(receivedMessage);
        }
    }else
    {
        digitalWrite(BLUE_TOOTH_POWER_PIN, LOW);  // Set pin 13 to LOW (OFF)  
    }
}

// Function to detect button press and toggle system state
void toggleSystemState() {
    Serial.println("pressing button");
    static bool lastButtonState = HIGH;
    static unsigned long lastDebounceTime = 0;
    const unsigned long debounceDelay = 50;

    bool currentButtonState = digitalRead(BUTTON_PIN);
    
    if (currentButtonState == LOW && lastButtonState == HIGH) {  
        delay(debounceDelay);  // Debounce
        if (digitalRead(BUTTON_PIN) == LOW) {  
            systemRunning = !systemRunning; // Toggle system state
            Serial.print("System State: ");
            Serial.println(systemRunning ? "ON" : "OFF");
            
            while (digitalRead(BUTTON_PIN) == LOW);  // Wait for button release
        }
    }
    
    lastButtonState = currentButtonState;
}
