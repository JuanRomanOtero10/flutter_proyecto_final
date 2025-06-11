#include <BluetoothSerial.h>

BluetoothSerial SerialBT;

void setup() {
  Serial.begin(115200);
  SerialBT.begin("ESP32_Test"); // Nombre Bluetooth del ESP32
  Serial.println("El dispositivo está listo para emparejarse");
}

void loop() {
  if (SerialBT.available()) {
    String mensaje = SerialBT.readStringUntil('\n');  // Lee hasta salto de línea
    Serial.print("Mensaje recibido: ");
    Serial.println(mensaje);
  }
  delay(20);
}

