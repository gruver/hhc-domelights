void bassRotateImage (int loopCounter, AudioBuffer buffer, PImage projectedImage) {
  float[] levels = analyzeSound(m_fftSource);
  
  if (bassHit) {
    volume += 20;
    volume = volume % 360;
  }
  
  float theta = radians(volume); 
  
  pushMatrix();
  translate(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2);
  rotate(theta);
  tint(color(0,0,100));
  image(projectedImage, 0, 0);
  popMatrix();
}
