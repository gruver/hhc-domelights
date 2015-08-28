void waterfall (int loopCounter, AudioBuffer m_fftSource, color color1, color color2) {
  float[] levels = analyzeSound(m_fftSource);
  
  
  background(hue(color1), .6 * saturation(color1), 30);
  imageMode(CENTER);
  
  
  float bassThreshold = 35;
  //float bassValue = max(levels[1], levels[5]);
  float bassValue = levels[7];
  
  if (bassValue > bassThreshold) { //boom
    if (!latch) { //add a new ring, latch
      float[] temp = new float[ringScales.length];
      arrayCopy(ringScales, temp);
      
      for (int i = 1; i < ringScales.length; i++) {
        ringScales[i] = temp[i-1];
      }
      ringScales[0] = .05;
      latch = true;
      toggle = !toggle;
    }
  }
  else { //no bass, reset
    latch = false;
  }
  
  for (int i = ringScales.length-1; i >= 0 ; i--) {
    if (ringScales[i] < 3.0) {
      if (toggle == ((i%2) == 0)) {
        tint(color1);
      }
      else {
        tint(color2);
      }
      image(ring, DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, ringScales[i] * DISPLAY_WIDTH, ringScales[i] * DISPLAY_HEIGHT);
      ringScales[i] *= 1.35;
    }
    else {
      ringScales[i] = 0;
    }
  }
}

void strobePixels (int loopCounter, AudioBuffer buffer) {
  float[] levels = analyzeSound(buffer);
  float threshold = 20;
  float center;
  float offset = (float(loopCounter) / 2.3) % 360;
  float brightness;
  float sliceWidth = 360.0 / FFT_BIN_COUNT;
  
  for (int i = 0; i < levels.length; i++) {
    center = i * 360.0 / FFT_BIN_COUNT;
    brightness = max(20, 4 * levels[i]);
    
    drawSlice(center, sliceWidth, 300, 1, color(0,0,brightness));
  }
}
  
void simpleBass (int loopCounter, AudioBuffer buffer) {
  //fade in fade out on bass
  float[] levels = analyzeSound(buffer);
  float trigger = max( levels[4], levels[5] );
  float filter = .20;
  volume = filter * volume + (1 - filter) * 1.6 * trigger;
  
  fill(color(85,10,max(20, volume)));
  rect(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, DISPLAY_WIDTH, DISPLAY_HEIGHT);
}

void loudColor  (int loopCounter, AudioBuffer buffer) {
  float[] levels = analyzeSound(buffer);
  float filter = 0.3;
  
  volume = psd * filter + volume * (1 - filter); 
  
  float h = min(100, volume / 2.6);
  background(h, psd13/2, psd13/2.4);
}

void brightByLevel (int loopCounter, AudioBuffer buffer) {
  float lightColor = (float(loopCounter) / 11.0) % 100;
  float filter = .23;
  background(color(lightColor,80,30));
  float[] levels = analyzeSound(buffer);
  println("PSD: ",psd);
  volume = filter*volume + (1-filter)*(psd / 1.8);
  fill(color(lightColor, volume, volume));
  rect(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT);
}

void propellor(int loopCounter, AudioBuffer buffer) {
  //EQ driven wheel rotation
}

void domeEq(int loopCounter, AudioBuffer buffer) {
  g_audioFFT.forward(buffer);
  
  float psd = 0;
  float barWidth = 360.0 / FFT_BIN_COUNT;
  
  for (int i=0; i<FFT_BIN_COUNT; i++) {
    psd += g_audioFFT.getBand(i);
    
    float center = (i+.5)*barWidth;
    float sHeight = .9 * g_audioFFT.getBand(i) / 15;
    float saturation = map(g_audioFFT.getBand(i),0,20,10,100);
    color sColor = color(((i+.5)*barWidth/3.6+loopCounter/80.0)%100.0, saturation, saturation);
    //drawSlice(center, barWidth, DISPLAY_WIDTH/2, sHeight, sColor);
    drawSlice(center, barWidth, DISPLAY_WIDTH/2, 1, sColor);
  }
}

void pinwheel(int loopCounter, int slices, float speed) {
  //speed is 1/speed
  float sliceWidth = 360.0/slices;
  
  for (int i = 1; i <= slices; i++) {
    color sliceColor = color(((i-1)*(100.0/slices)+(loopCounter/speed)) % 100.0, 100, 100);
    drawSlice(sliceWidth*(i-.5), sliceWidth, DISPLAY_WIDTH/2, .9, sliceColor);
  }
}


void drawSlice(float thetaCenter, float sliceWidth, float sliceRadius, float sliceHeight, color sliceColor) {
  //height is 0 to 1
  //thetaCenter is degrees, sliceWidth is degrees
  
  sliceHeight = min(sliceHeight, 1.0);
  noStroke();
  fill(sliceColor);
  float widthAngle = radians(sliceWidth) / 2;
  
  pushMatrix();
  translate(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2);
  rotate(radians(thetaCenter));
  
  beginShape();
  float x = (1-sliceHeight) * DISPLAY_WIDTH/2;
  float xSinT = sin(widthAngle);
  vertex(x, -x*xSinT);
  vertex(x, x*xSinT);
  
  vertex(sliceRadius, DISPLAY_WIDTH/2 * xSinT);
  vertex(sliceRadius, -1 * DISPLAY_WIDTH/2 * xSinT);
  endShape(CLOSE);
  
  popMatrix();
}

void spinImage(int loopCounter, float speed, PImage projectedImage) {
  imageMode(CENTER);
  float theta = radians((float(loopCounter) * speed) % 360);
  tint(color(0,0,100));
  pushMatrix();
  translate(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2);
  rotate(theta);
  image(projectedImage, 0, 0);
  popMatrix();
}

void slideImage(int loopCounter, float speed, PImage projectedImage) {
  int imHeight = projectedImage.height;
  tint(color(0,0,100));
  pushMatrix();
  translate(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2);
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
  rect(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, DISPLAY_WIDTH, DISPLAY_HEIGHT);
}

void rowTest(int loopCounter) {
  //go through all 5 rows
  float speed = 5;
  int rowLaps = 3;
  float countsOnRow = rowLaps * 360 / speed;
  float row = (loopCounter / countsOnRow) % DOME_ROW_COUNT;
  testSingleRow(loopCounter, DISPLAY_WIDTH/2 * ROW_SCALE_ARRAY[int(row)], speed);
}

void testSingleRow(int loopCounter, float rowRadius, float speed) {
  //roate a blob around a ring of radis ringRadis to light up each note one by one
  float angle = (loopCounter * speed) % 360;
  tint(color(60,30,100));
  pushMatrix();
  translate(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2);
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
  float xc = DISPLAY_WIDTH/2 * sin(.8*angle);
  float yc = DISPLAY_WIDTH/6 * cos(1*angle);
  
  tint(12, 100, 100);
  pushMatrix();
  translate(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2);
  rotate(angle * .01);
  image(ring, xc, yc, DISPLAY_WIDTH * .35, DISPLAY_WIDTH * .35);
  popMatrix();
  
}
