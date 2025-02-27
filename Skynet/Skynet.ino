#include <SoftwareSerial.h>
#include <EEPROM.h>
#include "push_button.h"
#include "auth_handler.h"  // Include the external file

#define BUTTON_PIN 12  // Push button connected to pin 12
#define BLUE_TOOTH_POWER_PIN 13
#define DEBOUNCE_DELAY 50     // Debounce time in ms
const int buzzerPin = A0; // Buzzer connected to A0
const int SystemOnPin = A1;
const int SystemOffPin = A2;

SoftwareSerial mySerial(10, 11); // RX, TX
const int EEPROM_ADDRESS = 0; // EEPROM memory location for UserId
bool systemRunning = false;  // Initial state: OFF

void setup() {
    pinMode(buzzerPin, OUTPUT);
    pinMode(SystemOnPin, OUTPUT);
    pinMode(SystemOffPin, OUTPUT);
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
                digitalWrite(buzzerPin, HIGH); // Turn buzzer ON
                delay(100); // Keep buzzer ON for 1 second
                digitalWrite(buzzerPin, LOW);  // Turn buzzer OFF

                if(systemRunning == true){
                    setupSockets();  // Start the system
                      digitalWrite(SystemOnPin, HIGH); 
                      
                
                } else {
                    for (int pin = 2; pin <= 9; pin++) {
                        digitalWrite(pin, HIGH);  // Turn off pins
                       
                      digitalWrite(SystemOnPin, LOW);
                      digitalWrite(SystemOffPin, HIGH);
                      
                    }
                }
            } else {
                      // Long press: You can add any specific logic for long press here
                resetEEPROM();
                delay(100);
                Serial.print("Long Pressing ");
                setupSockets();
                systemRunning = true;
                digitalWrite(buzzerPin, HIGH); // Turn buzzer ON
                delay(1000); // Keep buzzer ON for 1 second
                digitalWrite(buzzerPin, LOW);  // Turn buzzer OFF
  
                      

            }

            buttonHandled = true;  // Mark the press as handled
        }
    }

    lastButtonState = currentButtonState;  // Save last state
}



void resetEEPROM() {
    Serial.println("Resetting EEPROM...");

    for (int i = 0; i < 8; i++) {
        EEPROM.write(EEPROM_ADDRESS + i, 0);  // Set all 8 values to 0
    }
    
    Serial.println("EEPROM Reset Done. All values set to 0.");
}
