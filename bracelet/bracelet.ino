#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <ESP32Ping.h>
#include <WiFiClient.h>

const char* ssid = "ssid";
const char* password = "passwordku";
String serverName = "http://192.168.165.5:8080/read";
const int pwmChannel = 0;
const int resolution = 8;
const int freq = 5000;
const int amplifierPin = 17;
unsigned long lastTime = 0;
unsigned long timerDelay = 5000;

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while(WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  ledcSetup(pwmChannel, freq, resolution);
  ledcAttachPin(amplifierPin, pwmChannel);
  streamAudio();
}

void loop() {
  if((millis() - lastTime) > timerDelay) {
    if(WiFi.status() == WL_CONNECTED) {
      streamAudio();
      lastTime = millis();
    }
  }
}

void streamAudio() {
  HTTPClient http;
  WiFiClient client;
  String serverPath = serverName + "?filename=20_aku-pengen-beli-ketoprak-steve-jobs.wav";
  Serial.println("[HTTP] begin...");
  if(http.begin(client, serverPath)) {
    Serial.println("[HTTP] GET...");
    int httpResponseCode = http.GET();
    if(httpResponseCode > 0) {
      String payload = http.getString();
      Serial.println(httpResponseCode);
      Serial.println(payload);
      DynamicJsonDocument doc(1024);
      deserializeJson(doc, payload);
      String hexData = doc["hex"];

      int len = hexData.length() / 2;
      uint8_t* audioData = new uint8_t[len];
      for(int i=0; i<len; i++) {
        audioData[i] = strtoul(hexData.substring(i*2, i*2+2).c_str(), nullptr, 16);
      }
      for(int i=0; i<len; i++) {
        ledcWrite(pwmChannel, audioData[i]);
        delayMicroseconds(125);
      }
      delete[] audioData;
    } else {
      Serial.print("Error code: ");
      Serial.println(httpResponseCode);
      Serial.println("Error on HTTP request");
      Serial.println(http.errorToString(httpResponseCode));
      Serial.print("WiFi Status: ");
      Serial.println(WiFi.status() == WL_CONNECTED ? "Connected" : "Disconnected");
      String serverIP = "http://192.168.165.5:8080";
      if(Ping.ping(serverIP.c_str())) Serial.println("Ping to server IP successful");
      else Serial.println("Ping to server IP failed");
    }
  }
  http.end();
}

