#define BUTTON_PIN 12    // Define the button pin
#define LONG_PRESS_TIME 500  // Time threshold for long press (in ms)

unsigned long buttonPressTime = 0;
bool buttonPressed = false;

void handleButtonPress() {
    static bool buttonState = HIGH;
    static bool lastButtonState = HIGH;

    int reading = digitalRead(BUTTON_PIN);  // Read the button state

    if (reading == LOW && lastButtonState == HIGH) {  // Button just pressed
        buttonPressTime = millis();
        buttonPressed = true;
    }

    if (reading == HIGH && lastButtonState == LOW) {  // Button just released
        unsigned long pressDuration = millis() - buttonPressTime;
        buttonPressed = false;

        if (pressDuration < LONG_PRESS_TIME) {
            Serial.println("Short Press Detected");
        } else {
            Serial.println("Long Press Detected");
        }
    }

    lastButtonState = reading;  // Save the last state
}
