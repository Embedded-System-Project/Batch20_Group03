#define BUTTON_PIN 12  // Button connected to digital pin 12
#define LONG_PRESS_THRESHOLD 2000  // 2000ms = 2 second (adjust as needed)

void setup() {
    pinMode(BUTTON_PIN, INPUT_PULLUP);  // Enable internal pull-up resistor
    Serial.begin(9600);  // Start serial communication
}

void loop() {
    static bool buttonPressed = false;
    static unsigned long pressStartTime = 0;

    if (digitalRead(BUTTON_PIN) == LOW) {  // Button is pressed (LOW because of INPUT_PULLUP)
        if (!buttonPressed) {
            buttonPressed = true;  // Mark as pressed
            pressStartTime = millis();  // Record time when pressed
        }
    } else {  // Button is released
        if (buttonPressed) {  // If it was pressed before
            unsigned long pressDuration = millis() - pressStartTime;
            if (pressDuration >= 5000) {
                Serial.println("Long Press Detected!");
            } else {
                Serial.println("Short Press Detected!");
            }
            buttonPressed = false;  // Reset flag
        }
    }
}
