// DOME LIGHT SHOW
// Angry Monkey Software 2015
//
// Use OPC modified for circles and modified for WS2811 pixel color format

import ddf.minim.analysis.*;
import ddf.minim.*;
import java.util.Map;
import java.util.*;

/////////////////////////////////////////////////////
// Constants

int DISPLAY_WIDTH = 600;
int DISPLAY_HEIGHT = 600;

int FFT_BIN_COUNT = 36;
int FONT_SIZE = 16;
int LINE_HEIGHT = Math.round(FONT_SIZE*1.33);

int DOME_ROW_COUNT = 5;
float ROW_SCALE_1 = .15;
float ROW_SCALE_2 = .35;
float ROW_SCALE_3 = .55;
float ROW_SCALE_4 = .75;
float ROW_SCALE_5 = .95;
float[] ROW_SCALE_ARRAY = {ROW_SCALE_1, ROW_SCALE_2, ROW_SCALE_3, ROW_SCALE_4, ROW_SCALE_5};

float SLEEP_CYCLE_MODULO = (0.1 * 60 * 30); // minutes * 60 seconds * roughly 30 cycles per second
List SLEEP_STAGES_LIST = Arrays.asList(1,6,8,9,11,13);

/////////////////////////////////////////////////////
// Global Variables

FFT g_audioFFT;

/////////////////////////////////////////////////////
// Class Variables

Minim m_minim;

AudioPlayer m_soundFile;
AudioInput m_soundStream; //USB soundboard
AudioBuffer m_fftSource;

/////////////////////////////////////////////////////
// State Variables

int m_lightPattern = 0; //which pattern to use
int m_loopCounter = 0;
boolean m_sleeping = false;

int soundReference = 0;
String[] songList = new String[0];
int nowPlaying = 0; //song to use from songList[]

PFont mainFont;

float psd = 0;
float psd13 = 0;
float psd23 = 0;
float psd33 = 0;
float volume = 0;

boolean toggle = false;
boolean latch = false;

PImage mGradient;
PImage bluePink;
PImage lines;
PImage ring;
float[] ringScales = new float[15];

void setup() {
  size(DISPLAY_WIDTH, (DISPLAY_HEIGHT+100), P2D);
  frameRate(20);
  colorMode(HSB,100);
  
  songList = append(songList, "../music/Country_Roads.mp3");
  songList = append(songList, "../music/Mimiosa_Flourenscence.mp3");
  
  m_minim = new Minim(this);
  m_soundFile = m_minim.loadFile(songList[nowPlaying], 1024);
  m_soundStream = m_minim.getLineIn(Minim.STEREO, 1024);
  m_soundStream.enableMonitoring();
  m_soundStream.mute();
  
  // Setup the FFT
  g_audioFFT = new FFT(m_soundFile.bufferSize(), m_soundFile.sampleRate());
  g_audioFFT.linAverages(FFT_BIN_COUNT);
  
  mGradient = loadImage("../common/mardiGradient.png");
  bluePink = loadImage("../common/pbGradient.png");
  lines = loadImage("../common/brightStripes.png");
  ring = loadImage("../common/blurCircle.png");
  ring.mask(ring);
  for (int i = 0; i < ringScales.length; i++) {
    ringScales[i] = 0;
  }
  
  // Setup the Open Pixel Controller
  OPC opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledRing(0, 20, DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, (DISPLAY_WIDTH/2)*ROW_SCALE_5, .157);
  opc.ledRing(64, 20, DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, (DISPLAY_WIDTH/2)*ROW_SCALE_4, 0);
  opc.ledRing(128, 15, DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, (DISPLAY_WIDTH/2)*ROW_SCALE_3, 0);
  opc.ledRing(192, 10, DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, (DISPLAY_WIDTH/2)*ROW_SCALE_2, 0);
  opc.ledRing(256, 5, DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, (DISPLAY_WIDTH/2)*ROW_SCALE_1, 0);
  
  mainFont = createFont("Helvetica",16,true);   
}

