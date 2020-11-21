#include <Wire.h>

void setup() {
  Wire.begin();
  Wire.setClock(50000);
}

void loop() {
  Wire.beginTransmission(26);
  Wire.write(229);
  Wire.write(2);
  Wire.endTransmission();
  delay(500);
}
