// DOME LIGHT SHOW
// Angry Monkey Software 2015
//
// Use OPC modified for circles and modified for WS2811 pixel color format

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
OPC opc;

AudioPlayer soundFile;
AudioInput soundStream; //USB soundboard
AudioBuffer fftSource;

int soundReference = 0;
String[] songList = new String[0];
int nowPlaying = 0; //song to use from songList[]

FFT audioFFT;

/*
Row 0 is the top; number of lights, rotation angle
row0 = 1, 0rad
row1 = 5, 0rad
row2 = 10, 0rad
row3 = 15, 0rad
row4 = 20, 0rad
row5 = 20, 0.157rad
row6 = 20 - ground 
*/
int fftBins = 36;
float[] fftHist = new float[fftBins];

int lightPattern = 0; //which pattern to use
int domeRows = 5;

int loopCounter = 0;
float loopAngle = 0;

boolean toggle = false;
boolean latch = false;

PImage ring;
float[] ringScales = new float[15];

void setup() {
  size(800, 800, P2D);
  colorMode(HSB,100);
  
  songList = append(songList, "../music/Country_Roads.mp3");
  songList = append(songList, "../music/Mimiosa_Flourenscence.mp3");
  
  minim = new Minim(this);
  soundFile = minim.loadFile(songList[nowPlaying], 1024);
  soundStream = minim.getLineIn(Minim.STEREO, 1024);
  soundStream.enableMonitoring();
  soundStream.mute();
  
  
  audioFFT = new FFT(soundFile.bufferSize(), soundFile.sampleRate());
  audioFFT.linAverages(fftBins);
  
  ring = loadImage("../common/blurCircle.png");
  ring.mask(ring);
  for (int i = 0; i < ringScales.length; i++) {
    ringScales[i] = 0;
  }
  
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledRing(0, 20, width/2, height/2, 300, 0);
}

void draw() {
  background(0); //reset to black
  loopCounter++;
  
  switch(soundReference) {
    case 0 :
      fftSource = soundStream.mix;
      break;
    case 1 :
      fftSource = soundFile.mix;
      break;
    default :
      fftSource = soundStream.mix;
      break;
  }
  
  switch(lightPattern) {
    case 0 :
      domeEq(loopCounter, fftSource);
      break;
    case 1 :
      pinwheel(loopCounter, 60, 9);
      break;
    case 2 :
      bassStrobe(loopCounter, fftSource, color(80,100,100), color(20,100,100));
      break;
    case 3 :
      bassRings(loopCounter, fftSource, color(30,100,100), color(85,100,100));
      break;
    case 4 :
    default :
      domeBreathe(loopCounter, 2.0);
      break;
  }
}

void keyPressed () {
  int song = key - '0';
  
  switch(key) {
    case 'z' :
      soundReference = (soundReference + 1) % 2;
      println("SOUND SOURCE:", soundReference);
      break;
    case 'm' :
      if (soundStream.isMuted()) {
        soundStream.unmute();
        println("UNMUTE");
      } else {
        soundStream.mute();
        println("MUTE");
      }
      break;
    case 'p' :
      if (soundFile.isPlaying()) {
        soundFile.pause();
      }
      else {
        soundFile.play();
        println("PLAY SONG:", songList[nowPlaying]);
      }
      break;
    case 'n' :
      nowPlaying = (nowPlaying + 1) % songList.length;
      directPlaySong(songList[nowPlaying], 2);
      break;
    case 'a' :
      lightPattern = (lightPattern + 1) % 5;
      println("PATTERN:", lightPattern);
      break;
  }
  
  if (song > 0 && song <= songList.length) {
    directPlaySong(songList[song-1],15);
  }
}

void directPlaySong(String songPath, int offset) {
  minim.stop();
  soundFile = minim.loadFile(songPath,1024);
  soundFile.play(offset * 1000);
  println("Playing:", songPath);
}


void bassRings(int loopCounter, AudioBuffer fftSource, color color1, color color2) {
  imageMode(CENTER);
  //println(ringScales);
  
  audioFFT.forward(fftSource);
  float bassThreshold = 20;
  float bassValue = max(audioFFT.getBand(5), audioFFT.getBand(0));
  
  if (bassValue > bassThreshold) { //boom
    if (!latch) { //add a new ring, latch
      float[] temp = new float[ringScales.length];
      arrayCopy(ringScales, temp);
      
      for (int i = 1; i < ringScales.length; i++) {
        ringScales[i] = temp[i-1];
      }
      ringScales[0] = 2.1;
      latch = true;
      toggle = !toggle;
    }
  }
  else { //no bass, reset
    latch = false;
  }
  
  for (int i = 0; i < ringScales.length; i++) {
    if (ringScales[i] > 0.04) {
      if (toggle == ((i%2) == 0)) {
        tint(color1);
      }
      else {
        tint(color2);
      }
      image(ring, width/2, height/2, ringScales[i] * width, ringScales[i] * height);
      ringScales[i] *= 0.91;
    }
    else {
      ringScales[i] = 0;
    }
  }
}

void bassStrobe(int loopCounter, AudioBuffer fftSource, color color1, color color2) {
  ellipseMode(CENTER);
  
  audioFFT.forward(fftSource);
  float bassThreshold = 20;
  float bassValue = audioFFT.getBand(1);
  
  if (bassValue > bassThreshold) {
    println(loopCounter, toggle);
    
    if (!latch) {
      if (toggle) {
        fill(color1);
        toggle = !toggle;
      } else {
        fill(color2);
        toggle = !toggle;
      }
    }
    
    latch = true;
    ellipse(width/2, height/2, width, height);
  }
  else {
    latch = false;
  }
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
    drawSlice(center, barWidth, sHeight, sColor);
  }
  //println(psd);
}

void pinwheel(int loopCounter, int slices, float speed) {
  //speed is 1/speed
  float sliceWidth = 360.0/slices;
  
  for (int i = 1; i <= slices; i++) {
    color sliceColor = color(((i-1)*(100.0/slices)+(loopCounter/speed)) % 100.0, 100, 100);
    drawSlice(sliceWidth*(i-.5), sliceWidth, .9, sliceColor);
  }
}


void drawSlice(float thetaCenter, float sliceWidth, float sliceHeight, color sliceColor) {
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
  
  vertex(width/2, width/2 * xSinT);
  vertex(width/2, -1 * width/2 * xSinT);
  endShape(CLOSE);
  
  popMatrix();
}
