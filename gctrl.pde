import processing.serial.*;

Serial port = null;
boolean streaming = false;
float speed = 0.001;
String[] gcode;
int i = 0;

void openSerialPort()
{
  if (port != null) port.stop();
  
  // select and modify the appropriate line for your operating system
  port = new Serial(this, Serial.list()[0], 9600); // Mac OS X
  //port = new Serial(this, "/dev/ttyUSB0", 9600); // Linux
  //port = new Serial(this, "COM6", 9600); // Windows  s

  port.bufferUntil('\n');
}

void setup()
{
  size(500, 250);
  println(Serial.list());
  openSerialPort();
}

void draw()
{
  background(0);  
  fill(255);
  int y = 12, dy = 12;
  text("current jog speed: " + speed + " inches per step", 0, y); y += dy;
  y += dy;
  text("INSTRUCTIONS", 0, y); y += dy;
  text("1: set speed to 0.001 inches (1 mil) per jog", 0, y); y += dy;
  text("2: set speed to 0.010 inches (10 mil) per jog", 0, y); y += dy;
  text("3: set speed to 0.100 inches (100 mil) per jog", 0, y); y += dy;
  text("arrow keys: jog in x-y plane", 0, y); y += dy;
  text("page up & page down: jog in z axis", 0, y); y += dy;
  text("h: go home", 0, y); y += dy;
  text("0: zero machine (set home to the current location)", 0, y); y += dy;
  text("g: stream a g-code file", 0, y); y += dy;
  text("x: stop streaming g-code (this is NOT immediate)", 0, y); y += dy;
}

void keyPressed()
{
  if (key == '1') speed = 0.001;
  if (key == '2') speed = 0.01;
  if (key == '3') speed = 0.1;
  
  if (!streaming) {
    if (keyCode == LEFT) port.write("G91\nG20\nG00 X-" + speed + " Y0.000 Z0.000\n");
    if (keyCode == RIGHT) port.write("G91\nG20\nG00 X" + speed + " Y0.000 Z0.000\n");
    if (keyCode == UP) port.write("G91\nG20\nG00 X0.000 Y" + speed + " Z0.000\n");
    if (keyCode == DOWN) port.write("G91\nG20\nG00 X0.000 Y-" + speed + " Z0.000\n");
    if (keyCode == KeyEvent.VK_PAGE_UP) port.write("G91\nG20\nG00 X0.000 Y0.000 Z" + speed + "\n");
    if (keyCode == KeyEvent.VK_PAGE_DOWN) port.write("G91\nG20\nG00 X0.000 Y0.000 Z-" + speed + "\n");
    if (key == 'h') port.write("G90\nG20\nG00 X0.000 Y0.000 Z0.000\n");
    if (key == '0') openSerialPort();
  }
  
  if (!streaming && key == 'g') {
    gcode = null; i = 0;
    String file = selectInput();
    if (file == null) return;
    gcode = loadStrings(file);
    if (gcode == null) return;
    streaming = true;
    stream();
  }
  
  if (key == 'x') streaming = false;
}

void stream()
{
  if (i == gcode.length) {
    streaming = false;
    return;
  }
  
  println(gcode[i]);
  port.write(gcode[i] + '\n');
  i++;
}

void serialEvent(Serial p)
{
  String s = p.readStringUntil('\n');
  println(s);
  
  if (streaming && s.trim().startsWith("ok")) {
    stream();
  }
}

