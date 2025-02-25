#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <Arduino.h>

const int socketPins[8] = {2, 3, 4, 5, 6, 7, 8, 9};  // Define pin numbers for each socket

void setupSockets() {
    for (int i = 0; i < 8; i++) {
        pinMode(socketPins[i], OUTPUT);
        digitalWrite(socketPins[i], LOW);  // Ensure all sockets are OFF initially
    }
}

void controlSocket(int socket, int status) {
    if (socket >= 1 && socket <= 8) {  // Ensure valid socket range
        int pin = socketPins[socket - 1];  
        digitalWrite(pin, status);
        
        Serial.print("Socket ");
        Serial.print(socket);
        Serial.print(" turned ");
        Serial.println(status == 1 ? "ON" : "OFF");
    } else {
        Serial.println("Invalid socket number received!");
    }
}

#endif
