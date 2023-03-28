// Code generated by Arduino IoT Cloud, DO NOT EDIT.

#include <ArduinoIoTCloud.h>
#include <Arduino_ConnectionHandler.h>

const char DEVICE_LOGIN_NAME[]  = "02634488-3552-48da-b068-aefdd81c1013";

const char SSID[]               = SECRET_SSID;    // Network SSID (name)
const char PASS[]               = SECRET_OPTIONAL_PASS;    // Network password (use for WPA, or use as key for WEP)
const char DEVICE_KEY[]  = SECRET_DEVICE_KEY;    // Secret device password

void onBoardLEDChange();

float boardHumid;
float boardTemp;
bool boardLED;

void initProperties(){

  ArduinoCloud.setBoardId(DEVICE_LOGIN_NAME);
  ArduinoCloud.setSecretDeviceKey(DEVICE_KEY);
  ArduinoCloud.addProperty(boardHumid, READ, ON_CHANGE, NULL);
  ArduinoCloud.addProperty(boardTemp, READ, ON_CHANGE, NULL);
  ArduinoCloud.addProperty(boardLED, READWRITE, ON_CHANGE, onBoardLEDChange);

}

WiFiConnectionHandler ArduinoIoTPreferredConnection(SSID, PASS);