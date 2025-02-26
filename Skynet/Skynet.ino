#include <SoftwareSerial.h>
#include <EEPROM.h>
#include "push_button.h"
#include "auth_handler.h"  // Include the external file

#define BUTTON_PIN 12  // Push button connected to pin 12
#define BLUE_TOOTH_POWER_PIN 13
#define DEBOUNCE_DELAY 50     // Debounce time in ms

SoftwareSerial mySerial(10, 11); // RX, TX
const int EEPROM_ADDRESS = 0; // EEPROM memory location for UserId
bool systemRunning = false;  // Initial state: OFF

void setup() {
    Serial.begin(9600);
    pinMode(BUTTON_PIN, INPUT_PULLUP);  // Configure button as input with pull-up resistor
    pinMode(BLUE_TOOTH_POWER_PIN, OUTPUT);  // Set pin 13 as output
    mySerial.begin(9600);
    
    Serial.println("HC-06 Ready! Waiting for message...");

    // Initialize the sockets

//    setupSockets();



    // Read stored UserId from EEPROM on startup
    String storedUserId = readUserId();
    Serial.print("Stored UserId: ");
    Serial.println(storedUserId);
}

void loop() { 
    
    toggleSystemState();  // Check button press to toggle state

    if (systemRunning) {
        digitalWrite(BLUE_TOOTH_POWER_PIN, HIGH);

//        Serial.println("System is ON: Running loop functions...");

        captureBluetoothData(); // Call function from external file

        if (Serial.available()) {
            String message = Serial.readString();  
            Serial.print("Sending to Bluetooth: ");
            Serial.println(message);
            mySerial.print(message); // Send actual text, not ASCII
        }

        if (mySerial.available()) {
            String receivedMessage = mySerial.readString();
            Serial.print("Received from Bluetooth: ");
            Serial.println(receivedMessage);
        }
    } else {
        digitalWrite(BLUE_TOOTH_POWER_PIN, LOW);  // Set pin 13 to LOW (OFF)  
    }
}

// Function to detect button press and toggle system state
void toggleSystemState() {
    static bool lastButtonState = HIGH;
    static unsigned long pressStartTime = 0;  // Time when the button press started
    static bool buttonHandled = false;  // To track whether the button press was handled

    bool currentButtonState = digitalRead(BUTTON_PIN);  // Read the button state

    if (currentButtonState == LOW && lastButtonState == HIGH) { // Button just pressed
        delay(DEBOUNCE_DELAY);  // Debounce
        if (digitalRead(BUTTON_PIN) == LOW) {  // Confirm button is still pressed
            pressStartTime = millis();  // Start the press time
            buttonHandled = false;  // Reset the buttonHandled flag
        }
    }

    if (currentButtonState == HIGH && lastButtonState == LOW) { // Button just released
        unsigned long pressDuration = millis() - pressStartTime;  // Calculate press duration
        
        if (!buttonHandled) {
            if (pressDuration < LONG_PRESS_TIME) {
                // Short press: Toggle system state
                systemRunning = !systemRunning;
                Serial.print("System State: ");
                Serial.println(systemRunning ? "ON" : "OFF");

                if(systemRunning == true){
                    setupSockets();  // Start the system
                } else {
                    for (int pin = 2; pin <= 9; pin++) {
                        digitalWrite(pin, LOW);  // Turn off pins
                    }
                }
            } else {
                // Long press: You can add any specific logic for long press here
                  for (int i = 0; i < EEPROM.length(); i++) {
                    EEPROM.write(i, 0xFF); // Writing 0xFF (default erased state)
                  }
                  delay(100);
                  setupSockets();
                  systemRunning=true;
                  
                  

            }

            buttonHandled = true;  // Mark the press as handled
        }
    }

    lastButtonState = currentButtonState;  // Save last state
}
