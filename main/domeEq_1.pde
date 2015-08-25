void loudColor  (int loopCounter, AudioBuffer buffer) {
  float[] levels = analyzeSound(buffer);
  float filter = 0.3;
  
  volume = psd * filter + volume * (1 - filter); 
  
  float h = min(100, volume / 2.6);
  background(h, psd13/2, psd13/2.4);
}

void domeBlink (int loopCounter, AudioBuffer buffer) {
  background(color(50,80,30));
  int bassBin = 0;
  boolean isBass = (audioFFT.getBand(bassBin) > 25.0);
  if (isBass) {
    fill(color(50,90,100));
    rect(0, 0, width, height);
  }
}

void propellor(int loopCounter, AudioBuffer buffer) {
  //EQ driven wheel rotation
}

void domeEq(int loopCounter, AudioBuffer buffer) {
  //audioFFT.forward(soundStream.mix);
  audioFFT.forward(buffer);
  float psd = 0;
  
  float barWidth = 360.0 / fftBins;
  float offset = (loopCounter/500.0);
  
  for (int i=0; i<fftBins; i++) {
    psd += audioFFT.getBand(i);
    
    float center = (i+.5)*barWidth;
    float sHeight = .9 * audioFFT.getBand(i) / 15;
    float saturation = map(audioFFT.getBand(i),0,20,10,100);
    color sColor = color(((i+.5)*barWidth/3.6+loopCounter/80.0)%100.0, saturation, saturation);
    drawSlice(center, barWidth, width/2, sHeight, sColor);
  }
  //println(psd);
}

void pinwheel(int loopCounter, int slices, float speed) {
  //speed is 1/speed
  float sliceWidth = 360.0/slices;
  
  for (int i = 1; i <= slices; i++) {
    color sliceColor = color(((i-1)*(100.0/slices)+(loopCounter/speed)) % 100.0, 100, 100);
    drawSlice(sliceWidth*(i-.5), sliceWidth, width/2, .9, sliceColor);
  }
}


void drawSlice(float thetaCenter, float sliceWidth, float sliceRadius, float sliceHeight, color sliceColor) {
  //height is 0 to 1
  sliceHeight = min(sliceHeight, 1.0);
  noStroke();
  fill(sliceColor);
  float widthAngle = radians(sliceWidth) / 2;
  
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(thetaCenter));
  
  beginShape();
  float x = (1-sliceHeight) * width/2;
  float xSinT = sin(widthAngle);
  vertex(x, -x*xSinT);
  vertex(x, x*xSinT);
  
  vertex(sliceRadius, width/2 * xSinT);
  vertex(sliceRadius, -1 * width/2 * xSinT);
  endShape(CLOSE);
  
  popMatrix();
}

void spinImage(int loopCounter, float speed, PImage projectedImage) {
  imageMode(CENTER);
  float theta = radians((float(loopCounter) * speed) % 360);
  tint(color(0,0,100));
  pushMatrix();
  translate(width/2, height/2);
  rotate(theta);
  image(projectedImage, 0, 0);
  popMatrix();
}

void slideImage(int loopCounter, float speed, PImage projectedImage) {
  int imHeight = projectedImage.height;
  tint(color(0,0,100));
  pushMatrix();
  translate(width/2, height/2);
  image(projectedImage, 0, loopCounter * speed % imHeight);
  image(projectedImage, 0, (loopCounter * speed % imHeight) - imHeight);
  popMatrix();
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
  float speed = 5;
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
  image(ring, rowRadius, 0, 70, 210);
  popMatrix();
  
}

void colorTest(int loopCounter, float speed) {
  float h = (loopCounter * speed) % 100;
  background(h, 80, 80);
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
