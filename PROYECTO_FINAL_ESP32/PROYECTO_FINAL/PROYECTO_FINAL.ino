#include <BluetoothSerial.h>
#include <ArduinoJson.h>
#include <Adafruit_NeoPixel.h>
#include <Wire.h>
#include "RTClib.h"

BluetoothSerial SerialBT;
RTC_DS3231 rtc;

#define BOTON 14
#define MOTOR 4
#define LED_PIN 18
#define NUM_LEDS 12
#define SCL 22
#define SDA 21

Adafruit_NeoPixel ring(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

struct Alarma {
  String hora;
  String luz;
  String vibracion;
  bool activa;
  uint8_t r, g, b;
};

#define MAX_ALARMAS 10
Alarma alarmas[MAX_ALARMAS];
int totalAlarmas = 0;

unsigned long ultimoTitilar = 0;
bool estadoLED = false;
bool rtcConfigurado = false;

bool alarmaEnCurso = false;
unsigned long inicioAlarma = 0;
Alarma alarmaActual;

void setup() {
  Serial.begin(115200);
  SerialBT.begin("Sleep Deep");
  Serial.println("ESP32 listo para emparejarse por Bluetooth");

  Wire.begin(SDA, SCL);
  if (!rtc.begin()) {
    Serial.println("No se detecta el RTC DS3231");
    while (1)
      ;
  }

  pinMode(MOTOR, OUTPUT);
  pinMode(BOTON, INPUT_PULLUP);

  ring.begin();
  ring.show();
  digitalWrite(MOTOR, HIGH);

  Serial.println("Esperando alarmas...");
}

bool botonPresionado = false;
unsigned long ultimoCambioBoton = 0;
const unsigned long tiempoRebote = 300;  // ms

void loop() {
  unsigned long ahora = millis();

  // 🔹 Leer datos de Bluetooth
  if (SerialBT.available()) {
    String mensaje = SerialBT.readStringUntil('\n');
    StaticJsonDocument<1024> doc;
    DeserializationError error = deserializeJson(doc, mensaje);

    if (!error) {
      if (doc.containsKey("horaReloj") && !rtcConfigurado) {
        int h = doc["horaReloj"]["h"];
        int m = doc["horaReloj"]["m"];
        int s = doc["horaReloj"]["s"];
        DateTime now = DateTime(rtc.now().year(), rtc.now().month(), rtc.now().day(), h, m, s);
        rtc.adjust(now);
        rtcConfigurado = true;
        Serial.printf("RTC ajustado a %02d:%02d:%02d\n", h, m, s);
      }

      JsonArray arr = doc["alarmas"].as<JsonArray>();
      totalAlarmas = 0;

      for (JsonObject a : arr) {
        if (totalAlarmas < MAX_ALARMAS) {
          alarmas[totalAlarmas].hora = (const char*)a["hora"];
          alarmas[totalAlarmas].luz = (const char*)a["luz"];
          alarmas[totalAlarmas].vibracion = (const char*)a["vibracion"];
          alarmas[totalAlarmas].activa = a["activa"];
          alarmas[totalAlarmas].r = a["color"]["r"];
          alarmas[totalAlarmas].g = a["color"]["g"];
          alarmas[totalAlarmas].b = a["color"]["b"];
          totalAlarmas++;
        }
      }

      Serial.printf("Recibidas %d alarmas activas\n", totalAlarmas);
      mostrarAlarmasRestantes();
    } else {
      Serial.println("Error al parsear JSON");
    }
  }

  DateTime ahoraRTC = rtc.now();
  char horaActual[6];
  sprintf(horaActual, "%02d:%02d", ahoraRTC.hour(), ahoraRTC.minute());

  // 🔹 Iniciar alarma
  if (!alarmaEnCurso) {
    for (int i = 0; i < totalAlarmas; i++) {
      if (alarmas[i].activa && alarmas[i].hora == horaActual) {
        alarmaEnCurso = true;
        inicioAlarma = ahora;
        alarmaActual = alarmas[i];
        Serial.printf("⏰ Activando alarma de las %s\n", alarmaActual.hora.c_str());
        break;
      }
    }
  }

  int lecturaBoton = digitalRead(BOTON);
  if (lecturaBoton == LOW && (ahora - ultimoCambioBoton > tiempoRebote)) {
    botonPresionado = true;
    ultimoCambioBoton = ahora;
  }

  // 🔹 Ejecutar alarma
  if (alarmaEnCurso) {
    if (botonPresionado) {
      Serial.println("🖐️ Botón presionado: alarma detenida manualmente");
      finalizarAlarma();
      botonPresionado = false;
      return;
    }

    if (ahora - inicioAlarma < 30000) {
      // Luz
      if (alarmaActual.luz != "Desactivada") {
        if (alarmaActual.luz == "Titilar") Titilar(alarmaActual.r, alarmaActual.g, alarmaActual.b);
        else if (alarmaActual.luz == "Constante") Constante(alarmaActual.r, alarmaActual.g, alarmaActual.b);
      } else apagarLuz();

      // Vibración
      if (alarmaActual.vibracion != "Desactivada") {
        if (alarmaActual.vibracion == "Alta") V_Alta();
        else if (alarmaActual.vibracion == "Media") V_Media();
        else if (alarmaActual.vibracion == "Baja") V_Baja();
      } else {
        analogWrite(MOTOR, 255);
      }

    } else {
      Serial.println("⏹️ Alarma finalizada automáticamente");
      finalizarAlarma();
    }
  }
}

void finalizarAlarma() {
  alarmaEnCurso = false;
  apagarLuz();
  analogWrite(MOTOR, 255);

  for (int i = 0; i < totalAlarmas; i++) {
    if (alarmas[i].hora == alarmaActual.hora) {
      for (int j = i; j < totalAlarmas - 1; j++) {
        alarmas[j] = alarmas[j + 1];
      }
      totalAlarmas--;
      Serial.printf("🗑️ Alarma %s eliminada del ESP\n", alarmaActual.hora.c_str());
      mostrarAlarmasRestantes();
      break;
    }
  }
}


void mostrarAlarmasRestantes() {
  Serial.println("📋 Alarmas restantes en el ESP:");
  if (totalAlarmas == 0) {
    Serial.println("  (ninguna alarma cargada)");
    return;
  }

  for (int i = 0; i < totalAlarmas; i++) {
    Serial.printf("  %d) Hora: %s | Luz: %s | Vibración: %s | Color: (%d, %d, %d)\n",
                  i + 1,
                  alarmas[i].hora.c_str(),
                  alarmas[i].luz.c_str(),
                  alarmas[i].vibracion.c_str(),
                  alarmas[i].r,
                  alarmas[i].g,
                  alarmas[i].b);
  }
  Serial.println("-----------------------------");
}

// ------------------- FUNCIONES DE LUZ -------------------
void Constante(uint8_t r, uint8_t g, uint8_t b) {
  for (int i = 0; i < NUM_LEDS; i++) ring.setPixelColor(i, ring.Color(r, g, b));
  ring.show();
}

void Titilar(uint8_t r, uint8_t g, uint8_t b) {
  unsigned long ahora = millis();
  if (ahora - ultimoTitilar >= 500) {
    estadoLED = !estadoLED;
    for (int i = 0; i < NUM_LEDS; i++) {
      ring.setPixelColor(i, estadoLED ? ring.Color(r, g, b) : ring.Color(0, 0, 0));
    }
    ring.show();
    ultimoTitilar = ahora;
  }
}

void apagarLuz() {
  for (int i = 0; i < NUM_LEDS; i++) ring.setPixelColor(i, 0);
  ring.show();
}

// ------------------- FUNCIONES DE VIBRACIÓN -------------------
void V_Alta() {
  analogWrite(MOTOR, 100);
}
void V_Media() {
  analogWrite(MOTOR, 150);
}
void V_Baja() {
  analogWrite(MOTOR, 210);
}
