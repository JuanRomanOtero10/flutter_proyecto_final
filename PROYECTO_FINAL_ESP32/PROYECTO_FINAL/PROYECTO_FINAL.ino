#include <BluetoothSerial.h>
#include <ArduinoJson.h>

BluetoothSerial SerialBT;

#define LED 19
#define MOTOR 17
#define BOTON 18
unsigned long tiempoInicio = 0;
bool encendiendo = false;

// Para Titilar
unsigned long ultimoTitilar = 0;
bool estadoLED = false;

// Para V_Alta, V_Media y V_Baja
unsigned long ultimoVibrar = 0;
bool estadoMotor = false;
unsigned long intervaloVibracion = 0;



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
      bool activa = doc["activa"];


      // Actuá en base a los datos recibidos
      Serial.println("Alarma recibida:");
      Serial.println(hora);
      Serial.println(luz);
      Serial.println(vibracion);
      Serial.println("Activa: " + String(activa ? "Sí" : "No"));

      if (activa) {
        Serial.println("Alarma Activa");
        // LUZ
        if (luz == "Titilar") {
          Titilar();
        } else if (luz == "Constante") {
          Constante();
        } else {
          digitalWrite(LED, LOW);
        }

        // VIBRACIÓN
        if (vibracion == "Alta") {
          V_Alta();
        } else if (vibracion == "Media") {
          V_Media();
        } else if (vibracion == "Baja") {
          V_Baja();
        } else {
          digitalWrite(MOTOR, LOW);
        }

      } else {
        // Desactivar todo si la alarma está desactivada
        digitalWrite(LED, LOW);
        analogWrite(MOTOR, 0);  // Potencia máxima 
      }
    } else {
      Serial.println("Error de parseo JSON");
    }
  }

  delay(20);  
} 


void Titilar(void) {
  unsigned long ultimoCambio = 0;
  bool estado = false;

  unsigned long ahora = millis();
  if (ahora - ultimoCambio >= 500) {  // cambia cada 500 ms
    estado = !estado;
    digitalWrite(LED, estado ? HIGH : LOW);
    ultimoCambio = ahora;
  }
}

void Constante(void) {
  digitalWrite(LED, HIGH);  // LED siempre prendido
}

void V_Alta(void) {
  analogWrite(MOTOR, 255);  // Potencia máxima 
}

void V_Media(void) {
  analogWrite(MOTOR, 170);  // Potencia media (~66%)
}

void V_Baja(void) {
  analogWrite(MOTOR, 85);   // Potencia baja (~33%)
}
