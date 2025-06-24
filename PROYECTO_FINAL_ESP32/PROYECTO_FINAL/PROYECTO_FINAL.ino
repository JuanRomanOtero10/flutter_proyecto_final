#include <BluetoothSerial.h>

BluetoothSerial SerialBT;

#define LED 16

void setup() {
  Serial.begin(115200);
  SerialBT.begin("ESP32_Test");  // Nombre Bluetooth del ESP32
  Serial.println("El dispositivo está listo para emparejarse");
  
  pinMode(LED, OUTPUT);
  digitalWrite(LED, LOW);
}

void loop() {
  if (SerialBT.available()) {
    String mensaje = SerialBT.readStringUntil('\n');
    mensaje.trim();  // Limpia espacios o saltos de línea extra

    Serial.print("Mensaje recibido: ");
    Serial.println(mensaje);

    if (mensaje == "LED_ON") {
      digitalWrite(LED, HIGH);
      Serial.println("Led encendido");
      delay(3000);  // Mantener encendido por 3 segundos
      digitalWrite(LED, LOW);
      Serial.println("Led apagado");
    }
  }

  delay(20);  // Pequeño delay para evitar sobrecarga
}
