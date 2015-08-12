void blueRedTunnel (int loopCounter, AudioBuffer fftSource) {
  color blue = color(70,100,100);
  color red = color(2,100,100);
  
  
}

void domeBreathe (int loopCounter, float speed) {
  //set hue, saturation, ramp brightness
  float pulseSpeed = speed/100.0;
  
  float h = (loopCounter / 100.0) % 100;
  float s = 100;
  float b = 10 + 90 * (sin(float(loopCounter) * pulseSpeed) + 1);
  fill(h, b, b);
  rectMode(CENTER);
  rect(width/2, height/2, width, height);
}

void rowTest(int loopCounter) {
  //go through all 5 rows
  float speed = 10;
  int rowLaps = 3;
  float countsOnRow = rowLaps * 360 / speed;
  float row = (loopCounter / countsOnRow) % domeRows;
  testSingleRow(loopCounter, width/2 * rowScales[int(row)], speed);
}

void testSingleRow(int loopCounter, float rowRadius, float speed) {
  //roate a blob around a ring of radis ringRadis to light up each note one by one
  float angle = (loopCounter * speed) % 360;
  tint(color(60,30,100));
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(angle));
  image(ring, rowRadius, 0, 70, 70);
  popMatrix();
  
}

void domeFish(int loopCounter) {
  //orange dot swims around a blue dome
  //no EQ reactions
  background(55, 100, 70);
  float angle = radians(float(loopCounter % 36000));
  float xc = width/2 * sin(.8*angle);
  float yc = width/6 * cos(1*angle);
  
  tint(12, 100, 100);
  pushMatrix();
  translate(width/2, height/2);
  rotate(angle * .01);
  image(ring, xc, yc, width * .35, width * .35);
  popMatrix();
  
}
