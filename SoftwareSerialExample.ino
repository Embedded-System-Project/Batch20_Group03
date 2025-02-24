#include <SoftwareSerial.h>
#include <EEPROM.h>

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
    captureBluetoothData(); // Capture and process Bluetooth data

    if (mySerial.available()) {
        Serial.write(mySerial.read());
    }
    if (Serial.available()) {
        mySerial.write(Serial.read());
    }
}

// Function to capture and process Bluetooth data
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
            int startIndex = userIdIndex + 11; // Start after "UserId": "
            int endIndex = receivedMessage.indexOf("\"", startIndex); // Find closing "
            String extractedUserId = receivedMessage.substring(startIndex, endIndex);

            Serial.print("Extracted UserId: ");
            Serial.println(extractedUserId);

            // Check if UserId is "Akalanka123" and save it
            if (extractedUserId == "1jgre-1ref-tgwesfw-tfedw") {
                Serial.println("UserId Matched: Saving to EEPROM...");
                saveUserId(extractedUserId);
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
