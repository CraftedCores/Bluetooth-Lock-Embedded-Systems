
String command;

// the setup function runs once when you press reset or power the board
void setup() {
  Serial.begin(9600);
    
  pinMode(23, OUTPUT);
  
  Serial.println("Type 'ON' or 'OFF' to control relay");
}

// the loop function runs over and over again forever
void loop() {
  if(Serial.available()){
    command = Serial.readStringUntil('\n');

    if(command.equals("ON")){
      led_on();
    }
    else if(command.equals("OFF")){
      led_off();
    }
    else{
      Serial.println("Invalid Command");
    }
    
  }                
}

void led_on(){
  Serial.println("Relay On");
  digitalWrite(23, HIGH);
}

void led_off(){
  Serial.println("Relay off");
  digitalWrite(23, LOW);
}