float[] analyzeSound (AudioBuffer audio) {
  float[] fftAmplitude = new float[FFT_BIN_COUNT];
  
  audioFFT.forward(audio);
  
  for (int i=0; i<FFT_BIN_COUNT; i++) {
    float amp = audioFFT.getBand(i);
    fftAmplitude[i] = amp;
    psd += amp*amp;
    
    if (i < FFT_BIN_COUNT / 3) {
      psd13 += amp*amp;
    } else if (i < (FFT_BIN_COUNT * (2 / 3))) {
      psd23 += amp*amp;
    } else {
      psd33 += amp*amp;
    }
  }
  
  psd = sqrt(psd);
  psd13 = sqrt(psd13);
  psd23 = sqrt(psd23);
  psd33 = sqrt(psd33);
 // println("PSD: ", psd, "13: ", psd13, ", 23: ", psd23, ", 33: ", psd33);
  
  float bassLimit = 60;
  
  if (psd13 > bassLimit) {
    if (!latch) {
      //bass hit - latch, increment, etc
      println("-----BASS EVENT-----");
      fill(50,100,100);
      ellipse(width/2, height/2,200,200);
      if (toggle) {
        //A
        toggle = !toggle;
      } else {
        //B
        toggle = !toggle;
      }
    }
    latch = true;
  }
  else {
    latch = false;
  }
  
  return fftAmplitude;
}
