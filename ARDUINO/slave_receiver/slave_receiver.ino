#include <Wire.h>

void setup() {
  Wire.begin(26);
 Wire.setClock(400000);
  Wire.onReceive(receiveEvent);
  Serial.begin(9600);
}

void loop() {
  delay(100);
}

void receiveEvent(int howMany) {
  while (0 < Wire.available()) {
    int x = Wire.read();
    Serial.print(x);
    Serial.print(" ");
  }
  Serial.println(" ");
}
