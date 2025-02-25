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

        // Extract "action" value
        int actionIndex = receivedMessage.indexOf("\"action\": ");
        if (actionIndex != -1) {
            int startIndex = actionIndex + 9; // Move past "action": 
            while (receivedMessage[startIndex] == ' ') startIndex++; // Skip spaces

            int endIndex = receivedMessage.indexOf(",", startIndex); // Find next comma
            if (endIndex == -1) endIndex = receivedMessage.indexOf("}", startIndex); // Fallback if last element

            String extractedAction = receivedMessage.substring(startIndex, endIndex);
            extractedAction.trim(); // Remove any leading/trailing spaces

            Serial.print("Extracted Action: ");
            Serial.println(extractedAction);

            heartBeatHandler(extractedAction);
        }
       }
    }

 int heartBeatHandler(String extractedAction)
 {
        if(extractedAction == "heartbeat")
        {
//              // Extract UserId from received message
//              int userIdIndex = receivedMessage.indexOf("\"userId\": \"");
//              if (userIdIndex != -1) 
//              {
//                  int startIndex = userIdIndex + 11; // Start after "userId": "
//                  int endIndex = receivedMessage.indexOf("\"", startIndex); // Find closing "
//                  String extractedUserId = receivedMessage.substring(startIndex, endIndex);
//                  extractedUserId.trim();
//                  
//                  Serial.print("Extracted UserId: ");
//                  Serial.println(extractedUserId);
//
//                  // Check if UserId is "1jgre-1ref-tgwesfw-tfedw" and save it
//                  if (extractedUserId == "1jgre-1ref-tgwesfw-tfedw") 
//                  {
//                    Serial.println("UserId Matched: Saving to EEPROM...");
//                    saveUserId(extractedUserId);  // No more scope issue!
//
//                    return 1;
//                    
//                  }
//              }

          return 1;
    }
    return 0;
}

//String JSONGenerator(String status)
//{
//  String json = "{";
//    json += "\"action\": \"heartbeat\",";
//    json += "\"status\": \"" + status + "\",";
//    json += "}";
//
//    return json;
//}