void draw() {
  background(0); //reset to black  
  
  switch(soundReference) {
    case 0 :
      m_fftSource = m_soundStream.mix;
      break;
    case 1 :
      m_fftSource = m_soundFile.mix;
      break;
    default :
      m_fftSource = m_soundStream.mix;
      break;
  } 
  
  pushMatrix();
  
  m_loopCounter += 1;
  if (m_sleeping && m_loopCounter % SLEEP_CYCLE_MODULO == 0) {
    int stage_index = SLEEP_STAGES_LIST.indexOf(m_lightPattern) + 1;
    if (stage_index >= (SLEEP_STAGES_LIST.size())) {
      stage_index = 0;
    }
    
    int new_value = ((Integer)SLEEP_STAGES_LIST.get(stage_index)).intValue();
    println("index: " + stage_index + " new_value: " + new_value);
    m_lightPattern = new_value;
  }
  
  switch(m_lightPattern) {
    case 0 :
      domeEq(m_loopCounter, m_fftSource);
      break;
    case 1 :
      pinwheel(m_loopCounter, 60, 9);
      break;
    case 2 :
      bassStrobe(m_loopCounter, m_fftSource, color(80,100,100), color(20,100,100));
      break;
    case 3 :
      bassRings(m_loopCounter, m_fftSource, color(30,100,100), color(85,100,100));
      break;
    case 4 :
      //WALDO
      bassRings(m_loopCounter, m_fftSource, color(0,0,100), color(0,100,100));
      break;
    case 5 :
      domeBlink(m_loopCounter, m_fftSource);
      break;
    case 6 :
      domeFish(m_loopCounter);
      break;
    case 7 :
      slideImage(m_loopCounter, 4.8, lines);
      break;
    case 8 :
      spinImage(m_loopCounter, 1.8, mGradient);
      break;
    case 9 :
      spinImage(m_loopCounter, 1.8, bluePink);
      break;
    case 10 :
      rowTest(m_loopCounter);
      break;
    case 11 :
      domeBreathe(m_loopCounter, 2.0);
      break;
    case 12 :
      loudColor(m_loopCounter, m_fftSource);
      break;
    case 13 :
    default :
      colorTest(m_loopCounter, .2);
      break;
    case 14 :
      float[] foo = analyzeSound(m_fftSource);
      break;
  }
  
  popMatrix();
  
  displayContext(width, height);
  
}

void displayContext(int display_width, int display_height) {
  fill(4,100,100);
  textFont(mainFont);
  
  int yIndex = display_height-LINE_HEIGHT;
  
  if (m_sleeping){
    text("Sleeping .... (_) to wake up", 10, yIndex);
  } else {
    text(("Display Mode: " + m_lightPattern + " (a) advance (shift+a) previous"), 10, yIndex);
  }
  yIndex = yIndex-LINE_HEIGHT;
  
  if (!m_sleeping) {
    String sourceInfo = " (s) switch";
    if (soundReference == 1) {
      sourceInfo += " (p) ";
      if (m_soundFile.isPlaying()) {
        sourceInfo += "pause"; 
      } else {
        sourceInfo += "play";
      }
    }
    text(("Audio Source: " + soundReference + sourceInfo), 10, yIndex);
    yIndex = yIndex-LINE_HEIGHT;
  }  
}

void keyPressed () {
  int song = key - '0';
  
  switch(key) {
    case 's' :
      soundReference = (soundReference + 1) % 2;
      if (m_soundFile != null && m_soundFile.isPlaying()) {
        m_soundFile.pause();
      }
      break;
    case 'm' :
      if (m_soundStream.isMuted()) {
        m_soundStream.unmute();
        println("UNMUTE");
      } else {
        m_soundStream.mute();
        println("MUTE");
      }
      break;
    case 'p' :
      if (m_soundFile != null && m_soundFile.isPlaying()) {
        m_soundFile.pause();
      }
      else {
        m_soundFile.play();
        println("PLAY SONG:", songList[nowPlaying]);
      }
      break;
    case 'n' :
      nowPlaying = (nowPlaying + 1) % songList.length;
      directPlaySong(songList[nowPlaying], 2);
      break;
    case 'a' :
      if (!m_sleeping) {
        m_lightPattern = (m_lightPattern + 1) % 15;
        println("PATTERN:", m_lightPattern);
      }
      break;
    case 'A' :
      if (!m_sleeping) {
        m_lightPattern = (m_lightPattern + 14) % 15;
        println("PATTERN:", m_lightPattern);
      }
      break;
    case '_' :
      if (m_sleeping) {
        m_sleeping = false;
      } else {
        m_sleeping = true;
        m_lightPattern = ((Integer)SLEEP_STAGES_LIST.get(0)).intValue();
      }
      break;
  }
  
  if (song > 0 && song <= songList.length) {
    directPlaySong(songList[song-1],15);
  }
}

void directPlaySong(String songPath, int offset) {
  m_minim.stop();
  m_soundFile = m_minim.loadFile(songPath,1024);
  m_soundFile.play(offset * 1000);
  println("Playing:", songPath);
}

void bassRings(int loopCounter, AudioBuffer m_fftSource, color color1, color color2) {
  background(hue(color1), .6 * saturation(color1), 30);
  imageMode(CENTER);
  
  g_audioFFT.forward(m_fftSource);
  float bassThreshold = 20;
  float bassValue = max(g_audioFFT.getBand(5), g_audioFFT.getBand(0));
  
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
      image(ring, DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, ringScales[i] * DISPLAY_WIDTH, ringScales[i] * DISPLAY_HEIGHT);
      ringScales[i] *= 0.91;
    }
    else {
      ringScales[i] = 0;
    }
  }
}

void bassStrobe(int loopCounter, AudioBuffer m_fftSource, color color1, color color2) {
  ellipseMode(CENTER);
  
  g_audioFFT.forward(m_fftSource);
  float bassThreshold = 20;
  float bassValue = g_audioFFT.getBand(1);
  
  if (bassValue > bassThreshold) {
    //println(loopCounter, toggle);
    
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
    ellipse(DISPLAY_WIDTH/2, DISPLAY_HEIGHT/2, DISPLAY_WIDTH, DISPLAY_HEIGHT);
  }
  else {
    latch = false;
  }
}
