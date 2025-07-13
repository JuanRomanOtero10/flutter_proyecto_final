#include <BluetoothSerial.h>
#include <ArduinoJson.h>

BluetoothSerial SerialBT;

#define LED 16
#define MOTOR 17
#define BOTON 18
unsigned long tiempoInicio = 0;
bool encendiendo = false;





void setup() {
  Serial.begin(115200);
  SerialBT.begin("Sleep Deep");  // Nombre del producto
  Serial.println("El dispositivo está listo para emparejarse");

  pinMode(LED, OUTPUT);
  pinMode(MOTOR, OUTPUT);
  pinMode(BOTON, INPUT);
  digitalWrite(LED, LOW);
}


void loop() {
  if (SerialBT.available()) {
    String mensaje = SerialBT.readStringUntil('\n');
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, mensaje);

    if (!error) {
      String hora = doc["hora"];
      String luz = doc["luz"];
      String vibracion = doc["vibracion"];

      // Actuá en base a los datos recibidos
      Serial.println("Alarma recibida:");
      Serial.println(hora);
      Serial.println(luz);
      Serial.println(vibracion);
    } else {
      Serial.println("Error de parseo JSON");
    }
  }

  delay(20);  // Pequeño delay para evitar sobrecarga
}


void Titilar(void) {
}

void Constante(void) {
  digitalWrite(LED, HIGH);
}

void V_Alta(void) {
}

void V_Baja(void) {
}

void V_Media(void) {
}
