# Skynet Home Automation App

Skynet Home Automation is a **smart home scheduling system** built with **Flutter** and **Firebase**. It allows users to **schedule and automate** their smart devices based on predefined rules, making home automation seamless and efficient.

---

## 🚀 Features

### 🔐 User Authentication
- Users can **log in and manage** their home automation settings using Firebase Authentication.

### 📅 Scheduler Management
- Users can **create, edit, delete, and manage multiple schedulers**.
- Each scheduler includes:
  - **Name**
  - **Turn-on time**
  - **Turn-off time**
  - **Repetition type** (Daily, Custom days, etc.)
  - **Room assignment**
  - **Device assignment**
- Rooms and devices can be **added to the schedule** and controlled individually.

### 💡 Device Control
- Assign **smart devices** to schedulers.
- Devices automatically **turn on/off** at set times.
- Devices can also be **controlled individually**.

### 🔄 Real-time Status Updates
- Users can toggle the scheduler **ON/OFF** using a switch.
- Updates are instantly stored in **Firebase Firestore**.

### 📂 Data Storage
- **Firebase Firestore** for storing scheduler data.
- **Shared Preferences** for storing user session details locally.

---

## 🛠️ Tech Stack

- **Flutter (Dart)** – Frontend UI
- **Firebase Firestore** – Cloud database
- **Firebase Authentication** – User login
- **Shared Preferences** – Local storage
- **Arduino** – Hardware integration

---

## 🏗️ Hardware Components (Arduino Side)

In the Arduino side, the following components are used:
- **H-06 Bluetooth Module**
- **Arduino Uno**
- **LEDs**
- **Pushdown Switch**
- **Relays**
- **Mobile Device**

### 🔧 Circuit Diagram
The circuit diagram is located in the root of the repository:
```
Circuit diagram.png
```

![Circuit Diagram](Circuit%20diagram.png)

---



Enjoy automating your home with **Skynet Home Automation**! 🎉

