void eqRotate (int loopCounter, AudioBuffer fftSource, color color1, color color2) {
  //
  
  
}

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

