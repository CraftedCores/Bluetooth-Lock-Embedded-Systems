/*
  Chandler Johnson:
  
*/

#include "painlessMesh.h"
#include <Arduino_JSON.h>

// DHT11 
#include "DHT.h"
#define DHTPIN 22
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);

// MESH Details
#define   MESH_PREFIX     "RNTMESH" //name for your MESH
#define   MESH_PASSWORD   "MESHpassword" //password for your MESH
#define   MESH_PORT       5555 //default port

//Number for this node
int nodeNumber = 2;
int ledState = 0;

//String to send to other nodes with sensor readings
String readings;

Scheduler userScheduler; // to control your personal task
painlessMesh  mesh;

// User stub
void sendMessage(); // Prototype so PlatformIO doesn't complain
String getReadings(); // Prototype for sending sensor readings

//Create tasks: to send messages and get readings;
Task taskSendMessage(TASK_SECOND * 5 , TASK_FOREVER, &sendMessage);

String getReadings() {

  JSONVar jsonReadings;
  jsonReadings["node"] = nodeNumber;
  jsonReadings["TEMP"] = checkTemp();
  jsonReadings["HUMIDITY"] = checkHum();

  readings = JSON.stringify(jsonReadings);
  return readings;
}

void sendMessage () {
  String msg = getReadings();
  mesh.sendBroadcast(msg);
}


// Needed for painless library
void receivedCallback( uint32_t from, String &msg ) {
  Serial.printf("Received from %u msg=%s\n", from, msg.c_str());
  JSONVar myObject = JSON.parse(msg.c_str());
  int node = myObject["node"];
  String trigger = myObject["trigger"];

  if(ledState == 0){
    LedOn();
    ledState = 1;
  }
  else if(ledState == 1){
    LedOff();
    ledState = 0;
  }

  if(trigger == "ON"){
    relayOn();
  }
  else if(trigger == "OFF"){
    relayOff();
  }

}

// This function grabs temperature from DHT11 module.
float checkTemp(){
  float tempF = dht.readTemperature(true);
  return tempF;
}

// This function grabs Humidity data from DHT11 module.
float checkHum(){
  float humi = dht.readHumidity();
  return humi;
}

void LedOn() {
  digitalWrite(2, HIGH);
}

void LedOff() {
  digitalWrite(2, LOW);
}

void relayOn() {
  digitalWrite(23, HIGH);
}

void relayOff() {
  digitalWrite(23, LOW);
}

void newConnectionCallback(uint32_t nodeId) {
  Serial.printf("New Connection, nodeId = %u\n", nodeId);
}

void changedConnectionCallback() {
  Serial.printf("Changed connections\n");
}

void nodeTimeAdjustedCallback(int32_t offset) {
  Serial.printf("Adjusted time %u. Offset = %d\n", mesh.getNodeTime(),offset);
}

void setup() {
  Serial.begin(115200);

  // Start DHT module
  dht.begin();

  // on board LED
  pinMode(2, OUTPUT);
  
  // Relay Trigger pin
  pinMode(23, OUTPUT);


  //mesh.setDebugMsgTypes( ERROR | MESH_STATUS | CONNECTION | SYNC | COMMUNICATION | GENERAL | MSG_TYPES | REMOTE ); // all types on
  mesh.setDebugMsgTypes( ERROR | STARTUP );  // set before init() so that you can see startup messages

  mesh.init( MESH_PREFIX, MESH_PASSWORD, &userScheduler, MESH_PORT );
  mesh.onReceive(&receivedCallback);
  mesh.onNewConnection(&newConnectionCallback);
  mesh.onChangedConnections(&changedConnectionCallback);
  mesh.onNodeTimeAdjusted(&nodeTimeAdjustedCallback);

  userScheduler.addTask(taskSendMessage);
  taskSendMessage.enable();
}

void loop() {
  // it will run the user scheduler as well
  mesh.update();

}